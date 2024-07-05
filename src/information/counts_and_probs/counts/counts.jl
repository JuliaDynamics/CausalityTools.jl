using StatsBase: levelsmap
using ComplexityMeasures
using ComplexityMeasures: Counts

import ComplexityMeasures: counts
import ComplexityMeasures: codify
export counts

# ##########################################################################################
# Counts API.
# The following code extends the functionality of ComplexityMeasures.jl for multiple
# input data (ComplexityMeasures.jl only deals with single-variable estimation)
# ##########################################################################################
"""
    counts([o::OutcomeSpace], x₁, x₂, ..., xₙ) → Counts{N}

Construct an `N`-dimensional contingency table from the input iterables
`x₁, x₂, ..., xₙ` which are such that 
`length(x₁) == length(x₂) == ⋯ == length(xₙ)`.

## Discretization

If `x₁, x₂, ..., xₙ` are not already discretized, then the data must first
be discretized by providing either a [`CodifyPoints`](@ref), or a 
[`CodifyVariables`](@ref) as the first argument.

If `x₁, x₂, ..., xₙ` are already discretized, then [`UniqueElements`](@ref)
should be used as the first argument.

# Concrete implementations

- `counts(o::UniqueElements, x₁, x₂, ..., xₙ)`.
- `counts(encoding::CodifyPoints, x₁, x₂, ..., xₙ)`.
- `counts(encoding::CodifyVariables, x₁, x₂, ..., xₙ)`.

See also: [`CodifyPoints`](@ref), [`CodifyVariables`](@ref), [`UniqueElements`](@ref).
"""
function counts(o::UniqueElements, x::Vararg{VectorOrStateSpaceSet, N}) where N # this extends ComplexityMeasures.jl definition
    # Get marginal probabilities and outcomes
    L = length(x)
    cts, lmaps, encoded_outcomes = counts_table(x...)
    # lmaps[i]: a `Dict{outcome_type, Int}` containing the conversion between the
    #   internally encoded outcomes for the `i`-th input, and the actual outcomes
    #   for the `i`-th input.
    actual_outcomes = map(i -> to_outcomes(lmaps[i], encoded_outcomes[i]), tuple(1:L...))
    return Counts(cts, actual_outcomes)
end

function counts(x::Vararg{VectorOrStateSpaceSet, N}) where N
    if N == 1
        return ComplexityMeasures.counts(UniqueElements(), x)
    else
        return counts(UniqueElements(), x...)
    end
end

function to_outcomes(lmap::Dict, encoded_outcomes::Vector{<:Integer})
    # We want the encoded integers as keys and the actual outcomes as values.
    lmap_swapped = Dict(values(lmap) .=> keys(lmap))
    return [lmap_swapped[ωᵢ] for ωᵢ in encoded_outcomes]
end

function counts_table(x...)
    Ls = length.(x);
    if !allequal(Ls)
        throw(ArgumentError("Input data must have equal lengths. Got lengths $Ls."))
    end
    L = first(Ls)

    # Map the input data to integers. This ensures compatibility with *any* input type.
    # Then, we can simply create a joint `StateSpaceSet{length(x), Int}` and use its elements
    # as `CartesianIndex`es to update counts.
    lvl = tolevels.(x)
    levels = (first(l) for l in lvl) # TODO: construct SVector directly.
    lmaps = [last(l) for l in lvl]

    # Create the table with correct dimensions, assumming the outcome space is
    # fully determined by the elements that are present in `x`.
    table_dims = length.(unique_elements.(x));
    cts = zeros(Int, table_dims)

    # Each element in `X` isa `SVector{m, Int}`, so can be treated as a cartesian index.
    X = StateSpaceSet(levels...)

    # We sort, so that the positions in `cts` will correspond to the indices on
    # each of the axes of `cts`. Note: these are not the *actual* outcomes, but the
    # internal integer representation of each outcome. We need to use `lmaps` to convert
    # back in the higher-level function.
    for ix in X
        cts[ix...] += 1
    end

    # One set of outcomes per input
    outcomes = sort!.(unique!.(columns(X)))
    return cts, lmaps, outcomes
end

function to_cartesian(x)
    (CartesianIndex.(xᵢ...) for xᵢ in x)
end

"""
    tolevels!(levels, x) → levels, dict
    tolevels(x) → levels, dict

Apply the bijective map ``f : \\mathcal{Q} \\to \\mathbb{N}^+`` to each `x[i]` and store
the result in `levels[i]`, where `levels` is a pre-allocated integer vector such that
`length(x) == length(levels)`.

``\\mathcal{Q}`` can be any space, and each ``q \\in \\mathcal{Q}`` is mapped to a unique
integer  in the range `1, 2, …, length(unique(x))`. This is useful for integer-encoding
categorical data such as strings, or other complex discrete data structures.

The single-argument method allocated a `levels` vector internally.

`dict` gives the inverse mapping.
"""
function tolevels!(levels, x)
    @assert length(levels) == length(x)
    lmap = _levelsmap(x)
    for i in eachindex(x)
        levels[i] = lmap[x[i]]
    end
    return levels, lmap
end

function tolevels(x)
    lmap = _levelsmap(x)
    levels = zeros(Int, length(x))
    for i in eachindex(x)
        levels[i] = lmap[x[i]]
    end
    return levels, lmap
end

# Ugly hack, because levelsmap doesn't work out-of-the-box for statespacesets.
_levelsmap(x) = levelsmap(x)
_levelsmap(x::AbstractStateSpaceSet) = levelsmap(x.data)

# So that we can mix discrete-valued state space sets with discrete-valued regular
# vectors.
unique_elements(x) = unique(x)
unique_elements(x::AbstractStateSpaceSet) = unique(x.data)

# TODO: preserve axis labels
function marginal(p::Counts; dims = 1:ndims(p))
    alldims = 1:ndims(p)
    reduce_dims = (setdiff(alldims, dims)...,)
    marginal = dropdims(sum(p.p, dims = reduce_dims), dims = reduce_dims)
    return Counts(marginal)
end