export JointEntropy

"""
    JointEntropy <: BivariateInformationMeasure

The supertype for all joint entropy measures.

## Concrete implementations

- [`JointEntropyShannon`](@ref)
- [`JointEntropyRenyi`](@ref)
- [`JointEntropyTsallis`](@ref)
"""
abstract type JointEntropy <: BivariateInformationMeasure end

# q-logarithm for Tsallis and Renyi joint entropies
logq(x, q) = (x^(1-q) - 1) / (1 - q)

include("JointEntropyShannon.jl")
include("JointEntropyRenyi.jl")
include("JointEntropyTsallis.jl")