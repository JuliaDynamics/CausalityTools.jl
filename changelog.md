# Changelog

From version v4.0 onwards, this package has been renamed to to Associations.jl.

# 4.3 

- New association measure: `SECMI` (`ShortExpansionConditionalMutualInformation`)
- New independence test: `SECMITest`, which is based on `SECMI`.

# 4.2

- New association measure: `AzadkiaChatterjeeCoefficient`.

# 4.1

- New association measure: `ChatterjeeCorrelation`.

# 4.0 (package rename)

The package has been renamed from CausalityTools.jl to Associations.jl.

## 3.0 (new major release)

This release contains several breaking changes. Any code from before v3.0 will need 
updating to continue working with v3.0.

The main reason for these breaking changes is that estimators now store the 
definitions they estimate. This way, we reduce the amount of code we have to write 
maintain, document and test. At the same time, we hope it is a bit more user-friendly 
to only relate to "one way of thinking" about estimating association measures.

### Breaking changes 

#### Association measures

- The function `association(measure_or_est, input_data...)` is the central function that computes 
    all association measures. The first argument is either a measure definition (if it has no 
    estimator), or an estimator. This means that if `input_data` consists of two input datasets, 
    then a pairwise association is estimated. If `input_data` consists of three input datasets, then typically a conditional association is estimated (but exceptions are possible).

#### Independence testing 

- `SurrogateTest` is now `SurrogateAssociationTest`
- `SurrogateTestResult` is now `SurrogateAssociationTestResult`

#### Example systems 

- All example systems are removed.

#### Crossmap API

The crossmap API has been overhauled. 

- `CrossmapEstimator`s now take the `CrossmapMeasure` definition as their first argument.
    For example, you'll have to do `ExpandingSegment(CCM(); libsizes = 10:10:50)` instead
    of `ExpandingSegment(; libsizes = 10:10:50)`.

#### Information API

The information API has been overhauled.

- Multivariate information measures now store their parameters explicitly, instead 
    of using `ComplexityMeasures.EntropyDefinition` to do so. For example, to 
    define Shannon-type conditional mutual information, one should do 
    `CMIShannon(base = 2)` instead of `CMIShannon(Shannon(base = 2))`.
- New generic discrete estimator `JointDistribution` for estimating multivariate
    information measures. This estimators explicitly computes the joint distribution
    based on the given discretization, and can be applied to any measure which is 
    defined as a function of a joint distribution.
- New generic decomposition-based estimator `EntropyDecomposition`. This estimator
    computes some multivariate information measure by rewriting the measure definition
    as a combination of some lower-level measure. For example, `CMIShannon` can be 
    rewritten as a sum of `Shannon` entropies. Each of these terms can then 
    be estimated using some differential entropy estimator, e.g. `ZhuSingh` or `Kraskov`.
- New generic decomposition-based estimator `MIDecomposition`. This estimator
    computes some multivariate information measure by rewriting the measure definition
    as a combination of some mutual information measure.
- New generic decomposition-based estimator `CMIDecomposition`. This estimator
    computes some multivariate information measure by rewriting the measure definition
    as a combination of some conditional mutual information measure.

### Bux fixes

- There was an error in the implementation of `PartMutualInformation`. It is now fixed using explicit loops for computing the measures from a probability distribution.


## 2.10

- Progress bars in some independence tests (surrogate, local permutation) can be
  enabled by passing keyword `show_progress = true` in the test constructors.

## 2.9

### Bug fixes

- Fixed bug in `transferentropy` function which yielded identical results in both directions for the bivariate case.
- Fixed bug that occurred when using `LocalPermutationTest` with `TEShannon` as the measure and a dedicated `TransferEntropyEstimator` (e.g. `Zhu1` or `Lindner`). This occurred because the `LocalPermutationTest` is, strictly speaking, a test using conditional mutual information as the measure. Therefore, naively applying a `TransferEntropy` measure such as `TEShannon` would error. This is fixed by performing a similar procedure where the source marginal is shuffled according to local neighborhoods in the conditional marginal. This is similar, but not identical to the CMI-based `LocalPermutationTest`, and adapts to the specific case of transfer entropy estimation using dedicated transfer entropy estimators instead of some lower-level estimator.
- Fixed bug in `Zhu1` transfer entropy estimator where when box volumes were extremely small, taking the logarithm of volume ratios resulted in `Inf` values. This was solved by simply ignoring these volumes.

## 2.8.0

Moved to DynamicalSystemsBase v3.0 (`trajectory` now returns both the data and the time
indices).

### Bugfixes

- Fixed bug in `GaussianMI` that occurred when the keyword `normalize` was set to `true`.

## 2.7.1

- Fixed an import warning.

## 2.7.0

- New association measure: `PMI` (part mutual information).

## 2.6.0

- New causal graph inference algorithm: `PC`.

## 2.5.0

- New independence test: `CorrTest`, based on (partial) correlations.

## 2.4.0

- Added partial distance correlation measure. To compute it, simply provide a
    third input argument to `distance_correlation`.
- `DistanceCorrelation` is now compatible with both `SurrogateTest` and
    `LocalPermutationTest` in its conditional form.

## 2.3.1

- The `MesnerShalisi` estimator is now deprecated and renamed to `MesnerShalizi` (with
    correct spelling).

## 2.3.0

- Significant speed-ups for `OCE` by sorting on maximal measure, thus avoiding
    unnecessary significance tests.
- Default parameters for `OCE` default lag parameter have changed. Now, `τmax = 1`, since
    that is the only case considered in the original paper. We also use the
    `MesnerShalisi` CMI estimator for the conditional step, because in contrast to
    the `FPVP` estimator, it has been shown to be consistent.
- Source code for `OCE` has been drastically simplified by merging the pairwise
    and conditional parent finding steps.
- `OCE` result can now be converted to a `SimpleDiGraph` from Graphs.jl.

## 2.2.1

- `infer_graph` now accepts the `verbose` keyword.
- Fixed a bug in backwards elimination step of `OCE` algorithm that was caused due
    to an undefined variable.

## 2.2

- Added `MCR` and `RMCD` recurrence based association measures, along with
    the corresponding `mcr` and `rmcd` methods.

## 2.1

- Bugfix for `OCE` for certain conditional variable cases.
- Improve docstring for `OCE`.
- Updated readme.
- Fixed bug related to `DifferentialInfoEstimator` "unit" conversion.

## 2.0

The entire package has been completely redesigned. Previous methods are deprecated,
and will disappear completely in a v2.X release.
For a full overview of new functionality, see the online documentation.

## 1.4.0

### New methods

- Added [`conditional_mutualinfo`](@ref).

## 1.3.0

### Example systems

- Added continous example system [`repressilator`](@ref).
