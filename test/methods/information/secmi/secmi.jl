using Associations
using Test
using Random; rng = Xoshiro(8284)

# Categorical
n = 12
x = rand(rng, ["vegetables", "candy"], n)
y = [xᵢ == "candy" && rand() > 0.3 ? "yummy" : "yuck" for xᵢ in x]
z = [yᵢ == "yummy" && rand() > 0.6 ? "grown-up" : "child" for yᵢ in y]
w = [yᵢ == "yummy" && rand() > 0.6 ? "grown-up" : "child" for yᵢ in y]

d = CodifyVariables(UniqueElements())
est = JointProbabilities(SECMI(base = 2), d)

# Test both signatures
@test association(est, x, y, z) ≥ 0.0
@test association(est, x, y, StateSpaceSet(z, w)) ≥ 0.0
