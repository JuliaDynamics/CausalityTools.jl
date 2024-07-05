export KLDivergence

"""
    KLDivergence <: DivergenceOrDistance

The Kullback-Leibler (KL) divergence.

## Usage 

- [`information`](@ref). Used to compute the Hellinger distance between two pre-computed
    probability distributions.

## Description

The KL-divergence between two probability distributions
``P_X = (p_x(\\omega_1), \\ldots, p_x(\\omega_n))`` and
``P_Y = (p_y(\\omega_1), \\ldots, p_y(\\omega_m))``, both defined over the same
[`OutcomeSpace`](@ref) ``\\Omega = \\{\\omega_1, \\ldots, \\omega_n \\}``, is defined as

```math
D_{KL}(P_Y(\\Omega) || P_Y(\\Omega)) =
\\sum_{\\omega \\in \\Omega} p_x(\\omega) \\log\\dfrac{p_x(\\omega)}{p_y(\\omega)}
```

## Implements

- [`information`](@ref). Used to compute the KL-divergence between two pre-computed
    probability distributions. If used with [`RelativeAmount`](@ref), the KL divergence may
    be undefined to due some outcomes having zero counts. Use some other
    [`ProbabilitiesEstimator`](@ref) like [`BayesianRegularization`](@ref) to ensure
    all estimated probabilities are nonzero.

!!! note 
    Distances.jl also defines `KLDivergence`. Quality it if you're loading both 
    packages, i.e. do `information(CausalityTools.KLDivergence(), x, y)`.


## Examples

```julia
using CausalityTools

# There should be zero information gain from `x` over `y` for independent random variables.
using Random
rng = Xoshiro(1234)
n = 100000
x, y = rand(rng, n), rand(rng, n)
div_kl = information(KLDivergence(), OrdinalPatterns(m=3), x, y)
@test abs(div_kl) ≤ 0.001

```
"""
struct KLDivergence{B} <: DivergenceOrDistance
    base::B
end
KLDivergence(; base = 2) = KLDivergence(base)

function information(measure::KLDivergence, px::Probabilities, py::Probabilities)
    size_match(measure, px, py)
    return sum(pxᵢ * log(measure.base, pxᵢ / pyᵢ) for (pxᵢ, pyᵢ) in zip(px, py))
end