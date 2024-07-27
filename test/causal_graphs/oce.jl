using Associations
using Associations: OCESelectedParents
using Test
using StableRNGs
using Graphs.SimpleGraphs: SimpleEdge
using DynamicalSystemsBase

rng = StableRNG(123)
sys = system(Logistic4Chain(; rng))
X = columns(first(trajectory(sys, 50, Ttr = 10000)))
uest = KSG1(MIShannon(), k = 5, w = 1)
utest = SurrogateAssociationTest(uest; rng, nshuffles = 19)

cest = MesnerShalizi(CMIShannon(), k = 5, w = 1)
ctest = LocalPermutationTest(cest; rng, nshuffles = 19)
alg = OCE(; utest, ctest, τmax = 2)
parents = infer_graph(alg, X; verbose = true)
@test parents isa Vector{<:OCESelectedParents}
@test SimpleDiGraph(parents) isa SimpleDiGraph

# Convenience method for `StateSpaceSet`s.
d = first(trajectory(sys, 50, Ttr = 10000))
parents = infer_graph(alg, d; verbose = true)
@test parents isa Vector{<:OCESelectedParents}

rng = StableRNG(123)
sys = system(Logistic2Bidir(; rng))
X = columns(first(trajectory(sys, 100, Ttr = 10000)))

uest = KSG1(MIShannon(); k = 5, w = 1)
cest = MesnerShalizi(CMIShannon(); k = 5, w = 1)
utest = SurrogateAssociationTest(uest; rng, nshuffles = 19)
ctest = LocalPermutationTest(cest; rng, nshuffles = 19)
parents = infer_graph(OCE(; utest, ctest, τmax = 1), X; verbose = true)
@test parents isa Vector{<:OCESelectedParents}
g = SimpleDiGraph(parents)
@test g isa SimpleDiGraph

# "Analytical" test: check that we at least identify one true positive. There may
# be several false positives, but there's no way of telling a priori how many.
function at_least_one_true_positive(true_edges, estimated_graph)
    estimated_edges = edges(estimated_graph)
    at_least_one_tp = false
    for e in true_edges
        if e in estimated_edges
            at_least_one_tp = true
        end
    end
    return at_least_one_tp
end

@test at_least_one_true_positive([SimpleEdge(1, 2), SimpleEdge(2, 1)], g)

# printing
@test occursin(repr("text/plain", parents[1]), "x₁")
@test occursin(repr("text/plain", parents[2]), "x₂")
