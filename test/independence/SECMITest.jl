n = 40
using Associations
using Test
using Random; rng = Xoshiro(1234)
x = rand(rng, n)
y = randn(rng, n) .+ x .^ 2
z = randn(rng, n) .* y

# An estimator for estimating the SECMI measure
est = JointProbabilities(SECMI(base = 2), CodifyVariables(ValueBinning(3)))
test = SECMITest(est; nshuffles = 19, rng = rng)

# Do a test and check that we can reject null or not as expected
α = 0.05
@test pvalue(independence(test, x, y, z)) < α
@test pvalue(independence(test, x, z, y)) > α

out = repr(independence(SECMITest(est; nshuffles = 2), x, y, z))
@test occursin("D𝒳²", out)

# Categorical
rng = Xoshiro(1234)
n = 12
x = rand(rng, ["vegetables", "candy"], n)
y = [xᵢ == "candy" && rand(rng) > 0.3 ? "yummy" : "yuck" for xᵢ in x]
z = [yᵢ == "yummy" && rand(rng) > 0.6 ? "grown-up" : "child" for yᵢ in y]
d = CodifyVariables(UniqueElements())
est = JointProbabilities(SECMI(base = 2), d)
test = SECMITest(est; nshuffles = 19, rng = rng)
@test pvalue(independence(test, x, y, z)) < α
@test pvalue(independence(test, x, z, y)) > α