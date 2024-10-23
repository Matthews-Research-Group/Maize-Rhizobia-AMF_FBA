function [new_parameters] = modifyGlobalVariable(index, newValue)
    % Declare all parameters as global
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
    
    Carbo_proportion = 0.73376623 %(VARY FOR SENSITIVITY)
    Lipid_proportion = 0.03246753 %(VARY FOR SENSITIVITY)
    Lignin_proportion = 0.1038961 %(VARY FOR SENSITIVITY)
    Organic_proportion = 0.06493506 %(VARY FOR SENSITIVITY)
    Materials_proportion = 0.06493506 %(VARY FOR SENSITIVITY)

    TransportCost = 0.25 % Generic transport cost for inter-tissue movement of metabolites (VARY FOR SENSITIVITY)
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
            RootProportion = newValue;
        case 6
            NoduleProportion = newValue;
        case 7
            AMF_N_Benefit = newValue;
        case 8
            AMF_P_Benefit = newValue;
        case 9
            NecessaryAMFBiomass = newValue;
        case 10
            AMFGAM = newValue;
        case 11
            AMFNGAM = newValue;
        case 12
            TransportCost = newValue;
        otherwise
            error('Index out of range. Please check the parameter index.');
    end
    new_parameters = [BacteroidNGAM, PlantGAM, PlantNGAM, RootNGAM, RootProportion, ...
    NoduleProportion, AMF_N_Benefit, AMF_P_Benefit, ...
    NecessaryAMFBiomass, AMFGAM AMFNGAM, TransportCost]; 
end