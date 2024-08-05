```@meta
CollapsedDocStrings = true
```

# [Independence testing](@id independence_testing)

For practical applications, it is often useful to determine whether variables are independent, possible conditioned upon 
another set of variables. One way of doing so is to utilize an 
association measure, and perform some sort of randomization-based
[independence testing](@ref independence_testing).

For example, to test the dependence between time series, [time series surrogates testing](https://github.com/JuliaDynamics/TimeseriesSurrogates.jl) is used. Many other frameworks for independence exist too. Here, we've collected some independence testing frameworks, and made sure that they are compatible with as many of the implemented association measures as possible.

## Independence testing API

The independence test API is defined by

- [`independence`](@ref)
- [`IndependenceTest`](@ref)

```@docs
independence
IndependenceTest
```

## [`SurrogateAssociationTest`](@ref)

```@docs
SurrogateAssociationTest
SurrogateAssociationTestResult
```

## [`LocalPermutationTest`](@ref)

```@docs
LocalPermutationTest
LocalPermutationTestResult
```

## [`JointDistanceDistributionTest`](@ref)

```@docs
JointDistanceDistributionTest
JDDTestResult
```

## [`CorrTest`](@ref)

```@docs
CorrTest
CorrTestResult
```

## [`SECMITest`](@ref)

```@docs
SECMITest
SECMITestResult
```