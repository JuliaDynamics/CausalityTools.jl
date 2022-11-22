export Wang

using Neighborhood: KDTree, Euclidean
using Neighborhood: bulksearch

"""
    Wang <: RelativeEntropyEstimator
    Wang(k = 1, w = 1)

The `Wang` relative entropy estimator (Wang et al., 2009[^Wang2009] computes the relative
entropy between two `d`-dimensional `Dataset`s.

[^Wang2009]:
    Wang, Q., Kulkarni, S. R., & Verdú, S. (2009). Divergence estimation for
    multidimensional densities via k-Nearest-Neighbor distances. IEEE Transactions on
    Information Theory, 55(5), 2392-2405.
"""
Base.@kwdef struct Wang <: RelativeEntropyEstimator
    k::Int = 1
    w::Int = 0
end

function entropy_relative(e::Renyi, est::Wang,
        x::AbstractDataset{D, T1},
        y::AbstractDataset{D, T2}) where {D, T1, T2}
    e.q ≈ 1 || error("`entropy_relative` not defined for `Wang` estimator for Renyi with q = $(e.q)")
    (; k, w) = est
    n, m = length(x), length(y)

    tree_x = KDTree(x, Euclidean())
    tree_y = KDTree(y, Euclidean())
    theiler = Theiler(est.w)
    idxs_x, dists_x = bulksearch(tree_x, x, NeighborNumber(k), theiler)
    idxs_xiny, dists_xiny = bulksearch(tree_y, x, NeighborNumber(k), theiler)
    return (D / n) * sum(last.(dists_x) ./ last.(dists_xiny)) + log(m / (n - 1))
end