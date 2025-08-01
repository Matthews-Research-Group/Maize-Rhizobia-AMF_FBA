%% Initalization of COBRA

initCobraToolbox(false)


%% Key sensitivity parameters
environment = getEnvironment();
BacteroidNGAM = 3 %(VARY FOR SENSITIVITY)
PlantGAM = 19 %(VARY FOR SENSITIVITY)
PlantNGAM = 0.204 %(VARY FO                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 R SENSITIVITY)
RootNGAM = 7.36 %(VARY FOR SENSITIVITY)

ShootProportion = 0.9 %(VARY FOR SENSITIVITY)
RootProportion = 1 - ShootProportion %(VARY FOR SENSITIVITY)
PlantProportion = 0.98 %(VARY FOR SENSITIVITY)
NoduleProportion = 1 - PlantProportion %(VARY FOR SENSITIVITY)

AMF_N_Benefit = 0.23 %(VARY FOR SENSITIVITY)
AMF_P_Benefit = 2.16 %(VARY FOR SENSITIVITY)
NecessaryAMFBiomass = 0.10145398 %(VARY FOR SENSITIVITY)
AMFGAM = 60 %(VARY FOR SENSITIVITY)
AMFNGAM = 3.2 %(VARY FOR SENSITIVITY)

TransportCost = 0.25 % Generic transport cost for inter-tissue movement of metabolites (VARY FOR SENSITIVITY)

Carbo_proportion = 0.73376623 %(VARY FOR SENSITIVITY)
Lipid_proportion = 0.03246753 %(VARY FOR SENSITIVITY)
Lignin_proportion = 0.1038961 %(VARY FOR SENSITIVITY)
Organic_proportion = 0.06493506 %(VARY FOR SENSITIVITY)
Materials_proportion = 0.06493506 %(VARY FOR SENSITIVITY)

parameter_names = {'BacteroidNGAM', 'PlantGAM', 'PlantNGAM', 'RootNGAM', 'RootProportion', ...
    'NoduleProportion', 'AMF_N_Benefit', 'AMF_P_Benefit', ...
    'NecessaryAMFBiomass', 'AMFGAM', 'AMFNGAM', 'TransportCost'}; 

parameters = [BacteroidNGAM, PlantGAM, PlantNGAM, RootNGAM, RootProportion, ...
        NoduleProportion, AMF_N_Benefit, AMF_P_Benefit, ...
        NecessaryAMFBiomass, AMFGAM, AMFNGAM, TransportCost]; 

percentChange = 0.10;

% Preallocate results matrix
numParams = length(parameters);
numOutputs = 47;

echo off

% Sensitivity analysis loop

addAttachedFiles(gcp,["assignResults.m" "calculateBiomassCoefs.m" "modifyGlobalVariable" "run_analysis_abbrev_corrected.m" "mySave.m"])

parfor x = 1:numParams
    result = cell(47, 3);
    BacteroidNGAM = 3 %(VARY FOR SENSITIVITY)
    PlantGAM = 19 %(VARY FOR SENSITIVITY)
    PlantNGAM = 0.204 %(VARY FOR SENSITIVITY)
    RootNGAM = 7.36 %(VARY FOR SENSITIVITY)

    ShootProportion = 0.9 %(VARY FOR SENSITIVITY)
    RootProportion = 1 - ShootProportion %(VARY FOR SENSITIVITY)
    PlantProportion = 0.98 %(VARY FOR SENSITIVITY)
    NoduleProportion = 1 - PlantProportion %(VARY FOR SENSITIVITY)

    AMF_N_Benefit = 0.23 %(VARY FOR SENSITIVITY)
    AMF_P_Benefit = 2.16 %(VARY FOR SENSITIVITY)
    NecessaryAMFBiomass = 0.0972 %(VARY FOR SENSITIVITY)
    AMFGAM = 60 %(VARY FOR SENSITIVITY)
    AMFNGAM = 3.2 %(VARY FOR SENSITIVITY)

    TransportCost = 0.25 % Generic transport cost for inter-tissue movement of metabolites (VARY FOR SENSITIVITY)

    Carbo_proportion = 0.73376623 %(VARY FOR SENSITIVITY)
    Lipid_proportion = 0.03246753 %(VARY FOR SENSITIVITY)
    Lignin_proportion = 0.1038961 %(VARY FOR SENSITIVITY)
    Organic_proportion = 0.06493506 %(VARY FOR SENSITIVITY)
    Materials_proportion = 0.06493506 %(VARY FOR SENSITIVITY)

    parameters = [BacteroidNGAM, PlantGAM, PlantNGAM, RootNGAM, RootProportion, ...
        NoduleProportion, AMF_N_Benefit, AMF_P_Benefit, ...
        NecessaryAMFBiomass, AMFGAM, AMFNGAM, TransportCost]; 

    percentChange = 0.10;
    restoreEnvironment(environment);
    originalValue = parameters(x);

    % % original value
    parameters = modifyGlobalVariable(x, originalValue);  
    [RGR_values_combined, CO2_levels, Early_RGR_noBacteroidnoAMF, Mid_RGR_noBacteroidnoAMF, Late_RGR_noBacteroidnoAMF, Early_RGR_withBacteroidnoAMF, ...
    Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
    Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_WithBacteroidwithAMF, Mid_RGR_WithBacteroidwithAMF, Late_RGR_WithBacteroidwithAMF, EarlyRGR_noBacteroidwithAMF_AMFBiomass, ...
    MidRGR_noBacteroidwithAMF_AMFBiomass, LateRGR_noBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_noBacteroidwithAMF_GlucoseFluxes, MidRGR_noBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_noBacteroidwithAMF_GlucoseFluxes, EarlyRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_noBacteroidwithAMF_PalmitateFluxes, LateRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_noBacteroidwithAMF_CO2Fluxes, MidRGR_noBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_noBacteroidwithAMF_CO2Fluxes, EarlyRGR_noBacteroidwithAMF_PFluxes, ...
    MidRGR_noBacteroidwithAMF_PFluxes, LateRGR_noBacteroidwithAMF_PFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_AMFBiomass, ...
    MidRGR_WithBacteroidwithAMF_AMFBiomass, LateRGR_WithBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_WithBacteroidwithAMF_GlucoseFluxes, MidRGR_WithBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_WithBacteroidwithAMF_GlucoseFluxes, EarlyRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_WithBacteroidwithAMF_PalmitateFluxes, LateRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_CO2Fluxes, MidRGR_WithBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_WithBacteroidwithAMF_CO2Fluxes, EarlyRGR_WithBacteroidwithAMF_PFluxes, ...
    MidRGR_WithBacteroidwithAMF_PFluxes, LateRGR_WithBacteroidwithAMF_PFluxes, ...
    Nodule_CO2_efflux_early, N2_values_early, EarlyRGR_noBacteroidwithAMF_Nfluxes] = run_analysis_abbrev_corrected(parameters)
    result = assignResults(result, 1, RGR_values_combined, CO2_levels, Early_RGR_noBacteroidnoAMF, Mid_RGR_noBacteroidnoAMF, Late_RGR_noBacteroidnoAMF, Early_RGR_withBacteroidnoAMF, ...
    Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
    Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_WithBacteroidwithAMF, Mid_RGR_WithBacteroidwithAMF, Late_RGR_WithBacteroidwithAMF, EarlyRGR_noBacteroidwithAMF_AMFBiomass, ...
    MidRGR_noBacteroidwithAMF_AMFBiomass, LateRGR_noBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_noBacteroidwithAMF_GlucoseFluxes, MidRGR_noBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_noBacteroidwithAMF_GlucoseFluxes, EarlyRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_noBacteroidwithAMF_PalmitateFluxes, LateRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_noBacteroidwithAMF_CO2Fluxes, MidRGR_noBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_noBacteroidwithAMF_CO2Fluxes, EarlyRGR_noBacteroidwithAMF_PFluxes, ...
    MidRGR_noBacteroidwithAMF_PFluxes, LateRGR_noBacteroidwithAMF_PFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_AMFBiomass, ...
    MidRGR_WithBacteroidwithAMF_AMFBiomass, LateRGR_WithBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_WithBacteroidwithAMF_GlucoseFluxes, MidRGR_WithBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_WithBacteroidwithAMF_GlucoseFluxes, EarlyRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_WithBacteroidwithAMF_PalmitateFluxes, LateRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_CO2Fluxes, MidRGR_WithBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_WithBacteroidwithAMF_CO2Fluxes, EarlyRGR_WithBacteroidwithAMF_PFluxes, ...
    MidRGR_WithBacteroidwithAMF_PFluxes, LateRGR_WithBacteroidwithAMF_PFluxes, Nodule_CO2_efflux_early, N2_values_early, EarlyRGR_noBacteroidwithAMF_Nfluxes);

    % Adjust global variables for the sensitivity analysis
    % up 10%
    parameters = modifyGlobalVariable(x, originalValue * (1 + percentChange));  
    [RGR_values_combined, CO2_levels, Early_RGR_noBacteroidnoAMF, Mid_RGR_noBacteroidnoAMF, Late_RGR_noBacteroidnoAMF, Early_RGR_withBacteroidnoAMF, ...
    Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
    Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_WithBacteroidwithAMF, Mid_RGR_WithBacteroidwithAMF, Late_RGR_WithBacteroidwithAMF, EarlyRGR_noBacteroidwithAMF_AMFBiomass, ...
    MidRGR_noBacteroidwithAMF_AMFBiomass, LateRGR_noBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_noBacteroidwithAMF_GlucoseFluxes, MidRGR_noBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_noBacteroidwithAMF_GlucoseFluxes, EarlyRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_noBacteroidwithAMF_PalmitateFluxes, LateRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_noBacteroidwithAMF_CO2Fluxes, MidRGR_noBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_noBacteroidwithAMF_CO2Fluxes, EarlyRGR_noBacteroidwithAMF_PFluxes, ...
    MidRGR_noBacteroidwithAMF_PFluxes, LateRGR_noBacteroidwithAMF_PFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_AMFBiomass, ...
    MidRGR_WithBacteroidwithAMF_AMFBiomass, LateRGR_WithBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_WithBacteroidwithAMF_GlucoseFluxes, MidRGR_WithBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_WithBacteroidwithAMF_GlucoseFluxes, EarlyRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_WithBacteroidwithAMF_PalmitateFluxes, LateRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_CO2Fluxes, MidRGR_WithBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_WithBacteroidwithAMF_CO2Fluxes, EarlyRGR_WithBacteroidwithAMF_PFluxes, ...
    MidRGR_WithBacteroidwithAMF_PFluxes, LateRGR_WithBacteroidwithAMF_PFluxes, ...
    Nodule_CO2_efflux_early, N2_values_early, EarlyRGR_noBacteroidwithAMF_Nfluxes] = run_analysis_abbrev_corrected(parameters)
    result = assignResults(result, 2, RGR_values_combined, CO2_levels, Early_RGR_noBacteroidnoAMF, Mid_RGR_noBacteroidnoAMF, Late_RGR_noBacteroidnoAMF, Early_RGR_withBacteroidnoAMF, ...
    Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
    Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_WithBacteroidwithAMF, Mid_RGR_WithBacteroidwithAMF, Late_RGR_WithBacteroidwithAMF, EarlyRGR_noBacteroidwithAMF_AMFBiomass, ...
    MidRGR_noBacteroidwithAMF_AMFBiomass, LateRGR_noBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_noBacteroidwithAMF_GlucoseFluxes, MidRGR_noBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_noBacteroidwithAMF_GlucoseFluxes, EarlyRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_noBacteroidwithAMF_PalmitateFluxes, LateRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_noBacteroidwithAMF_CO2Fluxes, MidRGR_noBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_noBacteroidwithAMF_CO2Fluxes, EarlyRGR_noBacteroidwithAMF_PFluxes, ...
    MidRGR_noBacteroidwithAMF_PFluxes, LateRGR_noBacteroidwithAMF_PFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_AMFBiomass, ...
    MidRGR_WithBacteroidwithAMF_AMFBiomass, LateRGR_WithBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_WithBacteroidwithAMF_GlucoseFluxes, MidRGR_WithBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_WithBacteroidwithAMF_GlucoseFluxes, EarlyRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_WithBacteroidwithAMF_PalmitateFluxes, LateRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_CO2Fluxes, MidRGR_WithBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_WithBacteroidwithAMF_CO2Fluxes, EarlyRGR_WithBacteroidwithAMF_PFluxes, ...
    MidRGR_WithBacteroidwithAMF_PFluxes, LateRGR_WithBacteroidwithAMF_PFluxes, Nodule_CO2_efflux_early, N2_values_early, EarlyRGR_noBacteroidwithAMF_Nfluxes);

    % % down 10%
     parameters = modifyGlobalVariable(x, originalValue * (1 - percentChange));  
     [RGR_values_combined, CO2_levels, Early_RGR_noBacteroidnoAMF, Mid_RGR_noBacteroidnoAMF, Late_RGR_noBacteroidnoAMF, Early_RGR_withBacteroidnoAMF, ...
    Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
    Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_WithBacteroidwithAMF, Mid_RGR_WithBacteroidwithAMF, Late_RGR_WithBacteroidwithAMF, EarlyRGR_noBacteroidwithAMF_AMFBiomass, ...
    MidRGR_noBacteroidwithAMF_AMFBiomass, LateRGR_noBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_noBacteroidwithAMF_GlucoseFluxes, MidRGR_noBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_noBacteroidwithAMF_GlucoseFluxes, EarlyRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_noBacteroidwithAMF_PalmitateFluxes, LateRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_noBacteroidwithAMF_CO2Fluxes, MidRGR_noBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_noBacteroidwithAMF_CO2Fluxes, EarlyRGR_noBacteroidwithAMF_PFluxes, ...
    MidRGR_noBacteroidwithAMF_PFluxes, LateRGR_noBacteroidwithAMF_PFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_AMFBiomass, ...
    MidRGR_WithBacteroidwithAMF_AMFBiomass, LateRGR_WithBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_WithBacteroidwithAMF_GlucoseFluxes, MidRGR_WithBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_WithBacteroidwithAMF_GlucoseFluxes, EarlyRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_WithBacteroidwithAMF_PalmitateFluxes, LateRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_CO2Fluxes, MidRGR_WithBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_WithBacteroidwithAMF_CO2Fluxes, EarlyRGR_WithBacteroidwithAMF_PFluxes, ...
    MidRGR_WithBacteroidwithAMF_PFluxes, LateRGR_WithBacteroidwithAMF_PFluxes, ...
    Nodule_CO2_efflux_early, N2_values_early, EarlyRGR_noBacteroidwithAMF_Nfluxes] = run_analysis_abbrev_corrected(parameters)
    result = assignResults(result, 3, RGR_values_combined, CO2_levels, Early_RGR_noBacteroidnoAMF, Mid_RGR_noBacteroidnoAMF, Late_RGR_noBacteroidnoAMF, Early_RGR_withBacteroidnoAMF, ...
    Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
    Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_WithBacteroidwithAMF, Mid_RGR_WithBacteroidwithAMF, Late_RGR_WithBacteroidwithAMF, EarlyRGR_noBacteroidwithAMF_AMFBiomass, ...
    MidRGR_noBacteroidwithAMF_AMFBiomass, LateRGR_noBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_noBacteroidwithAMF_GlucoseFluxes, MidRGR_noBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_noBacteroidwithAMF_GlucoseFluxes, EarlyRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_noBacteroidwithAMF_PalmitateFluxes, LateRGR_noBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_noBacteroidwithAMF_CO2Fluxes, MidRGR_noBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_noBacteroidwithAMF_CO2Fluxes, EarlyRGR_noBacteroidwithAMF_PFluxes, ...
    MidRGR_noBacteroidwithAMF_PFluxes, LateRGR_noBacteroidwithAMF_PFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_AMFBiomass, ...
    MidRGR_WithBacteroidwithAMF_AMFBiomass, LateRGR_WithBacteroidwithAMF_AMFBiomass, ...
    EarlyRGR_WithBacteroidwithAMF_GlucoseFluxes, MidRGR_WithBacteroidwithAMF_GlucoseFluxes, ...
    LateRGR_WithBacteroidwithAMF_GlucoseFluxes, EarlyRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    MidRGR_WithBacteroidwithAMF_PalmitateFluxes, LateRGR_WithBacteroidwithAMF_PalmitateFluxes, ...
    EarlyRGR_WithBacteroidwithAMF_CO2Fluxes, MidRGR_WithBacteroidwithAMF_CO2Fluxes, ...
    LateRGR_WithBacteroidwithAMF_CO2Fluxes, EarlyRGR_WithBacteroidwithAMF_PFluxes, ...
    MidRGR_WithBacteroidwithAMF_PFluxes, LateRGR_WithBacteroidwithAMF_PFluxes,Nodule_CO2_efflux_early, N2_values_early, EarlyRGR_noBacteroidwithAMF_Nfluxes);
    
    disp(result)
    %result = cell2mat(result)
    filename = sprintf('results_%s.mat',parameter_names{x})
    parsave(filename,result)
end

function parsave(fname, x)
    save(fname, 'x')
end