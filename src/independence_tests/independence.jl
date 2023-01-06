export independence
export ConditionalIndependenceTest

abstract type IndependenceTest end
"""
    ConditionalIndependenceTest <: IndependenceTest

The supertype for all conditional independence tests, which are:

- [`LocalPermutation`](@ref).
"""
abstract type ConditionalIndependenceTest <: IndependenceTest end

"""
    independence(test, x, y, z)

Compute the conditional independence of `x` and `y` given `z` using
the provided [`ConditionalIndependenceTest`](@ref), which can be one of the following:

- [`LocalPermutation`](@ref)
- [`GlobalPermutation`](@ref). This is essentially a convenience wrapper that performs
    standard surrogate testing.

"""
function independence(test, args...; kwargs...)
    error("No concrete implementation for $(typeof(test)) test yet")
end

include("LocalPermutation.jl")