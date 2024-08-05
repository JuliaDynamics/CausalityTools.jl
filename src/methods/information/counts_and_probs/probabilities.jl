import ComplexityMeasures: probabilities
export marginal

# ##########################################################################################
# Probabilities API.
# The following code extends the functionality of ComplexityMeasures.jl for multiple
# input variables (ComplexityMeasures.jl only deals with single-variable estimation)
# ##########################################################################################

"""
    probabilities(o::UniqueElements, x₁, x₂, ..., xₙ) → Counts{N}
    probabilities(encoding::CodifyPoints, x₁, x₂, ..., xₙ) → Counts{N}
    probabilities(encoding::CodifyVariables, x₁, x₂, ..., xₙ) → Counts{N}

Construct an `N`-dimensional [`Probabilities`](@ref) array from the input iterables
`x₁, x₂, ..., xₙ` which are such that 
`length(x₁) == length(x₂) == ⋯ == length(xₙ)`.

## Description

Probabilities are computed by first constructing a joint contingency matrix in the form 
of a [`Counts`](@ref) instance. 

If `x₁, x₂, ..., xₙ` are already discrete, then use [`UniqueElements`](@ref) as 
the first argument to directly construct the joint contingency table.

If `x₁, x₂, ..., xₙ` need to be discretized, provide as the first argument
- [`CodifyPoints`](@ref) (encodes every *point* in each of the input variables `xᵢ`s individually)
- [`CodifyVariables`](@ref) (encodes every `xᵢ` individually using a sliding window encoding).

## Examples

```julia
# Discretizing some non-discrete data using a sliding-window encoding for each variable
x, y = rand(100), rand(100)
c = CodifyVariables(OrdinalPatterns(m = 4))
probabilities(c, x, y)

# Discretizing the data by binning each individual data point
binning = RectangularBinning(3)
encoding = RectangularBinEncoding(binning, [x; y]) # give input values to ensure binning covers all data
c = CodifyPoints(encoding)
probabilities(c, x, y)

# Joint probabilities for already discretized data
n = 50 # all variables must have the same number of elements
x = rand(["dog", "cat", "mouse"], n)
y = rand(1:3, n)
z = rand([(1, 2), (2, 1)], n)

probabilities(UniqueElements(), x, y, z)
```

See also: [`CodifyPoints`](@ref), [`CodifyVariables`](@ref), [`UniqueElements`](@ref), [`OutcomeSpace`](@ref).
"""
function probabilities(o::OutcomeSpace) end

function probabilities(o::OutcomeSpace, x::Vararg{VectorOrStateSpaceSet, N}) where N # this extends ComplexityMeasures.jl definition
    return Probabilities(counts(o, x...))
end
function probabilities(est::RelativeAmount, c::Counts{<:Integer, N}) where N
    probs = Probabilities(c)
    return Probabilities(probs.p, c.outcomes, c.dimlabels)
end

function probabilities(est::ProbabilitiesEstimator, c::Counts{<:Integer, N}) where N
    return Probabilities(probs.p, c.outcomes, c.dimlabels)
end

# Not providing any discretization defaults to `RelativeAmount` estimation.
function probabilities(x::Vararg{VectorOrStateSpaceSet, N}) where N
    cts = counts(UniqueElements(), x...)
    probs = probabilities(RelativeAmount(), cts)
    return Probabilities(probs.p, cts.outcomes, cts.dimlabels)
end

"""
    marginal(p::Probabilities; dims = 1:ndims(p))
    marginal(c::Counts; dims = 1:ndims(p))

Given a set of counts `c` (a contingency table), or a multivariate probability mass
function `p`, return the marginal counts/probabilities along the given `dims`.
"""
function marginal(p::Probabilities; dims = 1:ndims(p))
    alldims = 1:ndims(p)
    reduce_dims = (setdiff(alldims, dims)...,)
    # if all(a == b for (a, b) in zip(reduce_dims, alldims))
    #     @show "not taking marginal for $dims and $p"
    #     return p
    # end
    marg = dropdims(sum(p.p, dims = reduce_dims), dims = reduce_dims)
    include_idxs = setdiff(alldims, reduce_dims)
    N = length(include_idxs)
    if N > 0
        new_outcomes = p.outcomes[include_idxs]
        new_dimlabels = p.dimlabels[include_idxs]

        if marg isa Number
            marg = [marg]
        end
        return Probabilities(marg, new_outcomes, new_dimlabels)
    end
    return Probabilities(marg)
   
end

# ----------------------------------------------------------------
# Estimation from data
# ----------------------------------------------------------------

# Per point/row
# ----------------------------------------------------------------
function probabilities(encoding::CodifyPoints{1}, x::Vararg{Any, N}) where {N}
    cts = counts(encoding, x...)
    return Probabilities(cts)
end

function probabilities(encoding::CodifyPoints{N}, x::Vararg{Any, N}) where {N}
    cts = counts(encoding, x...)
    return Probabilities(cts)
end

# Per variable/column
# ----------------------------------------------------------------
function probabilities(discretization::CodifyVariables, x::Vararg{ArrayOrStateSpaceSet, N}) where N
    cts = counts(discretization, x...)
    return probabilities(RelativeAmount(), cts)
end