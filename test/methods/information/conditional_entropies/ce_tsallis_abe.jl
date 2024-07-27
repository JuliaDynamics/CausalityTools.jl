using Test
using Associations
using Random


# ---------------
# Internals
# ---------------
def = ConditionalEntropyTsallisAbe()
@test Associations.min_inputs_vars(def) == 2
@test Associations.max_inputs_vars(def) == 2


# ---------------------------------------------------------------------------------------
# Test all possible ways of estimating `ConditionalEntropyTsallisAbe`.
# ---------------------------------------------------------------------------------------
# `JointProbabilities` with ` CodifyPoints`
x, y, z = rand(rng, 1:5, 100), rand(rng, 1:5, 100), rand(rng, 1:3, 100)
X = StateSpaceSet(x, z)
Y = StateSpaceSet(y, z)
disc = CodifyPoints(UniqueElementsEncoding(X), UniqueElementsEncoding(Y));
est = JointProbabilities(ConditionalEntropyTsallisAbe(q = 0.5), disc);
@test association(est, X, Y) isa Real

est = JointProbabilities(ConditionalEntropyTsallisAbe(q = 1.5), disc);
@test association(est, X, Y) isa Real


est_t = JointProbabilities(ConditionalEntropyTsallisAbe(q = 1.0), disc);
est_s = JointProbabilities(ConditionalEntropyShannon(), disc);

@test association(est_t, X, Y) == association(est_s, X, Y)