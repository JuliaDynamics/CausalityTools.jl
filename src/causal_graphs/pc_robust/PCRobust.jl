using Random

export PCRobust

"""
    PCRobust <: GraphAlgorithm
    PCRobust(
        unconditional_test::IndependenceTest,
        conditional_test::IndependenceTest;
        α = 0.05)

The "robustified" version (Kalisch & Bühlmann, 2008[^Kalisch2008]) of the PC algorithm
(Spirtes et al., 2000)[^Spirtes2000]. The `unconditional_test` must be an
[`IndependenceTest`](@ref) with a valid pairwise [`AssociationMeasure`](@ref),
and `conditional_test` must be an [`IndependenceTest`](@ref) with a valid conditional
[`AssociationMeasure`](@ref).

## Description

When used with [`infer_graph`](@ref) on some input data `x`, the `PCRobust` algorithm
performs the following steps:

1. Initialize an empty fully connected graph `g` with `N` nodes, where `N` is the number
    of variables and `x[i]` is the data for the `i`-th node.
2. Reduce the fully connected `g` to a skeleton graph by performing pairwise
    [`independence`](@ref) tests between all vertices using `unconditional_test`. Remove
    any edges where adjacent vertices are found to be independent according to the test
    (i.e. the null hypothesis of independence cannot be rejected at significance level
    `1 - α`).
3. Thin the skeleton `g` by conditional [`independence`](@ref) testing. If
    `x[i] ⫫ x[j] | x[Z]` for some set of variables `Z` (not including `i` and `j`)
    according to `conditional_test` (i.e. the null hypothesis of conditional independence
    cannot be rejected at significance level `1 - α`), then the edge between `i` and `j` is
    removed, and we record the separating set S(i, j) = Z. Independence tests are first
    performed for conditioning sets of size 1, and repeated for conditioning sets of
    increasing size, which in most cases limits the number of tests needed.  The separating
    sets `S(i, j)`, which records which variables were in the conditioning set that
    rendered variables `i` and `j` independent, are recorded.
4. Create a directed graph `dg` from `g` by replacing every
    undirected edge `X - Y` in `g` by the bidirectional edge `X ↔ Y` (i.e.
    construct two directional edges `X → Y` and `Y → X`). Orientiation rules 0-3
    are then repeatedly applied to `dg` until no more edges can be oriented:
    - Rule 0 (orients v-structures): `X ↔ Y ↔ Z` becomes `X → Y ← Z` if `Y` is not in the
        separating set `S(X, Z)`.
    - Rule 1 (prevents new v-structures): `X → Y ↔ Z` becomes `X → Y → Z` if `X` and `Z`
        are not adjacent.
    - Rule 2 (avoids cycles): `X → Y → Z ↔ X` becomes `X → Y → Z ← X`.
    - Rule 3: To avoid creating cycles or new v-structures, whenever `X - Y → Z`,
        `X - W → Z`, and `X - Z` but there is no edge between `Y` and `W`, turn the
        undirected `X - Z` edge into the directed edge `X → Z`.

The resulting directed graph is then returned.

!!! info
    The "PC" algorithm is named after the *first names* of the authors, **P**eter Spirtes
    and **C**lark Glymour.

[^Kalisch2008]:
    Kalisch, M., & Bühlmann, P. (2008). Robustification of the PC-algorithm for directed
    acyclic graphs. Journal of Computational and Graphical Statistics, 17(4), 773-789.
[^Spirtes2000]:
    Spirtes, P., Glymour, C. N., Scheines, R., & Heckerman, D. (2000). Causation, prediction,
    and search. MIT press.
"""
struct PCRobust{U, C, A} <: GraphAlgorithm
    unconditional_test::U
    conditional_test::C
    α::A

    function PCRobust(unconditional_test::U, conditional_test::C;
            α::A = 0.05, rng = Random.default_rng()) where {U <: IndependenceTest, C <: IndependenceTest, A}
        0 < α < 1 || throw(ArgumentError("α must be on `(0, 1)`. α = 0.05 is commonly used"))
        new{U, C, A}(unconditional_test, conditional_test, α)
    end
end

include("skeleton.jl")
include("cpdag.jl")

function infer_graph(algorithm::PCRobust, x; verbose = false)
    skeleton_graph, separating_sets = skeleton(algorithm, x; verbose)
    directed_graph = cpdag(algorithm, skeleton_graph, separating_sets; verbose)

    return directed_graph
end
