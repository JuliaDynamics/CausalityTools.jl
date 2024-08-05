export independence, cit
export IndependenceTest

using Statistics: quantile

"""
    IndependenceTest <: IndependenceTest

The supertype for all independence tests.

## Concrete implementations

- [`SurrogateAssociationTest`](@ref)
- [`LocalPermutationTest`](@ref)
- [`JointDistanceDistributionTest`](@ref)
- [`CorrTest`](@ref)
- [`SECMITest`](@ref)
"""
abstract type IndependenceTest{M} end

# Internal type used to generate summary texts
abstract type IndependenceTestResult end

"""
    independence(test::IndependenceTest, x, y, [z]) → summary

Perform the given [`IndependenceTest`](@ref) `test` on data `x`, `y` and `z`.
If only `x` and `y` are given, `test` must provide a bivariate association measure.
If `z` is given too, then `test` must provide a conditional association measure.

Returns a test `summary`, whose type depends on `test`.

See [`IndependenceTest`](@ref) for a list of compatible tests.
"""
function independence(test::IndependenceTest, x...)
    L = length(x)
    throw(ArgumentError("No concrete implementation for $(typeof(test)) test with $(L) input variables."))
end

function pvalue_text_summary(test::IndependenceTestResult)
    α005 = pvalue(test) < 0.05 ?
        "α = 0.05:  ✓ Evidence favors dependence" :
        "α = 0.05:  ✖ Independence cannot be rejected"
    α001 = pvalue(test) < 0.01 ?
        "α = 0.01:  ✓ Evidence favors dependence" :
        "α = 0.01:  ✖ Independence cannot be rejected"
    α0001 = pvalue(test) < 0.001 ?
        "α = 0.001: ✓ Evidence favors dependence" :
        "α = 0.001: ✖ Independence cannot be rejected"

    return """\
    p-value:   $(test.pvalue)
      $α005
      $α001
      $α0001\
    """
end

function quantiles_text(test::IndependenceTestResult)
    return """\
    Estimated: $(test.m)
    Ensemble quantiles ($(test.nshuffles) permutations):
        (99.9%): $(quantile(test.m_surr, 0.999))
        (99%):   $(quantile(test.m_surr, 0.99))
        (95%):   $(quantile(test.m_surr, 0.95))\
    """
end

function null_hypothesis_text(test::IndependenceTestResult)
    if test.n_vars == 2
        return """\
        ---------------------------------------------------------------------
        H₀: "The variables are independent"
        Hₐ: "The variables are dependent"
        ---------------------------------------------------------------------\
        """
    elseif test.n_vars == 3
        """\
        ---------------------------------------------------------------------
        H₀: "The first two variables are independent, given the 3rd variable"
        Hₐ: "The first two variables are dependent, given the 3rd variable"
        ---------------------------------------------------------------------\
        """
    else
        return ""
    end
end
include("parametric/parametric.jl")
include("surrogate/SurrogateAssociationTest.jl")
include("local_permutation/LocalPermutationTest.jl")
include("secmi/secmi_test.jl")