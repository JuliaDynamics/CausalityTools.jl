using SpecialFunctions: gamma
using Neighborhood: bulksearch
using Neighborhood: Euclidean, Theiler
import Entropies: EntropyEstimator
import Entropies: entropy

export LeonenkoProzantoSavani

"""
    LeonenkoProzantoSavani <: EntropyEstimator
    LeonenkoProzantoSavani(k = 1, w = 0, base = MathConstants.e)

The `LeonenkoProzantoSavani` estimator computes the [`Shannon`](@ref), [`Renyi`](@ref), or
[`Tsallis`](@ref) to the given `base`, entropy using `k`-th nearest-neighbor approach
from Leonenko et al. (2008)[^LeonenkoProsantoSavani2008].

`w` is the Theiler window, which determines if temporal neighbors are excluded
during neighbor searches (defaults to `0`, meaning that only the point itself is excluded
when searching for neighbours).

[^LeonenkoProsantoSavani2008]:
    Leonenko, N., Pronzato, L., & Savani, V. (2008). A class of Rényi information
    estimators for multidimensional densities. The Annals of Statistics, 36(5), 2153-2182.
"""
Base.@kwdef struct LeonenkoProzantoSavani <: EntropyEstimator
    k::Int = 1
    w::Int = 0
end

function entropy(e::Renyi, est::LeonenkoProzantoSavani, x::AbstractDataset{D}) where D
    h = log(Î(e.q, est, x)) / (1 - e.q) # measured in nats
    return h / log(e.base, ℯ) # convert to desired base.
end

function entropy(e::Tsallis, est::LeonenkoProzantoSavani, x::AbstractDataset{D}) where D
    h = (Î(e.q, est, x) - 1) / (1 - e.q) # measured in nats
    return h / log(e.base, ℯ) # convert to desired base.
end

# TODO: this gives nan??
# Use notation from original paper
function Î(q, est::LeonenkoProzantoSavani, x::AbstractDataset{D}) where D
    (; k, w) = est
    N = length(x)
    Vₘ = ball_volume(D)
    Cₖ = (gamma(k) / gamma(k + 1 - q))^(1 / (1 - q))
    tree = KDTree(x, Euclidean())
    idxs, ds = bulksearch(tree, x, NeighborNumber(k), Theiler(w))
    if q ≈ 1.0
        h = (1 / N) * sum(ξᵢ_shannon(last(dᵢ), Vₘ, N, D, k)^(1 - q) for dᵢ in ds)
    else
        h = (1 / N) * sum(ξᵢ_renyi_tsallis(last(dᵢ), Cₖ, Vₘ, N, D)^(1 - q) for dᵢ in ds)
    end
    return h
end
ξᵢ_renyi_tsallis(dᵢ, Cₖ, Vₘ, N::Int, D::Int) = (N - 1) * Cₖ * Vₘ * (dᵢ)^D
ξᵢ_shannon(dᵢ, Vₘ, N::Int, D::Int, k) = (N - 1) * exp(digamma(k)) * Vₘ * (dᵢ)^D

using Distributions: MvNormal
using Distributions
function entropy(e::Renyi, 𝒩::MvNormal; base = 2)
    q = e.q
    if q ≈ 1.0
        h = Distributions.entropy(𝒩)
    else
        Σ = 𝒩.Σ
        D = length(𝒩.μ)
        h = Distributions.entropy(𝒩) - (D / 2) * (1 + log(q) / (1 - q))
    end
    return h / log(base, ℯ)
end

# Eq. 15 in Nielsen & Nock (2011); https://arxiv.org/pdf/1105.3259.pdf
function entropy(e::Tsallis, 𝒩::MvNormal; base = 2)
    q = e.q
    Σ = 𝒩.Σ
    D = length(𝒩.μ)
    hr = entropy(Renyi(q = q), 𝒩; base)
    h = (exp((1 - q) * hr) - 1) / (1 - q)
    return h / log(base, ℯ)
end
