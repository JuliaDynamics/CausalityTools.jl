using DelayEmbeddings: AbstractStateSpaceSet
using ComplexityMeasures: ProbabilitiesEstimator
const VectorOrStateSpaceSet{D, T} = Union{AbstractVector{T}, AbstractStateSpaceSet{D, T}} where {D, T}
const ArrayOrStateSpaceSet{D, T, N} = Union{AbstractArray{T, N}, AbstractStateSpaceSet{D, T}} where {D, T, N}

export AssociationMeasure
export DirectedAssociationMeasure


# Any non-bivariate association measures must implement:
# - [`min_inputs_vars`](@ref).
# - [`max_inputs_vars`](@ref).
"""
    AssociationMeasure

The supertype of all association measures.
"""
abstract type AssociationMeasure end

abstract type DirectedAssociationMeasure <: AssociationMeasure end

# For measures without dedicated estimators, skip the estimator.
function estimate(measure::M, est::Nothing, args...; kwargs...) where M
    estimate(measure, args...; kwargs...)
end

include("contingency_matrices.jl")


# Just use ComplexityMeasures.convert_logunit when it is released.
"""
    _convert_logunit(h_a::Real, , to) → h_b

Convert a number `h_a` computed with logarithms to base `a` to an entropy `h_b` computed
with logarithms to base `b`. This can be used to convert the "unit" of an entropy.
"""
function _convert_logunit(h::Real, base_from, base_to)
    h / log(base_from, base_to)
end

# Default to bivariate measures. Other measures override it.
"""
    min_inputs_vars(m::AssociationMeasure) → nmin::Int

Return the minimum number of variables is that the measure can be computed for.

For example, [`CMIShannon`](@ref) requires 3 input variables.
"""
min_inputs_vars(m::AssociationMeasure) = 2

# Default to bivariate measures. Other measures override it.

"""
    max_inputs_vars(m::AssociationMeasure) → nmax::Int

Return the maximum number of variables is that the measure can be computed for.

For example, [`MIShannon`](@ref) cannot be computed for more than 2 variables.
"""
max_inputs_vars(m::AssociationMeasure) = 2

function verify_number_of_inputs_vars(measure::AssociationMeasure, n::Int)
    T = typeof(measure)
    nmin = min_inputs_vars(measure)
    if n < nmin
        throw(ArgumentError("$T requires at least $nmin inputs. Got $n inputs."))
    end

    nmax = max_inputs_vars(measure)
    if n > nmax
        throw(ArgumentError("$T accepts a maximum of $nmax inputs. Got $n inputs."))
    end
end
