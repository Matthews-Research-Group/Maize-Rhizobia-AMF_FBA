function result = assignResults(result, scenario, RGR_values_combined, CO2_levels, Early_RGR_noBacteroidnoAMF, Mid_RGR_noBacteroidnoAMF, Late_RGR_noBacteroidnoAMF, Early_RGR_withBacteroidnoAMF, ...
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
    MidRGR_WithBacteroidwithAMF_PFluxes, LateRGR_WithBacteroidwithAMF_PFluxes, Nodule_CO2_efflux_early, N2_values_early, EarlyRGR_noBacteroidwithAMF_Nfluxes)
    
    result{1, scenario} = RGR_values_combined;
    result{2, scenario} = CO2_levels;
    result{3, scenario} = Early_RGR_withBacteroidnoAMF;
    result{4, scenario} = Mid_RGR_withBacteroidnoAMF;
    result{5, scenario} = Late_RGR_withBacteroidnoAMF;
    result{6, scenario} = Early_RGR_noBacteroidwithAMF;
    result{7, scenario} = Mid_RGR_noBacteroidwithAMF;
    result{8, scenario} = Late_RGR_noBacteroidwithAMF;
    result{9, scenario} = EarlyRGR_noBacteroidwithAMF_AMFBiomass;
    result{10, scenario} = MidRGR_noBacteroidwithAMF_AMFBiomass;
    result{11, scenario} = LateRGR_noBacteroidwithAMF_AMFBiomass;
    result{12, scenario} = EarlyRGR_noBacteroidwithAMF_GlucoseFluxes;
    result{13, scenario} = MidRGR_noBacteroidwithAMF_GlucoseFluxes;
    result{14, scenario} = LateRGR_noBacteroidwithAMF_GlucoseFluxes;
    result{15, scenario} = EarlyRGR_noBacteroidwithAMF_PalmitateFluxes;
    result{16, scenario} = MidRGR_noBacteroidwithAMF_PalmitateFluxes;
    result{17, scenario} = LateRGR_noBacteroidwithAMF_PalmitateFluxes;
    result{18, scenario} = EarlyRGR_noBacteroidwithAMF_CO2Fluxes;
    result{19, scenario} = MidRGR_noBacteroidwithAMF_CO2Fluxes;
    result{20, scenario} = LateRGR_noBacteroidwithAMF_CO2Fluxes;
    result{21, scenario} = EarlyRGR_noBacteroidwithAMF_PFluxes;
    result{22, scenario} = MidRGR_noBacteroidwithAMF_PFluxes;
    result{23, scenario} = LateRGR_noBacteroidwithAMF_PFluxes;
    result{24, scenario} = EarlyRGR_WithBacteroidwithAMF_AMFBiomass;
    result{25, scenario} = MidRGR_WithBacteroidwithAMF_AMFBiomass;
    result{26, scenario} = LateRGR_WithBacteroidwithAMF_AMFBiomass;
    result{27, scenario} = EarlyRGR_WithBacteroidwithAMF_GlucoseFluxes;
    result{28, scenario} = MidRGR_WithBacteroidwithAMF_GlucoseFluxes;
    result{29, scenario} = LateRGR_WithBacteroidwithAMF_GlucoseFluxes;
    result{30, scenario} = EarlyRGR_WithBacteroidwithAMF_PalmitateFluxes;
    result{31, scenario} = MidRGR_WithBacteroidwithAMF_PalmitateFluxes;
    result{32, scenario} = LateRGR_WithBacteroidwithAMF_PalmitateFluxes;
    result{33, scenario} = EarlyRGR_WithBacteroidwithAMF_CO2Fluxes;
    result{34, scenario} = MidRGR_WithBacteroidwithAMF_CO2Fluxes;
    result{35, scenario} = LateRGR_WithBacteroidwithAMF_CO2Fluxes;
    result{36, scenario} = EarlyRGR_WithBacteroidwithAMF_PFluxes;
    result{37, scenario} = MidRGR_WithBacteroidwithAMF_PFluxes;
    result{38, scenario} = LateRGR_WithBacteroidwithAMF_PFluxes;
    result{39, scenario} = Early_RGR_noBacteroidnoAMF;
    result{40, scenario} = Mid_RGR_noBacteroidnoAMF;
    result{41, scenario} = Late_RGR_noBacteroidnoAMF;
    result{42, scenario} = Early_RGR_WithBacteroidwithAMF;
    result{43, scenario} = Mid_RGR_WithBacteroidwithAMF;
    result{44, scenario} = Late_RGR_WithBacteroidwithAMF;
    result{45, scenario} = Nodule_CO2_efflux_early;
    result{46, scenario} = N2_values_early;
    result{47, scenario} = EarlyRGR_noBacteroidwithAMF_Nfluxes;
    
end
