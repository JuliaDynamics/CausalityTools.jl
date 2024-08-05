# [Examples of independence testing](@id examples_independence)


## [[`CorrTest`](@ref)](@id example_CorrTest)

```@example corrtest_example
using Associations
using Random; rng = Xoshiro(1234)

# Some normally distributed data
X = randn(rng, 1000) 
Y = 0.5*randn(rng, 1000) .+ X
Z = 0.5*randn(rng, 1000) .+ Y
W = randn(rng, 1000);
```

Let's test a few independence relationships. For example, we expect that `X ⫫ W`.
We also expect dependence `X !⫫ Z`, but this dependence should vanish when
conditioning on the intermediate variable, so we expect `X ⫫ Z | Y`.

```@example corrtest_example
independence(CorrTest(), X, W)
```

As expected, the outcome is that we can't reject the null hypothesis that `X ⫫ W`.

```@example corrtest_example
independence(CorrTest(), X, Z)
```

However, we *can* reject the  null hypothesis that `X ⫫ Z`, so the evidence favors
the alternative hypothesis `X !⫫ Z`.

```@example corrtest_example
independence(CorrTest(), X, Z, Y)
```

As expected, the correlation between `X` and `Z` significantly vanishes when conditioning
on `Y`, because `Y` is solely responsible for the observed correlation between `X` and `Y`.

## [[`JointDistanceDistributionTest`](@ref)](@id examples_independence_JointDistanceDistributionTest)

### Bidirectionally coupled logistic maps

Let's use the built-in `logistic2_bidir` discrete dynamical system to create a pair of
bidirectionally coupled time series and use the [`JointDistanceDistributionTest`](@ref)
to see if we can confirm from observed time series that these variables are
bidirectionally coupled. We'll use a significance level of `1 - α = 0.99`, i.e. `α = 0.01`.

```@example examples_independence_JointDistanceDistributionTest
using Associations
using DynamicalSystemsBase
using Random; rng = Xoshiro(1234)
Base.@kwdef struct Logistic2Bidir{V, C1, C2, R1, R2, Σx, Σy, R}
    xi::V = [0.5, 0.5]
    c_xy::C1 = 0.1
    c_yx::C2 = 0.1
    r₁::R1 = 3.78
    r₂::R2 = 3.66
    σ_xy::Σx = 0.05
    σ_yx::Σy = 0.05
    rng::R = Random.default_rng()
end

function system(definition::Logistic2Bidir)
    return DiscreteDynamicalSystem(eom_logistic2bidir, definition.xi, definition)
end

function eom_logistic2bidir(u, p::Logistic2Bidir, t)
    (; xi, c_xy, c_yx, r₁, r₂, σ_xy, σ_yx, rng) = p
    x, y = u
    f_xy = (y +  c_xy*(x + σ_xy * rand(rng)) ) / (1 + c_xy*(1+σ_xy))
    f_yx = (x +  c_yx*(y + σ_yx * rand(rng)) ) / (1 + c_yx*(1+σ_yx))
    dx = r₁ * (f_yx) * (1 - f_yx)
    dy = r₂ * (f_xy) * (1 - f_xy)
    return SVector{2}(dx, dy)
end
```

We start by generating some time series and configuring the test.

```@example examples_independence_JointDistanceDistributionTest
using Associations
sys = system(Logistic2Bidir(c_xy = 0.5, c_yx = 0.4))
x, y = columns(first(trajectory(sys, 2000, Ttr = 10000)))
measure = JointDistanceDistribution(D = 5, B = 5)
test = JointDistanceDistributionTest(measure)
```

Now, we test for independence in both directions.

```@example examples_independence_JointDistanceDistributionTest
independence(test, x, y)
```

```@example examples_independence_JointDistanceDistributionTest
independence(test, y, x)
```

As expected, the null hypothesis is rejected in both directions at the pre-determined 
significance level, and hence we detect directional coupling in both directions.

### Non-coupled logistic maps

What happens in the example above if there is no coupling?

```@example examples_independence_JointDistanceDistributionTest
sys = system(Logistic2Bidir(c_xy = 0.00, c_yx = 0.0))
x, y = columns(first(trajectory(sys, 1000, Ttr = 10000)));
rxy = independence(test, x, y)
ryx = independence(test, y, x)
pvalue(rxy), pvalue(ryx)
```

At significance level `0.99`, we can't reject the null in either direction, hence there's not
enough evidence in the data to suggest directional coupling.

## [[`SurrogateAssociationTest`](@ref)](@id examples_surrogatetest)

### [Chatterjee correlation](@id example_SurrogateAssociationTest_ChatterjeeCorrelation)

```@example example_SurrogateAssociationTest_ChatterjeeCorrelation
using Associations
using Random; rng = Xoshiro(1234)
n = 1000
x, y = rand(1:50, n), rand(1:50, n)
test = SurrogateAssociationTest(ChatterjeeCorrelation(), nshuffles = 19)
independence(test, x, y)
```

As expected, the test indicates that we can't reject independence. What happens if we introduce
a third variable that depends on `y`?

```@example example_SurrogateAssociationTest_ChatterjeeCorrelation
z = rand(1:20, n) .* y
independence(test, y, z)
```

The test clearly picks up on the functional dependence.


### [Azadkia-Chatterjee coefficient](@id example_SurrogateAssociationTest_AzadkiaChatterjeeCoefficient)

```@example example_SurrogateAssociationTest_AzadkiaChatterjeeCoefficient
using Associations
using Random; rng = Xoshiro(1234)
n = 1000
# Some categorical variables (we add a small amount of noise to avoid duplicate points 
# during neighbor searches)
x = rand(rng, 1.0:50.0, n) .+ rand(n) .* 1e-8
y = rand(rng, 1.0:50.0, n) .+ rand(n) .* 1e-8
test = SurrogateAssociationTest(AzadkiaChatterjeeCoefficient(), nshuffles = 19)
independence(test, x, y)
```

As expected, the test indicates that we can't reject independence. What happens if we introduce
a third variable that depends on `y`?

```@example example_SurrogateAssociationTest_AzadkiaChatterjeeCoefficient
z = rand(rng, 1.0:20.0, n) .* y
independence(test, y, z)
```

The test clearly picks up on the functional dependence. But what about conditioning?
Let's define three variables where `x → y → z`. When then expect significant association between `x` and `y`, possibly between `x` and `z` (depending on how strong the intermediate connection is), and 
non-significant association between `x` and `z` if conditioning on `y` (since `y` is the variable 
connecting `x` and `z`.) The Azadkia-Chatterjee coefficient also should be able to verify these 
claims.

```@example example_SurrogateAssociationTest_AzadkiaChatterjeeCoefficient
x = rand(rng, 120)
y = rand(rng, 120) .* x
z = rand(rng, 120) .+ y
independence(test, x, y)
```

The direct association between `x` and `y` is detected.

```@example example_SurrogateAssociationTest_AzadkiaChatterjeeCoefficient
independence(test, x, z)
```

The indirect association between `x` and `z` is also detected.

```@example example_SurrogateAssociationTest_AzadkiaChatterjeeCoefficient
independence(test, x, z, y)
```

We can't reject independence between `x` and `z` when taking into consideration 
`y`, as expected.


### [Distance correlation](@id example_SurrogateAssociationTest_DistanceCorrelation)

```@example
using Associations
x = randn(1000)
y = randn(1000) .+ 0.5x
independence(SurrogateAssociationTest(DistanceCorrelation()), x, y)
```

### [Partial correlation](@id example_SurrogateAssociationTest_PartialCorrelation)

```@example
using Associations
x = randn(1000)
y = randn(1000) .+ 0.5x
z = randn(1000) .+ 0.8y
independence(SurrogateAssociationTest(PartialCorrelation()), x, z, y)
```


### [[`SMeasure`](@ref)](@id example_SurrogateAssociationTest_SMeasure)

```@example example_SurrogateAssociationTest_SMeasure
using Associations
x, y = randn(1000), randn(1000)
measure = SMeasure(dx = 4, dy = 3)
s = association(measure,     x, y)
```

The `s` statistic is larger when there is stronger coupling and smaller
when there is weaker coupling. To check whether `s` is significant (i.e. large
enough to claim directional dependence), we can use a [`SurrogateAssociationTest`](@ref).

```@example example_SurrogateAssociationTest_SMeasure
test = SurrogateAssociationTest(measure)
independence(test, x, y)
```

The p-value is high, and we can't reject the null at any reasonable significance level.
Hence, there isn't evidence in the data to support directional coupling from `x` to `y`.

What happens if we use coupled variables?

```@example example_SurrogateAssociationTest_SMeasure
z = x .+ 0.1y
independence(test, x, z)
```

Now we can confidently reject the null (independence), and conclude that there is
evidence in the data to support directional dependence from `x` to `z`.


### [[`MIShannon`](@ref), categorical](@id example_SurrogateAssociationTest_MIShannon_categorical)

In this example, we expect the `preference` and the `food` variables to be independent.

```@example example_SurrogateAssociationTest_MIShannon_categorical
using Associations
using Random; rng = Xoshiro(1234)
# Simulate 
n = 1000
preference = rand(rng, ["yes", "no"], n)
food = rand(rng, ["veggies", "meat", "fish"], n)
est = JointProbabilities(MIShannon(), CodifyVariables(UniqueElements()))
test = SurrogateAssociationTest(est)
independence(test, preference, food)
```

As expected, there's not enough evidence to reject the null hypothesis that the
variables are independent.

### [[`CMIShannon`](@ref), categorical](@id example_SurrogateAssociationTest_CMIShannon_categorical)

Here, we simulate a survey at a ski resort. The data are such that the place a person
grew up is associated with how many times they fell while going skiing. The control
happens through an intermediate variable `preferred_equipment`, which indicates what
type of physical activity the person has engaged with in the past. Some activities
like skateboarding leads to better overall balance, so people that are good on
a skateboard also don't fall, and people that to less challenging activities fall
more often.

We should be able to reject `places ⫫ experience`, but not reject
`places ⫫ experience | preferred_equipment`.  Let's see if we can detect these
relationships using (conditional) mutual information.

```@example indep_cmi
using Associations
using Random; rng = Xoshiro(1234)
n = 1000

places = rand(rng, ["city", "countryside", "under a rock"], n);
preferred_equipment = map(places) do place
    if cmp(place, "city") == 1
        return rand(rng, ["skateboard", "bmx bike"])
    elseif cmp(place, "countryside") == 1
        return rand(rng, ["sled", "snowcarpet"])
    else
        return rand(rng, ["private jet", "ferris wheel"])
    end
end;
experience = map(preferred_equipment) do equipment
    if equipment ∈ ["skateboard", "bmx bike"]
        return "didn't fall"
    elseif equipment ∈ ["sled", "snowcarpet"]
        return "fell 3 times or less"
    else
        return "fell uncontably many times"
    end
end;
est_mi = JointProbabilities(MIShannon(), CodifyVariables(UniqueElements()))
test = SurrogateAssociationTest(est_mi)
independence(test, places, experience)
```

As expected, the evidence favors the alternative hypothesis that `places` and 
`experience` are dependent.

```@example  indep_cmi
est_cmi = JointProbabilities(CMIShannon(), CodifyVariables(UniqueElements()))
test = SurrogateAssociationTest(est_cmi)
independence(test, places, experience, preferred_equipment)
```

Again, as expected, when conditioning on the mediating variable, the dependence disappears,
and we can't reject the null hypothesis of independence.

### [[`MCR`](@ref)](@id example_independence_MCR)

```@example
using Associations
using Random; rng = Xoshiro(1234)

x = rand(rng, 300)
y = rand(rng, 300)
test = SurrogateAssociationTest(MCR(r = 0.5); rng, nshuffles = 100, surrogate = RandomShuffle())
independence(test, x, y)
```

As expected, we can't reject independence. What happens if two variables are coupled?

```@example
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 300)
z = x .+ rand(rng, 300)
test = SurrogateAssociationTest(MCR(r = 0.5); rng, nshuffles = 100, surrogate = RandomShuffle())
independence(test, x, z)
```

Now, because the variables are coupled, the evidence in the data support dependence.


## [[`LocalPermutationTest`](@ref)](@id example_LocalPermutationTest)

To demonstrate the local permutation test for independence, we'll again use the 
chain of unidirectionally coupled logistic maps.

We'll implement a set of chained logistic maps with unidirectional coupling.

```@example example_LocalPermutationTest
using DynamicalSystemsBase
Base.@kwdef struct Logistic4Chain{V, RX, RY, RZ, RW, C1, C2, C3, Σ1, Σ2, Σ3, RNG}
    xi::V = [0.1, 0.2, 0.3, 0.4]
    rx::RX = 3.9
    ry::RY = 3.6
    rz::RZ = 3.6
    rw::RW = 3.8
    c_xy::C1 = 0.4
    c_yz::C2 = 0.4
    c_zw::C3 = 0.35
    σ_xy::Σ1 = 0.05
    σ_yz::Σ2 = 0.05
    σ_zw::Σ3 = 0.05
    rng::RNG = Random.default_rng()
end

function eom_logistic4_chain(u, p::Logistic4Chain, t)
    (; xi, rx, ry, rz, rw, c_xy, c_yz, c_zw, σ_xy, σ_yz, σ_zw, rng) = p
    x, y, z, w = u
    f_xy = (y +  c_xy*(x + σ_xy * rand(rng)) ) / (1 + c_xy*(1+σ_xy))
    f_yz = (z +  c_yz*(y + σ_yz * rand(rng)) ) / (1 + c_yz*(1+σ_yz))
    f_zw = (w +  c_zw*(z + σ_zw * rand(rng)) ) / (1 + c_zw*(1+σ_zw))
    dx = rx * x * (1 - x)
    dy = ry * (f_xy) * (1 - f_xy)
    dz = rz * (f_yz) * (1 - f_yz)
    dw = rw * (f_zw) * (1 - f_zw)
    return SVector{4}(dx, dy, dz, dw)
end


function system(definition::Logistic4Chain)
    return DiscreteDynamicalSystem(eom_logistic4_chain, definition.xi, definition)
end
```

### [[`CMIShannon`](@ref)](@id example_LocalPermutationTest_CMIShannon)

To estimate CMI, we'll use the [`Kraskov`](@ref) differential
entropy estimator, which naively computes CMI as a sum of entropy terms without guaranteed
bias cancellation.

```@example example_LocalPermutationTest
using Associations
using Random; rng = Xoshiro(1234)
n = 100
X = randn(rng, n)
Y = X .+ randn(rng, n) .* 0.4
Z = randn(rng, n) .+ Y
x, y, z = StateSpaceSet.((X, Y, Z))
test = LocalPermutationTest(FPVP(CMIShannon()), nshuffles = 19)
independence(test, x, y, z)
```

We expect there to be a detectable influence from ``X`` to
``Y``, if we condition on ``Z`` or not, because ``Z`` doesn't influence neither ``X`` nor ``Y``.
The null hypothesis is that the first two variables are conditionally independent given the third, which we reject with a very low p-value. Hence, we accept the alternative
hypothesis that the first two variables ``X`` and ``Y``. are conditionally *dependent* given ``Z``.

```@example example_LocalPermutationTest
independence(test, x, z, y)
```

As expected, we cannot reject the null hypothesis that ``X`` and ``Z`` are conditionally independent given ``Y``, because ``Y`` is the variable that transmits information from
``X`` to ``Z``.

### [[`TEShannon`](@ref)](@id example_LocalPermutationTest_TEShannon)

Here, we demonstrate [`LocalPermutationTest`](@ref) with the [`TEShannon`](@ref) measure
with default parameters and the [`FPVP`](@ref) estimator. We'll use the system
of four coupled logistic maps that are linked `X → Y → Z → W` defined
[above](@ref example_LocalPermutationTest).

We should expect the transfer entropy `X → Z`
to be non-significant when conditioning on `Y`, because all information from `X` to `Z`
is transferred through `Y`.

```@example example_LocalPermutationTest
using Associations
using Random; rng = Random.default_rng()
n = 300
sys = system(Logistic4Chain(; xi = rand(rng, 4), rng))
x, y, z, w = columns(trajectory(sys, n) |> first)
est = CMIDecomposition(TEShannon(), FPVP(k = 10))
test = LocalPermutationTest(est, nshuffles = 19)
independence(test, x, z, y)
```

As expected, we cannot reject the null hypothesis that `X` and `Z` are conditionally
independent given `Y`.

The same goes for variables one step up the chain:

```@example example_LocalPermutationTest
independence(test, y, w, z)
```


### [[`AzadkiaChatterjeeCoefficient`](@ref)](@id example_LocalPermutationTest_AzadkiaChatterjeeCoefficient)

```@example example_LocalPermutationTest_AzadkiaChatterjeeCoefficient
using Associations
using Random; rng = Xoshiro(1234)
n = 300
# Some categorical variables (we add a small amount of noise to avoid duplicate points 
# during neighbor searches)
test = LocalPermutationTest(AzadkiaChatterjeeCoefficient(), nshuffles = 19)
x = rand(rng, n)
y = rand(rng, n) .* x
z = rand(rng, n) .+ y
```

Let's define three variables where `x → y → z`. We expect a 
non-significant association between `x` and `z` if conditioning on `y` (since `y` is the variable 
connecting `x` and `z`.) 

```@example example_LocalPermutationTest_AzadkiaChatterjeeCoefficient
independence(test, x, z, y)
```

The test verifies our expectation.
## [[`SECMITest`](@ref)](@id example_SECMITEST)

## [[`JointProbabilities`](@ref) estimation on numeric data](@id example_SECMITEST_JointProbabilities_CodifyVariables_ValueBinning)

```@example example_SECMITEst
using Associations
using Test
using Random; rng = Xoshiro(1234)
n = 25
x = rand(rng, n)
y = randn(rng, n) .+ x .^ 2
z = randn(rng, n) .* y

# An estimator for estimating the SECMI measure
est = JointProbabilities(SECMI(base = 2), CodifyVariables(ValueBinning(3)))
test = SECMITest(est; nshuffles = 19)
```

When analyzing ``SECMI(x, y | z)``, the expectation is to reject the null hypothesis (independence), since `x` and `y` are connected, regardless of the effect of `z`.

```@example example_SECMITEst
independence(test, x, y, z)
```

We can detect this association, even for `n = 25`! When analyzing ``SECMI(x, z | y)``, we 
expect that we can't reject the null (indepdendence), precisely since `x` and `z` are *not* 
connected when "conditioning away" `y`.

```@example example_SECMITEst
independence(test, x, z, y)
```

## [[`JointProbabilities`](@ref) estimation on categorical data](@id example_SECMITEST_JointProbabilities_CodifyVariables_UniqueElements)

Note that this also works for categorical variables. Just use [`UniqueElements`](@ref) to 
discretize!

```@example example_SECMITest_categorical
using Associations
using Test
using Random; rng = Xoshiro(1234)
n = 24
x = rand(rng, ["vegetables", "candy"], n)
y = [xᵢ == "candy" && rand(rng) > 0.3 ? "yummy" : "yuck" for xᵢ in x]
z = [yᵢ == "yummy" && rand(rng) > 0.6 ? "grown-up" : "child" for yᵢ in y]
d = CodifyVariables(UniqueElements())
est = JointProbabilities(SECMI(base = 2), d)

independence(SECMITest(est; nshuffles = 19), x, z, y)
```