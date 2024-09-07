% Parameters
global BacteroidNGAM PlantGAM PlantNGAM RootNGAM
global ShootProportion RootProportion PlantProportion NoduleProportion
global AMF_N_Benefit AMF_P_Benefit NecessaryAMFBiomass AMFGAM AMFNGAM
global TransportCost
global Carbo_proportion Lipid_proportion Lignin_proportion Organic_proportion Materials_proportion

% Outputs
global RGR_values_combined CO2_levels Early_RGR_withBacteroidnoAMF ...
    Mid_RGR_withBacteroidnoAMF Late_RGR_withBacteroidnoAMF Early_RGR_noBacteroidwithAMF ...
    Mid_RGR_noBacteroidwithAMF Late_RGR_noBacteroidwithAMF Early_RGR_noBacteroidwithAMF_AMFBiomass ...
    Mid_RGR_noBacteroidwithAMF_AMFBiomass Late_RGR_noBacteroidwithAMF_AMFBiomass ...
    Early_RGR_noBacteroidwithAMF_GlucoseFluxes Mid_RGR_noBacteroidwithAMF_GlucoseFluxes ...
    Late_RGR_noBacteroidwithAMF_GlucoseFluxes Early_RGR_noBacteroidwithAMF_PalmitateFluxes ...
    Mid_RGR_noBacteroidwithAMF_PalmitateFluxes Late_RGR_noBacteroidwithAMF_PalmitateFluxes ...
    Early_RGR_noBacteroidwithAMF_CO2Fluxes Mid_RGR_noBacteroidwithAMF_CO2Fluxes ...
    Late_RGR_noBacteroidwithAMF_CO2Fluxes Early_RGR_noBacteroidwithAMF_PFluxes ...
    Mid_RGR_noBacteroidwithAMF_PFluxes Late_RGR_noBacteroidwithAMF_PFluxes 


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

%% SA

parameters = [BacteroidNGAM, PlantGAM, PlantNGAM, RootNGAM, ShootProportion, ...
    RootProportion, PlantProportion, NoduleProportion, AMF_N_Benefit, AMF_P_Benefit, ...
    NecessaryAMFBiomass, AMFGAM AMFNGAM, TransportCost, Carbo_proportion, ... 
    Lipid_proportion, Lignin_proportion, Organic_proportion, Materials_proportion]; 

percentChange = 0.10;

% Preallocate results matrix
numParams = length(parameters);
numOutputs = 23;
result = cell(numParams, numOutputs, 3);  % Assuming some output result can be stored here

% Sensitivity analysis loop
for i = 1:numParams
    originalValue = parameters(i);

    % % original value
    modifyGlobalVariable(i, originalValue);  
    run('Analysis_Script_JRRV1.m');
    assignResults(result, i, 1, RGR_values_combined, CO2_levels, Early_RGR_withBacteroidnoAMF, ...
        Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
        Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_noBacteroidwithAMF_AMFBiomass, ...
        Mid_RGR_noBacteroidwithAMF_AMFBiomass, Late_RGR_noBacteroidwithAMF_AMFBiomass, ...
        Early_RGR_noBacteroidwithAMF_GlucoseFluxes, Mid_RGR_noBacteroidwithAMF_GlucoseFluxes, ...
        Late_RGR_noBacteroidwithAMF_GlucoseFluxes, Early_RGR_noBacteroidwithAMF_PalmitateFluxes, ...
        Mid_RGR_noBacteroidwithAMF_PalmitateFluxes, Late_RGR_noBacteroidwithAMF_PalmitateFluxes, ...
        Early_RGR_noBacteroidwithAMF_CO2Fluxes, Mid_RGR_noBacteroidwithAMF_CO2Fluxes, ...
        Late_RGR_noBacteroidwithAMF_CO2Fluxes, Early_RGR_noBacteroidwithAMF_PFluxes, ...
        Mid_RGR_noBacteroidwithAMF_PFluxes, Late_RGR_noBacteroidwithAMF_PFluxes);

    % Adjust global variables for the sensitivity analysis
    % up 10%
    modifyGlobalVariable(i, originalValue * (1 + percentChange));  
    run('Analysis_Script_JRRV1.m'); 
    assignResults(result, i, 2, RGR_values_combined, CO2_levels, Early_RGR_withBacteroidnoAMF, ...
        Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
        Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_noBacteroidwithAMF_AMFBiomass, ...
        Mid_RGR_noBacteroidwithAMF_AMFBiomass, Late_RGR_noBacteroidwithAMF_AMFBiomass, ...
        Early_RGR_noBacteroidwithAMF_GlucoseFluxes, Mid_RGR_noBacteroidwithAMF_GlucoseFluxes, ...
        Late_RGR_noBacteroidwithAMF_GlucoseFluxes, Early_RGR_noBacteroidwithAMF_PalmitateFluxes, ...
        Mid_RGR_noBacteroidwithAMF_PalmitateFluxes, Late_RGR_noBacteroidwithAMF_PalmitateFluxes, ...
        Early_RGR_noBacteroidwithAMF_CO2Fluxes, Mid_RGR_noBacteroidwithAMF_CO2Fluxes, ...
        Late_RGR_noBacteroidwithAMF_CO2Fluxes, Early_RGR_noBacteroidwithAMF_PFluxes, ...
        Mid_RGR_noBacteroidwithAMF_PFluxes, Late_RGR_noBacteroidwithAMF_PFluxes);

    % % down 10%
    % modifyGlobalVariable(i, originalValue * (1 - percentChange));  
    % run('Analysis_Script_JRRV1.m');
    % assignResults(result, i, 3, RGR_values_combined, CO2_levels, Early_RGR_withBacteroidnoAMF, ...
    %     Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
    %     Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_noBacteroidwithAMF_AMFBiomass, ...
    %     Mid_RGR_noBacteroidwithAMF_AMFBiomass, Late_RGR_noBacteroidwithAMF_AMFBiomass, ...
    %     Early_RGR_noBacteroidwithAMF_GlucoseFluxes, Mid_RGR_noBacteroidwithAMF_GlucoseFluxes, ...
    %     Late_RGR_noBacteroidwithAMF_GlucoseFluxes, Early_RGR_noBacteroidwithAMF_PalmitateFluxes, ...
    %     Mid_RGR_noBacteroidwithAMF_PalmitateFluxes, Late_RGR_noBacteroidwithAMF_PalmitateFluxes, ...
    %     Early_RGR_noBacteroidwithAMF_CO2Fluxes, Mid_RGR_noBacteroidwithAMF_CO2Fluxes, ...
    %     Late_RGR_noBacteroidwithAMF_CO2Fluxes, Early_RGR_noBacteroidwithAMF_PFluxes, ...
    %     Mid_RGR_noBacteroidwithAMF_PFluxes, Late_RGR_noBacteroidwithAMF_PFluxes);    
    % 
        
end

% Display or process the results as needed
disp(result);


%% Functions
function modifyGlobalVariable(index, newValue)
    % Declare all parameters as global
    global BacteroidNGAM PlantGAM PlantNGAM RootNGAM ShootProportion RootProportion
    global PlantProportion NoduleProportion AMF_N_Benefit AMF_P_Benefit
    global NecessaryAMFBiomass AMFGAM AMFNGAM TransportCost Carbo_proportion
    global Lipid_proportion Lignin_proportion Organic_proportion Materials_proportion

    % Use a switch statement to update the appropriate parameter
    switch index
        case 1
            BacteroidNGAM = newValue;
        case 2
            PlantGAM = newValue;
        case 3
            PlantNGAM = newValue;
        case 4
            RootNGAM = newValue;
        case 5
            ShootProportion = newValue;
        case 6
            RootProportion = newValue;
        case 7
            PlantProportion = newValue;
        case 8
            NoduleProportion = newValue;
        case 9
            AMF_N_Benefit = newValue;
        case 10
            AMF_P_Benefit = newValue;
        case 11
            NecessaryAMFBiomass = newValue;
        case 12
            AMFGAM = newValue;
        case 13
            AMFNGAM = newValue;
        case 14
            TransportCost = newValue;
        case 15
            Carbo_proportion = newValue;
        case 16
            Lipid_proportion = newValue;
        case 17
            Lignin_proportion = newValue;
        case 18
            Organic_proportion = newValue;
        case 19
            Materials_proportion = newValue;
        otherwise
            error('Index out of range. Please check the parameter index.');
    end
end


%% Functions
function assignResults(result, i, scenario, RGR_values_combined, CO2_levels, Early_RGR_withBacteroidnoAMF, ...
        Mid_RGR_withBacteroidnoAMF, Late_RGR_withBacteroidnoAMF, Early_RGR_noBacteroidwithAMF, ...
        Mid_RGR_noBacteroidwithAMF, Late_RGR_noBacteroidwithAMF, Early_RGR_noBacteroidwithAMF_AMFBiomass, ...
        Mid_RGR_noBacteroidwithAMF_AMFBiomass, Late_RGR_noBacteroidwithAMF_AMFBiomass, ...
        Early_RGR_noBacteroidwithAMF_GlucoseFluxes, Mid_RGR_noBacteroidwithAMF_GlucoseFluxes, ...
        Late_RGR_noBacteroidwithAMF_GlucoseFluxes, Early_RGR_noBacteroidwithAMF_PalmitateFluxes, ...
        Mid_RGR_noBacteroidwithAMF_PalmitateFluxes, Late_RGR_noBacteroidwithAMF_PalmitateFluxes, ...
        Early_RGR_noBacteroidwithAMF_CO2Fluxes, Mid_RGR_noBacteroidwithAMF_CO2Fluxes, ...
        Late_RGR_noBacteroidwithAMF_CO2Fluxes, Early_RGR_noBacteroidwithAMF_PFluxes, ...
        Mid_RGR_noBacteroidwithAMF_PFluxes, Late_RGR_noBacteroidwithAMF_PFluxes)
    
    result{i, 1, scenario} = RGR_values_combined;
    result{i, 2, scenario} = CO2_levels;
    result{i, 3, scenario} = Early_RGR_withBacteroidnoAMF;
    result{i, 4, scenario} = Mid_RGR_withBacteroidnoAMF;
    result{i, 5, scenario} = Late_RGR_withBacteroidnoAMF;
    result{i, 6, scenario} = Early_RGR_noBacteroidwithAMF;
    result{i, 7, scenario} = Mid_RGR_noBacteroidwithAMF;
    result{i, 8, scenario} = Late_RGR_noBacteroidwithAMF;
    result{i, 9, scenario} = Early_RGR_noBacteroidwithAMF_AMFBiomass;
    result{i, 10, scenario} = Mid_RGR_noBacteroidwithAMF_AMFBiomass;
    result{i, 11, scenario} = Late_RGR_noBacteroidwithAMF_AMFBiomass;
    result{i, 12, scenario} = Early_RGR_noBacteroidwithAMF_GlucoseFluxes;
    result{i, 13, scenario} = Mid_RGR_noBacteroidwithAMF_GlucoseFluxes;
    result{i, 14, scenario} = Late_RGR_noBacteroidwithAMF_GlucoseFluxes;
    result{i, 15, scenario} = Early_RGR_noBacteroidwithAMF_PalmitateFluxes;
    result{i, 16, scenario} = Mid_RGR_noBacteroidwithAMF_PalmitateFluxes;
    result{i, 17, scenario} = Late_RGR_noBacteroidwithAMF_PalmitateFluxes;
    result{i, 18, scenario} = Early_RGR_noBacteroidwithAMF_CO2Fluxes;
    result{i, 19, scenario} = Mid_RGR_noBacteroidwithAMF_CO2Fluxes;
    result{i, 20, scenario} = Late_RGR_noBacteroidwithAMF_CO2Fluxes;
    result{i, 21, scenario} = Early_RGR_noBacteroidwithAMF_PFluxes;
    result{i, 22, scenario} = Mid_RGR_noBacteroidwithAMF_PFluxes;
    result{i, 23, scenario} = Late_RGR_noBacteroidwithAMF_PFluxes;
end
