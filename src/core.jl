using ComplexityMeasures: DifferentialInfoEstimator, DiscreteInfoEstimator
using StateSpaceSets: AbstractStateSpaceSet

export AssociationMeasure
export AssociationMeasureEstimator
export association

const VectorOr1DDataset{T} = Union{AbstractVector{T}, AbstractStateSpaceSet{1, T}} where T
const VectorOrStateSpaceSet{D, T} = Union{AbstractVector{T}, AbstractStateSpaceSet{D, T}} where {D, T}
const ArrayOrStateSpaceSet{D, T, N} = Union{AbstractArray{T, N}, AbstractStateSpaceSet{D, T}} where {D, T, N}
const INFO_ESTS = Union{DifferentialInfoEstimator, DiscreteInfoEstimator}

"""
    AssociationMeasure

The supertype of all association measures. 

## Abstract implementations

Currently, the association measures are classified by abstract classes listed below.
These abstract classes offer common functionality among association measures that are 
conceptually similar. This makes maintenance and framework extension easier than 
if each measure was implemented "in isolation".

- [`MultivariateInformationMeasure`](@ref)
- [`CrossmapMeasure`](@ref)
- [`ClosenessMeasure`](@ref)
- [`CorrelationMeasure`](@ref)

## Concrete implementations

Concrete subtypes are given as input to [`association`](@ref). Many of these types require
an [`AssociationMeasureEstimator`](@ref) to compute.

| Type                       | [`AssociationMeasure`](@ref)                         | Pairwise | Conditional |
| -------------------------- | ---------------------------------------------------- | :------: | :---------: |
| Correlation                | [`PearsonCorrelation`](@ref)                         |    ✓    |     ✖      |
| Correlation                | [`PartialCorrelation`](@ref)                         |    ✓    |     ✓      |
| Correlation                | [`DistanceCorrelation`](@ref)                        |    ✓    |     ✓      |
| Correlation                | [`ChatterjeeCorrelation`](@ref)                      |    ✓    |     ✖      |
| Correlation                | [`AzadkiaChatterjeeCoefficient`](@ref)               |    ✓    |     ✓      |
| Closeness                  | [`SMeasure`](@ref)                                   |    ✓    |     ✖      |
| Closeness                  | [`HMeasure`](@ref)                                   |    ✓    |     ✖      |
| Closeness                  | [`MMeasure`](@ref)                                   |    ✓    |     ✖      |
| Closeness (ranks)          | [`LMeasure`](@ref)                                   |    ✓    |     ✖      |
| Closeness                  | [`JointDistanceDistribution`](@ref)                  |    ✓    |     ✖      |
| Cross-mapping              | [`PairwiseAsymmetricInference`](@ref)                |    ✓    |     ✖      |
| Cross-mapping              | [`ConvergentCrossMapping`](@ref)                     |    ✓    |     ✖      |
| Conditional recurrence     | [`MCR`](@ref)                                        |    ✓    |     ✖      |
| Conditional recurrence     | [`RMCD`](@ref)                                       |    ✓    |     ✓      |
| Shared information         | [`MIShannon`](@ref)                                  |    ✓    |     ✖      |
| Shared information         | [`MIRenyiJizba`](@ref)                               |    ✓    |     ✖      |
| Shared information         | [`MIRenyiSarbu`](@ref)                               |    ✓    |     ✖      |
| Shared information         | [`MITsallisFuruichi`](@ref)                          |    ✓    |     ✖      |
| Shared information         | [`PartialCorrelation`](@ref)                         |    ✖    |     ✓      |
| Shared information         | [`CMIShannon`](@ref)                                 |    ✖    |     ✓      |
| Shared information         | [`CMIRenyiSarbu`](@ref)                              |    ✖    |     ✓      |
| Shared information         | [`CMIRenyiJizba`](@ref)                              |    ✖    |     ✓      |
| Shared information         | [`CMIRenyiPoczos`](@ref)                             |    ✖    |     ✓      |
| Shared information         | [`CMITsallisPapapetrou`](@ref)                       |    ✖    |     ✓      |
| Shared information         | [`ShortExpansionConditionalMutualInformation`](@ref) |    ✖    |     ✓      |
| Information transfer       | [`TEShannon`](@ref)                                  |    ✓    |     ✓      |
| Information transfer       | [`TERenyiJizba`](@ref)                               |    ✓    |     ✓      |
| Partial mutual information | [`PartialMutualInformation`](@ref)                   |    ✖    |     ✓      |
| Information measure        | [`JointEntropyShannon`](@ref)                        |    ✓    |     ✖      |
| Information measure        | [`JointEntropyRenyi`](@ref)                          |    ✓    |     ✖      |
| Information measure        | [`JointEntropyTsallis`](@ref)                        |    ✓    |     ✖      |
| Information measure        | [`ConditionalEntropyShannon`](@ref)                  |    ✓    |     ✖      |
| Information measure        | [`ConditionalEntropyTsallisAbe`](@ref)               |    ✓    |     ✖      |
| Information measure        | [`ConditionalEntropyTsallisFuruichi`](@ref)          |    ✓    |     ✖      |
| Divergence                 | [`HellingerDistance`](@ref)                          |    ✓    |     ✖      |
| Divergence                 | [`KLDivergence`](@ref)                               |    ✓    |     ✖      |
| Divergence                 | [`RenyiDivergence`](@ref)                            |    ✓    |     ✖      |
| Divergence                 | [`VariationDistance`](@ref)                          |    ✓    |     ✖      |
"""
abstract type AssociationMeasure end

"""
    AssociationMeasureEstimator

The supertype of all association measure estimators.

Concrete subtypes are given as input to [`association`](@ref).

## Abstract subtypes

- [`MultivariateInformationMeasureEstimator`](@ref)
- [`CrossmapEstimator`](@ref)

## Concrete implementations

| AssociationMeasure                                   | Estimators                                                                                                                                                                                                                   |
| :--------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`PearsonCorrelation`](@ref)                         | Not required                                                                                                                                                                                                                 |
| [`DistanceCorrelation`](@ref)                        | Not required                                                                                                                                                                                                                 |
| [`PartialCorrelation`](@ref)                         | Not required                                                                                                                                                                                                                 |
| [`ChatterjeeCorrelation`](@ref)                      | Not required                                                                                                                                                                                                                 |
| [`AzadkiaChatterjeeCoefficient`](@ref)               | Not required                                                                                                                                                                                                                 |
| [`SMeasure`](@ref)                                   | Not required                                                                                                                                                                                                                 |
| [`HMeasure`](@ref)                                   | Not required                                                                                                                                                                                                                 |
| [`MMeasure`](@ref)                                   | Not required                                                                                                                                                                                                                 |
| [`LMeasure`](@ref)                                   | Not required                                                                                                                                                                                                                 |
| [`JointDistanceDistribution`](@ref)                  | Not required                                                                                                                                                                                                                 |
| [`PairwiseAsymmetricInference`](@ref)                | [`RandomVectors`](@ref), [`RandomSegment`](@ref)                                                                                                                                                                             |
| [`ConvergentCrossMapping`](@ref)                     | [`RandomVectors`](@ref), [`RandomSegment`](@ref)                                                                                                                                                                             |
| [`MCR`](@ref)                                        | Not required                                                                                                                                                                                                                 |
| [`RMCD`](@ref)                                       | Not required                                                                                                                                                                                                                 |
| [`MIShannon`](@ref)                                  | [`JointProbabilities`](@ref), [`EntropyDecomposition`](@ref), [`KraskovStögbauerGrassberger1`](@ref), [`KraskovStögbauerGrassberger2`](@ref), [`GaoOhViswanath`](@ref), [`GaoKannanOhViswanath`](@ref), [`GaussianMI`](@ref) |
| [`MIRenyiJizba`](@ref)                               | [`JointProbabilities`](@ref), [`EntropyDecomposition`](@ref)                                                                                                                                                                 |
| [`MIRenyiSarbu`](@ref)                               | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`MITsallisFuruichi`](@ref)                          | [`JointProbabilities`](@ref), [`EntropyDecomposition`](@ref)                                                                                                                                                                 |
| [`MITsallisMartin`](@ref)                            | [`JointProbabilities`](@ref), [`EntropyDecomposition`](@ref)                                                                                                                                                                 |
| [`CMIShannon`](@ref)                                 | [`JointProbabilities`](@ref), [`EntropyDecomposition`](@ref), [`MIDecomposition`](@ref), [`GaussianCMI`](@ref), [`FPVP`](@ref), [`MesnerShalizi`](@ref), [`Rahimzamani`](@ref)                                               |
| [`CMIRenyiSarbu`](@ref)                              | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`CMIRenyiJizba`](@ref)                              | [`JointProbabilities`](@ref), [`EntropyDecomposition`](@ref)                                                                                                                                                                 |
| [`CMIRenyiPoczos`](@ref)                             | [`PoczosSchneiderCMI`](@ref)                                                                                                                                                                                                 |
| [`CMITsallisPapapetrou`](@ref)                       | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`TEShannon`](@ref)                                  | [`JointProbabilities`](@ref), [`EntropyDecomposition`](@ref), [`Zhu1`](@ref), [`Lindner`](@ref)                                                                                                                              |
| [`TERenyiJizba`](@ref)                               | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`PartialMutualInformation`](@ref)                   | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`ShortExpansionConditionalMutualInformation`](@ref) | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`JointEntropyShannon`](@ref)                        | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`JointEntropyRenyi`](@ref)                          | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`JointEntropyTsallis`](@ref)                        | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`ConditionalEntropyShannon`](@ref)                  | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`ConditionalEntropyTsallisAbe`](@ref)               | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`ConditionalEntropyTsallisFuruichi`](@ref)          | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`HellingerDistance`](@ref)                          | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`KLDivergence`](@ref)                               | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`RenyiDivergence`](@ref)                            | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
| [`VariationDistance`](@ref)                          | [`JointProbabilities`](@ref)                                                                                                                                                                                                 |
"""
abstract type AssociationMeasureEstimator end

"""
    association(estimator::AssociationMeasureEstimator, x, y, [z, ...]) → r
    association(definition::AssociationMeasure, x, y, [z, ...]) → r

Estimate the (conditional) association between input variables `x, y, z, …` using 
the given `estimator` (an [`AssociationMeasureEstimator`](@ref)) or `definition`
(an [`AssociationMeasure`](@ref)).  

!!! info
    The type of the return value `r` depends on the `measure`/`estimator`. The *interpretation*
    of the returned value also depends on the specific measure and estimator used.

## Examples

The [examples](@ref examples_associations) section of the online documentation has numerous 
using `association`.

"""
function association(est, x...)
    throw(ArgumentError("`association` not implemented for `est = $est` for this input data"))
end

"""
    min_inputs_vars(m::AssociationMeasure) → nmin::Int

Return the minimum number of variables is that the measure can be computed for.

For example, [`CMIShannon`](@ref) requires 3 input variables.
"""
min_inputs_vars(m::AssociationMeasure) = 2

# Default to bivariate measures. Other measures override it.

"""
    max_inputs_vars(m::AssociationMeasure) → nmax::Int

Return the maximum number of variables is that the measure can be computed for.

For example, [`MIShannon`](@ref) cannot be computed for more than 2 variables.
"""
max_inputs_vars(m::AssociationMeasure) = 2

function verify_number_of_inputs_vars(measure::AssociationMeasure, n::Int)
    T = typeof(measure)
    nmin = min_inputs_vars(measure)
    if n < nmin
        throw(ArgumentError("$T requires at least $nmin inputs. Got $n inputs."))
    end

    nmax = max_inputs_vars(measure)
    if n > nmax
        throw(ArgumentError("$T accepts a maximum of $nmax inputs. Got $n inputs."))
    end
end