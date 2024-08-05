# [Examples of association measure estimation](@id examples_associations)

## [`HellingerDistance`](@ref)

### [From precomputed probabilities](@id example_HellingerDistance_precomputed_probabilities)

```@example example_HellingerDistance
using Associations
# From pre-computed PMFs
p1 = Probabilities([0.1, 0.5, 0.2, 0.2])
p2 = Probabilities([0.3, 0.3, 0.2, 0.2])
association(HellingerDistance(), p1, p2)
```

### [[`JointProbabilities`](@ref) + [`OrdinalPatterns`](@ref)](@id example_HellingerDistance_JointProbabilities_OrdinalPatterns)

We expect the Hellinger distance between two uncorrelated variables to be close to zero.

```@example example_HellingerDistance
using Associations
using Random; rng = Xoshiro(1234)
n = 100000
x, y = rand(rng, n), rand(rng, n)
est = JointProbabilities(HellingerDistance(), CodifyVariables(OrdinalPatterns(m=3)))
div_hd = association(est, x, y) # pretty close to zero
```

## [`KLDivergence`](@ref)

### [From precomputed probabilities](@id example_KLDivergence_precomputed_probabilities)

```@example example_KLDivergence
using Associations
# From pre-computed PMFs
p1 = Probabilities([0.1, 0.5, 0.2, 0.2])
p2 = Probabilities([0.3, 0.3, 0.2, 0.2])
association(KLDivergence(), p1, p2)
```

### [[`JointProbabilities`](@ref) + [`OrdinalPatterns`](@ref)](@id example_KLDivergence_JointProbabilities_OrdinalPatterns)

We expect the [`KLDivergence`](@ref) between two uncorrelated variables to be close to zero.

```@example example_KLDivergence
using Associations
using Random; rng = Xoshiro(1234)
n = 100000
x, y = rand(rng, n), rand(rng, n)
est = JointProbabilities(KLDivergence(), CodifyVariables(OrdinalPatterns(m=3)))
div_hd = association(est, x, y) # pretty close to zero
```


## [`RenyiDivergence`](@ref)

### [From precomputed probabilities](@id example_RenyiDivergence_precomputed_probabilities)

```@example example_RenyiDivergence
using Associations
# From pre-computed PMFs
p1 = Probabilities([0.1, 0.5, 0.2, 0.2])
p2 = Probabilities([0.3, 0.3, 0.2, 0.2])
association(RenyiDivergence(), p1, p2)
```

### [[`JointProbabilities`](@ref) + [`OrdinalPatterns`](@ref)](@id example_RenyiDivergence_JointProbabilities_OrdinalPatterns)

We expect the [`RenyiDivergence`](@ref) between two uncorrelated variables to be close to zero.

```@example example_RenyiDivergence
using Associations
using Random; rng = Xoshiro(1234)
n = 100000
x, y = rand(rng, n), rand(rng, n)
est = JointProbabilities(RenyiDivergence(), CodifyVariables(OrdinalPatterns(m=3)))
div_hd = association(est, x, y) # pretty close to zero
```


## [`VariationDistance`](@ref)

### [From precomputed probabilities](@id example_VariationDistance_precomputed_probabilities)

```@example example_VariationDistance
using Associations
# From pre-computed PMFs
p1 = Probabilities([0.1, 0.5, 0.2, 0.2])
p2 = Probabilities([0.3, 0.3, 0.2, 0.2])
association(VariationDistance(), p1, p2)
```

### [[`JointProbabilities`](@ref) + [`OrdinalPatterns`](@ref)](@id example_VariationDistance_JointProbabilities_OrdinalPatterns)

We expect the [`VariationDistance`](@ref) between two uncorrelated variables to be close to zero.

```@example example_VariationDistance
using Associations
using Random; rng = Xoshiro(1234)
n = 100000
x, y = rand(rng, n), rand(rng, n)
est = JointProbabilities(VariationDistance(), CodifyVariables(OrdinalPatterns(m=3)))
div_hd = association(est, x, y) # pretty close to zero
```

## [`JointEntropyShannon`](@ref)

### [[`JointProbabilities`](@ref) with [`Dispersion`](@ref)](@id example_JointEntropyShannon_Dispersion)

```@example example_JointEntropyShannon
using Associations
using Random; rng = Xoshiro(1234)
x, y = rand(rng, 100), rand(rng, 100)
measure = JointEntropyShannon()
discretization = CodifyVariables(Dispersion(m = 2, c = 3))
est = JointProbabilities(measure, discretization)
association(est, x, y)
```

## [`JointEntropyTsallis`](@ref)

### [[`JointProbabilities`](@ref) with [`OrdinalPatterns`](@ref)](@id example_JointEntropyTsallis_OrdinalPatterns)

```@example example_JointEntropyTsallis
using Associations
using Random; rng = Xoshiro(1234)
x, y = rand(rng, 100), rand(rng, 100)
measure = JointEntropyTsallis()
discretization = CodifyVariables(OrdinalPatterns(m = 3))
est = JointProbabilities(measure, discretization)
association(est, x, y)
```


## [`JointEntropyRenyi`](@ref)

### [[`JointProbabilities`](@ref) with [`OrdinalPatterns`](@ref)](@id example_JointEntropyRenyi_ValueBinning)

```@example example_JointEntropyRenyi
using Associations
using Random; rng = Xoshiro(1234)
x, y = rand(rng, 100), rand(rng, 100)
measure = JointEntropyRenyi(q = 0.5)
discretization = CodifyVariables(ValueBinning(2))
est = JointProbabilities(measure, discretization)
association(est, x, y)
```

## [`ConditionalEntropyShannon`](@ref)

### [Analytical examples](@id example_ConditionalEntropyShannon_analytical)

This is essentially example 2.2.1 in Cover & Thomas (2006), where they use the following
relative frequency table as an example. Notethat Julia is column-major, so we need to
transpose their example. Then their `X` is in the first dimension of our table (along
columns) and their `Y` is our second dimension (rows).

```@example ce_contingency_table
using Associations
freqs_yx = [1//8 1//16 1//32 1//32; 
    1//16 1//8  1//32 1//32;
    1//16 1//16 1//16 1//16; 
    1//4  0//1  0//1  0//1];
# `freqs_yx` is already normalized, se we can feed it directly to `Probabilities`
pxy = Probabilities(freqs_yx)
```

The marginal distribution for `x` (first dimension) is

```@example ce_contingency_table
marginal(pxy, dims = 2)
```

The marginal distribution for `y` (second dimension) is

```@example ce_contingency_table
marginal(pxy, dims = 1)
```

And the Shannon conditional entropy ``H^S(X | Y)``

```@example ce_contingency_table
ce_x_given_y = association(ConditionalEntropyShannon(), pxy) |> Rational
```

This is the same as in their example. Hooray! To compute ``H^S(Y | X)``, we just need to
flip the contingency matrix.

```@example ce_contingency_table
pyx = Probabilities(transpose(freqs_yx))
ce_y_given_x = association(ConditionalEntropyShannon(), pyx) |> Rational
```

### [[`JointProbabilities`](@ref) + [`CodifyVariables`](@ref) + [`UniqueElements`](@ref)](@id example_ConditionalEntropyShannon_JointProbabilities_CodifyVariables_UniqueElements)

We can of course also estimate conditional entropy from data. To do so, we'll use the 
[`JointProbabilities`](@ref) estimator, which constructs a multivariate PMF for us.
Thus, we don't explicitly need a set of counts, like in the example above, because they
are estimated under the hood for us. 

Let's first demonstrate on some categorical data. For that, we must use
[`UniqueElements`](@ref) as the discretization (i.e. just count unique elements).

```@example example_ConditionalEntropyShannon_JointProbabilities_CodifyVariables_UniqueElements
using Associations
using Random; rng = Xoshiro(1234)
n = 1000
rating = rand(rng, 1:6, n)
movie = rand(rng, ["The Witcher: the movie", "Lord of the Rings"], n)

disc = CodifyVariables(UniqueElements())
est = JointProbabilities(ConditionalEntropyShannon(), disc)
association(est, rating, movie)
```

### [[`JointProbabilities`](@ref) + [`CodifyPoints`](@ref) + [`UniqueElementsEncoding`](@ref)](@id example_ConditionalEntropyShannon_JointProbabilities_CodifyPoints_UniqueElementsEncoding)

```@example example_ConditionalEntropyShannon_JointProbabilities_CodifyPoints_UniqueElementsEncoding
using Associations
using Random; rng = Xoshiro(1234)
x, y, z = rand(rng, 1:5, 100), rand(rng, 1:5, 100), rand(rng, 1:3, 100)
X = StateSpaceSet(x, z)
Y = StateSpaceSet(y, z)
disc = CodifyPoints(UniqueElementsEncoding(X), UniqueElementsEncoding(Y));
est = JointProbabilities(ConditionalEntropyShannon(), disc);
association(est, X, Y)
```

## [`ConditionalEntropyTsallisAbe`](@ref)

### [[`JointProbabilities`](@ref) + [`CodifyVariables`](@ref) + [`UniqueElements`](@ref)](@id example_ConditionalEntropyTsallisAbe_JointProbabilities_CodifyVariables_UniqueElements)

We'll here repeat the analysis we did for [`ConditionalEntropyShannon`](@ref) above.

```@example example_ConditionalEntropyTsallisAbe_JointProbabilities_CodifyVariables_UniqueElements
using Associations
using Random; rng = Xoshiro(1234)
n = 1000
rating = rand(rng, 1:6, n)
movie = rand(rng, ["The Witcher: the movie", "Lord of the Rings"], n)

disc = CodifyVariables(UniqueElements())
est = JointProbabilities(ConditionalEntropyTsallisAbe(q =1.5), disc)
association(est, rating, movie)
```

### [[`JointProbabilities`](@ref) + [`CodifyPoints`](@ref) + [`UniqueElementsEncoding`](@ref)](@id example_ConditionalEntropyTsallisAbe_JointProbabilities_CodifyPoints_UniqueElementsEncoding)

```@example example_ConditionalEntropyTsallisAbe_JointProbabilities_CodifyPoints_UniqueElementsEncoding
using Associations
using Random; rng = Xoshiro(1234)
x, y, z = rand(rng, 1:5, 100), rand(rng, 1:5, 100), rand(rng, 1:3, 100)
X = StateSpaceSet(x, z)
Y = StateSpaceSet(y, z)
disc = CodifyPoints(UniqueElementsEncoding(X), UniqueElementsEncoding(Y));
est = JointProbabilities(ConditionalEntropyTsallisAbe(q = 1.5), disc);
association(est, X, Y)
```


## [`ConditionalEntropyTsallisFuruichi`](@ref)

### [[`JointProbabilities`](@ref) + [`CodifyVariables`](@ref) + [`UniqueElements`](@ref)](@id example_ConditionalEntropyTsallisFuruichi_JointProbabilities_CodifyVariables_UniqueElements)

We'll here repeat the analysis we did for [`ConditionalEntropyShannon`](@ref) and [`ConditionalEntropyTsallisAbe`](@ref) above.

```@example example_ConditionalEntropyTsallisFuruichi_JointProbabilities_CodifyVariables_UniqueElements
using Associations
using Random; rng = Xoshiro(1234)
n = 1000
rating = rand(rng, 1:6, n)
movie = rand(rng, ["The Witcher: the movie", "Lord of the Rings"], n)

disc = CodifyVariables(UniqueElements())
est = JointProbabilities(ConditionalEntropyTsallisFuruichi(q =0.5), disc)
association(est, rating, movie)
```

### [[`JointProbabilities`](@ref) + [`CodifyPoints`](@ref) + [`UniqueElementsEncoding`](@ref)](@id example_ConditionalEntropyTsallisFuruichi_JointProbabilities_CodifyPoints_UniqueElementsEncoding)

```@example example_ConditionalEntropyTsallisFuruichi_JointProbabilities_CodifyPoints_UniqueElementsEncoding
using Associations
using Random; rng = Xoshiro(1234)
x, y, z = rand(rng, 1:5, 100), rand(rng, 1:5, 100), rand(rng, 1:3, 100)
X = StateSpaceSet(x, z)
Y = StateSpaceSet(y, z)
disc = CodifyPoints(UniqueElementsEncoding(X), UniqueElementsEncoding(Y));
est = JointProbabilities(ConditionalEntropyTsallisFuruichi(q = 0.5), disc);
association(est, X, Y)
```


## [`MIShannon`](@ref)

### [[`JointProbabilities`](@ref) + [`ValueBinning`](@ref)](@id example_MIShannon_JointProbabilities_ValueBinning)

```@example mi_demonstration
using Associations
using Random; rng = MersenneTwister(1234)
x = rand(rng, 1000)
y = rand(rng, 1000)
discretization = CodifyVariables(ValueBinning(FixedRectangularBinning(0, 1, 5)))
est = JointProbabilities(MIShannon(), discretization)
association(est, x, y)
```


### [[`JointProbabilities`](@ref) + [`UniqueElements`](@ref)](@id example_MIShannon_JointProbabilities_UniqueElements)

The [`JointProbabilities`](@ref) estimator can also be used with categorical data.
For example, let's compare the Shannon mutual information between the preferences
of a population sample with regards to different foods.

```@example mi_demonstration
using Associations
n = 1000
preferences = rand(["neutral", "like it", "hate it"], n);
random_foods = rand(["water", "flour", "bananas", "booze", "potatoes", "beans", "soup"], n)
biased_foods = map(preferences) do preference
    if cmp(preference, "neutral") == 1
        return rand(["water", "flour"])
    elseif cmp(preference, "like it") == 1
        return rand(["bananas", "booze"])
    else
        return rand(["potatoes", "beans", "soup"])
    end
end

est = JointProbabilities(MIShannon(), UniqueElements())
association(est, preferences, biased_foods), association(est, preferences, random_foods)
```

### [Dedicated [`GaussianMI`](@ref) estimator](@id example_MIShannon_GaussianMI)

```@example mi_demonstration
using Associations
using Distributions
using Statistics

n = 1000
using Associations
x = randn(1000)
y = rand(1000) .+ x
association(GaussianMI(MIShannon()), x, y) # defaults to `MIShannon()`
```

### [Dedicated [`KraskovStögbauerGrassberger1`](@ref) estimator](@id example_MIShannon_KSG1)

```@example mi_demonstration
using Associations
x, y = rand(1000), rand(1000)
association(KSG1(MIShannon(); k = 5), x, y)
```

### [Dedicated [`KraskovStögbauerGrassberger2`](@ref) estimator](@id example_MIShannon_KSG2)

```@example mi_demonstration
using Associations
x, y = rand(1000), rand(1000)
association(KSG2(MIShannon(); k = 5), x, y)
```

### [Dedicated [`GaoKannanOhViswanath`](@ref) estimator](@id example_MIShannon_GaoKannanOhViswanath)

```@example mi_demonstration
using Associations
x, y = rand(1000), rand(1000)
association(GaoKannanOhViswanath(MIShannon(); k = 10), x, y)
```

### [[`EntropyDecomposition`](@ref) + [`Kraskov`](@ref)](@id example_MIShannon_EntropyDecomposition_Kraskov)

We can compute [`MIShannon`](@ref) by naively applying a [`DifferentialInfoEstimator`](@ref).
Note that this doesn't apply any bias correction.

```@example mi_demonstration
using Associations
x, y = rand(1000), rand(1000)
association(EntropyDecomposition(MIShannon(), Kraskov(k = 3)), x, y)
```


### [[`EntropyDecomposition`](@ref) + [`BubbleSortSwaps`](@ref)](@id example_MIShannon_EntropyDecomposition_BubbleSortSwaps)

We can also compute [`MIShannon`](@ref) by naively applying a [`DiscreteInfoEstimator`](@ref).
Note that this doesn't apply any bias correction.

```@example mi_demonstration
using Associations
x, y = rand(1000), rand(1000)
disc = CodifyVariables(BubbleSortSwaps(m=5))
hest = PlugIn(Shannon())
association(EntropyDecomposition(MIShannon(), hest, disc), x, y)
```


### [[`EntropyDecomposition`](@ref) + [`Jackknife`](@ref) + [`ValueBinning`](@ref)](@id example_MIShannon_EntropyDecomposition_Jackknife_ValueBinning)

Shannon mutual information can be written as a sum of marginal entropy terms.
Here, we use [`CodifyVariables`](@ref) with [`ValueBinning`](@ref) bin the data 
and compute discrete Shannon mutual information.

```@example mi_demonstration
using Associations
using Random; rng = MersenneTwister(1234)
x = rand(rng, 50)
y = rand(rng, 50)

# Use the H3-estimation method with a discrete visitation frequency based 
# probabilities estimator over a fixed grid covering the range of the data,
# which is on [0, 1].
discretization = CodifyVariables(ValueBinning(FixedRectangularBinning(0, 1, 5)))
hest = Jackknife(Shannon())
est = EntropyDecomposition(MIShannon(), hest, discretization)
association(est, x, y)
```


### [Reproducing Kraskov et al. (2004)](@id example_MIShannon_reproducing_Kraskov)

Here, we'll reproduce Figure 4 from [Kraskov2004](@citet)'s seminal paper on the nearest-neighbor based mutual information estimator. We'll estimate the mutual information
between marginals of a bivariate Gaussian for a fixed time series length of 1000,
varying the number of neighbors. *Note: in the original paper, they show multiple
curves corresponding to different time series length. We only show two single curves:
one for the [`KraskovStögbauerGrassberger1`](@ref) estimator and one for the [`KraskovStögbauerGrassberger2`](@ref) estimator*.

```@example ex_mutualinfo
using Associations
using LinearAlgebra: det
using Distributions: MvNormal
using StateSpaceSets: StateSpaceSet
using CairoMakie
using Statistics

N = 800
c = 0.9
Σ = [1 c; c 1]
N2 = MvNormal([0, 0], Σ)
mitrue = -0.5*log(det(Σ)) # in nats
ks = [2; 5; 7; 10:10:70] .* 2

nreps = 10 # plot average over 10 independent realizations
mis_ksg1 = zeros(nreps, length(ks))
mis_ksg2 = zeros(nreps, length(ks))
for i = 1:nreps
    D2 = StateSpaceSet([rand(N2) for i = 1:N])
    X = D2[:, 1] |> StateSpaceSet
    Y = D2[:, 2] |> StateSpaceSet
    for (j, k) in enumerate(ks)
        est1 = KSG1(MIShannon(; base = ℯ); k)
        est2 = KSG2(MIShannon(; base = ℯ); k)
        mis_ksg1[i, j] = association(est1, X, Y)
        mis_ksg2[i, j] = association(est2, X, Y)
    end
end
fig = Figure()
ax = Axis(fig[1, 1], xlabel = "k / N", ylabel = "Mutual infomation (nats)")
scatterlines!(ax, ks ./ N, mean(mis_ksg1, dims = 1) |> vec, label = "KSG1")
scatterlines!(ax, ks ./ N, mean(mis_ksg2, dims = 1) |> vec, label = "KSG2")
hlines!(ax, [mitrue], color = :black, linewidth = 3, label = "I (true)")
axislegend()
fig
```


### Estimator comparison for [`MIShannon`](@ref)

Most estimators suffer from significant bias when applied to discrete, finite data. One possible resolution is to add a small amount of noise to discrete variables, so that the data becomes continuous in practice.

But instead of adding noise to your data, you can also consider using an
estimator that is specifically designed to deal with continuous-discrete mixture data. 
One example is the [`GaoKannanOhViswanath`](@ref) estimator. Below, we compare its
performance to [`KraskovStögbauerGrassberger1`](@ref) on uniformly distributed discrete multivariate data.
The true mutual information is zero. While the "naive" [`KraskovStögbauerGrassberger1`](@ref) estimator 
diverges from the true value for these data, the [`GaoKannanOhViswanath`](@ref)
converges to the true value.

```@example ex_mutualinfo
using Associations
using Statistics
using StateSpaceSets: StateSpaceSet
using Statistics: mean
using CairoMakie

function compare_ksg_gkov(;
        k = 5,
        base = 2,
        nreps = 10,
        Ls = [500:100:1000; 1500; 2500; 5000; 7000])


    mis_ksg1_mix = zeros(nreps, length(Ls))
    mis_ksg1_discrete = zeros(nreps, length(Ls))
    mis_ksg1_cont = zeros(nreps, length(Ls))
    mis_gkov_mix = zeros(nreps, length(Ls))
    mis_gkov_discrete = zeros(nreps, length(Ls))
    mis_gkov_cont = zeros(nreps, length(Ls))

    for (j, L) in enumerate(Ls)
        for i = 1:nreps
            X = StateSpaceSet(float.(rand(1:8, L, 2)))
            Y = StateSpaceSet(float.(rand(1:8, L, 2)))
            Z = StateSpaceSet(rand(L, 2))
            W = StateSpaceSet(rand(L, 2))
            est_gkov = GaoKannanOhViswanath(MIShannon(; base = ℯ); k)
            est_ksg1 = KSG1(MIShannon(; base = ℯ); k)
            mis_ksg1_discrete[i, j] = association(est_ksg1, X, Y)
            mis_gkov_discrete[i, j] = association(est_gkov, X, Y)
            mis_ksg1_mix[i, j] = association(est_ksg1, X, Z)
            mis_gkov_mix[i, j] = association(est_gkov, X, Z)
            mis_ksg1_cont[i, j] = association(est_ksg1, Z, W)
            mis_gkov_cont[i, j] = association(est_gkov, Z, W)
        end
    end
    return mis_ksg1_mix, mis_ksg1_discrete, mis_ksg1_cont,
        mis_gkov_mix, mis_gkov_discrete, mis_gkov_cont
end

fig = Figure()
ax = Axis(fig[1, 1], 
    xlabel = "Sample size", 
    ylabel = "Mutual information (bits)")
Ls = [100; 200; 500; 1000; 2500; 5000; 7000]
nreps = 5
k = 3
mis_ksg1_mix, mis_ksg1_discrete, mis_ksg1_cont,
    mis_gkov_mix, mis_gkov_discrete, mis_gkov_cont = 
    compare_ksg_gkov(; nreps, k, Ls)

scatterlines!(ax, Ls, mean(mis_ksg1_mix, dims = 1) |> vec, 
    label = "KSG1 (mixed)", color = :black, 
    marker = :utriangle)
scatterlines!(ax, Ls, mean(mis_ksg1_discrete, dims = 1) |> vec, 
    label = "KSG1 (discrete)", color = :black, 
    linestyle = :dash, marker = '▲')
scatterlines!(ax, Ls, mean(mis_ksg1_cont, dims = 1) |> vec, 
    label = "KSG1 (continuous)", color = :black, 
    linestyle = :dot, marker = '●')
scatterlines!(ax, Ls, mean(mis_gkov_mix, dims = 1) |> vec, 
    label = "GaoKannanOhViswanath (mixed)", color = :red, 
    marker = :utriangle)
scatterlines!(ax, Ls, mean(mis_gkov_discrete, dims = 1) |> vec, 
    label = "GaoKannanOhViswanath (discrete)", color = :red, 
    linestyle = :dash, marker = '▲')
scatterlines!(ax, Ls, mean(mis_gkov_cont, dims = 1) |> vec, 
    label = "GaoKannanOhViswanath (continuous)", color = :red, 
    linestyle = :dot, marker = '●')
axislegend(position = :rb)
fig
```

### Estimation using [`DifferentialInfoEstimator`](@ref)s: a comparison

Let's compare the performance of a subset of the implemented mutual information estimators. We'll use example data from Lord et al., where the analytical mutual information is known.

```@example ex_mutualinfo
using Associations
using LinearAlgebra: det
using StateSpaceSets: StateSpaceSet
using Distributions: MvNormal
using LaTeXStrings
using CairoMakie

# adapted from https://juliadatascience.io/makie_colors
function new_cycle_theme()
    # https://nanx.me/ggsci/reference/pal_locuszoom.html
    my_colors = ["#D43F3AFF", "#EEA236FF", "#5CB85CFF", "#46B8DAFF",
        "#357EBDFF", "#9632B8FF", "#B8B8B8FF"]
    cycle = Cycle([:color, :linestyle, :marker], covary=true) # alltogether
    my_markers = [:circle, :rect, :utriangle, :dtriangle, :diamond,
        :pentagon, :cross, :xcross]
    my_linestyle = [nothing, :dash, :dot, :dashdot, :dashdotdot]
    return Theme(
        fontsize = 22, font="CMU Serif",
        colormap = :linear_bmy_10_95_c78_n256,
        palette = (
            color = my_colors, 
            marker = my_markers, 
            linestyle = my_linestyle,
        ),
        Axis = (
            backgroundcolor= (:white, 0.2), 
            xgridstyle = :dash, 
            ygridstyle = :dash
        ),
        Lines = (
            cycle= cycle,
        ), 
        ScatterLines = (
            cycle = cycle,
        ),
        Scatter = (
            cycle = cycle,
        ),
        Legend = (
            bgcolor = (:grey, 0.05), 
            framecolor = (:white, 0.2),
            labelsize = 13,
        )
    )
end

run(est; f::Function, # function that generates data
        base::Real = ℯ, 
        nreps::Int = 10, 
        αs = [1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1], 
        n::Int = 1000) =
    map(α -> association(est, f(α, n)...), αs)

function compute_results(f::Function; estimators, k = 5, k_lord = 20,
        n = 1000, base = ℯ, nreps = 10,
        as = 7:-1:0,
        αs = [1/10^(a) for a in as])
    
    is = [zeros(length(αs)) for est in estimators]
    for (k, est) in enumerate(estimators)
        tmp = zeros(length(αs))
        for i = 1:nreps
            tmp .+= run(est; f = f, αs, base, n)
        end
        is[k] .= tmp ./ nreps
    end

    return is
end

function plot_results(f::Function, ftrue::Function; 
        base, estimators, k_lord, k, 
        as = 7:-1:0, αs = [1/10^(a) for a in as], kwargs...
    )
    is = compute_results(f; 
        base, estimators, k_lord, k, as, αs, kwargs...)
    itrue = [ftrue(α; base) for α in αs]

    xmin, xmax = minimum(αs), maximum(αs)
    
    ymin = floor(Int, min(minimum(itrue), minimum(Iterators.flatten(is))))
    ymax = ceil(Int, max(maximum(itrue), maximum(Iterators.flatten(is))))
    f = Figure()
    ax = Axis(f[1, 1],
        xlabel = "α", ylabel = "I (nats)",
        xscale = log10, aspect = 1,
        xticks = (αs, [latexstring("10^{$(-a)}") for a in as]),
        yticks = (ymin:ymax)
        )
    xlims!(ax, (1/10^first(as), 1/10^last(as)))
    ylims!(ax, (ymin, ymax))
    lines!(ax, αs, itrue, 
        label = "I (true)", linewidth = 4, color = :black)
    for (i, est) in enumerate(estimators)
        if est isa EntropyDecomposition
            es = typeof(est.est).name.name |> String
        else
            es = typeof(est).name.name |> String
        end
        @show es
        lbl = occursin("Lord", es) ? "$es (k = $k_lord)" : "$es (k = $k)"
        scatter!(ax, αs, is[i], label = lbl)
        lines!(ax, αs, is[i])

    end
    axislegend()
    return f
end

set_theme!(new_cycle_theme())
k_lord = 20
k = 5
base = ℯ

def = MIShannon(base = ℯ)
estimators = [
    EntropyDecomposition(def, Kraskov(; k)),
    EntropyDecomposition(def, KozachenkoLeonenko()),
    EntropyDecomposition(def, Zhu(; k)),
    EntropyDecomposition(def, ZhuSingh(; k)),
    EntropyDecomposition(def, Gao(; k)),
    EntropyDecomposition(def, Lord(; k = k_lord)),
    EntropyDecomposition(def, LeonenkoProzantoSavani(Shannon(); k)),
    KSG1(def; k),
    KSG2(def; k),
    GaoOhViswanath(def; k),
    GaoKannanOhViswanath(def; k),
    GaussianMI(def),
];
```

#### Example system: family 1

In this system, samples are concentrated around the diagonal $X = Y$,
and the strip of samples gets thinner as $\alpha \to 0$.

```@example ex_mutualinfo
function family1(α, n::Int)
    x = rand(n)
    v = rand(n)
    y = x + α * v
    return StateSpaceSet(x), StateSpaceSet(y)
end

# True mutual information values for these data
function ifamily1(α; base = ℯ)
    mi = -log(α) - α - log(2)
    return mi / log(base, ℯ)
end

fig = plot_results(family1, ifamily1; 
    k_lord = k_lord, k = k, nreps = 10, n = 800,
    estimators = estimators,
    base = base)
```

#### Example system: family 2

```@example ex_mutualinfo
function family2(α, n::Int)
    Σ = [1 α; α 1]
    N2 = MvNormal(zeros(2), Σ)
    D2 = StateSpaceSet([rand(N2) for i = 1:n])
    X = StateSpaceSet(D2[:, 1])
    Y = StateSpaceSet(D2[:, 2])
    return X, Y
end

function ifamily2(α; base = ℯ)
    return (-0.5 * log(1 - α^2)) / log(ℯ, base)
end

αs = 0.05:0.05:0.95
estimators = estimators
with_theme(new_cycle_theme()) do
    f = Figure();
    ax = Axis(f[1, 1], xlabel = "α", ylabel = "I (nats)")
    is_true = map(α -> ifamily2(α), αs)
    is_est = map(est -> run(est; f = family2, αs, nreps = 20), estimators)
    lines!(ax, αs, is_true, 
        label = "I (true)", color = :black, linewidth = 3)
    for (i, est) in enumerate(estimators)
        if est isa EntropyDecomposition
            estname = typeof(est.est).name.name |> String
        else
            estname = typeof(est).name.name |> String
        end
        scatterlines!(ax, αs, is_est[i], label = estname)
    end
    axislegend(position = :lt)
    return f
end
```

#### Example system: family 3

In this system, we draw samples from a 4D Gaussian distribution distributed
as specified in the `ifamily3` function below. We let $X$ be the two first
variables, and $Y$ be the two last variables.

```@example ex_mutualinfo
function ifamily3(α; base = ℯ)
    Σ = [7 -5 -1 -3; -5 5 -1 3; -1 -1 3 -1; -3 3 -1 2+α]
    Σx = Σ[1:2, 1:2]; Σy = Σ[3:4, 3:4]
    mi = 0.5*log(det(Σx) * det(Σy) / det(Σ))
    return mi / log(ℯ, base)
end

function family3(α, n::Int)
    Σ = [7 -5 -1 -3; -5 5 -1 3; -1 -1 3 -1; -3 3 -1 2+α]
    N4 = MvNormal(zeros(4), Σ)
    D4 = StateSpaceSet([rand(N4) for i = 1:n])
    X = D4[:, 1:2]
    Y = D4[:, 3:4]
    return X, Y
end

fig = plot_results(family3, ifamily3; 
    k_lord = k_lord, k = k, nreps = 5, n = 800,
    estimators = estimators, base = base)
```

We see that the [`Lord`](@ref) estimator, which estimates local volume elements using a singular-value decomposition (SVD) of local neighborhoods, outperforms the other estimators by a large margin.


## [`MIRenyiJizba`](@ref)

### [[`JointProbabilities`](@ref) + [`UniqueElements`](@ref)](@id example_MIRenyiJizba_JointProbabilities_UniqueElements)

[`MIRenyiJizba`](@ref) can be estimated for categorical data using [`JointProbabilities`](@ref) estimator
with the [`UniqueElements`](@ref) outcome space.

```@example example_mirenyijizba
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, ["a", "b", "c"], 200);
y = rand(rng, ["hello", "yoyo", "heyhey"], 200);
est = JointProbabilities(MIRenyiJizba(), UniqueElements())
association(est, x, y)
```

### [[`EntropyDecomposition`](@ref) + [`LeonenkoProzantoSavani`](@ref)](@id example_MIRenyiJizba_JointProbabilities_LeonenkoProzantoSavani)

[`MIRenyiJizba`](@ref) can also estimated for numerical data using [`EntropyDecomposition`](@ref)
in combination with any [`DifferentialInfoEstimator`](@ref) capable of estimating differential 
[`Renyi`](@ref) entropy.

```@example example_MIRenyiJizba
using Associations
using Random; rng = Xoshiro(1234)
x = randn(rng, 50); y = randn(rng, 50);
def = MIRenyiJizba()
est_diff = EntropyDecomposition(def, LeonenkoProzantoSavani(Renyi(), k=3))
association(est_diff, x, y) 
```

### [[`EntropyDecomposition`](@ref) + [`LeonenkoProzantoSavani`](@ref)](@id example_MIRenyiJizba_EntropyDecomposition_ValueBinning)

[`MIRenyiJizba`](@ref) can also estimated for numerical data using [`EntropyDecomposition`](@ref)
in combination with any [`DiscreteInfoEstimator`](@ref) capable of estimating differential 
[`Renyi`](@ref) entropy over some [`OutcomeSpace`](@ref), e.g. [`ValueBinning`](@ref).


```@example example_MIRenyiJizba
using Associations
using Random; rng = Xoshiro(1234)
x = randn(rng, 50); y = randn(rng, 50);
def = MIRenyiJizba()

disc = CodifyVariables(ValueBinning(2))
est_disc = EntropyDecomposition(def, PlugIn(Renyi()), disc);
association(est_disc, x, y)
```

## [`MIRenyiSarbu`](@ref)

[`MIRenyiSarbu`](@ref) can be estimated using the [`JointProbabilities`](@ref) estimator 
in combination with any [`CodifyVariables`](@ref) or [`CodifyPoints`](@ref) discretization scheme.

### [[`JointProbabilities`](@ref) + [`UniqueElements`](@ref)](@id example_MIRenyiSarbu_JointProbabilities_UniqueElements)

```@example example_MIRenyiSarbu
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, ["a", "b", "c"], 200)
y = rand(rng, ["hello", "yoyo", "heyhey"], 200)

est = JointProbabilities(MIRenyiSarbu(), CodifyVariables(UniqueElements()))
association(est, x, y)
```

### [[`JointProbabilities`](@ref) + [`CosineSimilarityBinning`](@ref)](@id example_MIRenyiSarbu_JointProbabilities_CosineSimilarityBinning)

```@example example_MIRenyiSarbu
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 200)
y = rand(rng, 200)

est = JointProbabilities(MIRenyiSarbu(), CodifyVariables(CosineSimilarityBinning()))
association(est, x, y)
```

## [`MITsallisFuruichi`](@ref)

### [[`JointProbabilities`](@ref) + [`UniqueElements`](@ref)](@id example_MITsallisFuruichi_JointProbabilities_UniqueElements)

[`MITsallisFuruichi`](@ref) can be estimated using the [`JointProbabilities`](@ref) estimator 
in combination with any [`CodifyVariables`](@ref) or [`CodifyPoints`](@ref) discretization scheme.

```@example example_MITsallisFuruichi
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 200)
y = rand(rng, 200)

est = JointProbabilities(MITsallisFuruichi(q = 0.3), UniqueElements())
association(est, x, y) 
```

### [[`EntropyDecomposition`](@ref) + [`LeonenkoProzantoSavani`](@ref)](@id example_MITsallisFuruichi_EntropyDecomposition_LeonenkoProzantoSavani)

```@example example_MITsallisFuruichi
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 200)
y = rand(rng, 200)

est_diff = EntropyDecomposition(MITsallisFuruichi(), LeonenkoProzantoSavani(Tsallis(q= 2)))
association(est_diff, x, y)
```


### [[`EntropyDecomposition`](@ref) + [`Dispersion`](@ref)](@id example_MITsallisFuruichi_EntropyDecomposition_Dispersion)

```@example example_MITsallisFuruichi
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 200)
y = rand(rng, 200)
disc = CodifyVariables(Dispersion())
est_disc = EntropyDecomposition(MITsallisFuruichi(), PlugIn(Tsallis()), disc)

association(est_disc, x, y)
```


## [`MITsallisMartin`](@ref)

### [[`JointProbabilities`](@ref) + [`UniqueElements`](@ref)](@id example_MITsallisMartin_JointProbabilities_UniqueElements)

```@example example_MITsallisMartin
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 200)
y = rand(rng, 200)

est = JointProbabilities(MITsallisMartin(q = 1.5), UniqueElements())
association(est, x, y) 
```

### [[`EntropyDecomposition`](@ref) + [`LeonenkoProzantoSavani`](@ref)](@id example_MITsallisMartin_EntropyDecomposition_LeonenkoProzantoSavani)

[`MITsallisMartin`](@ref) can be estimated using a decomposition into entropy 
terms using [`EntropyDecomposition`](@ref) with any compatible estimator 
that can estimate differential [`Tsallis`](@ref) entropy. 


```@example example_MITsallisMartin
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 500)
y = rand(rng, 500)

est_diff = EntropyDecomposition(MITsallisMartin(), LeonenkoProzantoSavani(Tsallis(q= 1.5)))
association(est_diff, x, y)
```

### [[`EntropyDecomposition`](@ref) + [`OrdinalPatterns`](@ref)](@id example_MITsallisMartin_EntropyDecomposition_OrdinalPatterns)


```@example 
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 200)
y = rand(rng, 200)
disc = CodifyVariables(OrdinalPatterns())
est_disc = EntropyDecomposition(MITsallisMartin(), PlugIn(Tsallis()), disc)

association(est_disc, x, y)
```

## [`CMIShannon`](@ref)

### [[`CMIShannon`](@ref) with [`GaussianCMI`](@ref)](@id example_CMIShannon_GaussianCMI)

```@example mi_demonstration
using Associations
using Distributions
using Statistics

n = 1000
# A chain X → Y → Z
x = randn(1000)
y = randn(1000) .+ x
z = randn(1000) .+ y
association(GaussianCMI(), x, z, y) # defaults to `CMIShannon()`
```

### [[`CMIShannon`](@ref) with [`FPVP`](@ref)](@id example_CMIShannon_FPVP)

```@example mi_demonstration
using Associations
using Distributions
using Statistics

n = 1000
# A chain X → Y → Z
x = rand(Normal(-1, 0.5), n)
y = rand(BetaPrime(0.5, 1.5), n) .+ x
z = rand(Chisq(100), n)
z = (z ./ std(z)) .+ y

# We expect zero (in practice: very low) CMI when computing I(X; Z | Y), because
# the link between X and Z is exclusively through Y, so when observing Y,
# X and Z should appear independent.
association(FPVP(k = 5), x, z, y) # defaults to `CMIShannon()`
```

### [`CMIShannon`](@ref) with [`MesnerShalizi`](@ref)

```@example mi_demonstration
using Associations
using Distributions
using Statistics
using Random; rng = Xoshiro(1234)

n = 1000
# A chain X → Y → Z
x = rand(rng, Normal(-1, 0.5), n)
y = rand(rng, BetaPrime(0.5, 1.5), n) .+ x
z = rand(rng, Chisq(100), n)
z = (z ./ std(z)) .+ y

# We expect zero (in practice: very low) CMI when computing I(X; Z | Y), because
# the link between X and Z is exclusively through Y, so when observing Y,
# X and Z should appear independent.
association(MesnerShalizi(; k = 10), x, z, y) # defaults to `CMIShannon()`
```

### [`CMIShannon`](@ref) with [`Rahimzamani`](@ref)

```@example mi_demonstration
using Associations
using Distributions
using Statistics
using Random; rng = Xoshiro(1234)

n = 1000
# A chain X → Y → Z
x = rand(rng, Normal(-1, 0.5), n)
y = rand(rng, BetaPrime(0.5, 1.5), n) .+ x
z = rand(rng, Chisq(100), n)
z = (z ./ std(z)) .+ y

# We expect zero (in practice: very low) CMI when computing I(X; Z | Y), because
# the link between X and Z is exclusively through Y, so when observing Y,
# X and Z should appear independent.
association(Rahimzamani(CMIShannon(base = 10); k = 10), x, z, y)
```

### [[`MIDecomposition`](@ref)](@id example_CMIShannon_MIDecomposition)

Shannon-type conditional mutual information can be decomposed as a sum of 
mutual information terms, which we can each estimate with any dedicated [`MutualInformationEstimator`](@ref) estimator.

```julia
using Associations
using Random; rng = MersenneTwister(1234)
x = rand(rng, 300)
y = rand(rng, 300) .+ x
z = rand(rng, 300) .+ y

est = MIDecomposition(CMIShannon(), KSG1(MIShannon(base = 2), k = 3))
association(est, x, z, y) # should be near 0 (and can be negative)
```


## [`CMIRenyiPoczos`](@ref)

### [[`PoczosSchneiderCMI`](@ref)](@id CMIRenyiPoczos_PoczosSchneiderCMI)

```@example example_cmirenyipoczos
using Associations
using Distributions
using Statistics
using Random; rng = Xoshiro(1234)

n = 1000
# A chain X → Y → Z
x = rand(rng, Normal(-1, 0.5), n)
y = rand(rng, BetaPrime(0.5, 1.5), n) .+ x
z = rand(rng, Chisq(100), n)
z = (z ./ std(z)) .+ y

# We expect zero (in practice: very low) CMI when computing I(X; Z | Y), because
# the link between X and Z is exclusively through Y, so when observing Y,
# X and Z should appear independent.
est = PoczosSchneiderCMI(CMIRenyiPoczos(base = 2, q = 1.2); k = 5)
association(est, x, z, y)
```

In addition to the dedicated [`ConditionalMutualInformationEstimator`](@ref)s, any [`MutualInformationEstimator`](@ref) can also be used to compute conditional
mutual information using the chain rule of mutual information. However, the naive
application of these estimators don't perform any bias correction when
taking the difference of mutual information terms.

## [`CMIShannon`](@ref)

### [[`MIDecomposition`](@ref) + [`KraskovStögbauerGrassberger1`](@ref)](@id example_CMIShannon_MIDecomposition_KSG1)

```@example mi_demonstration
using Associations
using Distributions
using Statistics

n = 1000
# A chain X → Y → Z
x = rand(Normal(-1, 0.5), n)
y = rand(BetaPrime(0.5, 1.5), n) .+ x
z = rand(Chisq(100), n)
z = (z ./ std(z)) .+ y

# We expect zero (in practice: very low) CMI when computing I(X; Z | Y), because
# the link between X and Z is exclusively through Y, so when observing Y,
# X and Z should appear independent.
est = MIDecomposition(CMIShannon(base = 2), KSG1(k = 10))
association(est, x, z, y)
```

## [`ShortExpansionConditionalMutualInformation`](@ref)

### [[`JointProbabilities`](@ref) with [`CodifyVariables`](@ref) and [`ValueBinning`](@ref)](@id example_ShortExpansionConditionalMutualInformation_JointProbabilities_CodifyVariables_ValueBinning)

```@example
using Associations
using Test
using Random; rng = Xoshiro(1234)
n = 20
x = rand(rng, n)
y = randn(rng, n) .+ x .^ 2
z = randn(rng, n) .* y

# An estimator for estimating the SECMI measure
est = JointProbabilities(SECMI(base = 2), CodifyVariables(ValueBinning(3)))
association(est, x, z, y)
```

### [[`EntropyDecomposition`](@ref) + [`Kraskov`](@ref)](@id example_CMIShannon_EntropyDecomposition_Kraskov)

Any [`DifferentialInfoEstimator`](@ref) can also be used to compute conditional
mutual information using a sum of entropies. For that, we 
usethe [`EntropyDecomposition`](@ref) estimator. No bias correction is applied for 
[`EntropyDecomposition`](@ref) either.

```@example
using Associations
using Distributions
using Random; rng = Xoshiro(1234)
n = 500
# A chain X → Y → Z
x = rand(rng, Epanechnikov(0.5, 1.0), n)
y = rand(rng, Normal(0, 0.2), n) .+ x
z = rand(rng, FDist(3, 2), n)
est = EntropyDecomposition(CMIShannon(), Kraskov(k = 5))
association(est, x, z, y)
```

Any [`DiscreteInfoEstimator`](@ref) that computes entropy can also be used to compute
conditional mutual information using a sum of entropies. For that, we also
use [`EntropyDecomposition`](@ref). In the discrete case, we also have to specify a
discretization (an [`OutcomeSpace`](@ref)).

### [[`EntropyDecomposition`](@ref) + [`ValueBinning`](@ref)](@id example_CMIShannon_EntropyDecomposition_ValueBinning)

```@example
using Associations
using Distributions
using Random; rng = Xoshiro(1234)
n = 500
# A chain X → Y → Z
x = rand(rng, Epanechnikov(0.5, 1.0), n)
y = rand(rng, Normal(0, 0.2), n) .+ x
z = rand(rng, FDist(3, 2), n)
discretization = CodifyVariables(ValueBinning(RectangularBinning(5)))
hest = PlugIn(Shannon())
est = EntropyDecomposition(CMIShannon(), hest, discretization)
association(est, x, y, z)
```

## [`CMIRenyiJizba`](@ref)

### [[`JointProbabilities`](@ref) + [`BubbleSortSwaps`](@ref)](@id example_CMIRenyiJizba_JointProbabilities_BubbleSortSwaps)

```@example example_CMIRenyiJizba
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 100)
y = x .+ rand(rng, 100)
z = y .+ rand(rng, 100)
disc = CodifyVariables(BubbleSortSwaps(m = 4))
est = JointProbabilities(CMIRenyiJizba(), disc)
association(est, x, z, y)
```


### [[`EntropyDecomposition`](@ref) + [`LeonenkoProzantoSavani`](@ref)](@id example_CMIRenyiJizba_EntropyDecomposition_LeonenkoProzantoSavani)

```@example example_CMIRenyiJizba
using Associations
using Random; rng = Xoshiro(1234)
x, y, z = rand(rng, 1000), rand(rng, 1000), rand(rng, 1000)
def = CMIRenyiJizba(q = 1.5)

# Using a differential Rényi entropy estimator
est = EntropyDecomposition(def, LeonenkoProzantoSavani(Renyi(), k = 10))
association(est, x, y, z)
```


### [[`EntropyDecomposition`](@ref) + [`OrdinalPatterns`](@ref)](@id example_CMIRenyiJizba_EntropyDecomposition_OrdinalPatterns)

```@example example_CMIRenyiJizba
using Associations
using Random; rng = Xoshiro(1234)
x, y, z = rand(rng, 1000), rand(rng, 1000), rand(rng, 1000)
def = CMIRenyiJizba(q = 1.5)

# Using a plug-in Rényi entropy estimator, discretizing using ordinal patterns.
est = EntropyDecomposition(def, PlugIn(Renyi()), CodifyVariables(OrdinalPatterns(m=2)), RelativeAmount())
association(est, x, y, z)
```

## [`TEShannon`](@ref)

### [[`EntropyDecomposition`](@ref) + [`TransferOperator`](@ref)](@id example_TEShannon_EntropyDecomposition_TransferOperator)

For transfer entropy examples, we'll construct some time series for which 
there is time-delayed forcing between variables.

```@example transfer_entropy_examples

using Associations
using DynamicalSystemsBase
using StableRNGs
rng = StableRNG(123)

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

# An example system where `X → Y → Z → W`.
sys = system(Logistic4Chain(; rng))
x, y, z, w = columns(first(trajectory(sys, 300, Ttr = 10000)))

precise = true # precise bin edges
discretization = CodifyVariables(TransferOperator(RectangularBinning(2, precise))) #
est_disc_to = EntropyDecomposition(TEShannon(), PlugIn(Shannon()), discretization);
association(est_disc_to, x, y), association(est_disc_to, y, x)
```

The Shannon-type transfer entropy from `x` to `y` is stronger than from `y` to `x`,
which is what we expect if `x` drives `y`.

```@example transfer_entropy_examples
association(est_disc_to, x, z), association(est_disc_to, x, z, y)
```

The Shannon-type transfer entropy from `x` to `z` is stronger than the transfer entropy from `x` to `z` given `y`. This is expected, because `x` drives `z` *through*
`y`, so "conditioning away" the effect of `y` should decrease the estimated 
information transfer.

### [[`CMIDecomposition`](@ref)](@id example_TEShannon_CMIDecomposition)

```@example 
using Associations
using Random; rng = MersenneTwister(1234)
x = rand(rng, 1000)
y = rand(rng, 1000) .+ x
z = rand(rng, 1000) .+ y

# Estimate transfer entropy by representing it as a CMI and using the `FPVP` estimator.
est = CMIDecomposition(TEShannon(base = 2), FPVP(k = 3))
association(est, x, z, y) # should be near 0 (and can be negative)
```

### [[`SymbolicTransferEntropy`](@ref) estimator](@id example_TEShannon_SymbolicTransferEntropy)

The [`SymbolicTransferEntropy`](@ref) estimator is just a convenience wrapper which utilizes
[`CodifyVariables`](@ref)with the [`OrdinalPatterns`](@ref) outcome space to 
discretize the input time series before computing transfer entropy.

We'll use coupled time series from the `logistic4` system above, where `x → y → z → w`.
Thus, we expect that the association for the direction `x → y` is larger than for `y → x`. We also expect an association `x → z`, but the association should weaken when conditioning 
on the intermediate value `y`.

```@example transfer_entropy_examples
using Associations
using DynamicalSystemsBase
using Random; rng = Xoshiro(1234)
sys = system(Logistic4Chain(; rng))
x, y, z, w = columns(first(trajectory(sys, 300, Ttr = 10000)))
est = SymbolicTransferEntropy(m = 5)
association(est, x, y), association(est, y, x), association(est, x, z), association(est, x, z, y)
```


### [Comparing different estimators ](@id example_TEShannon_estimator comparison)

Let's reproduce Figure 4 from [Zhu2015](@citet), where they test some
dedicated transfer entropy estimators on a bivariate autoregressive system.
We will test

- The [`Lindner`](@ref) and [`Zhu1`](@ref) dedicated transfer entropy estimators,
    which try to eliminate bias.
- The [`KraskovStögbauerGrassberger1`](@ref) estimator, which computes TE naively as a sum of mutual information
    terms (without guaranteed cancellation of biases for the total sum).
- The [`Kraskov`](@ref) estimator, which computes TE naively as a sum of entropy 
    terms (without guaranteed cancellation of biases for the total sum).

```@example
using Associations
using CairoMakie
using Statistics
using Distributions: Normal

function model2(n::Int)
    𝒩x = Normal(0, 0.1)
    𝒩y = Normal(0, 0.1)
    x = zeros(n+2)
    y = zeros(n+2)
    x[1] = rand(𝒩x)
    x[2] = rand(𝒩x)
    y[1] = rand(𝒩y)
    y[2] = rand(𝒩y)

    for i = 3:n+2
        x[i] = 0.45*sqrt(2)*x[i-1] - 0.9*x[i-2] - 0.6*y[i-2] + rand(𝒩x)
        y[i] = 0.6*x[i-2] - 0.175*sqrt(2)*y[i-1] + 0.55*sqrt(2)*y[i-2] + rand(𝒩y)
    end
    return x[3:end], y[3:end]
end
te_true = 0.42 # eyeball the theoretical value from their Figure 4.

m = TEShannon(embedding = EmbeddingTE(dT = 2, dS = 2), base = ℯ)
estimators = [  
    Zhu1(m, k = 8), 
    Lindner(m, k = 8), 
    MIDecomposition(m, KSG1(k = 8)),
    EntropyDecomposition(m, Kraskov(k = 8)),
]
Ls = [floor(Int, 2^i) for i in 8.0:0.5:11]
nreps = 8
tes_xy = [[zeros(nreps) for i = 1:length(Ls)] for e in estimators]
tes_yx = [[zeros(nreps) for i = 1:length(Ls)] for e in estimators]
for (k, est) in enumerate(estimators)
    for (i, L) in enumerate(Ls)
        for j = 1:nreps
            x, y = model2(L);
            tes_xy[k][i][j] = association(est, x, y)
            tes_yx[k][i][j] = association(est, y, x)
        end
    end
end

ymin = minimum(map(x -> minimum(Iterators.flatten(Iterators.flatten(x))), (tes_xy, tes_yx)))
estimator_names = ["Zhu1", "Lindner", "KSG1", "Kraskov"]
ls = [:dash, :dot, :dash, :dot]
mr = [:rect, :hexagon, :xcross, :pentagon]

fig = Figure(resolution = (800, 350))
ax_xy = Axis(fig[1,1], xlabel = "Signal length", ylabel = "TE (nats)", title = "x → y")
ax_yx = Axis(fig[1,2], xlabel = "Signal length", ylabel = "TE (nats)", title = "y → x")
for (k, e) in enumerate(estimators)
    label = estimator_names[k]
    marker = mr[k]
    scatterlines!(ax_xy, Ls, mean.(tes_xy[k]); label, marker)
    scatterlines!(ax_yx, Ls, mean.(tes_yx[k]); label, marker)
    hlines!(ax_xy, [te_true]; xmin = 0.0, xmax = 1.0, linestyle = :dash, color = :black) 
    hlines!(ax_yx, [te_true]; xmin = 0.0, xmax = 1.0, linestyle = :dash, color = :black)
    linkaxes!(ax_xy, ax_yx)
end
axislegend(ax_xy, position = :rb)

fig
```

### Reproducing Schreiber (2000)

Let's try to reproduce the results from Schreiber's original paper [Schreiber2000](@cite) where
he introduced the transfer entropy. We'll here use the [`JointProbabilities`](@ref) estimator,
discretizing per column of the input data using the [`CodifyVariables`](@ref) discretization
scheme with the [`ValueBinning`](@ref) outcome space.

```@example example_te_schreiber
using Associations
using DynamicalSystemsBase
using CairoMakie
using Statistics
using Random; Random.seed!(12234);

function ulam_system(dx, x, p, t)
    f(x) = 2 - x^2
    ε = p[1]
    dx[1] = f(ε*x[length(dx)] + (1-ε)*x[1])
    for i in 2:length(dx)
        dx[i] = f(ε*x[i-1] + (1-ε)*x[i])
    end
end

ds = DiscreteDynamicalSystem(ulam_system, rand(100) .- 0.5, [0.04])
first(trajectory(ds, 1000; Ttr = 1000));

εs = 0.02:0.02:1.0
te_x1x2 = zeros(length(εs)); te_x2x1 = zeros(length(εs))
# Guess an appropriate bin width of 0.2 for the histogram
disc = CodifyVariables(ValueHistogram(0.2))
est = JointProbabilities(TEShannon(; base = 2), disc)

for (i, ε) in enumerate(εs)
    set_parameter!(ds, 1, ε)
    tr = first(trajectory(ds, 300; Ttr = 5000))
    X1 = tr[:, 1]; X2 = tr[:, 2]
    @assert !any(isnan, X1)
    @assert !any(isnan, X2)
    te_x1x2[i] = association(est, X1, X2)
    te_x2x1[i] = association(est, X2, X1)
end

fig = Figure(size = (800, 600))
ax = Axis(fig[1, 1], xlabel = "epsilon", ylabel = "Transfer entropy (bits)")
lines!(ax, εs, te_x1x2, label = "X1 to X2", color = :black, linewidth = 1.5)
lines!(ax, εs, te_x2x1, label = "X2 to X1", color = :red, linewidth = 1.5)
axislegend(ax, position = :lt)
return fig
```

As expected, transfer entropy from `X1` to `X2` is higher than from `X2` to `X1` across parameter values for `ε`. But, by our definition of the ulam system, dynamical coupling only occurs from `X1` to `X2`. The results, however, show nonzero transfer entropy in both directions. What does this mean?

Computing transfer entropy from finite time series introduces bias, and so does any particular choice of entropy estimator used to calculate it. To determine whether a transfer entropy estimate should be trusted, we can employ surrogate testing. We'll generate surrogate using
[TimeseriesSurrogates.jl](https://github.com/JuliaDynamics/TimeseriesSurrogates.jl).
One possible way to do so is to use a [`SurrogateAssociationTest`](@ref) with [`independence`](@ref), but
here we'll do the surrogate resampling manually, so we can plot and inspect the results.

In the example below, we continue with the same time series generated above. However, at each value of `ε`, we also compute transfer entropy for `nsurr = 50` different randomly shuffled (permuted) versions of the source process. If the original transfer entropy exceeds that of some percentile the transfer entropy estimates of the surrogate ensemble, we will take that as "significant" transfer entropy.

```@example example_te_schreiber
nsurr = 25 # in real applications, you should use more surrogates
base = 2
te_x1x2 = zeros(length(εs)); te_x2x1 = zeros(length(εs))
te_x1x2_surr = zeros(length(εs), nsurr); te_x2x1_surr = zeros(length(εs), nsurr)

# use same bin-width as before
disc = CodifyVariables(ValueHistogram(0.2))
est = JointProbabilities(TEShannon(; base = 2), disc)

for (i, ε) in enumerate(εs)
    set_parameter!(ds, 1, ε)
    tr = first(trajectory(ds, 300; Ttr = 5000))
    X1 = tr[:, 1]; X2 = tr[:, 2]
    @assert !any(isnan, X1)
    @assert !any(isnan, X2)
    te_x1x2[i] = association(est, X1, X2)
    te_x2x1[i] = association(est, X2, X1)
    s1 = surrogenerator(X1, RandomShuffle()); s2 = surrogenerator(X2, RandomShuffle())

    for j = 1:nsurr
        te_x1x2_surr[i, j] = association(est, s1(), X2)
        te_x2x1_surr[i, j] = association(est, s2(), X1)
    end
end

# Compute 95th percentiles of the surrogates for each ε
qs_x1x2 = [quantile(te_x1x2_surr[i, :], 0.95) for i = 1:length(εs)]
qs_x2x1 = [quantile(te_x2x1_surr[i, :], 0.95) for i = 1:length(εs)]

fig = with_theme(theme_minimal(), markersize = 2) do
    fig = Figure()
    ax = Axis(fig[1, 1], xlabel = "epsilon", ylabel = "Transfer entropy (bits)")
    scatterlines!(ax, εs, te_x1x2, label = "X1 to X2", color = :black, linewidth = 1.5)
    scatterlines!(ax, εs, qs_x1x2, color = :black, linestyle = :dot, linewidth = 1.5)
    scatterlines!(ax, εs, te_x2x1, label = "X2 to X1", color = :red)
    scatterlines!(ax, εs, qs_x2x1, color = :red, linestyle = :dot)
    axislegend(ax, position = :lt)
    return fig
end
fig
```

The plot above shows the original transfer entropies (solid lines) and the 95th percentile transfer entropies of the surrogate ensembles (dotted lines). As expected, using the surrogate test, the transfer entropies from `X1` to `X2` are mostly significant (solid black line is above dashed black line). The transfer entropies from `X2` to `X1`, on the other hand, are mostly not significant (red solid line is below red dotted line).

## [`TERenyiJizba`](@ref)

### [[`EntropyDecomposition`](@ref) + [`TransferOperator`](@ref)](@id example_TERenyiJizba_EntropyDecomposition_TransferOperator)

We can perform the same type of analysis as above using [`TERenyiJizba`](@ref)
instead of [`TEShannon`](@ref).

```@example transfer_entropy_examples
using Associations
using DynamicalSystemsBase
using StableRNGs; rng = StableRNG(123)

# An example system where `X → Y → Z → W`.
sys = system(Logistic4Chain(; rng))
x, y, z, w = columns(first(trajectory(sys, 300, Ttr = 10000)))

precise = true # precise bin edges
discretization = CodifyVariables(TransferOperator(RectangularBinning(2, precise))) #
est_disc_to = EntropyDecomposition(TERenyiJizba(), PlugIn(Renyi()), discretization);
association(est_disc_to, x, y), association(est_disc_to, y, x)
```

## [`ConvergentCrossMapping`](@ref)

### [[`RandomVectors`](@ref) estimator](@id example_ConvergentCrossMapping_RandomVectors)

When cross-mapping with the [`RandomVectors`](@ref) estimator, a single random subsample
of time indices (i.e. not in any particular order) of length `l` is drawn for each library
size `l`, and cross mapping is performed using the embedding vectors corresponding
to those time indices.

```@example example_ConvergentCrossMapping
using Associations
using Random; rng = MersenneTwister(1234)
x, y = randn(rng, 200), randn(rng, 200)

# We'll draw a single sample at each `l ∈ libsizes`. Sampling with replacement is then
# necessary, because our 200-pt timeseries will result in embeddings with
# less than 200 points.
est = RandomVectors(ConvergentCrossMapping(d = 3); libsizes = 50:25:200, replace = true, rng)
crossmap(est, x, y)
```

To generate a distribution of cross-map estimates for each `l ∈ libsizes`, just call
crossmap repeatedly, e.g.

```@example example_ConvergentCrossMapping
using Associations
using Random; rng = MersenneTwister(1234)
using Statistics

x, y = randn(rng, 300), randn(rng, 300)
def = ConvergentCrossMapping(d = 3)
libsizes = 25:25:200

ρs = [[crossmap(RandomVectors(def; libsizes = L, replace = true, rng), x, y) for i = 1:50] for L in libsizes]

using CairoMakie
f = Figure(); ax = Axis(f[1, 1]);
plot!(ax, libsizes, mean.(ρs))
errorbars!(ax, libsizes, mean.(ρs), std.(ρs))
f
```

Now, the `k`-th element of `ρs` contains `80` estimates of the correspondence measure `ρ`
at library size `libsizes[k]`.

###  [[`RandomSegment`](@ref) estimator](@id example_ConvergentCrossMapping_RandomSegment)

When cross-mapping with the [`RandomSegment`](@ref) estimator, a single random subsample
of continguous, ordered time indices of length `l` is drawn for each library
size `l`, and cross mapping is performed using the embedding vectors corresponding
to those time indices.

```@example example_ConvergentCrossMapping
using Associations
using Random; rng = MersenneTwister(1234)
x, y = randn(rng, 200), randn(rng, 200)

# We'll draw a single sample at each `l ∈ libsizes`. We limit the library size to 100, 
# because drawing segments of the data longer than half the available data doesn't make
# much sense.
est = RandomSegment(ConvergentCrossMapping(d = 3); libsizes = 50:25:100, rng)
crossmap(est, x, y)
```

As above, to generate a distribution of cross-map estimates for each `l ∈ libsizes`, just call
crossmap repeatedly, e.g.

```@example example_ConvergentCrossMapping
using Associations
using Random; rng = MersenneTwister(1234)
using Statistics

x, y = randn(rng, 200), randn(rng, 200)
def = ConvergentCrossMapping(d = 3)
libsizes = 25:25:100

ρs = [[crossmap(RandomSegment(def; libsizes = L, rng), x, y) for i = 1:50] for L in libsizes]

f = Figure(); ax = Axis(f[1, 1]);
plot!(ax, libsizes, mean.(ρs))
errorbars!(ax, libsizes, mean.(ρs), std.(ρs))
f
```




## [`PairwiseAsymmetricInference`](@ref)

We repeat the analyses above, but here use the pairwise asymmetric inference algorithm
instead of the convergent cross map algorithm.

### [[`RandomVectors`](@ref) estimator](@id example_PairwiseAsymmetricInference_RandomVectors)


```@example example_PairwiseAsymmetricInference
using Associations
using Random; rng = MersenneTwister(1234)
x, y = randn(rng, 300), randn(rng, 300)

# We'll draw a single sample at each `l ∈ libsizes`. Sampling with replacement is then
# necessary, because our 200-pt timeseries will result in embeddings with
# less than 200 points.
est = RandomVectors(PairwiseAsymmetricInference(d = 3); libsizes = 50:25:200, replace = true, rng)
crossmap(est, x, y)
```

To generate a distribution of cross-map estimates for each `l ∈ libsizes`, just call
crossmap repeatedly, e.g.

```@example example_PairwiseAsymmetricInference
using Associations
using Random; rng = MersenneTwister(1234)
using Statistics

x, y = randn(rng, 300), randn(rng,300)
def = PairwiseAsymmetricInference(d = 3)
libsizes = 25:25:200

ρs = [[crossmap(RandomVectors(def; libsizes = L, replace = true, rng), x, y) for i = 1:50] for L in libsizes]

using CairoMakie
f = Figure(); ax = Axis(f[1, 1]);
plot!(ax, libsizes, mean.(ρs))
errorbars!(ax, libsizes, mean.(ρs), std.(ρs))
f
```

### [[`RandomSegment`](@ref) estimator](@id example_PairwiseAsymmetricInference_RandomSegment)

```@example example_PairwiseAsymmetricInference
using Associations
using Random; rng = MersenneTwister(1234)
x, y = randn(rng, 200), randn(rng, 200)

# We'll draw a single sample at each `l ∈ libsizes`. We limit the library size to 100, 
# because drawing segments of the data longer than half the available data doesn't make
# much sense.
est = RandomSegment(PairwiseAsymmetricInference(d = 3); libsizes = 50:25:100, rng)
crossmap(est, x, y)
```

As above, to generate a distribution of cross-map estimates for each `l ∈ libsizes`, just call
crossmap repeatedly, e.g.

```@example
using Associations
using Random; rng = MersenneTwister(1234)
using Statistics

x, y = randn(rng, 300), randn(rng, 300)
def = PairwiseAsymmetricInference(d = 3)
libsizes = 25:25:100

ρs = [[crossmap(RandomSegment(def; libsizes = L, rng), x, y) for i = 1:50] for L in libsizes]

using CairoMakie
f = Figure(); ax = Axis(f[1, 1]);
plot!(ax, libsizes, mean.(ρs))
errorbars!(ax, libsizes, mean.(ρs), std.(ρs))
f
```


## [[`MCR`](@ref)](@id example_MCR)


To quantify association by the mean conditional probability of recurrence (MCR),
we'll create a chain of variables where `X` drives `Y`, which in turn drives 
`Z`. We then expect there to be significant detectable association between both
`X` and `Y`, `Y` and `Z` and also `X` and `Z` (because `Y` transfers information
from `X` to `Z`. We expect the association between `X` and `Z` to disappear when
conditioning on `Y` (since we're then "removing the effect" of `Y`).

```@example example_mcr
using Associations
using Random; rng = Xoshiro(1234);
x = rand(rng, 300); y = rand(rng, 300) .* sin.(x); z = rand(rng, 300) .* y;
est = MCR(r = 0.5)
association(est, x, y), association(est, x, z), association(est, y, z), association(est, x, z, y)
```

The interpretation of the [`MCR`](@ref) measure is that if two variables are
symmetrically coupled, then the conditional recurrence in both directions is equal.
Two variables that are uncoupled are symmetrically coupled (i.e. no coupling). We
therefore expect the difference in conditional recurrence to be around zero.

```@example
using Associations
using Random; rng = Xoshiro(1234)
x = rand(rng, 300)
y = rand(rng, 300)
m = MCR(r = 0.5)
Δ = association(m, x, y) - association(m, y, x)
```

## [[`RMCD`](@ref)](@id example_RMCD)

To quantify association by the recurrence measure of conditional dependence (RMCD),
we'll create a chain of variables where `X` drives `Y`, which in turn drives 
`Z`. We then expect there to be significant detectable association between both
`X` and `Y`, `Y` and `Z` and also `X` and `Z` (because `Y` transfers information
from `X` to `Z`. We expect the association between `X` and `Z` to disappear when
conditioning on `Y` (since we're then "removing the effect" of `Y`).

```@example example_mcr
using Associations
using Random; rng = Xoshiro(1234);
x = rand(rng, 300); y = rand(rng, 300) .* sin.(x); z = rand(rng, 300) .* y;
est = RMCD(r = 0.5)
association(est, x, y), association(est, x, z), association(est, x, z, y)
```

## [[`ChatterjeeCorrelation`](@ref)](@id example_ChatterjeeCorrelation)

```@example example_ChatterjeeCorrelation
using Associations
using Random; rng = Xoshiro(1234);
x = rand(rng, 120)
y = rand(rng, 120) .* sin.(x)
```

By construction, there will almust surely be no ties in `x`, so we can use the 
fast estimate by setting `handle_ties == false`. 

```@example example_ChatterjeeCorrelation
association(ChatterjeeCorrelation(handle_ties = false), x, y)
```

If we have data where we know there are ties in the data, then
we should set `handle_ties == true`.

```@example example_ChatterjeeCorrelation
w = rand(rng, 1:10, 120) # there will be some ties
z = rand(rng, 1:15, 120) .* sin.(w) # introduce some dependence
association(ChatterjeeCorrelation(handle_ties = true), w, z)
```

## [[`AzadkiaChatterjeeCoefficient`](@ref)](@id example_AzadkiaChatterjeeCoefficient)


```@example example_AzadkiaChatterjeeCoefficient
using Associations
using Random; rng = Xoshiro(1234);
x = rand(rng, 120)
y = rand(rng, 120) .* x
z = rand(rng, 120) .+ y
```

For the variables above, where `x → y → z`, we expect stronger assocation between `x` and `y` than
between `x` and `z`. We also expect the strength of the association between `x` and `z` to drop when conditioning on `y`, because `y` is the variable that connects `x` and `z`.

```@example example_AzadkiaChatterjeeCoefficient
m = AzadkiaChatterjeeCoefficient(theiler = 0) # only exclude self-neighbors
association(m, x, y), association(m, x, z), association(m, x, z, y)
```

