using Test
using CausalityTools 
using StableRNGs

rng = StableRNG(123)
x, y, z = rand(rng, 30), rand(rng, 30), rand(rng, 30)

independence_test = LocalPermutationTest(PartialCorrelation())
@test independence(independence_test, x, y, z) isa LocalPermutationTestResult