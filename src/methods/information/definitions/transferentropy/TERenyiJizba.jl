export TERenyiJizba

"""
    TERenyiJizba() <: TransferEntropy

The Rényi transfer entropy from [Jizba2012](@citet).

## Usage

- Use with [`association`](@ref) to compute the raw transfer entropy.
- Use with an [`IndependenceTest`](@ref) to perform a formal hypothesis test for pairwise
    and conditional dependence.

## Description

The transfer entropy from source ``S`` to target ``T``, potentially
conditioned on ``C`` is defined as

```math
\\begin{align*}
TE(S \\to T) &:= I_q^{R_J}(T^+; S^- | T^-) \\\\
TE(S \\to T | C) &:= I_q^{R_J}(T^+; S^- | T^-, C^-),
\\end{align*},
```
where ``I_q^{R_J}(T^+; S^- | T^-)`` is Jizba et al. (2012)'s definition of
conditional mutual information ([`CMIRenyiJizba`](@ref)).
The `-` and `+` subscripts on the marginal variables ``T^+``, ``T^-``,
``S^-`` and ``C^-`` indicate that the embedding vectors for that marginal
are constructed using present/past values and future values, respectively.

## Estimation

Estimating Jizba's Rényi transfer entropy is a bit complicated, since it doesn't have 
a dedicated estimator. Instead, we re-write the Rényi transfer entropy as a 
Rényi conditional mutual information, and estimate it using an 
[`EntropyDecomposition`](@ref) with a suitable discrete/differential Rényi entropy
estimator from the list below as its input.

| Estimator                      | Sub-estimator                    | Principle                    |
| :----------------------------- | :------------------------------- | :--------------------------- |
| [`EntropyDecomposition`](@ref) | [`LeonenkoProzantoSavani`](@ref) | Four-entropies decomposition |
| [`EntropyDecomposition`](@ref) | [`ValueBinning`](@ref)           | Four-entropies decomposition |
| [`EntropyDecomposition`](@ref) | [`Dispersion`](@ref)             | Four-entropies decomposition |
| [`EntropyDecomposition`](@ref) | [`OrdinalPatterns`](@ref)        | Four-entropies decomposition |
| [`EntropyDecomposition`](@ref) | [`UniqueElements`](@ref)         | Four-entropies decomposition |
| [`EntropyDecomposition`](@ref) | [`TransferOperator`](@ref)       | Four-entropies decomposition |

Any of these estimators must be given as input to a [`CMIDecomposition](@ref) estimator.

## Estimation

- [Example 1](@ref example_TERenyiJizba_EntropyDecomposition_TransferOperator): [`EntropyDecomposition`](@ref) with [`TransferOperator`](@ref) outcome space.

"""
struct TERenyiJizba{B, Q, EMB} <: TransferEntropy
    base::B
    q::Q
    embedding::EMB
    function TERenyiJizba(; base::B = 2, q::Q = 1.5, embedding::EMB = EmbeddingTE()) where {B, Q, EMB}
        return new{B, Q, EMB}(base, q, embedding)
    end
end

function convert_to_cmi_estimator(est::EntropyDecomposition{<:TERenyiJizba, <:DiscreteInfoEstimator{<:Renyi}})
    (; definition, est, discretization, pest) = est
    base = definition.base
    return EntropyDecomposition(CMIRenyiJizba(; base), est, discretization, pest)
end

function convert_to_cmi_estimator(est::EntropyDecomposition{<:TERenyiJizba, <:DifferentialInfoEstimator{<:Renyi}})
    return EntropyDecomposition(CMIRenyiJizba(; est.definition.base), est.est)
end

# ------------------------------------------------
# Pretty printing for decomposition estimators.
# ------------------------------------------------
# These are some possible decompositions
# TE(s -> t | c) =
# = I(t⁺; s⁻ | t⁻, c⁻)
# = I(t⁺; s⁻, t⁻, c⁻) - I(t⁺; t⁻, c⁻)
# = h(t⁺ | t⁻,c⁻) - h(t⁺ | s⁻,t⁻,c⁻)
# = h(t⁺, t⁻,c⁻) - h(t⁻,c⁻) - h(t⁺,s⁻,t⁻,c⁻) + h(s⁻,t⁻,c⁻)"

function decomposition_string(
        definition::TERenyiJizba, 
        est::EntropyDecomposition{M, <:DiscreteInfoEstimator}
    ) where M
    return "TEᵣⱼ(s → t | c) = Hᵣ(t⁺, t⁻,c⁻) - Hᵣ(t⁻,c⁻) - Hᵣ(t⁺,s⁻,t⁻,c⁻) + Hᵣ(s⁻,t⁻,c⁻)"
end

function decomposition_string(
    definition::TERenyiJizba, 
    est::EntropyDecomposition{M, <:DifferentialInfoEstimator}
    ) where M
    return "TEᵣⱼ(s → t | c) = hᵣ(t⁺, t⁻,c⁻) - hᵣ(t⁻,c⁻) - hᵣ(t⁺,s⁻,t⁻,c⁻) + hᵣ(s⁻,t⁻,c⁻)"
end