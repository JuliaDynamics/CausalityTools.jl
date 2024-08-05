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
    counts(o::UniqueElements, x₁, x₂, ..., xₙ) → Counts{N}
    counts(encoding::CodifyPoints, x₁, x₂, ..., xₙ) → Counts{N}
    counts(encoding::CodifyVariables, x₁, x₂, ..., xₙ) → Counts{N}

Construct an `N`-dimensional contingency table from the input iterables
`x₁, x₂, ..., xₙ` which are such that 
`length(x₁) == length(x₂) == ⋯ == length(xₙ)`.

If `x₁, x₂, ..., xₙ` are already discrete, then use [`UniqueElements`](@ref) as 
the first argument to directly construct the joint contingency table.

If `x₁, x₂, ..., xₙ` need to be discretized, provide as the first argument
- [`CodifyPoints`](@ref) (encodes every *point* in each of the input variables `xᵢ`s individually)
- [`CodifyVariables`](@ref) (encodes every `xᵢ` individually using a sliding window encoding). NB: If 
    using different [`OutcomeSpace`](@ref)s for the different `xᵢ`, then [`total_outcomes`](@ref) must 
    be the same for every outcome space.

## Examples

```julia
# Discretizing some non-discrete data using a sliding-window encoding for each variable
x, y = rand(100), rand(100)
c = CodifyVariables(OrdinalPatterns(m = 4))
counts(c, x, y)

# Discretizing the data by binning each individual data point
binning = RectangularBinning(3)
encoding = RectangularBinEncoding(binning, [x; y]) # give input values to ensure binning covers all data
c = CodifyPoints(encoding)
counts(c, x, y)

# Counts table for already discrete data
n = 50 # all variables must have the same number of elements
x = rand(["dog", "cat", "mouse"], n)
y = rand(1:3, n)
z = rand([(1, 2), (2, 1)], n)

counts(UniqueElements(), x, y, z)
```

See also: [`CodifyPoints`](@ref), [`CodifyVariables`](@ref), [`UniqueElements`](@ref), [`OutcomeSpace`](@ref),
[`probabilities`](@ref).
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
        return ComplexityMeasures.counts(UniqueElements(), x...)
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

function marginal(c::Counts; dims = 1:ndims(c))
    alldims = 1:ndims(c)
    reduce_dims = (setdiff(alldims, dims)...,)
    marginal = dropdims(sum(c.cts, dims = reduce_dims), dims = reduce_dims)
    include_idxs = setdiff(alldims, reduce_dims)
    new_outcomes = c.outcomes[include_idxs]
    new_dimlabels = c.dimlabels[include_idxs]
    return Counts(marginal, new_outcomes, new_dimlabels)
end

# ----------------------------------------------------------------
# Estimation from data
# ----------------------------------------------------------------

# Per point/row
# ----------------------------------------------------------------
# If multiple encodings are given, the number of encodings must match the number of
# input variables.
function counts(encoding::CodifyPoints{N}, x::Vararg{Any, N}) where {N}
    x̂ = codify(encoding, x...)
    return counts(UniqueElements(), x̂...)
end

# If only one encoding is given, apply same encoding to all points
function counts(encoding::CodifyPoints{1}, x::Vararg{Any, N}) where {Any, N}
    e = first(encoding.encodings)
    x̂ = ([encode(e, pt) for pt in xₖ] for xₖ in x)
    return counts(UniqueElements(), x̂...)
end

# Per variable/column
# ----------------------------------------------------------------
function counts(discretization::CodifyVariables{1}, x::Vararg{ArrayOrStateSpaceSet, N}) where N
    o = first(discretization.outcome_spaces)
    # Treat 1D state space sets as vectors, so we can apply the outcome space sequentially.
    # TODO: show warning or not? I think this can be silent, because I can't really think of a situation
    # where the outcome space couldn't be applied to the raw values of a 1D dataset.
    # @warn "`CodifyVariables` is meant for sequential application over vectors. You provided a 1D `StateSpaceSet`. Treating this 1D input dataset as a vector..."
    x̂ = (codify(o, xₖ isa AbstractStateSpaceSet{1} ? as_vec(xₖ) : xₖ) for xₖ in x)
    return counts(x̂...)
end

function counts(d::CodifyVariables{1, UniqueElements}, x::Vararg{ArrayOrStateSpaceSet, N}) where N
    o = first(d.outcome_spaces)
    return counts(o, x...)
end

as_vec(x::AbstractStateSpaceSet{1}) = [first(xᵢ) for xᵢ in vec(x)]


# TODO: We should formalize this in ComplexityMeasures.jl by constructing 
# an "EmbeddingBasedOutcomeSpace" that all construct the embedding vectors 
# in the same way. This is a bit fragile as it is now, because it is not 
# guaranteed API-wise that embedding vectors are constructed in the same way
# (although *in practice* all `OutcomeSpace` that use embeddings do so 
# per v3.6 of ComplexityMeasures.jl).
function counts(discretization::CodifyVariables{N}, x::Vararg{Any, N}) where N
    encoded_pts = codify(discretization, x...)
    return counts(encoded_pts...)
end
