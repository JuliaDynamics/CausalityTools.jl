```@meta
CollapsedDocStrings = true
```

# [Associations](@id association_measures)

## Association API
The most basic components of Associations.jl are a collection of statistics that in some manner quantify the "association" between input datasets. Precisely what is meant by "association" depends on the measure, and precisely what is meant by "quantify" depends on the *estimator* of that measure. We formalize this notion below with the [`association`](@ref)
function, which dispatches on [`AssociationMeasureEstimator`](@ref) and [`AssociationMeasure`](@ref).


```@docs
association
AssociationMeasure
AssociationMeasureEstimator
```

Here are some examples of how to use [`association`](@ref).

```@repl
using Associations
x, y, z = rand(1000), rand(1000), rand(1000);
association(LMeasure(), x, y)
association(DistanceCorrelation(), x, y)
association(JointProbabilities(JointEntropyShannon(), CodifyVariables(Dispersion(c = 3, m = 2))), x, y)
association(EntropyDecomposition(MIShannon(), PlugIn(Shannon()), CodifyVariables(OrdinalPatterns(m=3))), x, y)
association(KSG2(MIShannon(base = 2)), x, y)
association(JointProbabilities(PartialMutualInformation(), CodifyVariables(OrdinalPatterns(m=3))), x, y, z)
association(FPVP(CMIShannon(base = 2)), x, y, z)
```

## [Information measures](@id information_api)

```@docs
MultivariateInformationMeasure
```

### [Conditional entropies](@id conditional_entropies)

```@docs
ConditionalEntropy
ConditionalEntropyShannon
ConditionalEntropyTsallisFuruichi
ConditionalEntropyTsallisAbe
```

### [Divergences and distances](@id divergences_and_distances)

```@docs
DivergenceOrDistance
HellingerDistance
KLDivergence
RenyiDivergence
VariationDistance
```

### [Joint entropies](@id joint_entropies)

```@docs
JointEntropy
JointEntropyShannon
JointEntropyTsallis
JointEntropyRenyi
```

### Mutual informations

```@docs
MutualInformation
MIShannon
MITsallisFuruichi
MITsallisMartin
MIRenyiJizba
MIRenyiSarbu
```

### Conditional mutual informations

```@docs
ConditionalMutualInformation
CMIShannon
CMIRenyiSarbu
CMIRenyiJizba
CMIRenyiPoczos
CMITsallisPapapetrou
```

### Transfer entropy

```@docs
TransferEntropy
TEShannon
TERenyiJizba
```

The following utility functions and types are also useful for transfer entropy estimation.

```@docs
optimize_marginals_te
EmbeddingTE
```


### Partial mutual information

```@docs
PartialMutualInformation
```

### Short expansion of conditional mutual information

```@docs
ShortExpansionConditionalMutualInformation
```

## [Correlation measures](@id correlation_api)

```@docs
CorrelationMeasure
PearsonCorrelation
PartialCorrelation
DistanceCorrelation
ChatterjeeCorrelation
AzadkiaChatterjeeCoefficient
```

## [Cross-map measures](@id cross_map_api)

The cross-map measures define different ways of quantifying association based on the 
concept of "cross mapping", which has appeared in many contexts in the literature,
and gained huge popularity with  [Sugihara2012](@citet)'s on *convergent cross mapping*.

Since their paper, several cross mapping methods and frameworks have emerged in the
literature. In Associations.jl, we provide a unified interface for using these cross
mapping methods.

```@docs
CrossmapMeasure
ConvergentCrossMapping
PairwiseAsymmetricInference
```

## [Closeness measures](@id closeness_api)

```@docs
ClosenessMeasure
JointDistanceDistribution
SMeasure
HMeasure
MMeasure
LMeasure
```

## Recurrence measures

```@docs
MCR
RMCD
```