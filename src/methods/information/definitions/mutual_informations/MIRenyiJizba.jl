using ComplexityMeasures: Renyi

export MIRenyiJizba

"""
    MIRenyiJizba <: <: BivariateInformationMeasure
    MIRenyiJizba(; q = 1.5, base = 2)

The Rényi mutual information ``I_q^{R_{J}}(X; Y)`` defined in [Jizba2012](@cite).

## Usage

- Use with [`association`](@ref) to compute the raw Rényi-Jizba mutual information from input data
    using of of the estimators listed below.
- Use with [`independence`](@ref) to perform a formal hypothesis test for pairwise dependence using
    the Rényi-Jizba mutual information.

## Compatible estimators

- [`JointProbabilities`](@ref).
- [`EntropyDecomposition`](@ref).

## Definition

```math
I_q^{R_{J}}(X; Y) = H_q^{R}(X) + H_q^{R}(Y) - H_q^{R}(X, Y),
```

where ``H_q^{R}(\\cdot)`` is the [`Rényi`](@ref) entropy.


## Estimation

- [Example 1](@ref example_MIRenyiJizba_JointProbabilities_UniqueElements): [`JointProbabilities`](@ref) with [`UniqueElements`](@ref) outcome space.
- [Example 2](@ref example_MIRenyiJizba_JointProbabilities_LeonenkoProzantoSavani): [`EntropyDecomposition`](@ref) with [`LeonenkoProzantoSavani`](@ref).
- [Example 3](@ref example_MIRenyiJizba_EntropyDecomposition_ValueBinning): [`EntropyDecomposition`](@ref) with [`ValueBinning`](@ref).
"""
Base.@kwdef struct MIRenyiJizba{B, Q} <: MutualInformation
    base::B = 2
    q::Q = 1.5
end

# ----------------------------------------------------------------
# Estimation methods
# ----------------------------------------------------------------
function association(est::JointProbabilities{<:MIRenyiJizba}, x, y)
    probs = probabilities(est.discretization, x, y)
    return association(est.definition, probs)
end

function association(definition::MIRenyiJizba, pxy::Probabilities{T, 2}) where T
    (; base, q) = definition

    px = marginal(pxy, dims = 1)
    py = marginal(pxy, dims = 2)
    
    logb = log_with_base(base)
    num = 0.0
    den = 0.0
    for i in eachindex(px.p)
        for j in eachindex(py.p)
            num += px[i]^q * py[j]^q
            den += pxy[i, j]^q
        end
    end
    if den != 0
        mi = logb(num / den)
    else
        mi = 0.0
    end

    return (1 / (1 / q)) * mi
end

# --------------------------------------------------------------
# `MIRenyiJizba` through entropy decomposition.
# Eq. 24 in
# Jizba, P., Lavička, H., & Tabachová, Z. (2021). Rényi Transfer Entropy Estimators for
# Financial Time Series. Engineering Proceedings, 5(1), 33.
# --------------------------------------------------------------
function association(est::EntropyDecomposition{<:MIRenyiJizba, <:DifferentialInfoEstimator{<:Renyi}}, x, y)
    HX, HY, HXY = marginal_entropies_mi3h_differential(est, x, y)
    mi =  HX + HY - HXY
    return mi
end

function association(est::EntropyDecomposition{<:MIRenyiJizba, <:DiscreteInfoEstimator{<:Renyi}}, x, y)
    HX, HY, HXY = marginal_entropies_mi3h_discrete(est, x, y)
    mi =  HX + HY - HXY
    return mi
end

# ------------------------------------------------
# Pretty printing for decomposition estimators.
# ------------------------------------------------
function decomposition_string(
        definition::MIRenyiJizba, 
        est::EntropyDecomposition{<:MIRenyiJizba, <:DifferentialInfoEstimator{<:Renyi}}
    )
    return "Iᵣⱼ(X, Y) = hᵣ(X) + hᵣ(Y) - hᵣ(X, Y)"
end

function decomposition_string(
        definition::MIRenyiJizba, 
        est::EntropyDecomposition{<:MIRenyiJizba, <:DiscreteInfoEstimator{<:Renyi}}
    )
    return "Iᵣⱼ(X, Y) = Hᵣ(X) + Hᵣ(Y) - Hᵣ(X, Y)"
end
