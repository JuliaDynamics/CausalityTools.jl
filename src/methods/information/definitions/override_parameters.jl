using Accessors

export estimator_with_overridden_parameters

# For internal use only.
"""
    estimator_with_overridden_parameters(definition, lower_level_estimator) → e::typeof(lower_level_estimator)

Given some higher-level `definition` of an information measure, which is to be 
estimated using some `lower_level_estimator`, return a modified version of 
the estimator in which its parameter have been overriden by any overlapping
parameters from the `defintiion`.

This method is explicitly extended for each possible decomposition.
"""
function estimator_with_overridden_parameters(definition, lower_level_estimator) end

const TSALLIS_MULTIVARIATE_MEASURES = Union{
    CMITsallisPapapetrou, 
    MITsallisFuruichi, MITsallisMartin,
    ConditionalEntropyTsallisAbe, ConditionalEntropyTsallisFuruichi,
    JointEntropyTsallis,
}

const RENYI_MULTIVARIATE_MEASURES = Union{
    TERenyiJizba,
    CMIRenyiPoczos, CMIRenyiSarbu, CMIRenyiJizba,
    MIRenyiJizba, MIRenyiSarbu,
    JointEntropyRenyi,
}

const SHANNON_MULTIVARIATE_MEASURES = Union{
    CMIShannon,
    MIShannon,
    ConditionalEntropyShannon,
    JointEntropyShannon,
    TEShannon,
}


function estimator_with_overridden_parameters(
        definition::TSALLIS_MULTIVARIATE_MEASURES, 
        est::InformationMeasureEstimator{<:Tsallis}
    )
    # The low-level definition
    lowdef = est.definition
   
    # Update the low-level definition. Have to do this step-wise. Ugly, but works.
    modified_lowdef = Accessors.@set lowdef.base = definition.base # update `base` field
    modified_lowdef = Accessors.@set modified_lowdef.q = definition.q # update `q` field

    # Set the definition for the low-level estimator to the updated definition.
    modified_est = Accessors.@set est.definition = modified_lowdef
    
    return modified_est
end

function estimator_with_overridden_parameters(
        definition::RENYI_MULTIVARIATE_MEASURES, 
        est::InformationMeasureEstimator{<:Renyi}
    )
    lowdef = est.definition
    modified_lowdef = Accessors.@set lowdef.base = definition.base # update `base` field
    modified_lowdef = Accessors.@set modified_lowdef.q = definition.q # update `q` field
    modified_est = Accessors.@set est.definition = modified_lowdef
    return modified_est
end

function estimator_with_overridden_parameters(
        definition::SHANNON_MULTIVARIATE_MEASURES, 
        est::InformationMeasureEstimator{<:Shannon}
    )
    lowdef = est.definition
    modified_lowdef = Accessors.@set lowdef.base = definition.base # update `base` field
    modified_est = Accessors.@set est.definition = modified_lowdef
    return modified_est
end

function estimator_with_overridden_parameters(
        definition::CMIShannon, 
        est::MutualInformationEstimator{<:MIShannon}
    )
    lowdef = est.definition
    modified_lowdef = Accessors.@set lowdef.base = definition.base # update `base` field
    modified_est = Accessors.@set est.definition = modified_lowdef
    return modified_est
end