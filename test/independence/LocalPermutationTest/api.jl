using Test
using CausalityTools 
using StableRNGs

rng = StableRNG(123)
x, y, z = rand(rng, 30), rand(rng, 30), rand(rng, 30)

independence_test = LocalPermutationTest(CMIShannon(), FPVP())
# We should get back a convenience wrapper containing the result.
res = independence(independence_test, x, z, y)
@test res isa LocalPermutationTestResult

# We should be able to compute p-values for the result.
@test pvalue(res) isa Real
@test pvalue(res) ≥ 0

# Only conditional analyses are possible, meaning that we need three inputs.
# Pairwise analyses won't work, because only two inputs are given.
@test_throws ArgumentError independence(independence_test, x, y)

# Sampling with/without replacement
test_cmi_replace = LocalPermutationTest(CMIShannon(), FPVP(), replace = true)
test_cmi_nonreplace = LocalPermutationTest(CMIShannon(), FPVP(), replace = false)
@test independence(test_cmi_replace, x, y, z) isa LocalPermutationTestResult
@test independence(test_cmi_nonreplace, x, y, z) isa LocalPermutationTestResult

# Measure definition AND estimator must be provided for info measures
@test_throws ArgumentError LocalPermutationTest(TEShannon()) # estimator needed

# The number of local neighbors can't exceed the number of input datapoints
test_kperm_toolarge = LocalPermutationTest(CMIShannon(), FPVP(); kperm = 200, rng)
@test_throws ArgumentError independence(test_kperm_toolarge, x, y, z)
