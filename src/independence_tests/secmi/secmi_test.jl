export SECMITest
export SECMITestResult

"""
    SECMITest <: IndependenceTest
    SECMITest(est; nshuffles = 19, surrogate = RandomShuffle(), rng = Random.default_rng())

A test for conditional independence based on the [`ShortExpansionConditionalMutualInformation`](@ref) measure [Kubkowski2021](@cite).

The first argument `est` must be a [`InformationMeasureEstimator`](@ref) that provides the 
[`ShortExpansionConditionalMutualInformation`](@ref) instance. See examples below.

## Examples

- [Example 1](@ref example_SECMITEST_JointProbabilities_CodifyVariables_ValueBinning): Independence test for small sample sizes using [`CodifyVariables`](@ref) with 
    [`ValueBinning`](@ref) discretization.
- [Example 2](@ref example_SECMITEST_JointProbabilities_CodifyVariables_UniqueElements): Independence test for small sample
    sizes with categorical data (using [`CodifyVariables`](@ref) with [`UniqueElements`](@ref) discretization).
"""
struct SECMITest{E, S, I, RNG} <: IndependenceTest{E}
    # really, this can only be an estimator, but we name it `est_or_measure` for consistency 
    # with the remaining tests, so we don't have to write custom code.
    est_or_measure::E 
    surrogate::S
    nshuffles::I
    rng::RNG
end

function SECMITest(est; nshuffles = 19, surrogate = RandomShuffle(), rng = Random.default_rng())
    return SECMITest(est, surrogate, nshuffles, rng)
end

"""
    SECMITestResult <: IndependenceTestResult
    SECMITestResult(secmi₀, secmiₖ, p, μ̂, σ̂, emp_cdf, D𝒩, D𝒳², nshuffles::Int)

A simple struct that holds the computed parameters of a [`SECMITest`](@ref) when called 
with [`independence`](@ref), as described in [Kubkowski2021](@cite).

## Parameters

- `p`: The p-value for the test.
- `secmi₀`: The value of the [`ShortExpansionConditionalMutualInformation`](@ref) measure estimated on the original data.
- `secmiₖ`: An ensemble of values for the [`ShortExpansionConditionalMutualInformation`](@ref) measure estimated on triples 
    `SECMI(X̂, Y, Z)`, where `X̂` indicates a shuffled version of the first variable `X` 
    and `length(secmiₖ) == nshuffles`.
- `μ̂`: The estimated mean of the `secmiₖ`.
- `σ̂`: The estimated standard deviation of the `secmiₖ`.
- `emp_cdf`: The empirical cumulative distribution function (CDF) of the `secmiₖ`s.
- `D𝒩`: The ``D_{N(\\hat{\\mu}, \\hat{\\sigma})}`` statistic.
- `D𝒳²`: The ``D_{\\chi^2}`` statistic.
"""
struct SECMITestResult{S0, SK, P, MU, S, E, DN, DCHI} <: IndependenceTestResult
    n_vars::Int # 3 vars = conditional (always 3)
    secmi₀::S0 # the value of the measure, non-permuted
    secmiₖ::SK # the values of the measure, permuted `nshuffles` times
    pvalue::P # the p-value, computed from the estimatedd parameters below.
    μ̂::MU
    σ̂::S
    emp_cdf::E
    D𝒩::DN
    D𝒳²::DCHI
end
pvalue(r::SECMITestResult) = r.pvalue

function Base.show(io::IO, test::SECMITestResult)
    print(io,
        """\
        `SECMITEST` independence test
        $(null_hypothesis_text(test::IndependenceTestResult))
        Estimated parameters:
        μ̂ = $(test.μ̂), σ̂ = $(test.σ̂)
        D𝒩 = $(test.D𝒩), D𝒳² = $(test.D𝒳²)

        $(pvalue_text_summary(test))
        """
        )
end

function independence(test::SECMITest, x, y, z)
    (; est_or_measure, surrogate, nshuffles, rng) = test
    secmi₀ = association(est_or_measure, x, y, z)
    sx = surrogenerator(x, surrogate, rng)
    secmiₖ = zeros(test.nshuffles)
    for k = 1:nshuffles
        secmiₖ[k] = association(est_or_measure, sx(), y, z)
    end
    μ̂ = 1/nshuffles * sum(secmiₖ)
    σ̂ = 1/(nshuffles - 1) * sum((sₖ - μ̂)^2 for sₖ in secmiₖ)
    emp_cdf = ecdf(secmiₖ) 
    F𝒩 = Normal(μ̂, σ̂)

    if μ̂ ≤ 0.0
        p = 1 - cdf(F𝒩, secmi₀)
        return SECMITestResult(3, secmi₀, secmiₖ, p, μ̂, σ̂, emp_cdf, nothing, nothing)
    else
        # Degrees of freedom for Chi squared distribution estimated as the mean of the `secmiₖ`
        # (page 18 in Kubkowski et al.). The `Chisq` distribution is only defined for μ̂ > 0,
        # so we put μ̂ <= 0.0 in a separate criterion first to avoid errors.
        F𝒳² = Chisq(μ̂)
        D𝒩, D𝒳² = sup_values(emp_cdf, F𝒩, F𝒳², secmiₖ)
        if  D𝒩 < D𝒳²
            p = 1 - cdf(F𝒩, secmi₀)
        else
            p = 1 - cdf(F𝒳², secmi₀)
        end
        return SECMITestResult(3, secmi₀, secmiₖ, p, μ̂, σ̂, emp_cdf, D𝒩, D𝒳²)

    end

   
    return SECMITestResult(3, secmi₀, secmiₖ, p, μ̂, σ̂, emp_cdf, D𝒩, D𝒳²)
end



function sup_values(emp_cdf, F𝒩, F𝒳², secmiₖ)
    empirical_cdf_values = emp_cdf.(secmiₖ)
    normal_cdf_values = cdf.(F𝒩, secmiₖ)
    chi2_cdf_values = cdf.(F𝒳², secmiₖ)
    D𝒩 = maximum(abs.(empirical_cdf_values .- normal_cdf_values))
    D𝒳² = maximum(abs.(empirical_cdf_values .- chi2_cdf_values))
    return D𝒩, D𝒳²
end
