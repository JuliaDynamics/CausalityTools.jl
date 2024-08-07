# ------------------------------------------------------------------------
# API
# ------------------------------------------------------------------------
# Error for wrong number of input datasets.
est = JointProbabilities(MIShannon(), OrdinalPatterns(m=3))
test = SurrogateAssociationTest(est)
x, y, z = rand(30), rand(30), rand(30)
@test_throws ArgumentError independence(test, x)
@test_throws ArgumentError independence(test, x, y, z)


# Pairwise measures
include("MutualInformation.jl")
include("SMeasure.jl")
include("HMeasure.jl")
include("MMeasure.jl")
include("LMeasure.jl")
include("TransferEntropyPairwise.jl")
include("crossmappings.jl")
include("chatterjee_correlation.jl")
include("azadkia_chatterjee_correlation.jl")

# Conditional measures
include("ConditionalMutualInformation.jl")
include("pmi.jl")

# Pairwise + conditional
include("TransferEntropyConditional.jl")
