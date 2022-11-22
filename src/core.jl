using DelayEmbeddings: AbstractDataset
using Entropies: ProbabilitiesEstimator
const Vector_or_Dataset{D, T} = Union{AbstractVector{T}, AbstractDataset{D, T}} where {D, T}

abstract type CausalityMeasure end
abstract type InformationMeasure <: CausalityMeasure end

function estimate_from_marginals(measure::InformationMeasure, args...;
        kwargs...) where I <: InformationMeasure
    msg = "Marginal estimation of $I is not implemented"
    throw(ArgumentError(msg))
end