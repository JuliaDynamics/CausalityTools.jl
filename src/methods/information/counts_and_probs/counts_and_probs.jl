export Discretization

# The type parameter `N` indicates the number of input datasets to be discretized.
"""
    Discretization

The supertype of all discretization schemes.

## Concrete implementations

- [`CodifyVariables`](@ref)
- [`CodifyPoints`](@ref)
"""
abstract type Discretization{N} end


# Concrete ways of encoding multivariate data, each defined as a type.
include("encoding/codify_points.jl")
include("encoding/codify_variables.jl")

# Counting and probabilities (contingency tables and probabilities for multivariate data)
include("counts.jl")
include("probabilities.jl")
