function [RGR_values_combined, CO2_levels, Early_RGR_noBacteroidnoAMF, Mid_RGR_noBacteroidnoAMF, Late_RGR_noBacteroidnoAMF, Early_RGR_withBacteroidnoAMF, ...
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

% Building base Zea mays model
    parameters = num2cell(parameters);
    
    Carbo_proportion = 0.73376623
    Lipid_proportion = 0.03246753
    Lignin_proportion = 0.1038961 
    Organic_proportion = 0.06493506
    Materials_proportion = 0.06493506 
    
    [BacteroidNGAM, PlantGAM, PlantNGAM, RootNGAM, RootProportion, ...
    NoduleProportion, AMF_N_Benefit, AMF_P_Benefit, ...
    NecessaryAMFBiomass, AMFGAM, AMFNGAM, TransportCost] = parameters{:};
    
    ShootProportion = 1 - RootProportion;
    PlantProportion = 1 - NoduleProportion;
    
    Bd_model = readCbModel('BdiazoModel.xml'); % Bradyrhizobium diazoefficiens model
    Zm_model = readCbModel('ArabidopsisCoreModel.xml'); % Arabidopsis core model that we build the Zea mays model out of

    % Updating and adding some photosynthesis reactions

    Zm_model = addReaction(Zm_model,'PSII_h','reactionFormula','hnu[h] + 0.5 PQ[h] + 0.5 H2O[h] + H[h] -> 0.5 PQH2[h] + 0.25 O2[h] + H[l]');
    Zm_model = addReaction(Zm_model,'Cybb6f_h','reactionFormula','PCox[h] + PQH2[h] -> PQ[h] + 2 H[l] + PCrd[h] + eq[h]');
    Zm_model = addReaction(Zm_model,'QCYC_h','reactionFormula','2 eq[h] + PQ[h] + 2 H[h] -> PQH2[h]');
    Zm_model = addReaction(Zm_model,'CEF_h','reactionFormula','2 Fdrd[h] + 2 H[h] + PQ[h] -> 2 Fdox[h] + PQH2[h]');
    Zm_model = addReaction(Zm_model,'PTOX_h','reactionFormula','O2[h] + 2 PQH2[h] -> 2 H2O[h] + 2 PQ[h]');
    Zm_model = addReaction(Zm_model,'NDHq_h','reactionFormula','H[h] + NADPH[h] + PQ[h] -> NADP[h] + PQH2[h]');

    % Allowing free proton movement between cytosol, stroma, and mitochondria

    Zm_model = addReaction(Zm_model,'Proton_CP_transport','reactionFormula','H[c] -> H[p]');
    Zm_model = addReaction(Zm_model,'Proton_CH_transport','reactionFormula','H[c] -> H[h]');
    Zm_model = addReaction(Zm_model,'Proton_CM_transport','reactionFormula','H[c] -> H[m]');

    Zm_model = changeRxnBounds(Zm_model,'Proton_CP_transport',-1000,'l');
    Zm_model = changeRxnBounds(Zm_model,'Proton_CH_transport',-1000,'l');
    Zm_model = changeRxnBounds(Zm_model,'Proton_CM_transport',-1000,'l');

    % Disabling uptake/export of most exchangeable metabolites in the base
    % model

    DisableTransporters = find(contains(Zm_model.rxns,{'Ex_Ala_c','Ex_Ala_h','Ex_Ala_m', ...
        'Ex_Ala_p','Ex_Arg_c','Ex_Arg_h','Ex_Arg_m','Ex_Arg_p','Ex_Asn_c','Ex_Asn_h','Ex_Asn_m', ...
        'Ex_Asn_p','Ex_Asp_c','Ex_Asp_h','Ex_Asp_m','Ex_Asp_p','Ex_Cys_c','Ex_Cys_h','Ex_Cys_m', ...
        'Ex_Cys_p','Ex_Gln_c','Ex_Gln_h','Ex_Gln_m','Ex_Gln_p','Ex_Glu_c','Ex_Glu_h','Ex_Glu_m', ...
        'Ex_Glu_p','Ex_Gly_c','Ex_Gly_h','Ex_Gly_m','Ex_Gly_p','Ex_His_c','Ex_His_h','Ex_His_m', ...
        'Ex_His_p','Ex_Ile_c','Ex_Ile_h','Ex_Ile_m','Ex_Ile_p','Ex_Leu_c','Ex_Leu_h','Ex_Leu_m', ...
        'Ex_Leu_p','Ex_Lys_c','Ex_Lys_h','Ex_Lys_m','Ex_Lys_p','Ex_Met_c','Ex_Met_h','Ex_Met_m', ...
        'Ex_Met_p','Ex_Phe_c','Ex_Phe_h','Ex_Phe_m','Ex_Phe_p','Ex_Pro_c','Ex_Pro_h','Ex_Pro_m', ...
        'Ex_Pro_p','Ex_Ser_c','Ex_Ser_h','Ex_Ser_m','Ex_Ser_p','Ex_Thr_c','Ex_Thr_h','Ex_Thr_m', ... 
        'Ex_Thr_p','Ex_Trp_c','Ex_Trp_h','Ex_Trp_m','Ex_Trp_p','Ex_Tyr_c','Ex_Tyr_h','Ex_Tyr_m', ...
        'Ex_Tyr_p','Ex_Val_c','Ex_Val_h','Ex_Val_m','Ex_Val_p','Ex_starch','Ex_Glc','Ex_Frc','Ex_Suc', ...
        'Ex_cellulose','Ex_Mas','Ex_MACP','Ex_Tre'}));

    for i=1:numel(DisableTransporters);
        Zm_model = changeRxnBounds(Zm_model,Zm_model.rxns(DisableTransporters(i)),0,'b');
    end

    % Adding reactions necessary for biosynthesis of compounds in the Zea mays
    % biomass equation

    Zm_model = addReaction(Zm_model,'R01227','reactionFormula','GMP[c] + H2O[c] -> Guanosine[c] + Pi[c]');
    Zm_model = addReaction(Zm_model,'R01677','reactionFormula','Guanosine[c] + H2O[c] -> Guanine[c] + Rib[c]');
    Zm_model = addReaction(Zm_model,'R01676','reactionFormula','Guanine[c] + H2O[c] -> Xanthine[c] + NH4[c]');
    Zm_model = addReaction(Zm_model,'R02103','reactionFormula','Xanthine[c] + NAD[c] + H2O[c] -> Urate[c] + NADH[c] + H[c]');
    Zm_model = addReaction(Zm_model,'R02106','reactionFormula','Urate[c] + O2[c] + H2O[c] -> 5-Hydroxyisourate[c] + H2O2[c]');
    Zm_model = addReaction(Zm_model,'Tr_H2O2_cp','reactionFormula','H2O2[c] -> H2O2[p]');
    Zm_model = addReaction(Zm_model,'R06601','reactionFormula','5-Hydroxyisourate[c] + H2O[c] -> OHCU[c]');
    Zm_model = addReaction(Zm_model,'R06604','reactionFormula','OHCU[c] -> CO2[c] + Allantoin[c]');
    Zm_model = addReaction(Zm_model,'R02425','reactionFormula','Allantoin[c] + H2O[c] -> Allantoate[c]');
    Zm_model = addReaction(Zm_model,'R02423','reactionFormula','Allantoate[c] + H2O[c] -> Ureidoglycine[c] + NH4[c] + CO2[c]');
    Zm_model = addReaction(Zm_model,'R05554','reactionFormula','Ureidoglycine[c] + H2O[c] -> Ureidoglycolate[c] + NH4[c]');
    Zm_model = addReaction(Zm_model,'R00776','reactionFormula','Ureidoglycolate[c] -> GLX[c] + urea[c]');
    Zm_model = addReaction(Zm_model,'CM_Urea_Transporters','reactionFormula','urea[c] -> urea[m]');

    Zm_model = addReaction(Zm_model,'Oxalate_synthesis','reactionFormula','For[h] + CO2[h] -> Oxalate[h]');
    Zm_model = addReaction(Zm_model,'UDPGlucuronic_acid_synthesis','reactionFormula','UDPG[c] + 2 NADPH[c] -> UDP-Glucuronic_acid[c] + 2 NADP[c]');
    Zm_model = addReaction(Zm_model,'UDPGalactose_synthesis','reactionFormula','UDPG[c] -> UDP-Galactose[c]');
    Zm_model = addReaction(Zm_model,'UDPXylose_biosynthesis','reactionFormula','UDP-Glucuronic_acid[c] -> UDP-Xylose[c]');
    Zm_model = addReaction(Zm_model,'UDP-Arabinose_biosynthesis','reactionFormula','UDP-Xylose[c] -> UDP-Arabinose[c]');
    Zm_model = changeRxnBounds(Zm_model,'UDP-Arabinose_biosynthesis',-1000,'l');

    Zm_model = addReaction(Zm_model,'Mannose-6-phosphate_biosynthesis','reactionFormula','F6P[c] -> M6P[c]');
    Zm_model = addReaction(Zm_model,'Mannose-6-phosphate_dephosphorylation','reactionFormula','M6P[c] + ADP[c] -> Mannose[c] + ATP[c]');
    Zm_model = addReaction(Zm_model,'UDP-Galacturonate_synthesis','reactionFormula','UDP-Arabinose[c] + CO2[c] -> UDP-Galacturonate[c]');
    Zm_model = addReaction(Zm_model,'G3P_biosynthesis','reactionFormula','DHAP[h] + NADH[h] -> NAD[h] + G3P[h]');
    Zm_model = addReaction(Zm_model,'Glycerol_biosynthesis','reactionFormula','G3P[h] -> Glycerol[h] + Pi[h]');

    Zm_model = addReaction(Zm_model,'Arabinose-1-phosphate_biosynthesis','reactionFormula','UDP-Arabinose[c] + PPi[c] -> H[c] + Arabinose-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Arabinose_biosynthesis','reactionFormula','Arabinose-1-phosphate[c] + ADP[c] -> Arabinose[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'Xylose-1-phosphate_biosynthesis','reactionFormula','UDP-Xylose[c] + PPi[c] <=> H[c] + Xylose-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Xylose_biosynthesis','reactionFormula','Xylose-1-phosphate[c] + ADP[c] -> Xylose[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'Galactose-1-phosphate_biosynthesis','reactionFormula','UDP-Galactose[c] + PPi[c] <=> H[c] + Galactose-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Galactose_biosynthesis','reactionFormula','Galactose-1-phosphate[c] + ADP[c] -> Galactose[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'Glucuronate-1-phosphate_biosynthesis','reactionFormula','UDP-Glucuronic_acid[c] + PPi[c] <=> H[c] + Glucuronate-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Glucuronic_acid_biosynthesis','reactionFormula','Glucuronate-1-phosphate[c] + ADP[c] -> Glucuronic_acid[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'Galacturonate-1-phosphate_biosynthesis','reactionFormula','UDP-Galacturonate[c] + PPi[c] <=> H[c] + Galacturonate-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Galacturonate_biosynthesis','reactionFormula','Galacturonate-1-phosphate[c] + ADP[c] -> Galacturonate[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'LipidPrecursor_biosynthesis','reactionFormula','27 M-ACP[h] + 1 Glycerol[h] -> Lipid_precursor[h] + 27 ACP[h]');

    Zm_model = addReaction(Zm_model,'Prephenate_TR','reactionFormula','PRE[h] -> PRE[c]');
    Zm_model = addReaction(Zm_model,'Coumaryl-alcohol_biosynth','reactionFormula','PRE[h] + 3 ATP[c] + NADH[c] + NADPH[c] -> Coumaryl-alcohol[c] + 3 ADP[c] + PPi[c] + Pi[c] + CO2[c] + NAD[c] + NADP[c]');
    Zm_model = addReaction(Zm_model,'Coniferyl-alcohol_biosynth','reactionFormula','PRE[h] + 3 ATP[c] + NADH[c] + 2 NADPH[c] + O2[c] + aMet[c] -> Coniferyl-alcohol[c] + 3 ADP[c] + NAD[c] + 2 NADP[c] + PPi[c] + Pi[c] + CO2[c] + H2O[c] + H-Cys[c] + ADN[c]');
    Zm_model = addReaction(Zm_model,'Sinapyl-alcohol_biosynth','reactionFormula','PRE[h] + 3 ATP[c] + NADH[c] + 3 NADPH[c] + 2 O2[c] + 2 aMet[c] -> Sinapyl_alcohol[c] + 3 ADP[c] + NAD[c] + 3 NADP[c] + PPi[c] + Pi[c] + CO2[c] + 2 H2O[c] + 2 H-Cys[c] + 2 ADN[c] ');

    Zm_model = addReaction(Zm_model,'CelluloseEffective_biosynthesis','360 cellulose1[c] -> cellulose_effective[c]');
    Zm_model = addReaction(Zm_model,'NewBiomass','reactionFormula','1.757 Nitrogeneous_compounds[c] + 4.415 Carbohydrates[c] + 0.079 Lipids[c] + 0.453 Lignin[c] + 0.339 Organic_acids[c] + 30 ATP[c] --> 30 ADP[c] + 30 Pi[c]');

    Zm_model = addReaction(Zm_model,'OrganicAcid_synthesis','reactionFormula','0.081 Oxalate[h] + 0.01 GLX[c] + 0.223 OAA[c] + 0.11 Mal[c] + 0.23 Cit[c] + 0.25 cACN[c] -> Organic_acids[c]');
    Zm_model = addReaction(Zm_model,'NucleicAcid_synthesis','reactionFormula','0.121 ATP[c] + 0.117 GTP[c] + 0.127 CTP[c] + 0.127 UTP[c] + 0.125 dATP[c] + 0.121 dGTP[c] + 0.131 dCTP[c] + 0.127 dTTP[c] -> Nucleic_acids[c]');
    Zm_model = addReaction(Zm_model,'NitrogenousCompounds_synthesis','reactionFormula','0.102 Amino_acids[c] + 0.89 Proteins[c] + 0.0079 Nucleic_acids[c] -> Nitrogeneous_compounds[c]');
    %Zm_model =
    %addReaction(Zm_model,'NitrogenousCompounds_synthesis','reactionFormula','0.061 Nucleic_acids[c] -> Nitrogeneous_compounds[c]')

    Zm_model = addReaction(Zm_model,'Lipid_synthesis','reactionFormula','3.158 Lipid_precursor[h] -> Lipids[c]');
    Zm_model = addReaction(Zm_model,'Lignin_synthesis','reactionFormula','0.39 Coumaryl-alcohol[c] + 0.327 Coniferyl-alcohol[c] + 0.28 Sinapyl_alcohol[c] -> Lignin[c]');
    Zm_model = addReaction(Zm_model,'Hemicellulose_synthesis','reactionFormula',' 0.094 Arabinose[c] + 0.21 Xylose[c] + 0.05 Mannose[c] + 0.025 Galactose[c] + 0.55 Glc[c] + 0.029 Galacturonate[c] + 0.029 Glucuronic_acid[c] -> Hemicellulose[c]');
    Zm_model = addReaction(Zm_model,'Carbohydrate_synthesis','reactionFormula',' 0.01245  Rib[c] + 0.051892 Glc[c] + 0.0207568 Frc[c] + 0.0103784 Mannose[c] + 0.0103784 Galactose[c] + 0.02731 Suc[c] + 0.415 cellulose1[c] + 0.4356 Hemicellulose[c] + 0.0016 Galacturonate[c] -> Carbohydrates[c]');
    Zm_model = addReaction(Zm_model,'Protein_synthesis','reactionFormula','0.1475 Ala[c] + 0.012 Arg[c] + 0.053 Asp[c] + 0.004 Cys[c] + 0.195 Glu[c] + 0.006 Gly[c] + 0.012 His[c] + 0.06 Ile[c] + 0.193 Leu[c] + 0.00000731 Lys[c] + 0.016 Met[c] + 0.04 Phe[c] + 0.097 Pro[c] +0.078 Ser[c] + 0.022 Thr[c] + 0.00052 Trp[c] + 0.031 Tyr[c] + 0.031 Val[c] -> Proteins[c]');
    Zm_model = addReaction(Zm_model,'Aminoacid_synthesis','reactionFormula','0.08 Ala[c] + 0.04 Arg[c] + 0.05 Asp[c] + 0.03 Cys[c] + 0.048 Glu[c] + 0.0947 Gly[c] + 0.0458 His[c] + 0.0543 Ile[c] + 0.0543 Leu[c] + 0.0480 Lys[c] + 0.048 Met[c] + 0.043 Phe[c] + 0.061 Pro[c] +0.067 Ser[c] + 0.059 Thr[c] + 0.034 Trp[c] + 0.039 Tyr[c] + 0.06 Val[c] -> Amino_acids[c]');
    Zm_model = addReaction(Zm_model,'Inorganic_materials_synthesis','reactionFormula','-> Materials[c]');


    % Setting up constraints

    Zm_model = changeObjective(Zm_model,['NewBiomass']);
    Zm_model = changeRxnBounds(Zm_model,'Im_hnu',70.08,'u');
    Zm_model = changeRxnBounds(Zm_model,'Im_hnu',0,'l');
    Zm_model = changeRxnBounds(Zm_model,'Im_NO3',0,'u');
    Zm_model = changeRxnBounds(Zm_model,'Im_NH4',0,'b');
    Zm_model = changeRxnBounds(Zm_model,'Si_H',-1000,'l');
    Zm_model = changeRxnBounds(Zm_model,'Si_H',1000,'u');

    Zm_model = changeRxnBounds(Zm_model,'NewBiomass',1000,'u');
    Zm_model = changeRxnBounds(Zm_model,'NewBiomass',0,'l');

    solution = optimizeCbModel(Zm_model,'max','one');

    % Disabling transporters and reactions to force NADP-ME 

    Zm_model = addReaction(Zm_model,'NewBiomass','reactionFormula','1.757 Nitrogeneous_compounds[c] + 4.415 Carbohydrates[c] + 0.079 Lipids[c] + 0.453 Lignin[c] + 0.339 Organic_acids[c] + 30 ATP[c] --> Biomass[e] + 30 ADP[c] + 30 Pi[c]');

    Zm_model = changeRxnBounds(Zm_model,'G6PDH_h',0,'b');
    Zm_model = changeRxnBounds(Zm_model,'PPIF6PK_c',0,'b');
    %Zm_model = changeRxnBounds(Zm_model,'AOX4_h',0,'b') %Need to add first
    Zm_model = changeRxnBounds(Zm_model,'iCitDHNADP_h',0,'b');
    Zm_model = changeRxnBounds(Zm_model,'Tr_NTT',0,'b');
    Zm_model = changeRxnBounds(Zm_model,'Tr_Pyr1',0,'b');
    Zm_model = changeRxnBounds(Zm_model,'Tr_Pyr2',0,'b');

    % Duplicate models

    Zm_BS_model = Zm_model;
    Zm_M_model = Zm_model;

    % Rename mets and rxns

    Zm_BS_model.rxns = strcat('BS_', Zm_BS_model.rxns);
    Zm_BS_model.mets = strcat('BS_', Zm_BS_model.mets);
    Zm_M_model.rxns = strcat('M_', Zm_M_model.rxns);
    Zm_M_model.mets = strcat('M_', Zm_M_model.mets);

    % Combine models

    CombinedModel = mergeTwoModels(Zm_BS_model,Zm_M_model);

    % Set NGAM

    CombinedModel = addReaction(CombinedModel,'BS_ATPM','reactionFormula','BS_Glc[c] + 6 BS_O2[c] -> 6 BS_CO2[c] + 6 BS_H2O[c] + ShootATPM[c]');
    CombinedModel = addReaction(CombinedModel,'M_ATPM','reactionFormula','M_Glc[c] + 6 M_O2[c] -> 6 M_CO2[c] + + 6 M_H2O[c] + ShootATPM[c]');
    CombinedModel = addReaction(CombinedModel,'Shoot_ATPM_Drain','reactionFormula','ShootATPM[c] ->');

    CombinedModel = changeRxnBounds(CombinedModel,'Shoot_ATPM_Drain',0.204,'l');

    % Creating transports between mesophyll and bundle sheath cells

    ExcludedTransportReactions = {'NO3[c]','NO2[c]','O2[c]','Na[c]','H2S[c]','SO4[c]', ...
        'H2O[c]','FBP[c]','F26BP[c]','DPGA[c]','H[c]','ACD[c]','AC[c]','M-THF[c]','5M-THF[c]','H-Cys[c]','aH-Cys[c]','ORO[c]','DHO[c]', ...
                    'GABA[c]','A-Ser[c]','PRPP[c]','AD[c]','THF[c]','DHF[c]','ADN[c]','Mas[c]','CoA[c]','GluP[c]', ...
                    'A-CoA[c]','cellulose1[c]','cellulose2[c]','cellulose3[c]','starch1[c]', ...
                    'starch2[c]','starch3[c]','TRXox[c]','TRXrd[c]','Glu-SeA[c]','T6P[c]','aMet[c]', ...
                    'PPi[c]', 'P5C[c]', 'NH4[c]', 'Pi[c]', 'CO2[c]', 'OAA[c]','HCO3[c]', ...
                    'UTP[c]', 'UDP[c]', 'UDPG[c]', 'ATP[c]', 'ADP[c]', 'AMP[c]', 'IMP[c]', 'XMP[c]', ...
                    'GTP[c]', 'GDP[c]', 'GMP[c]', 'OMP[c]', 'UMP[c]', 'CTP[c]', 'GDP[c]', 'CDP[c]', 'dADP[c]', ...
                    'dCDP[c]', 'dGDP[c]', 'dUDP[c]', 'dUTP[c]', 'dUMP[c]', 'dTMP[c]', 'dTDP[c]', 'GTP[c]', ...
                    'dATP[c]', 'dCTP[c]', 'dGTP[c]', 'dTTP[c]', 'NAD[c]', 'NADH[c]', 'NADP[c]', 'NADPH[c]','Asp[c]','KG[c]'};

    for i=1:numel(CombinedModel.mets);
        if strcmp(CombinedModel.mets{i}(length(CombinedModel.mets{i})-2:length(CombinedModel.mets{i})),'[c]') & ~any(contains(ExcludedTransportReactions,extractAfter(CombinedModel.mets{i},2)));
                CombinedModel = addReaction(CombinedModel,['TR_BS_M_' CombinedModel.mets{i}],{['BS_' extractAfter(CombinedModel.mets{i},2)],['M_' extractAfter(CombinedModel.mets{i},2)]}, [-1 1], 0,-1000,1000);
        end
    end

    CombinedModel = changeRxnBounds(CombinedModel,'B_RBC_h',0,'l');
    CombinedModel = changeRxnBounds(CombinedModel,'B_RBC_h',1000,'u');


    CombinedModel = changeRxnBounds(CombinedModel,'[MB]_Tr_CO2',-1000,'l');
    CombinedModel = changeRxnBounds(CombinedModel,'[MB]_Tr_CO2',1000,'u');

    % Disallow CO2 uptake in the bundle sheath 

    CombinedModel = changeRxnBounds(CombinedModel,'BS_Im_CO2',0,'b');

    % Disallow rubisco carboxylation in the mesophyll

    CombinedModel = changeRxnBounds(CombinedModel,'M_RBC_h',0,'l');
    CombinedModel = changeRxnBounds(CombinedModel,'M_RBC_h',0,'u');

    % Split biomass between the bundle sheath and mesophyll cells

    CombinedModel = addReaction(CombinedModel,'Total_Shoot_Biomass','reactionFormula','0.5 BS_Biomass[e] + 0.5 M_Biomass[e] -> Total_Shoot_Biomass[e]');
    %CombinedModel = addReaction(CombinedModel,'Total_Shoot_Biomass','reactionFormula','0.5 BS_Biomass[e] -> Total_Biomass[e]')

    CombinedModel = addReaction(CombinedModel,'EX_Total_Shoot_Biomass','reactionFormula','Total_Shoot_Biomass[e] ->');

    % Make a summed light importer so I can constrain light uptake

    CombinedModel = addReaction(CombinedModel,'M_Im_hnu','reactionFormula','-> M_hnu[h] + dummy_photon[c]');
    CombinedModel = addReaction(CombinedModel,'BS_Im_hnu','reactionFormula','-> BS_hnu[h] + dummy_photon[c]');
    CombinedModel = addReaction(CombinedModel,'DummyPhoton_sink','reactionFormula','dummy_photon[c] ->');
    CombinedModel = changeRxnBounds(CombinedModel,'DummyPhoton_sink',70.08,'u');
    CombinedModel = changeRxnBounds(CombinedModel,'DummyPhoton_sink',0,'l');


    CombinedModel = changeObjective(CombinedModel,'EX_Total_Shoot_Biomass');
    solution = optimizeCbModel(CombinedModel,'max','one');

    % Now, adding a root

    Zm_root_model = Zm_model;

    % Rename root mets and rxns
    Zm_root_model = addReaction(Zm_root_model,'ATPM','ATP[c] + H2O[c] -> ADP[c] + Pi[c]');
    Zm_root_model = changeRxnBounds(Zm_root_model,'ATPM',7.36*0.1,'l');

    Zm_root_model.rxns = strcat('R_', Zm_root_model.rxns);
    Zm_root_model.mets = strcat('R_', Zm_root_model.mets);

    CombinedModel = mergeTwoModels(CombinedModel,Zm_root_model);

    %Defining transport between root and shoot

    ShootUptake = {'Mal[c]','SCA[c]','Cit[c]','UMP[c]','UDP[c]','CTP[c]','UTP[c]','Ser[c]','Gly[c]','Ala[c]','His[c]','H2O[c]','Pi[c]','Glu[c]','Asp[c]','Gln[c]','Asn[c]','SO4[c]','H2S[c]','CMP[c]','IMP[c]','CDP[c]','ADP[c]','GDP[c]','NO3[c]'};

    RootDelivery = {'Suc[c]','UTP[c]','GTP[c]','Thr[c]','Ser[c]','Gly[c]','Cys[c]','Met[c]','Ile[c]','Tyr[c]','Phe[c]','Leu[c]','Arg[c]','Glu[c]','Asp[c]','Gln[c]','Asn[c]','AMP[c]','GMP[c]','ATP[c]'};

    disp('Adding Transporters');
    for i=1:numel(ShootUptake);
        CombinedModel = addReaction(CombinedModel,['TRM_' ShootUptake{i}],{['R_' ShootUptake{i}],['R_ATP[c]'],['M_' ShootUptake{i}],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
        CombinedModel = addReaction(CombinedModel,['TRBS_' ShootUptake{i}],{['R_' ShootUptake{i}],['R_ATP[c]'],['BS_' ShootUptake{i}],['R_ADP[c]'],['R_Pi[c]']}, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    end

    for i=1:numel(RootDelivery);
        CombinedModel = addReaction(CombinedModel,['TMR_' RootDelivery{i}],{['M_' RootDelivery{i}],['M_ATP[c]'],['R_' RootDelivery{i}],['M_ADP[c]'],['M_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
        CombinedModel = addReaction(CombinedModel,['TBSR_' RootDelivery{i}],{['BS_' RootDelivery{i}],['BS_ATP[c]'],['R_' RootDelivery{i}],['BS_ADP[c]'],['BS_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    end

    % Block all shoot imports except for light and gas 

    CombinedModel = changeRxnBounds(CombinedModel,'M_Im_NO3',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'BS_Im_NO3',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'M_Im_NH4',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'BS_Im_NH4',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'M_Im_H2S',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'BS_Im_H2S',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'M_Im_SO4',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'BS_Im_SO4',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'M_Im_Pi',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'BS_Im_Pi',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'M_Im_H2O',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'BS_Im_H2O',0,'b');

    % Block light uptake in root

    CombinedModel = addReaction(CombinedModel,'R_Im_hnu','reactionFormula','-> R_hnu[h] + dummy_photon[c]');

    %Block PEPC2 in BS to force this to happen in the bundle sheath

    CombinedModel = changeRxnBounds(CombinedModel,'R_Im_hnu',0,'u');
    CombinedModel = changeRxnBounds(CombinedModel,'R_Im_hnu',0,'l');
    CombinedModel = changeRxnBounds(CombinedModel,'R_RBC_h',0,'b');
    CombinedModel = changeRxnBounds(CombinedModel,'R_Im_NO3',0,'u');
    CombinedModel = changeRxnBounds(CombinedModel,'R_Im_NH4',1000,'u');


    CombinedModel = changeRxnBounds(CombinedModel,'R_Im_CO2',-1000,'l');
    CombinedModel = changeRxnBounds(CombinedModel,'R_Im_CO2',0,'u');

    CombinedModel = changeRxnBounds(CombinedModel,'R_Ex_O2',-1000,'l');

    % Make a whole plant biomass reaction

    CombinedModel = addReaction(CombinedModel,'Total_plant_biomass','reactionFormula','0.90 Total_Shoot_Biomass[e] + 0.1 R_Biomass[e] -> Total_Plant_Biomass[e]');
    CombinedModel = addReaction(CombinedModel,'EX_Total_Plant_Biomass','reactionFormula','Total_Plant_Biomass[e] ->');

    CombinedModel = changeObjective(CombinedModel,'Total_plant_biomass');
    solution = optimizeCbModel(CombinedModel,'max','one');

    % Making the nodule to associate with the bacteroid

    Bd_model = readCbModel('BdiazoModel.xml');
    Zm_model = readCbModel('ArabidopsisCoreModel.xml');


    Zm_model = changeObjective(Zm_model,'Bio_opt');

    solution = optimizeCbModel(Zm_model,'max','one');

    Zm_model = addReaction(Zm_model,'PSII_h','reactionFormula','hnu[h] + 0.5 PQ[h] + 0.5 H2O[h] + H[h] -> 0.5 PQH2[h] + 0.25 O2[h] + H[l]');
    Zm_model = addReaction(Zm_model,'Cybb6f_h','reactionFormula','PCox[h] + PQH2[h] -> PQ[h] + 2 H[l] + PCrd[h] + eq[h]');
    Zm_model = addReaction(Zm_model,'Cybb6f_h','reactionFormula','PCox[h] + PQH2[h] -> PQ[h] + 2 H[l] + PCrd[h] + eq[h]');
    Zm_model = addReaction(Zm_model,'QCYC_h','reactionFormula','2 eq[h] + PQ[h] + 2 H[h] -> PQH2[h]');
    Zm_model = addReaction(Zm_model,'CEF_h','reactionFormula','2 Fdrd[h] + 2 H[h] + PQ[h] -> 2 Fdox[h] + PQH2[h]');
    Zm_model = addReaction(Zm_model,'PTOX_h','reactionFormula','O2[h] + 2 PQH2[h] -> 2 H2O[h] + 2 PQ[h]');
    Zm_model = addReaction(Zm_model,'NDHq_h','reactionFormula','H[h] + NADPH[h] + PQ[h] -> NADP[h] + PQH2[h]');

    Zm_model = addReaction(Zm_model,'Proton_CP_transport','reactionFormula','H[c] -> H[p]');
    Zm_model = addReaction(Zm_model,'Proton_CH_transport','reactionFormula','H[c] -> H[h]');
    Zm_model = addReaction(Zm_model,'Proton_CM_transport','reactionFormula','H[c] -> H[m]');

    Zm_model = changeRxnBounds(Zm_model,'Proton_CP_transport',-1000,'l');
    Zm_model = changeRxnBounds(Zm_model,'Proton_CH_transport',-1000,'l');
    Zm_model = changeRxnBounds(Zm_model,'Proton_CM_transport',-1000,'l');

    DisableTransporters = find(contains(Zm_model.rxns,{'Ex_Ala_c','Ex_Ala_h','Ex_Ala_m', ...
        'Ex_Ala_p','Ex_Arg_c','Ex_Arg_h','Ex_Arg_m','Ex_Arg_p','Ex_Asn_c','Ex_Asn_h','Ex_Asn_m', ...
        'Ex_Asn_p','Ex_Asp_c','Ex_Asp_h','Ex_Asp_m','Ex_Asp_p','Ex_Cys_c','Ex_Cys_h','Ex_Cys_m', ...
        'Ex_Cys_p','Ex_Gln_c','Ex_Gln_h','Ex_Gln_m','Ex_Gln_p','Ex_Glu_c','Ex_Glu_h','Ex_Glu_m', ...
        'Ex_Glu_p','Ex_Gly_c','Ex_Gly_h','Ex_Gly_m','Ex_Gly_p','Ex_His_c','Ex_His_h','Ex_His_m', ...
        'Ex_His_p','Ex_Ile_c','Ex_Ile_h','Ex_Ile_m','Ex_Ile_p','Ex_Leu_c','Ex_Leu_h','Ex_Leu_m', ...
        'Ex_Leu_p','Ex_Lys_c','Ex_Lys_h','Ex_Lys_m','Ex_Lys_p','Ex_Met_c','Ex_Met_h','Ex_Met_m', ...
        'Ex_Met_p','Ex_Phe_c','Ex_Phe_h','Ex_Phe_m','Ex_Phe_p','Ex_Pro_c','Ex_Pro_h','Ex_Pro_m', ...
        'Ex_Pro_p','Ex_Ser_c','Ex_Ser_h','Ex_Ser_m','Ex_Ser_p','Ex_Thr_c','Ex_Thr_h','Ex_Thr_m', ... 
        'Ex_Thr_p','Ex_Trp_c','Ex_Trp_h','Ex_Trp_m','Ex_Trp_p','Ex_Tyr_c','Ex_Tyr_h','Ex_Tyr_m', ...
        'Ex_Tyr_p','Ex_Val_c','Ex_Val_h','Ex_Val_m','Ex_Val_p','Ex_starch','Ex_Glc','Ex_Frc','Ex_Suc', ...
        'Ex_cellulose','Ex_Mas','Ex_MACP','Ex_Tre'}));

    for i=1:numel(DisableTransporters);
        Zm_model = changeRxnBounds(Zm_model,Zm_model.rxns(DisableTransporters(i)),0,'b');
    end

    % GMPS already present for first step. Then, need to make xanothosine or
    % guanosine

    Zm_model = addReaction(Zm_model,'R01227','reactionFormula','GMP[c] + H2O[c] -> Guanosine[c] + Pi[c]');
    Zm_model = addReaction(Zm_model,'R01677','reactionFormula','Guanosine[c] + H2O[c] -> Guanine[c] + Rib[c]');
    Zm_model = addReaction(Zm_model,'R01676','reactionFormula','Guanine[c] + H2O[c] -> Xanthine[c] + NH4[c]');
    Zm_model = addReaction(Zm_model,'R02103','reactionFormula','Xanthine[c] + NAD[c] + H2O[c] -> Urate[c] + NADH[c] + H[c]');
    Zm_model = addReaction(Zm_model,'R02106','reactionFormula','Urate[c] + O2[c] + H2O[c] -> 5-Hydroxyisourate[c] + H2O2[c]');
    Zm_model = addReaction(Zm_model,'Tr_H2O2_cp','reactionFormula','H2O2[c] -> H2O2[p]');
    Zm_model = addReaction(Zm_model,'R06601','reactionFormula','5-Hydroxyisourate[c] + H2O[c] -> OHCU[c]');
    Zm_model = addReaction(Zm_model,'R06604','reactionFormula','OHCU[c] -> CO2[c] + Allantoin[c]');
    Zm_model = addReaction(Zm_model,'R02425','reactionFormula','Allantoin[c] + H2O[c] -> Allantoate[c]');
    Zm_model = addReaction(Zm_model,'R02423','reactionFormula','Allantoate[c] + H2O[c] -> Ureidoglycine[c] + NH4[c] + CO2[c]');
    Zm_model = addReaction(Zm_model,'R05554','reactionFormula','Ureidoglycine[c] + H2O[c] -> Ureidoglycolate[c] + NH4[c]');
    Zm_model = addReaction(Zm_model,'R00776','reactionFormula','Ureidoglycolate[c] -> GLX[c] + urea[c]');
    Zm_model = addReaction(Zm_model,'CM_Urea_Transporters','reactionFormula','urea[c] -> urea[m]');

    Zm_model = addReaction(Zm_model,'Oxalate_synthesis','reactionFormula','For[h] + CO2[h] -> Oxalate[h]');
    Zm_model = addReaction(Zm_model,'UDPGlucuronic_acid_synthesis','reactionFormula','UDPG[c] + 2 NADPH[c] -> UDP-Glucuronic_acid[c] + 2 NADP[c]');
    Zm_model = addReaction(Zm_model,'UDPGalactose_synthesis','reactionFormula','UDPG[c] -> UDP-Galactose[c]');
    Zm_model = addReaction(Zm_model,'UDPXylose_biosynthesis','reactionFormula','UDP-Glucuronic_acid[c] -> UDP-Xylose[c]');
    Zm_model = addReaction(Zm_model,'UDP-Arabinose_biosynthesis','reactionFormula','UDP-Xylose[c] -> UDP-Arabinose[c]');
    Zm_model = changeRxnBounds(Zm_model,'UDP-Arabinose_biosynthesis',-1000,'l');

    Zm_model = addReaction(Zm_model,'Mannose-6-phosphate_biosynthesis','reactionFormula','F6P[c] -> M6P[c]');
    Zm_model = addReaction(Zm_model,'Mannose-6-phosphate_dephosphorylation','reactionFormula','M6P[c] + ADP[c] -> Mannose[c] + ATP[c]');
    Zm_model = addReaction(Zm_model,'UDP-Galacturonate_synthesis','reactionFormula','UDP-Arabinose[c] + CO2[c] -> UDP-Galacturonate[c]');
    Zm_model = addReaction(Zm_model,'G3P_biosynthesis','reactionFormula','DHAP[h] + NADH[h] -> NAD[h] + G3P[h]');
    Zm_model = addReaction(Zm_model,'Glycerol_biosynthesis','reactionFormula','G3P[h] -> Glycerol[h] + Pi[h]');

    Zm_model = addReaction(Zm_model,'Arabinose-1-phosphate_biosynthesis','reactionFormula','UDP-Arabinose[c] + PPi[c] -> H[c] + Arabinose-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Arabinose_biosynthesis','reactionFormula','Arabinose-1-phosphate[c] + ADP[c] -> Arabinose[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'Xylose-1-phosphate_biosynthesis','reactionFormula','UDP-Xylose[c] + PPi[c] <=> H[c] + Xylose-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Xylose_biosynthesis','reactionFormula','Xylose-1-phosphate[c] + ADP[c] -> Xylose[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'Galactose-1-phosphate_biosynthesis','reactionFormula','UDP-Galactose[c] + PPi[c] <=> H[c] + Galactose-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Galactose_biosynthesis','reactionFormula','Galactose-1-phosphate[c] + ADP[c] -> Galactose[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'Glucuronate-1-phosphate_biosynthesis','reactionFormula','UDP-Glucuronic_acid[c] + PPi[c] <=> H[c] + Glucuronate-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Glucuronic_acid_biosynthesis','reactionFormula','Glucuronate-1-phosphate[c] + ADP[c] -> Glucuronic_acid[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'Galacturonate-1-phosphate_biosynthesis','reactionFormula','UDP-Galacturonate[c] + PPi[c] <=> H[c] + Galacturonate-1-phosphate[c] + UTP[c]');
    Zm_model = addReaction(Zm_model,'Galacturonate_biosynthesis','reactionFormula','Galacturonate-1-phosphate[c] + ADP[c] -> Galacturonate[c] + ATP[c]');

    Zm_model = addReaction(Zm_model,'LipidPrecursor_biosynthesis','reactionFormula','27 M-ACP[h] + 1 Glycerol[h] -> Lipid_precursor[h] + 27 ACP[h]');

    Zm_model = addReaction(Zm_model,'Prephenate_TR','reactionFormula','PRE[h] -> PRE[c]')
    Zm_model = addReaction(Zm_model,'Coumaryl-alcohol_biosynth','reactionFormula','PRE[h] + 3 ATP[c] + NADH[c] + NADPH[c] -> Coumaryl-alcohol[c] + 3 ADP[c] + PPi[c] + Pi[c] + CO2[c] + NAD[c] + NADP[c]');
    Zm_model = addReaction(Zm_model,'Coniferyl-alcohol_biosynth','reactionFormula','PRE[h] + 3 ATP[c] + NADH[c] + 2 NADPH[c] + O2[c] + aMet[c] -> Coniferyl-alcohol[c] + 3 ADP[c] + NAD[c] + 2 NADP[c] + PPi[c] + Pi[c] + CO2[c] + H2O[c] + H-Cys[c] + ADN[c]');
    Zm_model = addReaction(Zm_model,'Sinapyl-alcohol_biosynth','reactionFormula','PRE[h] + 3 ATP[c] + NADH[c] + 3 NADPH[c] + 2 O2[c] + 2 aMet[c] -> Sinapyl_alcohol[c] + 3 ADP[c] + NAD[c] + 3 NADP[c] + PPi[c] + Pi[c] + CO2[c] + 2 H2O[c] + 2 H-Cys[c] + 2 ADN[c] ');

    Zm_model = addReaction(Zm_model,'CelluloseEffective_biosynthesis','360 cellulose1[c] -> cellulose_effective[c]');
    Zm_model = addReaction(Zm_model,'NewBiomass','reactionFormula','1.757 Nitrogeneous_compounds[c] + 4.415 Carbohydrates[c] + 0.079 Lipids[c] + 0.453 Lignin[c] + 0.339 Organic_acids[c] + 30 ATP[c] --> 30 ADP[c] + 30 Pi[c]');

    Zm_model = addReaction(Zm_model,'OrganicAcid_synthesis','reactionFormula','0.081 Oxalate[h] + 0.01 GLX[c] + 0.223 OAA[c] + 0.11 Mal[c] + 0.23 Cit[c] + 0.25 cACN[c] -> Organic_acids[c]');
    Zm_model = addReaction(Zm_model,'NucleicAcid_synthesis','reactionFormula','0.121 ATP[c] + 0.117 GTP[c] + 0.127 CTP[c] + 0.127 UTP[c] + 0.125 dATP[c] + 0.121 dGTP[c] + 0.131 dCTP[c] + 0.127 dTTP[c] -> Nucleic_acids[c]');
    Zm_model = addReaction(Zm_model,'NitrogenousCompounds_synthesis','reactionFormula','0.102 Amino_acids[c] + 0.89 Proteins[c] + 0.0079 Nucleic_acids[c] -> Nitrogeneous_compounds[c]');
    %Zm_model = addReaction(Zm_model,'NitrogenousCompounds_synthesis','reactionFormula','0.061 Nucleic_acids[c] -> Nitrogeneous_compounds[c]')

    Zm_model = addReaction(Zm_model,'Lipid_synthesis','reactionFormula','3.158 Lipid_precursor[h] -> Lipids[c]');
    Zm_model = addReaction(Zm_model,'Lignin_synthesis','reactionFormula','0.39 Coumaryl-alcohol[c] + 0.327 Coniferyl-alcohol[c] + 0.28 Sinapyl_alcohol[c] -> Lignin[c]');
    Zm_model = addReaction(Zm_model,'Hemicellulose_synthesis','reactionFormula',' 0.094 Arabinose[c] + 0.21 Xylose[c] + 0.05 Mannose[c] + 0.025 Galactose[c] + 0.55 Glc[c] + 0.029 Galacturonate[c] + 0.029 Glucuronic_acid[c] -> Hemicellulose[c]');
    Zm_model = addReaction(Zm_model,'Carbohydrate_synthesis','reactionFormula',' 0.01245  Rib[c] + 0.051892 Glc[c] + 0.0207568 Frc[c] + 0.0103784 Mannose[c] + 0.0103784 Galactose[c] + 0.02731 Suc[c] + 0.415 cellulose1[c] + 0.4356 Hemicellulose[c] + 0.0016 Galacturonate[c] -> Carbohydrates[c]');
    Zm_model = addReaction(Zm_model,'Protein_synthesis','reactionFormula','0.1475 Ala[c] + 0.012 Arg[c] + 0.053 Asp[c] + 0.004 Cys[c] + 0.195 Glu[c] + 0.006 Gly[c] + 0.012 His[c] + 0.06 Ile[c] + 0.193 Leu[c] + 0.00000731 Lys[c] + 0.016 Met[c] + 0.04 Phe[c] + 0.097 Pro[c] +0.078 Ser[c] + 0.022 Thr[c] + 0.00052 Trp[c] + 0.031 Tyr[c] + 0.031 Val[c] -> Proteins[c]');
    Zm_model = addReaction(Zm_model,'Aminoacid_synthesis','reactionFormula','0.08 Ala[c] + 0.04 Arg[c] + 0.05 Asp[c] + 0.03 Cys[c] + 0.048 Glu[c] + 0.0947 Gly[c] + 0.0458 His[c] + 0.0543 Ile[c] + 0.0543 Leu[c] + 0.0480 Lys[c] + 0.048 Met[c] + 0.043 Phe[c] + 0.061 Pro[c] +0.067 Ser[c] + 0.059 Thr[c] + 0.034 Trp[c] + 0.039 Tyr[c] + 0.06 Val[c] -> Amino_acids[c]');
    Zm_model = addReaction(Zm_model,'Inorganic_materials_synthesis','reactionFormula','-> Materials[c]');


    Zm_model = changeObjective(Zm_model,['NewBiomass']);

    Zm_model = changeRxnBounds(Zm_model,'NewBiomass',1000,'u');
    Zm_model = changeRxnBounds(Zm_model,'NewBiomass',0,'l');

    Zm_model = addReaction(Zm_model,'NewBiomass','reactionFormula','1.757 Nitrogeneous_compounds[c] + 4.415 Carbohydrates[c] + 0.079 Lipids[c] + 0.453 Lignin[c] + 0.339 Organic_acids[c] + 30 ATP[c] --> Biomass[e] + 30 ADP[c] + 30 Pi[c]');

    Zm_model = changeRxnBounds(Zm_model,'Im_hnu',70.08,'u');
    Zm_model = changeRxnBounds(Zm_model,'Im_hnu',0,'l');
    Zm_model = changeRxnBounds(Zm_model,'Im_NO3',1000,'u');
    Zm_model = changeRxnBounds(Zm_model,'Im_NH4',0,'u');
    Zm_model = changeRxnBounds(Zm_model,'Si_H',-1000,'l');
    Zm_model = changeRxnBounds(Zm_model,'Si_H',1000,'u');
    Zm_model = changeRxnBounds(Zm_model,'ATPM',7.36*0.02,'l');
    Zm_model = changeRxnBounds(Zm_model,'NewBiomass',1000,'u');
    Zm_model = changeRxnBounds(Zm_model,'NewBiomass',0,'l');

    solution = optimizeCbModel(Zm_model,'max','one');

    Zm_model = addReaction(Zm_model,'ATPM','ATP[c] + H2O[c] -> ADP[c] + Pi[c]');
    Zm_model = changeRxnBounds(Zm_model,'ATPM',7.36*0.02,'l');


    for i=1:numel(DisableTransporters);
        Zm_model = changeRxnBounds(Zm_model,Zm_model.rxns(DisableTransporters(i)),0,'b');
    end

    Zm_model.rxns = strcat('Nodule_', Zm_model.rxns);
    Zm_model.mets = strcat('Nodule_', Zm_model.mets);
    Bd_model.rxns = strcat('Bacteroid_', Bd_model.rxns);
    Bd_model.mets = strcat('Bacteroid_', Bd_model.mets);

    NoduleModel = mergeTwoModels(Zm_model,Bd_model);

    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_2PGA[c]','reactionFormula','Nodule_2PGA[c] -> Bacteroid_2pg[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_2PGA[c]','reactionFormula','Bacteroid_2pg[c]  -> Nodule_2PGA[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_PGA[c]','reactionFormula','Nodule_PGA[c] -> Bacteroid_3pg[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_PGA[c]','reactionFormula','Bacteroid_3pg[c] -> Nodule_PGA[c]')
    NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_ACD[c]','reactionFormula','Nodule_ACD[c] -> Bacteroid_acald[c]','upperBound',0.00024);
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_ACD[c]','reactionFormula','Bacteroid_acald[c] -> Nodule_ACD[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_AD','reactionFormula','Nodule_AD[c] -> Bacteroid_ade[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_AD','reactionFormula','Bacteroid_ade[c] -> Nodule_AD[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Ala[c]','reactionFormula','Nodule_Ala[c] -> Bacteroid_ala__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Ala[c]','reactionFormula','Bacteroid_ala__L[c] -> Nodule_Ala[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Arabinose[c]','reactionFormula','Nodule_Arabinose[c] -> Bacteroid_arab__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Arabinose[c]','reactionFormula','Bacteroid_arab__L[c] -> Nodule_Arabinose[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Arg[c]','reactionFormula','Nodule_Arg[c] -> Bacteroid_arg__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Arg[c]','reactionFormula','Bacteroid_arg__L[e] -> Nodule_Arg[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Asn[c]','reactionFormula','Nodule_Asn[c] -> Bacteroid_asn__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Asn[c]','reactionFormula','Bacteroid_asn__L[e] -> Nodule_Asn[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Asp[c]','reactionFormula','Nodule_Asp[c] -> Bacteroid_asp__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Asp[c]','reactionFormula','Bacteroid_asp__L[e] -> Nodule_Asp[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Cit[c]','reactionFormula','Nodule_Cit[c] -> Bacteroid_cit[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Cit[c]','reactionFormula','Bacteroid_cit[e] -> Nodule_Cit[c]')
    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_CO2[c]'],{['Nodule_CO2[c]'],['Bacteroid_co2[c]']}, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_CO2[c]'],{['Bacteroid_co2[e]'],['Nodule_CO2[c]']}, [-1 1], 0,0,1000);

    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Cys[c]','reactionFormula','Nodule_Cys[c] -> Bacteroid_cys__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Cys[c]','reactionFormula','Bacteroid_cys__L[e] -> Nodule_Cys[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_DHAP[c]','reactionFormula','Nodule_DHAP[c] -> Bacteroid_dhap[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_DHAP[c]','reactionFormula','Bacteroid_dhap[e] -> Nodule_DHAP[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Fum[c]','reactionFormula','Nodule_Fum[c] -> Bacteroid_fum[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Fum[c]','reactionFormula','Bacteroid_fum[e] -> Nodule_Fum[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Galactose[c]','reactionFormula','Nodule_Galactose[c] -> Bacteroid_gal[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Galactose[c]','reactionFormula','Bacteroid_gal[e] -> Nodule_Galactose[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Gln[c]','reactionFormula','Nodule_Gln[c] -> Bacteroid_gln__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Gln[c]','reactionFormula','Bacteroid_gln__L[e] -> Nodule_Gln[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Glu[c]','reactionFormula','Nodule_Glu[c] -> Bacteroid_glu__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Glu[c]','reactionFormula','Bacteroid_glu__L[e] -> Nodule_Glu[c]')
    NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Gly[c]','reactionFormula','Nodule_Gly[c] -> Bacteroid_gly[c]','upperBound',0.00024);
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Gly[c]','reactionFormula','Bacteroid_gly[e] -> Nodule_Gly[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Glycerol[c]','reactionFormula','Nodule_Glycerol[c] -> Bacteroid_glyc[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Glycerol[c]','reactionFormula','Bacteroid_glyc[c] -> Nodule_Glycerol[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_GSH[h]','reactionFormula','Nodule_GSH[h] -> Bacteroid_gthox[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_GSH[h]','reactionFormula','Bacteroid_gthox[c] -> Nodule_GSH[h]')
    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_H[c]'],{['Nodule_H[c]'],['Bacteroid_h[c]']}, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_h[c]'],{['Bacteroid_h[c]'],['Nodule_H[c]']}, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_H2O2[c]'],{['Nodule_H2O2[c]'],['Bacteroid_h2o2[c]']}, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_H2O2[c]'],{['Bacteroid_h2o2[c]'],['Nodule_H2O2[c]']}, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_H2O[c]'],{['Nodule_H2O[c]'],['Bacteroid_h2o[c]']}, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_H2O[c]'],{['Bacteroid_h2o[c]'],['Nodule_H2O[c]']}, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_HCO3[c]'],{['Nodule_HCO3[c]'],['Bacteroid_hco3[c]']}, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_HCO3[c]'],{['Bacteroid_hco3[c]'],['Nodule_HCO3[c]']}, [-1 1], 0,0,1000);

    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_His[c]','reactionFormula','Nodule_His[c] -> Bacteroid_his__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_His[c]','reactionFormula','Bacteroid_his__L[e] -> Nodule_His[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Ile[c]','reactionFormula','Nodule_Ile[c] -> Bacteroid_ile__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Ile[c]','reactionFormula','Bacteroid_ile__L[e] -> Nodule_Ile[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Leu[c]','reactionFormula','Nodule_Leu[c] -> Bacteroid_leu__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Leu[c]','reactionFormula','Bacteroid_leu__L[e] -> Nodule_Leu[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Lys[c]','reactionFormula','Nodule_Lys[c] -> Bacteroid_lys__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Lys[c]','reactionFormula','Bacteroid_lys__L[e] -> Nodule_Lys[c]')
    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_Mal[c]'],{['Nodule_Mal[c]'],['Nodule_ATP[c]'],['Bacteroid_mal__D[c]'],['Nodule_ADP[c]'],['Nodule_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Mal[c]','reactionFormula','Bacteroid_mal__D[c] -> Nodule_Mal[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Mas[c]','reactionFormula','Nodule_Mas[c] -> Bacteroid_malt[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Mas[c]','reactionFormula','Bacteroid_malt[c] -> Nodule_Mas[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Mannose[c]','reactionFormula','Nodule_Mannose[c] -> Bacteroid_man[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Mannose[c]','reactionFormula','Bacteroid_man[c] -> Nodule_Mannose[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_M1P[c]','reactionFormula','Nodule_M1P[c] -> Bacteroid_man1p[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_M1P[c]','reactionFormula','Bacteroid_man1p[c] -> Nodule_M1P[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Met[c]','reactionFormula','Nodule_Met[c] -> Bacteroid_met__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Met[c]','reactionFormula','Bacteroid_met__L[e] -> Nodule_Met[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_NH4[c]','reactionFormula','Nodule_NH4[c] -> Bacteroid_nh3[c]','upperBound',0.00024)
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_NH4[c]'],{['Bacteroid_nh3[c]'],['Bacteroid_atp[c]'],['Nodule_NH4[c]'],['Bacteroid_adp[c]'],['Bacteroid_pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_NO2[c]','reactionFormula','Nodule_NO2[c] -> Bacteroid_no2[c]','upperBound',0.00024)
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_NO2[c]'],{['Bacteroid_no2[c]'],['Bacteroid_atp[c]'],['Nodule_NO2[c]'],['Bacteroid_adp[c]'],['Bacteroid_pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_NO3[c]','reactionFormula','Nodule_NO3[c] -> Bacteroid_no3[c]','upperBound',0.00024)
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_NO3[c]'],{['Bacteroid_no3[c]'],['Bacteroid_atp[c]'],['Nodule_NO3[c]'],['Bacteroid_adp[c]'],['Bacteroid_pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_O2[c]'],{['Nodule_O2[c]'],['Bacteroid_o2[c]'] }, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_O2[c]'],{['Bacteroid_o2[c]'],['Nodule_O2[c]'] }, [-1 1], 0,0,1000);

    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Orn[h]','reactionFormula','Nodule_Orn[h] -> Bacteroid_orn[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Orn[h]','reactionFormula','Bacteroid_orn[c] -> Nodule_Orn[h]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_PEP[c]','reactionFormula','Nodule_PEP[c] -> Bacteroid_pep[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_PEP[c]','reactionFormula','Bacteroid_pep[c] -> Nodule_PEP[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Phe[c]','reactionFormula','Nodule_Phe[c] -> Bacteroid_phe__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Phe[c]','reactionFormula','Bacteroid_phe__L[e] -> Nodule_Phe[c]')
    %NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_Pi[c]'],{['Nodule_Pi[c]'],['Nodule_ATP[c]'],['Bacteroid_pi[c]'],['Nodule_ADP[c]'],['Nodule_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_Pi[c]'],{['Bacteroid_pi[c]'],['Bacteroid_atp[c]'],['Nodule_Pi[c]'],['Bacteroid_adp[c]'],['Bacteroid_pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_Pi[c]'],{['Nodule_Pi[c]'],['Bacteroid_pi[c]']}, [-1 1], 0,0,1000);
    NoduleModel = addReaction(NoduleModel,['NoduleTR_reverse_Pi[c]'],{['Bacteroid_pi[c]'],['Nodule_Pi[c]']}, [-1 1], 0,0,1000);

    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Pro[c]','reactionFormula','Nodule_Pro[c] -> Bacteroid_pro__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Pro[c]','reactionFormula','Bacteroid_pro__L[e] -> Nodule_Pro[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Pyr[c]','reactionFormula','Nodule_Pyr[c] -> Bacteroid_pyr[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Pyr[c]','reactionFormula','Bacteroid_pyr[c] -> Nodule_Pyr[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Ser[c]','reactionFormula','Nodule_Ser[c] -> Bacteroid_ser__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Ser[c]','reactionFormula','Bacteroid_ser__L[e] -> Nodule_Ser[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_SA[h]','reactionFormula','Nodule_SA[h] -> Bacteroid_skm[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_SA[h]','reactionFormula','Bacteroid_skm[c] -> Nodule_SA[h]')
    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_H2S[c]'],{['Nodule_H2S[c]'],['Nodule_ATP[c]'],['Bacteroid_h2s[c]'],['Nodule_ADP[c]'],['Nodule_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_SO4[c]','reactionFormula','Bacteroid_so4[c] -> Nodule_SO4[c]')
    NoduleModel = addReaction(NoduleModel,['NoduleTR_forward_SCA[c]'],{['Nodule_SCA[c]'],['Nodule_ATP[c]'],['Bacteroid_succ[c]'],['Nodule_ADP[c]'],['Nodule_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_SCA[c]','reactionFormula','Bacteroid_succ[c] -> Nodule_SCA[c]')
    NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Suc[c]','reactionFormula','Nodule_Suc[c] -> Bacteroid_sucr[c]','upperBound',0.00024);
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Suc[c]','reactionFormula','Bacteroid_sucr[e] -> Nodule_Suc[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Tre[c]','reactionFormula','Nodule_Tre[c] -> Bacteroid_tre[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Tre[c]','reactionFormula','Bacteroid_tre[c] -> Nodule_Tre[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Trp[c]','reactionFormula','Nodule_Trp[c] -> Bacteroid_trp__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Trp[c]','reactionFormula','Bacteroid_trp__L[e] -> Nodule_Trp[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Tyr[c]','reactionFormula','Nodule_Tyr[c] -> Bacteroid_tyr__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Tyr[c]','reactionFormula','Bacteroid_tyr__L[e] -> Nodule_Tyr[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_urea[m]','reactionFormula','Nodule_urea[m] -> Bacteroid_urea[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_urea[m]','reactionFormula','Bacteroid_urea[e] -> Nodule_urea[m]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Val[c]','reactionFormula','Nodule_Val[c] -> Bacteroid_val__L[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Val[c]','reactionFormula','Bacteroid_val__L[e] -> Nodule_Val[c]')
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_forward_Xylose[c]','reactionFormula','Nodule_Xylose[c] -> Bacteroid_xyl__D[c]','upperBound',0.00024)
    %NoduleModel = addReaction(NoduleModel,'NoduleTR_reverse_Xylose[c]','reactionFormula','Bacteroid_xyl__D[e] -> Nodule_Xylose[c]')


    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_1btol(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_2pg(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_2pglyc(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_3pg(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_aacald(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_acald(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_acetone(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_ade(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_ala-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_amob(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_arab__D(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_arab-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_arg-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_asn-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_asp__D(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_asp-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_btn(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_cellb(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_chol(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_cholp(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_cit(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_co(e)',0,'b');
    %NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_co2(e)',0,'b')
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_cobalt2(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_csn(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_cynt(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_cys-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_dha(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_drib(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_etoh(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_fald(e)',0,'b');
    %NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_fe2(e)',0,'b')
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_fmnhdp(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_fuc-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_fum(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_gal(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_gam(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_gam6p(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_glc_A(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_glc_bD(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_gln-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_glu-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_glus__D(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_gly(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_glyc(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_gthrd(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_gua(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_h(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_h2(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_h2o(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_h2o2(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_hco3(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_his-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_ile-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_leu-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_lys-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_mal-D(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_mal-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_maln(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_malt(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_man(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_man1p(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_man6p(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_meoh(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_met-L(e)',0,'b');
    %NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_n2(e)',0,'b')
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_n2o(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_nh4(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_no(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_no2(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_no3(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_o2(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_orn(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_pep(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_phe-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_pheme(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_pi(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_pro-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_ptrc(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_pyr(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_rib-D(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_ser-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_skm(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_so2(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_so4(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_succ(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_sucr(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_tag__D(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_tartr-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_taur(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_tre(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_trp-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_tsul(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_tyr-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_ura(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_urea(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_val-L(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_xan(e)',0,'b');
    NoduleModel = changeRxnBounds(NoduleModel,'Bacteroid_EX_xyl-D(e)',0,'b');

    NoduleModel = changeRxnBounds(NoduleModel,'Nodule_Im_NH4',1000,'u');
    NoduleModel = changeRxnBounds(NoduleModel,'Nodule_Im_NO3',0,'u');
    NoduleModel = changeRxnBounds(NoduleModel,'Nodule_Im_Pi',1000,'u');
    NoduleModel = changeRxnBounds(NoduleModel,'Nodule_Im_Pi',0,'l');

    NoduleModel= addReaction(NoduleModel,'EX_NewBiomass','reactionFormula','Nodule_Biomass[e] ->');

    NoduleModel = changeObjective(NoduleModel,'Nodule_NewBiomass');
    solution = optimizeCbModel(NoduleModel,'max','one');


    NoduleModel = changeRxnBounds(NoduleModel,'Nodule_Im_NH4',0,'u');
    NoduleModel = changeRxnBounds(NoduleModel,'Nodule_Im_NO3',0,'u');
    NoduleModel = changeRxnBounds(NoduleModel,'Nodule_Im_Pi',1000,'u');
    NoduleModel = changeRxnBounds(NoduleModel,'Nodule_Im_Pi',0,'l');

    NoduleModel= addReaction(NoduleModel,'EX_NewBiomass','reactionFormula','Nodule_Biomass[e] ->');


    NoduleModel = changeObjective(NoduleModel,'Nodule_NewBiomass');

    solution = optimizeCbModel(NoduleModel,'max','one');


    FullModel = mergeTwoModels(CombinedModel,NoduleModel);

    FullModel = addReaction(FullModel,['RootNodule_forward_NH4[c]'],{['R_NH4[c]'],['R_ATP[c]'],['Nodule_NH4[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %FullModel = addReaction(FullModel,'RootNodule_reverse_NH4','reactionFormula','Nodule_NH4[c] -> R_NH4[c]')

    FullModel = addReaction(FullModel,['RootNodule_forward_Gln[c]'],{['R_Gln[c]'],['R_ATP[c]'],['Nodule_Gln[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %FullModel = addReaction(FullModel,'RootNodule_reverse_Gln','reactionFormula','Nodule_Gln[c] -> R_Gln[c]')

    FullModel = addReaction(FullModel,['RootNodule_forward_Asp[c]'],{['R_Asp[c]'],['R_ATP[c]'],['Nodule_Asp[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %FullModel = addReaction(FullModel,'RootNodule_reverse_Asp','reactionFormula','Nodule_Asp[c] -> R_Asp[c]')
    FullModel = addReaction(FullModel,['RootNodule_forward_GSH[c]'],{['R_GSH[c]'],['R_ATP[c]'],['Nodule_GSH[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %FullModel = addReaction(FullModel,'RootNodule_reverse_GSH','reactionFormula','Nodule_GSH[c] -> R_GSH[c]')
    FullModel = addReaction(FullModel,['RootNodule_forward_Ala[c]'],{['R_Ala[c]'],['R_ATP[c]'],['Nodule_Ala[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %FullModel = addReaction(FullModel,'RootNodule_reverse_Ala','reactionFormula','Nodule_Ala[c] -> R_Ala[c]')

    FullModel = addReaction(FullModel,'RootNodule_forward_Proton','reactionFormula','R_H[c] -> Nodule_H[c]');
    FullModel = addReaction(FullModel,'RootNodule_reverse_Proton','reactionFormula','Nodule_H[c] -> R_H[c]');
    FullModel = addReaction(FullModel,'RootNodule_forward_H2O','reactionFormula','R_H2O[c] -> Nodule_H2O[c]');
    FullModel = addReaction(FullModel,'RootNodule_reverse_H2O','reactionFormula','Nodule_H2O[c] -> R_H2O[c]');

    FullModel = addReaction(FullModel,['RootNodule_forward_SO4[c]'],{['R_SO4[c]'],['R_ATP[c]'],['Nodule_SO4[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %FullModel = addReaction(FullModel,'RootNodule_reverse_SO4','reactionFormula','Nodule_SO4[c] -> R_SO4[c]')
    %FullModel = addReaction(FullModel,['RootNodule_forward_Pi[c]'],{['R_Pi[c]'],['R_ATP[c]'],['Nodule_Pi[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %FullModel = addReaction(FullModel,['RootNodule_reverse_Pi[c]'],{['Nodule_Pi[c]'],['Nodule_ATP[c]'],['R_Pi[c]'],['Nodule_ADP[c]'],['Nodule_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    FullModel = addReaction(FullModel,['RootNodule_forward_Pi[c]'],{['R_Pi[c]'],['Nodule_Pi[c]']}, [-1 1], 0,0,1000);
    FullModel = addReaction(FullModel,['RootNodule_reverse_Pi[c]'],{['Nodule_Pi[c]'],['R_Pi[c]']}, [-1 1], 0,0,1000);

    FullModel = addReaction(FullModel,['RootNodule_forward_Asn[c]'],{['R_Asn[c]'],['R_ATP[c]'],['Nodule_Asn[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %FullModel = addReaction(FullModel,'RootNodule_reverse_Asn','reactionFormula','Nodule_Asn[c] -> R_Asn[c]')
    FullModel = addReaction(FullModel,['RootNodule_forward_Ser[c]'],{['R_Ser[c]'],['R_ATP[c]'],['Nodule_Ser[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %FullModel = addReaction(FullModel,'RootNodule_reverse_Ser','reactionFormula','Nodule_Ser[c] -> R_Ser[c]')
    FullModel = addReaction(FullModel,['RootNodule_forward_Pro[c]'],{['R_Pro[c]'],['R_ATP[c]'],['Nodule_Pro[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %FullModel = addReaction(FullModel,'RootNodule_reverse_Pro','reactionFormula','Nodule_Pro[c] -> R_Pro[c]')

    FullModel = addReaction(FullModel,['RootNodule_forward_Gly[c]'],{['R_Gly[c]'],['R_ATP[c]'],['Nodule_Gly[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %FullModel = addReaction(FullModel,'RootNodule_reverse_Gly','reactionFormula','Nodule_Gly[c] -> R_Gly[c]')

    FullModel = addReaction(FullModel,['RootNodule_forward_Val[c]'],{['R_Val[c]'],['R_ATP[c]'],['Nodule_Val[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %FullModel = addReaction(FullModel,'RootNodule_reverse_Val','reactionFormula','Nodule_Val[c] -> R_Val[c]')

    FullModel = addReaction(FullModel,['RootNodule_forward_Ile[c]'],{['R_Ile[c]'],['R_ATP[c]'],['Nodule_Ile[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %FullModel = addReaction(FullModel,'RootNodule_reverse_Ile','reactionFormula','Nodule_Ile[c] -> R_Ile[c]')

    FullModel = addReaction(FullModel,['RootNodule_forward_Leu[c]'],{['R_Leu[c]'],['R_ATP[c]'],['Nodule_Leu[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %FullModel = addReaction(FullModel,'RootNodule_reverse_Leu','reactionFormula','Nodule_Leu[c] -> R_Leu[c]')

    FullModel = addReaction(FullModel,['RootNodule_forward_Lys[c]'],{['R_Lys[c]'],['R_ATP[c]'],['Nodule_Lys[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %FullModel = addReaction(FullModel,'RootNodule_reverse_Lys','reactionFormula','Nodule_Lys[c] -> R_Lys[c]')

    FullModel = addReaction(FullModel,['RootNodule_forward_Arg[c]'],{['R_Arg[c]'],['R_ATP[c]'],['Nodule_Arg[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %FullModel = addReaction(FullModel,'RootNodule_reverse_Arg','reactionFormula','Nodule_Arg[c] -> R_Arg[c]')

    FullModel = addReaction(FullModel,['RootNodule_forward_His[c]'],{['R_His[c]'],['R_ATP[c]'],['Nodule_His[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    %FullModel = addReaction(FullModel,'RootNodule_reverse_His','reactionFormula','Nodule_His[c] -> R_His[c]')
    FullModel = addReaction(FullModel,['RootNodule_forward_Sucrose[c]'],{['R_Suc[c]'],['R_ATP[c]'],['Nodule_Suc[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    %FullModel = addReaction(FullModel,'RootNodule_reverse_Sucrose','reactionFormula','Nodule_suc[c] -> R_suc[c]')
    FullModel = addReaction(FullModel,['RootNodule_forward_Allantoin[c]'],{['R_Allantoin[c]'],['R_ATP[c]'],['Nodule_Allantoin[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    FullModel = addReaction(FullModel,['RootNodule_reverse_Allantoin[c]'],{['Nodule_Allantoin[c]'],['Nodule_ATP[c]'],['R_Allantoin[c]'],['Nodule_ADP[c]'],['Nodule_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    FullModel = addReaction(FullModel,['RootNodule_forward_Allantoate[c]'],{['R_Allantoate[c]'],['R_ATP[c]'],['Nodule_Allantoate[c]'],['R_ADP[c]'],['R_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);
    FullModel = addReaction(FullModel,['RootNodule_reverse_Allantoate[c]'],{['Nodule_Allantoate[c]'],['Nodule_ATP[c]'],['R_Allantoate[c]'],['Nodule_ADP[c]'],['Nodule_Pi[c]'] }, [-1 -TransportCost 1 TransportCost TransportCost], 0,0,1000);

    % Can full model grow? 

    solution = optimizeCbModel(FullModel,'max','one');

    % Can full model grow without nodule light?(yes)

    FullModel = changeRxnBounds(FullModel,'Nodule_Im_hnu',0,'b');
    solution = optimizeCbModel(FullModel,'max','one');

    % Can it grow without any nitrate uptake in root? (yes)

    FullModel = changeRxnBounds(FullModel,'R_Im_NO3',0,'b');
    solution = optimizeCbModel(FullModel,'max','one');

    FullModel = addReaction(FullModel,'Total_plant_biomass','reactionFormula','0.90 Total_Shoot_Biomass[e] + 0.1 R_Biomass[e] -> Total_Plant_Biomass[e]');
    FullModel = addReaction(FullModel,'FullBiomass_Accumulation','reactionFormula','0.98 Total_Plant_Biomass[e] + 0.02 Nodule_Biomass[e] -> FullBiomass[e]');
    FullModel = addReaction(FullModel,'EX_FullBiomass','reactionFormula','FullBiomass[e] ->');

    FullModel = changeObjective(FullModel,'EX_FullBiomass');
    solution = optimizeCbModel(FullModel,'max');

    % Can it grow without any CO2 or other uptakes in the nodule?

    FullModel = changeRxnBounds(FullModel,'Nodule_Im_hnu',0,'u');
    FullModel = changeRxnBounds(FullModel,'Nodule_Im_CO2',-1000,'l');
    FullModel = changeRxnBounds(FullModel,'Nodule_Im_CO2',0,'u');
    FullModel = changeRxnBounds(FullModel,'Nodule_Im_Pi',-1000,'l');
    FullModel = changeRxnBounds(FullModel,'Nodule_Im_Pi',0,'u');
    FullModel = changeRxnBounds(FullModel,'Nodule_Ex_O2',-1000,'l');
    FullModel = changeRxnBounds(FullModel,'Nodule_Ex_O2',1000,'u');
    FullModel = changeRxnBounds(FullModel,'Nodule_Im_NH4',0,'u');
    FullModel = changeRxnBounds(FullModel,'Nodule_Im_NH4',0,'l');
    %FullModel = changeRxnBounds(FullModel,'Nodule_Im_NO3',0,'b')
    FullModel = changeRxnBounds(FullModel,'R_Im_NH4',0,'u');
    %FullModel = changeRxnBounds(FullModel,'Nodule_Im_Pi',0,'b')
    %FullModel = changeRxnBounds(FullModel,'Nodule_Im_SO4',0,'b')
    %FullModel = changeRxnBounds(FullModel,'Nodule_Im_H2S',0,'b')

    FullModel = changeRxnBounds(FullModel,'BS_Bio_AA',0,'b');
    FullModel = changeRxnBounds(FullModel,'BS_Bio_Clim',0,'b');
    FullModel = changeRxnBounds(FullModel,'BS_Bio_NLim',0,'b');
    FullModel = changeRxnBounds(FullModel,'BS_Bio_opt',0,'b');
    FullModel = changeRxnBounds(FullModel,'M_Bio_AA',0,'b');
    FullModel = changeRxnBounds(FullModel,'M_Bio_Clim',0,'b');
    FullModel = changeRxnBounds(FullModel,'M_Bio_NLim',0,'b');
    FullModel = changeRxnBounds(FullModel,'M_Bio_opt',0,'b');
    FullModel = changeRxnBounds(FullModel,'R_Bio_AA',0,'b');
    FullModel = changeRxnBounds(FullModel,'R_Bio_Clim',0,'b');
    FullModel = changeRxnBounds(FullModel,'R_Bio_NLim',0,'b');
    FullModel = changeRxnBounds(FullModel,'R_Bio_opt',0,'b');
    FullModel = changeRxnBounds(FullModel,'Nodule_Bio_AA',0,'b');
    FullModel = changeRxnBounds(FullModel,'Nodule_Bio_Clim',0,'b');
    FullModel = changeRxnBounds(FullModel,'Nodule_Bio_NLim',0,'b');
    FullModel = changeRxnBounds(FullModel,'Nodule_Bio_opt',0,'b');
    FullModel = changeRxnBounds(FullModel,'Nodule_Im_Pi',0,'b');

    FullModel = changeObjective(FullModel,'EX_FullBiomass');
    solution = optimizeCbModel(FullModel,'max','one');

    %

    changeCobraSolver('ibm_cplex');
    %
    PI_INDEX = find(contains(FullModel.rxns,{'R_Im_Pi'}));
    NH4_INDEX = find(contains(FullModel.rxns,{'R_Im_NH4'}));
    Pi_max = solution.x(PI_INDEX);
    NH4_max = solution.x(NH4_INDEX);

    P_levels = linspace(0,Pi_max,11);
    P_levels_AMF = P_levels * 3.16;
    N_levels = linspace(0,NH4_max,11);
    N_levels_AMF = N_levels * 1.23;

    FullModel = changeRxnBounds(FullModel,'R_Im_NH4',1000,'u');
    FullModel = changeRxnBounds(FullModel,'NoduleTR_reverse_NH4[c]',1000,'u');
    FullModel = changeRxnBounds(FullModel,'NoduleTR_reverse_NH4[c]',-1000,'l');

    FullModel = addReaction(FullModel,'R_Im_Pi','reactionFormula','R_ATP[c] + R_H2O[c] -> R_H[h] + 2 R_Pi[h] + R_ADP[c] + R_Pi[c]');

    FullModel = addReaction(FullModel,'R_Im_NH4','reactionFormula','-> R_NH4[c]');

    RGR_values_combined = {};

    % Recalculating biomass coefficients 

    ER_Nitro_coef = 1.757;
    ER_Carbo_coef = 3.023;
    ER_Lipid_coef = 0.07838;
    ER_Lignin_coef = 0.4527;
    ER_Organic_coef = 0.339;
    ER_Materials_coef = 1.305;

    ES_Nitro_coef = 1.757;
    ES_Carbo_coef = 3.023;
    ES_Lipid_coef = 0.07838;
    ES_Lignin_coef = 0.4527;
    ES_Organic_coef = 0.339;
    ES_Materials_coef = 1.305;
    
    coef_params = [Carbo_proportion, Lipid_proportion, Lignin_proportion, Organic_proportion, Materials_proportion]

    [MR_Nitro_coef, MR_Carbo_coef, MR_Lipid_coef, MR_Lignin_coef, MR_Organic_coef, MR_Materials_coef] = calculateBiomassCoefs(20.105, coef_params);
    [LR_Nitro_coef, LR_Carbo_coef, LR_Lipid_coef, LR_Lignin_coef, LR_Organic_coef, LR_Materials_coef] = calculateBiomassCoefs(35.245, coef_params);
    [MS_Nitro_coef, MS_Carbo_coef, MS_Lipid_coef, MS_Lignin_coef, MS_Organic_coef, MS_Materials_coef] = calculateBiomassCoefs(10.87, coef_params);
    [LS_Nitro_coef, LS_Carbo_coef, LS_Lipid_coef, LS_Lignin_coef, LS_Organic_coef, LS_Materials_coef] = calculateBiomassCoefs(37.19, coef_params);

    ER_set = [ER_Nitro_coef, ER_Carbo_coef, ER_Lipid_coef, ER_Lignin_coef, ER_Organic_coef, ER_Materials_coef];
    MR_set = [MR_Nitro_coef, MR_Carbo_coef, MR_Lipid_coef, MR_Lignin_coef, MR_Organic_coef, MR_Materials_coef];
    LR_set = [LR_Nitro_coef, LR_Carbo_coef, LR_Lipid_coef, LR_Lignin_coef, LR_Organic_coef, LR_Materials_coef];
    ES_set = [ES_Nitro_coef, ES_Carbo_coef, ES_Lipid_coef, ES_Lignin_coef, ES_Organic_coef, ES_Materials_coef];
    MS_set = [MS_Nitro_coef, MS_Carbo_coef, MS_Lipid_coef, MS_Lignin_coef, MS_Organic_coef, MS_Materials_coef];
    LS_set = [LS_Nitro_coef, LS_Carbo_coef, LS_Lipid_coef, LS_Lignin_coef, LS_Organic_coef, LS_Materials_coef];

    E_set = {ES_set ER_set};
    M_set = {MS_set, MR_set};
    L_set = {LS_set, LR_set};

    all_sets = {E_set, M_set, L_set};

    Early_RGR_withBacteroidnoAMF = {};
    Mid_RGR_withBacteroidnoAMF = {};
    Late_RGR_withBacteroidnoAMF = {};


    WithBacteroidModel = FullModel;

    solution = optimizeCbModel(FullModel,'max');



    % Calculate P and N levels for early biomass

    NoBacteroidModel = FullModel;

    for i=1:numel(NoBacteroidModel.rxns);
        if strcmp(extractBefore(NoBacteroidModel.rxns{i},'_'),'Nodule') | strcmp(extractBefore(NoBacteroidModel.rxns{i},'_'),'Bacteroid');
                NoBacteroidModel = changeRxnBounds(NoBacteroidModel,NoBacteroidModel.rxns{i},0,'b');
        end
    end

    NoBacteroidModel = addReaction(NoBacteroidModel,['Total_plant_biomass'],{['Total_Shoot_Biomass[e]'],['R_Biomass[e]'],['Total_Plant_Biomass[e]']},[-ShootProportion -RootProportion 1]);
    NoBacteroidModel = addReaction(NoBacteroidModel,['FullBiomass_Accumulation'],{['Total_Plant_Biomass[e]'],['FullBiomass[e]']},[-1 1]);
    NoBacteroidModel = addReaction(NoBacteroidModel,'EX_FullBiomass','reactionFormula','FullBiomass[e] ->');


    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'Shoot_ATPM_Drain',PlantNGAM*ShootProportion,'l');
    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_ATPM',RootNGAM*RootProportion,'l');

    b=1;
    working_set = all_sets{b};
    S_set = working_set{1};
    R_set = working_set{2};
    NoBacteroidModel = addReaction(NoBacteroidModel,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    NoBacteroidModel = addReaction(NoBacteroidModel,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
    NoBacteroidModel = addReaction(NoBacteroidModel,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    NoBacteroidModel = changeObjective(NoBacteroidModel,'EX_FullBiomass');
    solution = optimizeCbModel(NoBacteroidModel,'max','one');

    PI_INDEX = find(contains(NoBacteroidModel.rxns,{'R_Im_Pi'}));
    NH4_INDEX = find(contains(NoBacteroidModel.rxns,{'R_Im_NH4'}));
    Pi_max = solution.x(PI_INDEX);
    NH4_max = solution.x(NH4_INDEX);

    Pi_max_base = Pi_max;
    NH4_max_base = NH4_max;

    P_levels_early = linspace(0,Pi_max,11);
    N_levels_early = linspace(0,NH4_max,11);

    % Calculate P and N levels for mid biomass

    b=2;
    working_set = all_sets{b};
    S_set = working_set{1};
    R_set = working_set{2};
    NoBacteroidModel = addReaction(NoBacteroidModel,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    NoBacteroidModel = addReaction(NoBacteroidModel,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
    NoBacteroidModel = addReaction(NoBacteroidModel,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    NoBacteroidModel = changeObjective(NoBacteroidModel,'EX_FullBiomass');
    solution = optimizeCbModel(NoBacteroidModel,'max','one');

    PI_INDEX = find(contains(NoBacteroidModel.rxns,{'R_Im_Pi'}));
    NH4_INDEX = find(contains(NoBacteroidModel.rxns,{'R_Im_NH4'}));
    Pi_max = solution.x(PI_INDEX);
    NH4_max = solution.x(NH4_INDEX);

    P_levels_mid = linspace(0,Pi_max,11);
    N_levels_mid = linspace(0,NH4_max,11);

    % Calculate P and N levels for late biomass

    b=3;
    working_set = all_sets{b};
    S_set = working_set{1};
    R_set = working_set{2};
    NoBacteroidModel = addReaction(NoBacteroidModel,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    NoBacteroidModel = addReaction(NoBacteroidModel,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
    NoBacteroidModel = addReaction(NoBacteroidModel,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    NoBacteroidModel = changeObjective(NoBacteroidModel,'EX_FullBiomass');
    solution = optimizeCbModel(NoBacteroidModel,'max','one');

    PI_INDEX = find(contains(NoBacteroidModel.rxns,{'R_Im_Pi'}));
    NH4_INDEX = find(contains(NoBacteroidModel.rxns,{'R_Im_NH4'}));
    Pi_max = solution.x(PI_INDEX);
    NH4_max = solution.x(NH4_INDEX);

    P_levels_late = linspace(0,Pi_max,11);
    N_levels_late = linspace(0,NH4_max,11);

    Early_RGR_noBacteroidnoAMF = {};
    Mid_RGR_noBacteroidnoAMF = {};
    Late_RGR_noBacteroidnoAMF = {};

    NH4_values_early = {};
    NH4_values_mid = {};
    NH4_values_late = {};

    changeCobraSolver('ibm_cplex');

    %

    changeCobraSolver('ibm_cplex');


    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'Bacteroid_NIT',1000,'u');
    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'Bacteroid_NIT',0,'l');
    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'Bacteroid_ATPMR',BacteroidNGAM*NoduleProportion*0.25,'l');
    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'Nodule_ATPM',RootNGAM*NoduleProportion,'l');
    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'Nodule_Im_Pi',0,'l');
    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'Bacteroid_EX_co2(e)',0,'b');

    Fixation_flux = find(contains(WithBacteroidModel.rxns,{'Bacteroid_NIT'}));
    CO2_efflux = find(contains(WithBacteroidModel.rxns,{'Nodule_Im_CO2'}));
    Other_efflux = find(contains(WithBacteroidModel.rxns,{'NoduleTR_reverse_CO2[c]'}));

    WithBacteroidModel = addReaction(WithBacteroidModel,['Total_plant_biomass'],{['Total_Shoot_Biomass[e]'],['R_Biomass[e]'],['Total_Plant_Biomass[e]']},[-ShootProportion -RootProportion 1]);
    WithBacteroidModel = addReaction(WithBacteroidModel,['FullBiomass_Accumulation'],{['Total_Plant_Biomass[e]'],['Nodule_Biomass[e]'],['FullBiomass[e]']},[-PlantProportion -NoduleProportion 1]);
    WithBacteroidModel = addReaction(WithBacteroidModel,'EX_FullBiomass','reactionFormula','FullBiomass[e] ->');

    % Preallocate arrays

    Early_RGR_withBacteroidnoAMF = cell(length(N_levels),length(P_levels));
    Mid_RGR_withBacteroidnoAMF = cell(length(N_levels),length(P_levels));
    Late_RGR_withBacteroidnoAMF = cell(length(N_levels),length(P_levels));

    for b=1:numel(all_sets);
        disp(b)
        working_set = all_sets{b};
        S_set = working_set{1};
        R_set = working_set{2};
        WithBacteroidModel = addReaction(WithBacteroidModel,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
        WithBacteroidModel = addReaction(WithBacteroidModel,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);           
        WithBacteroidModel = addReaction(WithBacteroidModel,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
        WithBacteroidModel = addReaction(WithBacteroidModel,['Nodule_NewBiomass'],{['Nodule_Nitrogeneous_compounds[c]'],['Nodule_Carbohydrates[c]'],['Nodule_Lipids[c]'],['Nodule_Lignin[c]'],['Nodule_Organic_acids[c]'],['Nodule_Materials[c]'],['Nodule_ATP[c]'],['Nodule_Biomass[e]'],['Nodule_ADP[c]'],['Nodule_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);

        WithBacteroidModel = changeObjective(WithBacteroidModel,'EX_FullBiomass');
        WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'Shoot_ATPM_Drain',PlantNGAM*ShootProportion*PlantProportion,'l');
        WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'R_ATPM',RootNGAM*RootProportion*PlantProportion,'l');

        for i=1:numel(N_levels);
            for n=2:numel(P_levels);
                disp(i)
                disp(n)

                if b == 1
                    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'R_Im_NH4',N_levels_early(i),'u');
                    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'R_Im_NH4',0,'l');

                    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'R_Im_Pi',P_levels_early(n),'u');
                    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'R_Im_Pi',0,'l');

                    solution = optimizeCbModel(WithBacteroidModel,'max','one',1);
                    if isnan(solution.f);
                        disp('Trying again')
                        changeCobraSolver('gurobi');
                        solution = optimizeCbModel(WithBacteroidModel,'max','one',1);
                        changeCobraSolver('ibm_cplex');
                    end
                    Early_RGR_withBacteroidnoAMF{i,n} = solution.f;
                    disp(ShootProportion)
                    disp(parameters)
                    N2_values_early{i,n} = solution.x(Fixation_flux);
                    Nodule_CO2_efflux_early{i,n} = solution.x(CO2_efflux);
                end
                if b == 2
                    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'R_Im_NH4',N_levels_mid(i),'u');
                    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'R_Im_Pi',P_levels_mid(n),'u');
                    solution = optimizeCbModel(WithBacteroidModel,'max','one',1);
                    if isnan(solution.f);
                        disp('Trying again')
                        changeCobraSolver('gurobi');
                        solution = optimizeCbModel(WithBacteroidModel,'max','one',1);
                        changeCobraSolver('ibm_cplex');
                    end
                    Mid_RGR_withBacteroidnoAMF{i,n} = solution.f;            
                    N2_values_mid{i,n} = solution.x(Fixation_flux);
                    Nodule_CO2_efflux_mid{i,n} = solution.x(CO2_efflux);

                end
                if b == 3;
                    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'R_Im_NH4',N_levels_late(i),'u');
                    WithBacteroidModel = changeRxnBounds(WithBacteroidModel,'R_Im_Pi',P_levels_late(n),'u');
                    solution = optimizeCbModel(WithBacteroidModel,'max','one',1);
                    if isnan(solution.f);
                        disp('Trying again')
                        changeCobraSolver('gurobi');
                        solution = optimizeCbModel(WithBacteroidModel,'max','one',1);
                        changeCobraSolver('ibm_cplex');
                    end
                    Late_RGR_withBacteroidnoAMF{i,n} = solution.f;

                    N2_values_late{i,n} = solution.x(Fixation_flux);
                    Nodule_CO2_efflux_late{i,n} = solution.x(CO2_efflux);
                end
            end
        end
    end

    %Assign to the global variables


    %
    changeCobraSolver('ibm_cplex');

    for i=1:numel(NoBacteroidModel.rxns);
        if strcmp(extractBefore(NoBacteroidModel.rxns{i},'_'),'Nodule') | strcmp(extractBefore(NoBacteroidModel.rxns{i},'_'),'Bacteroid');
                NoBacteroidModel = changeRxnBounds(NoBacteroidModel,NoBacteroidModel.rxns{i},0,'b');
        end
    end

    NoBacteroidModel = addReaction(NoBacteroidModel,['Total_plant_biomass'],{['Total_Shoot_Biomass[e]'],['R_Biomass[e]'],['Total_Plant_Biomass[e]']},[-ShootProportion -RootProportion 1]);
    NoBacteroidModel = addReaction(NoBacteroidModel,['FullBiomass_Accumulation'],{['Total_Plant_Biomass[e]'],['FullBiomass[e]']},[-1 1]);
    NoBacteroidModel = addReaction(NoBacteroidModel,'EX_FullBiomass','reactionFormula','FullBiomass[e] ->');

    Fixation_flux = find(contains(NoBacteroidModel.rxns,{'Bacteroid_NIT'}));
    CO2_efflux = find(contains(NoBacteroidModel.rxns,{'Nodule_Im_CO2'}));
    Other_efflux = find(contains(NoBacteroidModel.rxns,{'NoduleTR_reverse_CO2[c]'}));

    % Preallocate arrays

    Early_RGR_noBacteroidnoAMF = cell(length(N_levels),length(P_levels));
    Mid_RGR_noBacteroidnoAMF = cell(length(N_levels),length(P_levels));
    Late_RGR_noBacteroidnoAMF = cell(length(N_levels),length(P_levels));

    for b=1:numel(all_sets);
        working_set = all_sets{b};
        S_set = working_set{1};
        R_set = working_set{2};
        NoBacteroidModel = addReaction(NoBacteroidModel,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
        NoBacteroidModel = addReaction(NoBacteroidModel,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
        NoBacteroidModel = addReaction(NoBacteroidModel,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);

        NoBacteroidModel = changeObjective(NoBacteroidModel,'EX_FullBiomass');
        NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'Shoot_ATPM_Drain',PlantNGAM*ShootProportion,'l');
        NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_ATPM',RootNGAM*RootProportion,'l');

        for i=1:numel(N_levels);
            for n=1:numel(P_levels);


                if b == 1;
                    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_Im_NH4',N_levels_early(i),'u');
                    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_Im_NH4',0,'l');

                    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_Im_Pi',P_levels_early(n),'u');
                    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_Im_Pi',0,'l');

                    solution = optimizeCbModel(NoBacteroidModel,'max','one');
                    if isnan(solution.f);
                        disp('Trying again')
                        changeCobraSolver('gurobi');
                        solution = optimizeCbModel(NoBacteroidModel,'max','one',1);
                        changeCobraSolver('ibm_cplex');        
                    end
                    Early_RGR_noBacteroidnoAMF{i,n} = solution.f ;
                    %N2_values_early{i,n} = solution.x(Fixation_flux)
                    %Nodule_CO2_efflux_early{i,n} = solution.x(CO2_efflux)
                end
                if b == 2
                    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_Im_NH4',N_levels_mid(i),'u');
                    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_Im_Pi',P_levels_mid(n),'u');
                    solution = optimizeCbModel(NoBacteroidModel,'max','one');
                    if isnan(solution.f)
                        disp('Trying again');
                        changeCobraSolver('gurobi');
                        solution = optimizeCbModel(NoBacteroidModel,'max','one',1);
                        changeCobraSolver('ibm_cplex');
                    end
                    Mid_RGR_noBacteroidnoAMF{i,n} = solution.f;
                    %N2_values_mid{i,n} = solution.x(Fixation_flux)
                    %Nodule_CO2_efflux_mid{i,n} = solution.x(CO2_efflux)

                end
                if b == 3
                    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_Im_NH4',N_levels_late(i),'u');
                    NoBacteroidModel = changeRxnBounds(NoBacteroidModel,'R_Im_Pi',P_levels_late(n),'u');
                    solution = optimizeCbModel(NoBacteroidModel,'max','one');
                    if isnan(solution.f);
                        disp('Trying again')
                        changeCobraSolver('gurobi');
                        solution = optimizeCbModel(NoBacteroidModel,'max','one',1);
                        changeCobraSolver('ibm_cplex');
                    end
                    Late_RGR_noBacteroidnoAMF{i,n} = solution.f;

                    %N2_values_late{i,n} = solution.x(Fixation_flux)
                    %Nodule_CO2_efflux_late{i,n} = solution.x(CO2_efflux)
                end
            end
        end
    end
    
    % AMF + Nodule model ...

    % Baseline first
    % We'll scan N as primary and P as secondary
    % So, in each N loop, just nest a loop to scan P. 

    FullModel = WithBacteroidModel;

    AMF_cost = 0.1;

    fungus_model = readCbModel('iRi1574.xml');

    sinks = contains(fungus_model.rxnNames,'sink');
    uptakes = contains(fungus_model.rxnNames,'uptake');

    for i = 1:numel(fungus_model.rxnNames);
        if contains(fungus_model.rxnNames(i),'sink');
            fungus_model = changeRxnBounds(fungus_model,fungus_model.rxns(i),0,'u');
        end
    end
    for i = 1:numel(fungus_model.rxnNames);
        if contains(fungus_model.rxnNames(i),'uptake');
            fungus_model = changeRxnBounds(fungus_model,fungus_model.rxns(i),0,'l');
        end
    end
    % Confirming no growth with no uptakes or sinks

    fungus_model = changeRxnBounds(fungus_model,'r1067_c0',1000,'u'); %Biomass sink
    fungus_model = changeObjective(fungus_model,'r1067_c0');

    solution = optimizeCbModel(fungus_model,'max');


    % Find minimal set of inputs/outputs that allow the model to grow

    fungus_model = changeRxnBounds(fungus_model,'r0728_e0',0,'b');
    fungus_model = changeRxnBounds(fungus_model,'r1632_e0',0,'b');
    fungus_model = changeRxnBounds(fungus_model,'r1533_e0',-1000,'l'); % Glucose
    fungus_model = changeRxnBounds(fungus_model,'r1012_e0',-1000,'l'); % O2 uptake
    fungus_model = changeRxnBounds(fungus_model,'r1012_e0',1000,'u');

    fungus_model = changeRxnBounds(fungus_model,'r1571_e0',1000,'u'); % CO2 sink
    fungus_model = changeRxnBounds(fungus_model,'r1571_e0',-1000,'l');

    fungus_model = changeRxnBounds(fungus_model,'r0992_e0',-1000,'l'); %Nitrate uptake
    fungus_model = changeRxnBounds(fungus_model,'r0994_e0',-1000,'l'); % Phosphate uptake
    fungus_model = changeRxnBounds(fungus_model,'r0990_e0',-1000,'l'); % Sulfate uptake
    fungus_model = changeRxnBounds(fungus_model,'r1573_e0',1000,'u'); % H2O
    fungus_model = changeRxnBounds(fungus_model,'r1573_e0',-1000,'l'); % H2O

    fungus_model = changeRxnBounds(fungus_model,'r1574_e0',1000,'u'); % H plus sink
    fungus_model = changeRxnBounds(fungus_model,'r1574_e0',-1000,'l');

    %fungus_model = changeRxnBounds(fungus_model,'r1534_e0',-1000,'l') % D fructose
    fungus_model = changeRxnBounds(fungus_model,'r1011_e0',-1000,'l'); % CO2 uptake
    fungus_model = changeRxnBounds(fungus_model,'r1011_e0',1000,'u');



    fungus_model = changeRxnBounds(fungus_model,'r1102_e0',1000,'u'); % This is the key one - need to be able to dispense
    %fungus_model = changeRxnBounds(fungus_model,'r1103_e0',1000,'u')
    %fungus_model = changeRxnBounds(fungus_model,'r1105_e0',1000,'u')


    fungus_model = changeRxnBounds(fungus_model,'r1007_e0',1000,'u'); % Palmitate uptake, essential
    %fungus_model = changeRxnBounds(fungus_model,'r1006_e0',-1000,'l') % myo-inositol uptake
    fungus_model = changeRxnBounds(fungus_model,'r0996_e0',-1000,'l'); % iron uptake
    fungus_model = changeRxnBounds(fungus_model,'r1001_e0',-1000,'l'); % molybdate uptake


    fungus_model = changeRxnBounds(fungus_model,'r0988_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0989_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0990_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0991_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0992_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0993_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0994_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0995_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0996_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0997_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0998_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r0999_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r1000_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r1001_e0',-1000,'l');
    fungus_model = changeRxnBounds(fungus_model,'r1013_e0',-1000,'l'); % cobalt
    %fungus_model = changeRxnBounds(fungus_model,'r1002_e0',-1000,'l') % glycine
    fungus_model = changeRxnBounds(fungus_model,'r1003_e0',-1000,'l'); % thiamin, essential
    %fungus_model = changeRxnBounds(fungus_model,'r1004_e0',-1000,'l') % pyridoxol
    %fungus_model = changeRxnBounds(fungus_model,'r1005_e0',-1000,'l') % Niacin

    %fungus_model = addReaction(fungus_model,'r0986_c0','reactionFormula','-> m1030[c0]')

    solution = optimizeCbModel(fungus_model,'max');



    % Defining base uptake vectors

    %P_levels = linspace(0,Pi_max,11)
    %P_levels_AMF = P_levels * 3.16
    %N_levels = linspace(0,NH4_max,11)
    %N_levels_AMF = N_levels * 1.23

    AMF_model = mergeTwoModels(WithBacteroidModel,fungus_model);

    AMF_model = addReaction(AMF_model,'AMF_Glucose_TR','reactionFormula','R_Glc[c] -> m0564[e0]');

    % Add palmitate synthesis

    AMF_model = addReaction(AMF_model,'Palmitate_synthesis','reactionFormula','8 R_M-ACP[h] -> R_Palmitic_acid[h] + 8 R_ACP[h]'); 

    % Add palmitate transport

    AMF_model = addReaction(AMF_model,'AMF_Palmitate_TR','reactionFormula','R_Palmitic_acid[h] -> m0384[e0]');

    % Add PPi transport

    AMF_model = addReaction(AMF_model,'AMF_Pi_TR','reactionFormula','m0410[c0] + 2 H[a] -> R_PPi[c] + R_PI_TRANSPORT[c]');
    AMF_model = addReaction(AMF_model,'AMF_PlantHPump','reactionFormula','R_ATP[c] + R_H2O[c] -> R_ADP[c] + R_Pi[c] + 4 H[a]');
    AMF_model = addReaction(AMF_model,'AMF_FungusHPump','reactionFormula','m0464[c0] + m0528[c0] -> m0503[c0] + m0137[c0] + 4 H[a]');
    AMF_model = addReaction(AMF_model,'R_Im_Pi','reactionFormula','R_ATP[c] + R_H2O[c] -> R_H[h] + 2 R_Pi[h] + R_ADP[c] + R_Pi[c] + R_PI_TRANSPORT[c]');
    AMF_model = addReaction(AMF_model,'PI_TRANSPORT_DRAIN','reactionFormula','R_PI_TRANSPORT[c] ->');

    % Add NH4 transport

    AMF_model = addReaction(AMF_model,'AMF_NH4_TR','reactionFormula','m0110[c0] -> R_NH4[c] + R_NH4_Transport[c]');
    AMF_model = addReaction(AMF_model,'R_Im_NH4','reactionFormula','-> R_NH4[c] + R_NH4_Transport[c]');
    AMF_model = addReaction(AMF_model,'NH4_TRANSPORT_DRAIN','reactionFormula','R_NH4_Transport[c] ->');

    % Turn off glucose and palmitate uptake in fungus

    AMF_model = changeRxnBounds(AMF_model,'r1007_e0',0,'u');
    AMF_model = changeRxnBounds(AMF_model,'r1533_e0',0,'l');

    %AMF_model = changeRxnBounds(AMF_model,'r1067_c0',2,'b') % This is the key one - need to be able to dispense

    % Grow plant

    AMF_model = changeObjective(AMF_model,'Total_plant_biomass');
    solution = optimizeCbModel(AMF_model,'max');



    % Plant can take 1X nitrogen itself and 1X nitrogen via AMF
    % Plant can take 1X P itself and 9X P via AMF, based off of 90% P coming
    % from AMF value from Bennett and Groten 2022. 

    % Upper bounds for both can be whatever the minimal value is for either Nh4
    % uptake or Pi uptake under given light conditions

    % Finding maxima

    % Defining base uptake vectors

    %P_levels = linspace(0,Pi_max,11)
    %P_levels_AMF = P_levels * 3
    %N_levels = linspace(0,NH4_max,11)
    %N_levels_AMF = N_levels * 1.23

    P_levels = linspace(0,Pi_max,11);
    P_levels_AMF = P_levels * 3.16;
    N_levels = linspace(0,NH4_max,11);
    N_levels_AMF = N_levels * 1.23;


    % At the given N level, ask how much the plant could grow. With or without
    % carbon paid to AMF? Without, clearly. But with the N boost from the AMF. 
    AMF_model = changeRxnBounds(AMF_model,'R_Im_CO2',-1000,'l');

    CO2_levels = {}

    AMF_model = addReaction(AMF_model,'M_Im_CO2','reactionFormula','-> M_CO2[c] + C_uptake[c]');
    AMF_model = addReaction(AMF_model,'R_Im_CO2','reactionFormula','-> R_CO2[c] + C_uptake[c]');
    AMF_model = addReaction(AMF_model,'AMF_C_Total','reactionFormula','C_uptake[c] ->');
    AMF_model = changeRxnBounds(AMF_model,'R_Im_CO2',-1000,'l');

    % Adding in for testing purposes
    AMF_model = changeRxnBounds(AMF_model,'r0066_c0',0,'l');

    %

    CO2_INDEX = find(contains(AMF_model.rxns,{'AMF_C_Total'}));

    % Find AMF max biomass

    AMF_model = changeRxnBounds(AMF_model,'NH4_TRANSPORT_DRAIN',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'NH4_TRANSPORT_DRAIN',0,'l');
    AMF_model = changeRxnBounds(AMF_model,'PI_TRANSPORT_DRAIN',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'PI_TRANSPORT_DRAIN',0,'l');

    % Constrain 20% of C to go to the AMF given the previous optimization

    AMF_model = removeRxns(AMF_model,'AMF_C_Total');
    AMF_model = addReaction(AMF_model,'M_Im_CO2','reactionFormula','-> M_CO2[c] + C_uptake[c] + C_tracker[c]');
    AMF_model = addReaction(AMF_model,'R_Im_CO2','reactionFormula','-> R_CO2[c] + C_uptake[c] + C_tracker[c]');
    AMF_model = changeRxnBounds(AMF_model,'R_Im_CO2',-1000,'l');
    AMF_model = addReaction(AMF_model,'R_CO2_Ex','reactionFormula','R_CO2[c] ->');
    AMF_model = addReaction(AMF_model,'AMF_C_Total','reactionFormula','C_tracker[c] ->');

    AMF_model = addReaction(AMF_model,['AMF_Glucose_TR'],{['R_Glc[c]'],['m0564[e0]'],['C_cost[c]']},[-1 1 6/AMF_cost],0,0,1000);
    AMF_model = addReaction(AMF_model,['AMF_Palmitate_TR'],{['R_Palmitic_acid[h]'],['m0384[e0]'],['C_cost[c]']},[-1 1 16/AMF_cost],0,0,1000);
    AMF_model = addReaction(AMF_model,'AMF_C_Balance','reactionFormula','C_uptake[c] + C_cost[c] ->');

    % Optimize AMF biomass accumulation

    AMF_biomass_index = find(contains(AMF_model.rxns,{'r1067_c0'}));
    AMF_biomass = {}

    AMF_model = changeObjective(AMF_model,'r1067_c0');

    solution = optimizeCbModel(AMF_model,'max','one');


    AMF_model = changeRxnBounds(AMF_model,'r0992_e0',-1000,'l');
    AMF_model = changeRxnBounds(AMF_model,'r0994_e0',-1000,'l');

    solution = optimizeCbModel(AMF_model,'max','one');



    AMF_model = changeRxnBounds(AMF_model,'AMF_C_Total',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'AMF_C_Total',0,'l');

    AMF_model = changeRxnBounds(AMF_model,'r0992_e0',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'r0992_e0',-1000,'l');
    AMF_model = changeRxnBounds(AMF_model,'r0994_e0',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'r0994_e0',-1000,'l');



    % Constrain AMF biomass accumulation to the optimal value and then optimize
    % plant growth. This is our final RGR value. 

    AMF_model = changeObjective(AMF_model,'Total_plant_biomass');
    solution = optimizeCbModel(AMF_model,'max','one');
    RGR_values_combined = {};


    AMF_model = removeRxns(AMF_model,'AMF_C_Total');
    AMF_model = addReaction(AMF_model,'M_Im_CO2','reactionFormula','-> M_CO2[c]');
    AMF_model = addReaction(AMF_model,'R_Im_CO2','reactionFormula','-> R_CO2[c]');
    AMF_model = changeRxnBounds(AMF_model,'R_Im_CO2',-1000,'l');
    AMF_model = addReaction(AMF_model,'R_CO2_Ex','reactionFormula','R_CO2[c] ->');

    AMF_model = addReaction(AMF_model,['AMF_Glucose_TR'],{['R_Glc[c]'],['m0564[e0]']},[-1 1],0,0,1000);
    AMF_model = addReaction(AMF_model,['AMF_Palmitate_TR'],{['R_Palmitic_acid[h]'],['m0384[e0]']},[-1 1],0,0,1000);
    % Create a reaction constrained to go at the same rate as the AMF biomass
    % reaction

    AMF_model = addReaction(AMF_model,'AMF_Biomass_Counter','reactionFormula','-> P_uptake_credit[c] + N_uptake_credit[c]');
    AMF_model = addRatioReaction(AMF_model,{'AMF_Biomass_Counter' 'r1067_c0'},[1 1]);

    AMF_model = addReaction(AMF_model,'R_Im_Pi','reactionFormula','R_ATP[c] + R_H2O[c] -> R_H[h] + 2 R_Pi[h] + R_ADP[c] + R_Pi[c]');
    AMF_model = addReaction(AMF_model,'R_Im_NH4','reactionFormula','-> R_NH4[c]');

    AMF_model = changeRxnBounds(AMF_model,'r1067_c0',0,'l');
    Percent_allocation = {}

    AMF_biomass_index = find(contains(AMF_model.rxns,{'r1067_c0'}));


    changeCobraSolver('ibm_cplex');

    Glucose_flux = find(contains(AMF_model.rxns,{'AMF_Glucose_TR'}));
    Palmitate_flux = find(contains(AMF_model.rxns,{'AMF_Palmitate_TR'}));
    CO2_flux = find(contains(AMF_model.rxns,{'M_Im_CO2'}));
    P_flux = find(contains(AMF_model.rxns,{'AMF_Pi_TR'}));
    AMF_model = addReaction(AMF_model,['AMF_Glucose_TR'],{['R_Glc[c]'],['m0563[c0]']},[-1 1],0,0,1000);
    AMF_biomass_index = find(contains(AMF_model.rxns,{'r1067_c0'}));

    Percent_allocation = {};
    Glucose_fluxes = {};
    Palmitate_fluxes = {};
    CO2_fluxes = {};
    RGR_values_combined = {};
    P_fluxes = {};

    %AMF_model = changeObjective(AMF_model,'r1067_c0')
    %AMF_model = changeObjective(AMF_model,'AMF_PlantHPump')

    AMF_model = changeObjective(AMF_model,'Total_plant_biomass');
    AMF_model = changeRxnBounds(AMF_model,'r0066_c0',3.2*0.0972,'b');

    AMF_model = changeRxnBounds(AMF_model,'r0728_e0',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'r1632_e0',0,'u');
    AMF_model = changeRxnBounds(AMF_model,'r1010_e0',1000,'u');

    AMF_model = addReaction(AMF_model,'ammonium_uptake','reactionFormula','-> m0110[c0]');

    AMF_model = addReaction(AMF_model, ...
        ['r0648_c0'],{['m0034[c0]'],['m0071[c0]'],['m0072[c0]'],['m0159[c0]'],['m0163[c0]'],['m0165[c0]'],['m0185[c0]'],['m0208[c0]'],['m0237[c0]'],['m0239[c0]'],['m0262[m0]'],['m0265[c0]'],['m0298[c0]'],['m0308[c0]'],['m0328[c0]'],['m0334[c0]'],['m0446[c0]'],['m0464[c0]'],['m0470[c0]'],['m0528[c0]'],['m0604[m0]'],['m0733[c0]'],['m0761[c0]'],['m0944[m0]'],['m0995[c0]'],['m1027[r0]'],['m1028[n0]'],['m1030[c0]'],['m1031[n0]'],['m1327[c0]'],['m0137[c0]'],['m0503[c0]'],['m0544[c0]'],['m0754[c0]']}, ...
        [-0.021979,-0.047546,-0.059153,-0.018606,-0.16149,-0.034319,-0.038794,-0.036459,-0.098208,-0.34786,-0.017094,-0.34786,-0.032839,-0.030887,-0.031832,-0.016025,-0.019664,-AMFGAM,-0.019071,-AMFGAM,-0.010596,-0.023695,-0.00381,-0.020029,-1,-1,-1,-1,-1,-0.027185,AMFGAM,AMFGAM,AMFGAM,1],0,0,1000)

    Early_RGR_noBacteroidwithAMF = {};
    Mid_RGR_noBacteroidwithAMF = {};
    Late_RGR_noBacteroidwithAMF = {};

    Early_RGR_noBacteroidwithAMF_AMFBiomass = {};
    Mid_RGR_noBacteroidwithAMF_AMFBiomass = {};
    Late_RGR_noBacteroidwithAMF_AMFBiomass = {};

    Early_RGR_noBacteroidwithAMF_GlucoseFluxes = {};
    Mid_RGR_noBacteroidwithAMF_GlucoseFluxes = {};
    Late_RGR_noBacteroidwithAMF_GlucoseFluxes = {};

    Early_RGR_noBacteroidwithAMF_PalmitateFluxes = {};
    Mid_RGR_noBacteroidwithAMF_PalmitateFluxes = {};
    Late_RGR_noBacteroidwithAMF_PalmitateFluxes = {};

    Early_RGR_noBacteroidwithAMF_CO2Fluxes = {};
    Mid_RGR_noBacteroidwithAMF_CO2Fluxes = {};
    Late_RGR_noBacteroidwithAMF_CO2Fluxes = {};

    Early_RGR_noBacteroidwithAMF_PFluxes = {};
    Mid_RGR_noBacteroidwithAMF_PFluxes = {};
    Late_RGR_noBacteroidwithAMF_PFluxes = {};

    AMF_model = changeObjective(AMF_model,'EX_Total_Plant_Biomass');
    AMF_model = changeRxnBounds(AMF_model,'R_Im_Pi',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'R_Im_NH4',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'r1067_c0',0,'u');
    AMF_model = changeRxnBounds(AMF_model,'r0066_c0',0,'b');
    solution = optimizeCbModel(AMF_model,'max','one');

    changeCobraSolver('ibm_cplex');

    AMF_model = changeRxnBounds(AMF_model,'AMF_Pi_TR',0,'b');
    AMF_model = changeRxnBounds(AMF_model,'AMF_NH4_TR',0,'b');
    AMF_model = changeRxnBounds(AMF_model,'ammonium_uptake',0,'b');



    %
    ER_Nitro_coef = 1.757;
    ER_Carbo_coef = 3.023;
    ER_Lipid_coef = 0.07838;
    ER_Lignin_coef = 0.4527;
    ER_Organic_coef = 0.339;
    ER_Materials_coef = 1.305;

    ES_Nitro_coef = 1.757;
    ES_Carbo_coef = 3.023;
    ES_Lipid_coef = 0.07838;
    ES_Lignin_coef = 0.4527;
    ES_Organic_coef = 0.339;
    ES_Materials_coef = 1.305;

    [MR_Nitro_coef, MR_Carbo_coef, MR_Lipid_coef, MR_Lignin_coef, MR_Organic_coef, MR_Materials_coef] = calculateBiomassCoefs(20.105, coef_params);
    [LR_Nitro_coef, LR_Carbo_coef, LR_Lipid_coef, LR_Lignin_coef, LR_Organic_coef, LR_Materials_coef] = calculateBiomassCoefs(35.245, coef_params);
    [MS_Nitro_coef, MS_Carbo_coef, MS_Lipid_coef, MS_Lignin_coef, MS_Organic_coef, MS_Materials_coef] = calculateBiomassCoefs(10.87, coef_params);
    [LS_Nitro_coef, LS_Carbo_coef, LS_Lipid_coef, LS_Lignin_coef, LS_Organic_coef, LS_Materials_coef] = calculateBiomassCoefs(37.19, coef_params);

    ER_set = [ER_Nitro_coef, ER_Carbo_coef, ER_Lipid_coef, ER_Lignin_coef, ER_Organic_coef, ER_Materials_coef];
    MR_set = [MR_Nitro_coef, MR_Carbo_coef, MR_Lipid_coef, MR_Lignin_coef, MR_Organic_coef, MR_Materials_coef];
    LR_set = [LR_Nitro_coef, LR_Carbo_coef, LR_Lipid_coef, LR_Lignin_coef, LR_Organic_coef, LR_Materials_coef];
    ES_set = [ES_Nitro_coef, ES_Carbo_coef, ES_Lipid_coef, ES_Lignin_coef, ES_Organic_coef, ES_Materials_coef];
    MS_set = [MS_Nitro_coef, MS_Carbo_coef, MS_Lipid_coef, MS_Lignin_coef, MS_Organic_coef, MS_Materials_coef];
    LS_set = [LS_Nitro_coef, LS_Carbo_coef, LS_Lipid_coef, LS_Lignin_coef, LS_Organic_coef, LS_Materials_coef];

    E_set = {ES_set ER_set};
    M_set = {MS_set, MR_set};
    L_set = {LS_set, LR_set};

    all_sets = {E_set, M_set, L_set};

    AMF_model = changeRxnBounds(AMF_model,'Bacteroid_NIT',0,'b');
    AMF_model = changeRxnBounds(AMF_model,'r0066_c0',0,'l');
    AMF_model = changeRxnBounds(AMF_model,'r0066_c0',1000,'u');

    AMF_model = changeRxnBounds(AMF_model,'Bacteroid_ATPMR',0,'l');
    AMF_model = changeRxnBounds(AMF_model,'Bacteroid_ATPMR',1000,'u');

    AMF_model = addReaction(AMF_model,['Total_plant_biomass'],{['Total_Shoot_Biomass[e]'],['R_Biomass[e]'],['Total_Plant_Biomass[e]']},[-ShootProportion -RootProportion 1]);
    AMF_model = addReaction(AMF_model,['FullBiomass_Accumulation'],{['Total_Plant_Biomass[e]'],['Nodule_Biomass[e]'],['FullBiomass[e]']},[-PlantProportion -NoduleProportion 1]);
    AMF_model = addReaction(AMF_model,'EX_FullBiomass','reactionFormula','FullBiomass[e] ->');


    AMF_model = changeRxnBounds(AMF_model,'R_Im_NH4',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'R_Im_Pi',1000,'u');

    AMF_model = changeObjective(AMF_model,'EX_FullBiomass');
    solution = optimizeCbModel(AMF_model,'max','one');

    if isnan(solution.f)
        disp('Trying again');
        changeCobraSolver('gurobi');
        solution = optimizeCbModel(AMF_model,'max','one');
        changeCobraSolver('ibm_cplex');
    end

    PI_INDEX = find(contains(AMF_model.rxns,{'R_Im_Pi'}));
    NH4_INDEX = find(contains(AMF_model.rxns,{'R_Im_NH4'}));

    Pi_max = solution.x(PI_INDEX);
    NH4_max = solution.x(NH4_INDEX);

    P_levels = linspace(0,Pi_max,11);
    P_levels_AMF = P_levels * 3.16;
    N_levels = linspace(0,NH4_max,11);
    N_levels_AMF = N_levels * 1.23;

    %

    AMF_model = changeRxnBounds(AMF_model,'Bacteroid_NIT',1000,'u');
    AMF_model = changeRxnBounds(AMF_model,'Bacteroid_NIT',0,'l');
    AMF_model = changeRxnBounds(AMF_model,'Bacteroid_ATPMR',BacteroidNGAM*NoduleProportion*0.25,'l');
    AMF_model = changeRxnBounds(AMF_model,'Nodule_ATPM',RootNGAM*NoduleProportion,'l');



    b = 1;
    working_set = all_sets{b};
    S_set = working_set{1};
    R_set = working_set{2};

    AMF_model = addReaction(AMF_model,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    AMF_model = addReaction(AMF_model,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
    AMF_model = addReaction(AMF_model,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    AMF_model = addReaction(AMF_model,['Nodule_NewBiomass'],{['Nodule_Nitrogeneous_compounds[c]'],['Nodule_Carbohydrates[c]'],['Nodule_Lipids[c]'],['Nodule_Lignin[c]'],['Nodule_Organic_acids[c]'],['Nodule_Materials[c]'],['Nodule_ATP[c]'],['Nodule_Biomass[e]'],['Nodule_ADP[c]'],['Nodule_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    for i=1:numel(N_levels);
        for n=1:numel(P_levels);
            AMF_model = changeRxnBounds(AMF_model,'R_Im_NH4',N_levels_early(i),'u');
            AMF_model = changeRxnBounds(AMF_model,'R_Im_Pi',P_levels_early(n),'u');
            solution = optimizeCbModel(AMF_model,'max');
            Growth_early{i,n} = solution.f;
        end
    end


    b = 2;
    working_set = all_sets{b};
    S_set = working_set{1};
    R_set = working_set{2};

    AMF_model = addReaction(AMF_model,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    AMF_model = addReaction(AMF_model,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
    AMF_model = addReaction(AMF_model,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    AMF_model = addReaction(AMF_model,['Nodule_NewBiomass'],{['Nodule_Nitrogeneous_compounds[c]'],['Nodule_Carbohydrates[c]'],['Nodule_Lipids[c]'],['Nodule_Lignin[c]'],['Nodule_Organic_acids[c]'],['Nodule_Materials[c]'],['Nodule_ATP[c]'],['Nodule_Biomass[e]'],['Nodule_ADP[c]'],['Nodule_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);

    for i=1:numel(N_levels);
        for n=1:numel(P_levels);
            AMF_model = changeRxnBounds(AMF_model,'R_Im_NH4',N_levels_mid(i),'u');
            AMF_model = changeRxnBounds(AMF_model,'R_Im_Pi',P_levels_mid(n),'u');
            solution = optimizeCbModel(AMF_model,'max');
            Growth_mid{i,n} = solution.f;
        end
    end

    b = 3;
    working_set = all_sets{b};
    S_set = working_set{1};
    R_set = working_set{2};

    AMF_model = addReaction(AMF_model,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    AMF_model = addReaction(AMF_model,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
    AMF_model = addReaction(AMF_model,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    AMF_model = addReaction(AMF_model,['Nodule_NewBiomass'],{['Nodule_Nitrogeneous_compounds[c]'],['Nodule_Carbohydrates[c]'],['Nodule_Lipids[c]'],['Nodule_Lignin[c]'],['Nodule_Organic_acids[c]'],['Nodule_Materials[c]'],['Nodule_ATP[c]'],['Nodule_Biomass[e]'],['Nodule_ADP[c]'],['Nodule_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    for i=1:numel(N_levels);
        for n=1:numel(P_levels);
            AMF_model = changeRxnBounds(AMF_model,'R_Im_NH4',N_levels_late(i),'u');
            AMF_model = changeRxnBounds(AMF_model,'R_Im_Pi',P_levels_late(n),'u');
            solution = optimizeCbModel(AMF_model,'max');
            Growth_late{i,n} = solution.f;
        end
    end

    AMFWithBacteroid = AMF_model;

    %

    original_AMF_model = AMFWithBacteroid;

    Early_RGR_WithBacteroidwithAMF = cell(length(N_levels),length(P_levels));
    Mid_RGR_WithBacteroidwithAMF = cell(length(N_levels),length(P_levels));
    Late_RGR_WithBacteroidwithAMF = cell(length(N_levels),length(P_levels));
    Early_RGR_WithBacteroidwithAMF_AMFBiomass = cell(length(N_levels),length(P_levels));
    EarlyRGR_WithBacteroidwithAMF_GlucoseFluxes = cell(length(N_levels),length(P_levels));
    EarlyRGR_WithBacteroidwithAMF_PalmitateFluxes = cell(length(N_levels),length(P_levels));
    EarlyRGR_WithBacteroidwithAMF_CO2Fluxes = cell(length(N_levels),length(P_levels));
    EarlyRGR_WithBacteroidwithAMF_PFluxes = cell(length(N_levels),length(P_levels));     
    Mid_RGR_WithBacteroidwithAMF_AMFBiomass = cell(length(N_levels),length(P_levels));
    MidRGR_WithBacteroidwithAMF_GlucoseFluxes = cell(length(N_levels),length(P_levels));
    MidRGR_WithBacteroidwithAMF_PalmitateFluxes = cell(length(N_levels),length(P_levels));
    MidRGR_WithBacteroidwithAMF_CO2Fluxes = cell(length(N_levels),length(P_levels));
    MidRGR_WithBacteroidwithAMF_PFluxes = cell(length(N_levels),length(P_levels));      
    Late_RGR_WithBacteroidwithAMF_AMFBiomass = cell(length(N_levels),length(P_levels));
    LateRGR_WithBacteroidwithAMF_GlucoseFluxes = cell(length(N_levels),length(P_levels));
    LateRGR_WithBacteroidwithAMF_PalmitateFluxes = cell(length(N_levels),length(P_levels));
    LateRGR_WithBacteroidwithAMF_CO2Fluxes = cell(length(N_levels),length(P_levels));
    LateRGR_WithBacteroidwithAMF_PFluxes = cell(length(N_levels),length(P_levels));   



    for b=1:numel(all_sets);
        AMFWithBacteroid = original_AMF_model;
        AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'ammonium_uptake',0,'u');
        AMFWithBacteroid = changeObjective(AMFWithBacteroid,'EX_Total_Plant_Biomass');

        AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'AMF_Pi_TR',1000,'u');
        AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'AMF_NH4_TR',1000,'u');

        AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'ammonium_uptake',1000,'u');
        AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'r1067_c0',1000,'u');
        AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'r0066_c0',AMFNGAM*NecessaryAMFBiomass,'l');
        AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'r0066_c0',1000,'u');


        for i=1:numel(N_levels);
            for n=1:numel(P_levels);
                working_set = all_sets{b};
                S_set = working_set{1};
                R_set = working_set{2};
                AMFWithBacteroid = addReaction(AMFWithBacteroid,['AMF_Glucose_TR'],{['R_Glc[c]'],['m0564[e0]']},[-1 1]);
                AMFWithBacteroid = addReaction(AMFWithBacteroid,['AMF_Palmitate_TR'],{['R_Palmitic_acid[h]'],['m0384[e0]']},[-1 1]);
                AMFWithBacteroid = addReaction(AMFWithBacteroid,['P_uptake_dump'],{['P_uptake_credit[c]']},[-1],0,0,1000);
                AMFWithBacteroid = addReaction(AMFWithBacteroid,['N_uptake_dump'],{['N_uptake_credit[c]']},[-1],0,0,1000);

                AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'ammonium_uptake',1000,'u');

                AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'r0992_e0',1000,'u');
                AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'r0992_e0',-1000,'l');


                AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'r0994_e0',-1000,'l');
                AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'r0994_e0',1000,'u');

                AMFWithBacteroid = addReaction(AMFWithBacteroid,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
                AMFWithBacteroid = addReaction(AMFWithBacteroid,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);           
                AMFWithBacteroid = addReaction(AMFWithBacteroid,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
                AMFWithBacteroid = addReaction(AMFWithBacteroid,['Nodule_NewBiomass'],{['Nodule_Nitrogeneous_compounds[c]'],['Nodule_Carbohydrates[c]'],['Nodule_Lipids[c]'],['Nodule_Lignin[c]'],['Nodule_Organic_acids[c]'],['Nodule_Materials[c]'],['Nodule_ATP[c]'],['Nodule_Biomass[e]'],['Nodule_ADP[c]'],['Nodule_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);

                if b == 1;
                    try
                        AMFWithBacteroid = addReaction(AMFWithBacteroid,['P_uptake_conversion'],{['P_uptake_credit[c]'],['P_uptake[c]']},[-Growth_early{i,n}*NecessaryAMFBiomass 1],0,0,1);
                        AMFWithBacteroid = addReaction(AMFWithBacteroid,['N_uptake_conversion'],{['N_uptake_credit[c]'],['N_uptake[c]']},[-Growth_early{i,n}*NecessaryAMFBiomass 1],0,0,1);               
                        AMFWithBacteroid = addReaction(AMFWithBacteroid,['AMF_Pi_TR'],{['m0137[c0]'],['H[a]'],['P_uptake[c]'],['R_Pi[c]']},[-2*P_levels_early(n)*AMF_P_Benefit -4*P_levels_early(n)*AMF_P_Benefit -1 2*P_levels_early(n)*AMF_P_Benefit]);
                        AMFWithBacteroid = addReaction(AMFWithBacteroid,['AMF_NH4_TR'],{['m0110[c0]'],['N_uptake[c]'],['R_NH4[c]']},[-N_levels_early(i)*AMF_N_Benefit -1 N_levels_early(i)*AMF_N_Benefit]);
                        AMFWithBacteroid = addReaction(AMFWithBacteroid,'R_Im_Pi','reactionFormula','R_ATP[c] + R_H2O[c] -> R_H[h] + 2 R_Pi[h] + R_ADP[c] + R_Pi[c]');
                        AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_NH4',N_levels_early(i),'u');
                        AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_Pi',P_levels_early(n),'u');
                        Glucose_flux = find(contains(AMFWithBacteroid.rxns,{'AMF_Glucose_TR'}));
                        Palmitate_flux = find(contains(AMFWithBacteroid.rxns,{'AMF_Palmitate_TR'}));
                        CO2_flux = find(contains(AMFWithBacteroid.rxns,{'M_Im_CO2'}));
                        P_flux = find(contains(AMFWithBacteroid.rxns,{'AMF_Pi_TR'}));
                        AMF_biomass_index = find(contains(AMFWithBacteroid.rxns,{'r1067_c0'}));

                        solution = optimizeCbModel(AMFWithBacteroid,'max','one');
                        if isnan(solution.f);
                            disp('Trying again');
                            solution = optimizeCbModel(AMFWithBacteroid,'max','one');
                            changeCobraSolver('ibm_cplex');
                            if isnan(solution.f);
                                disp('Trying again');
                                changeCobraSolver('gurobi');
                                solution = optimizeCbModel(AMFWithBacteroid,'max','one');
                                changeCobraSolver('ibm_cplex');
                                if isnan(solution.f);
                                    disp('Trying again');
                                    changeCobraSolver('gurobi');
                                    solution = optimizeCbModel(AMFWithBacteroid,'max','one');
                                    changeCobraSolver('ibm_cplex');
                                    if isnan(solution.f);
                                        disp('Trying again');
                                        changeCobraSolver('glpk');
                                        solution = optimizeCbModel(AMFWithBacteroid,'max','one');
                                        changeCobraSolver('ibm_cplex');
                                        if isnan(solution.f);
                                            disp('Trying again');
                                            changeCobraSolver('glpk');
                                            solution = optimizeCbModel(AMFWithBacteroid,'max','one');
                                            changeCobraSolver('ibm_cplex');
                                        end
                                    end
                                end
                            end
                        end

                        Early_RGR_WithBacteroidwithAMF{i,n} = solution.f;

                        EarlyRGR_WithBacteroidwithAMF_AMFBiomass{i,n} = solution.x(AMF_biomass_index);

                        EarlyRGR_WithBacteroidwithAMF_GlucoseFluxes{i,n} = solution.x(Glucose_flux);

                        EarlyRGR_WithBacteroidwithAMF_PalmitateFluxes{i,n} = solution.x(Palmitate_flux);

                        EarlyRGR_WithBacteroidwithAMF_CO2Fluxes{i,n} = solution.x(CO2_flux);

                        EarlyRGR_WithBacteroidwithAMF_PFluxes{i,n} = solution.x(P_flux)*(P_levels_early(n)*2.16);                
                    catch
                    end
                end
                if b == 2;
                    Mid_RGR_WithBacteroidwithAMF{i,n} = 1;

                    MidRGR_WithBacteroidwithAMF_AMFBiomass{i,n} = 1;

                    MidRGR_WithBacteroidwithAMF_GlucoseFluxes{i,n} = 1;

                    MidRGR_WithBacteroidwithAMF_PalmitateFluxes{i,n} = 1;

                    MidRGR_WithBacteroidwithAMF_CO2Fluxes{i,n} = 1;

                    MidRGR_WithBacteroidwithAMF_PFluxes{i,n} = 1;  
                    
                    %AMF_biomass_index = find(contains(AMFWithBacteroid.rxns,{'r1067_c0'}));
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,['P_uptake_conversion'],{['P_uptake_credit[c]'],['P_uptake[c]']},[-Growth_mid{i,n}*NecessaryAMFBiomass 1],0,0,1);
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,['N_uptake_conversion'],{['N_uptake_credit[c]'],['N_uptake[c]']},[-Growth_mid{i,n}*NecessaryAMFBiomass 1],0,0,1);                
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,['AMF_Pi_TR'],{['m0137[c0]'],['H[a]'],['P_uptake[c]'],['R_Pi[c]']},[-P_levels_mid(n)*AMF_P_Benefit -2*P_levels_mid(n)*AMF_P_Benefit -1 P_levels_mid(n)*AMF_P_Benefit]);
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,['AMF_NH4_TR'],{['m0110[c0]'],['N_uptake[c]'],['R_NH4[c]']},[-N_levels_mid(i)*AMF_N_Benefit -1 N_levels_mid(i)*AMF_N_Benefit]);
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,'R_Im_Pi','reactionFormula','R_ATP[c] + R_H2O[c] -> R_H[h] + 2 R_Pi[h] + R_ADP[c] + R_Pi[c]');               
                    %AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_NH4',N_levels_mid(i),'u');
                    %AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_Pi',P_levels_mid(n),'u');

                    %AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_NH4',N_levels_mid(i),'u');
                    %AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_Pi',P_levels_mid(n),'u');
                    %Glucose_flux = find(contains(AMFWithBacteroid.rxns,{'AMF_Glucose_TR'}));
                    %Palmitate_flux = find(contains(AMFWithBacteroid.rxns,{'AMF_Palmitate_TR'}));
                    %CO2_flux = find(contains(AMFWithBacteroid.rxns,{'M_Im_CO2'}));
                    %P_flux = find(contains(AMFWithBacteroid.rxns,{'AMF_Pi_TR'}));
                    %solution = optimizeCbModel(AMFWithBacteroid,'max','one',1);
                    %if isnan(solution.f);
                    %    disp('Trying again');
                    %    solution = optimizeCbModel(AMFWithBacteroid,'max','one',0);
                    %    changeCobraSolver('ibm_cplex');
                    %    if isnan(solution.f);
                    %        disp('Trying again');
                    %        changeCobraSolver('gurobi');
                    %        solution = optimizeCbModel(AMFWithBacteroid,'max','one',1);
                    %        changeCobraSolver('ibm_cplex');
                    %        if isnan(solution.f);
                    %            disp('Trying again');
                    %            changeCobraSolver('gurobi');
                    %            solution = optimizeCbModel(AMFWithBacteroid,'max','one',0);
                    %            changeCobraSolver('ibm_cplex');
                    %            if isnan(solution.f);
                    %                disp('Trying again');
                    %                changeCobraSolver('glpk');
                    %                solution = optimizeCbModel(AMFWithBacteroid,'max','one',1);
                    %                changeCobraSolver('ibm_cplex');
                    %                if isnan(solution.f);
                    %                    disp('Trying again');
                    %                    changeCobraSolver('glpk');
                    %                    solution = optimizeCbModel(AMFWithBacteroid,'max','one',0);
                    %                    changeCobraSolver('ibm_cplex');
                    %                end
                    %            end
                    %        end
                    %    end
                    %end  

                end
                if b == 3;

                    Late_RGR_WithBacteroidwithAMF{i,n} = 1;

                    LateRGR_WithBacteroidwithAMF_AMFBiomass{i,n} = 1;

                    LateRGR_WithBacteroidwithAMF_GlucoseFluxes{i,n} = 1;

                    LateRGR_WithBacteroidwithAMF_PalmitateFluxes{i,n} = 1;

                    LateRGR_WithBacteroidwithAMF_CO2Fluxes{i,n} = 1;

                    LateRGR_WithBacteroidwithAMF_PFluxes{i,n} = 1;
                    
                    %AMF_biomass_index = find(contains(AMFWithBacteroid.rxns,{'r1067_c0'}));
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,['P_uptake_conversion'],{['P_uptake_credit[c]'],['P_uptake[c]']},[-Growth_late{i,n}*NecessaryAMFBiomass 1],0,0,1);
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,['N_uptake_conversion'],{['N_uptake_credit[c]'],['N_uptake[c]']},[-Growth_late{i,n}*NecessaryAMFBiomass 1],0,0,1);                
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,['AMF_Pi_TR'],{['m0137[c0]'],['H[a]'],['P_uptake[c]'],['R_Pi[c]']},[-P_levels_late(n)*AMF_P_Benefit -2*P_levels_late(n)*AMF_P_Benefit -1 P_levels_late(n)*AMF_P_Benefit]);
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,['AMF_NH4_TR'],{['m0110[c0]'],['N_uptake[c]'],['R_NH4[c]']},[-N_levels_late(i)*AMF_N_Benefit -1 N_levels_late(i)*AMF_N_Benefit]);
                    %AMFWithBacteroid = addReaction(AMFWithBacteroid,'R_Im_Pi','reactionFormula','R_ATP[c] + R_H2O[c] -> R_H[h] + 2 R_Pi[h] + R_ADP[c] + R_Pi[c]');                
                    %AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_NH4',N_levels_late(i),'u');
                    %AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_Pi',P_levels_late(n),'u');

                    %AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_NH4',N_levels_late(i),'u');
                    %AMFWithBacteroid = changeRxnBounds(AMFWithBacteroid,'R_Im_Pi',P_levels_late(n),'u');
                    %Glucose_flux = find(contains(AMFWithBacteroid.rxns,{'AMF_Glucose_TR'}));
                    %Palmitate_flux = find(contains(AMFWithBacteroid.rxns,{'AMF_Palmitate_TR'}));
                    %CO2_flux = find(contains(AMFWithBacteroid.rxns,{'M_Im_CO2'}));
                    %P_flux = find(contains(AMFWithBacteroid.rxns,{'AMF_Pi_TR'}));
                    %solution = optimizeCbModel(AMFWithBacteroid,'max','one',1);
                    %if isnan(solution.f);
                    %    disp('Trying again');
                    %    solution = optimizeCbModel(AMFWithBacteroid,'max','one',0);
                    %    changeCobraSolver('ibm_cplex');
                    %    if isnan(solution.f);
                    %        disp('Trying again');
                    %        changeCobraSolver('gurobi');
                    %        solution = optimizeCbModel(AMFWithBacteroid,'max','one',1);
                    %        changeCobraSolver('ibm_cplex');
                    %        if isnan(solution.f);
                    %            disp('Trying again');
                    %            changeCobraSolver('gurobi');
                    %            solution = optimizeCbModel(AMFWithBacteroid,'max','one',0);
                    %            changeCobraSolver('ibm_cplex');
                    %            if isnan(solution.f);
                    %                disp('Trying again');
                    %                changeCobraSolver('glpk');
                    %                solution = optimizeCbModel(AMFWithBacteroid,'max','one',1);
                    %                changeCobraSolver('ibm_cplex');
                    %                if isnan(solution.f);
                    %                    disp('Trying again');
                    %                    changeCobraSolver('glpk');
                    %                    solution = optimizeCbModel(AMFWithBacteroid,'max','one',0);
                    %                    changeCobraSolver('ibm_cplex');
                    %                end
                    %            end
                    %        end
                    %    end
                    %end
                   
                end
            end
        end
    end

    %

    for i=1:numel(AMF_model.rxns);
        if strcmp(extractBefore(AMF_model.rxns{i},'_'),'Nodule') | strcmp(extractBefore(AMF_model.rxns{i},'_'),'Bacteroid');
                AMF_model = changeRxnBounds(AMF_model,AMF_model.rxns{i},0,'b');
        end
    end

    AMFNoBacteroid = AMF_model;

    %

    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',1000,'u');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',1000,'u');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r1067_c0',0,'u');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r0066_c0',0,'b');
    solution = optimizeCbModel(AMFNoBacteroid,'max','one');

    changeCobraSolver('ibm_cplex');

    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'AMF_Pi_TR',0,'b');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'AMF_NH4_TR',0,'b');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'ammonium_uptake',0,'b');

    AMFNoBacteroid = addReaction(AMFNoBacteroid,'Total_plant_biomass','reactionFormula','0.90 Total_Shoot_Biomass[e] + 0.1 R_Biomass[e] -> Total_Plant_Biomass[e]');
    AMFNoBacteroid = addReaction(AMFNoBacteroid,'FullBiomass_Accumulation','reactionFormula','Total_Plant_Biomass[e] -> FullBiomass[e]');
    AMFNoBacteroid = addReaction(AMFNoBacteroid,'EX_FullBiomass','reactionFormula','FullBiomass[e] ->');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'Shoot_ATPM_Drain',PlantNGAM*ShootProportion,'l');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_ATPM',RootNGAM*RootProportion,'l');

    b = 1;
    working_set = all_sets{b};
    S_set = working_set{1};
    R_set = working_set{2};

    AMFNoBacteroid = addReaction(AMFNoBacteroid,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    AMFNoBacteroid = addReaction(AMFNoBacteroid,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
    AMFNoBacteroid = addReaction(AMFNoBacteroid,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);


    for i=1:numel(N_levels);
        for n=1:numel(P_levels);
            AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',N_levels_early(i),'u');
            AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',P_levels_early(n),'u');
            solution = optimizeCbModel(AMFNoBacteroid,'max','one');
            Growth_early{i,n} = solution.f;
        end
    end

    %

    b = 2;
    working_set = all_sets{b};
    S_set = working_set{1};
    R_set = working_set{2};

    AMFNoBacteroid = addReaction(AMFNoBacteroid,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    AMFNoBacteroid = addReaction(AMFNoBacteroid,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
    AMFNoBacteroid = addReaction(AMFNoBacteroid,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);

    for i=1:numel(N_levels);
        for n=1:numel(P_levels);
            AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',N_levels_mid(i),'u');
            AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',P_levels_mid(n),'u');
            solution = optimizeCbModel(AMFNoBacteroid,'max');
            Growth_mid{i,n} = solution.f;
        end
    end



    b = 3;
    working_set = all_sets{b};
    S_set = working_set{1};
    R_set = working_set{2};

    AMFNoBacteroid = addReaction(AMFNoBacteroid,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);
    AMFNoBacteroid = addReaction(AMFNoBacteroid,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);            
    AMFNoBacteroid = addReaction(AMFNoBacteroid,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-PlantGAM,1,PlantGAM,PlantGAM]);

    for i=1:numel(N_levels);
        for n=1:numel(P_levels);
            AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',N_levels_late(i),'u');
            AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',P_levels_late(n),'u');
            solution = optimizeCbModel(AMFNoBacteroid,'max');
            Growth_late{i,n} = solution.f;
        end
    end

    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',1000,'u');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',1000,'u');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r1067_c0',1000,'u');
    solution = optimizeCbModel(AMFNoBacteroid,'max','one');

    changeCobraSolver('ibm_cplex');

    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'AMF_Pi_TR',1000,'u');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'AMF_NH4_TR',1000,'u');
    AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'ammonium_uptake',1000,'u');


    original_AMF_model = AMFNoBacteroid;
    %
    % Preallocation 

    Early_RGR_noBacteroidwithAMF = cell(length(N_levels),length(P_levels));
    Mid_RGR_noBacteroidwithAMF = cell(length(N_levels),length(P_levels));
    Late_RGR_noBacteroidwithAMF = cell(length(N_levels),length(P_levels));
    EarlyRGR_noBacteroidwithAMF_AMFBiomass = cell(length(N_levels),length(P_levels));
    EarlyRGR_noBacteroidwithAMF_GlucoseFluxes = cell(length(N_levels),length(P_levels));
    EarlyRGR_noBacteroidwithAMF_PalmitateFluxes = cell(length(N_levels),length(P_levels));
    EarlyRGR_noBacteroidwithAMF_CO2Fluxes = cell(length(N_levels),length(P_levels));
    EarlyRGR_noBacteroidwithAMF_PFluxes = cell(length(N_levels),length(P_levels));  
    MidRGR_noBacteroidwithAMF_AMFBiomass = cell(length(N_levels),length(P_levels));
    MidRGR_noBacteroidwithAMF_GlucoseFluxes = cell(length(N_levels),length(P_levels));
    MidRGR_noBacteroidwithAMF_PalmitateFluxes = cell(length(N_levels),length(P_levels));
    MidRGR_noBacteroidwithAMF_CO2Fluxes = cell(length(N_levels),length(P_levels));
    MidRGR_noBacteroidwithAMF_PFluxes = cell(length(N_levels),length(P_levels));      
    LateRGR_noBacteroidwithAMF_AMFBiomass = cell(length(N_levels),length(P_levels));
    LateRGR_noBacteroidwithAMF_GlucoseFluxes = cell(length(N_levels),length(P_levels));
    LateRGR_noBacteroidwithAMF_PalmitateFluxes = cell(length(N_levels),length(P_levels));
    LateRGR_noBacteroidwithAMF_CO2Fluxes = cell(length(N_levels),length(P_levels));
    LateRGR_noBacteroidwithAMF_PFluxes = cell(length(N_levels),length(P_levels));   


    for b=1:numel(all_sets);
        AMFNoBacteroid = original_AMF_model;
        AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'ammonium_uptake',0,'u');
        AMFNoBacteroid = changeObjective(AMFNoBacteroid,'EX_Total_Plant_Biomass');

        AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'AMF_Pi_TR',1000,'u');
        AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'AMF_NH4_TR',1000,'u');

        AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'ammonium_uptake',1000,'u');
        AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r1067_c0',1000,'u');
        AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r0066_c0',AMFNGAM*NecessaryAMFBiomass,'l');
        AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r0066_c0',1000,'u');


        for i=2:numel(N_levels);
            for n=2:numel(P_levels);
                working_set = all_sets{b};
                S_set = working_set{1};
                R_set = working_set{2};
                AMFNoBacteroid = addReaction(AMFNoBacteroid,['AMF_Glucose_TR'],{['R_Glc[c]'],['m0564[e0]']},[-1 1]);
                AMFNoBacteroid = addReaction(AMFNoBacteroid,['AMF_Palmitate_TR'],{['R_Palmitic_acid[h]'],['m0384[e0]']},[-1 1]);
                AMFNoBacteroid = addReaction(AMFNoBacteroid,['P_uptake_dump'],{['P_uptake_credit[c]']},[-1],0,0,1000);
                AMFNoBacteroid = addReaction(AMFNoBacteroid,['N_uptake_dump'],{['N_uptake_credit[c]']},[-1],0,0,1000);

                AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'ammonium_uptake',1000,'u');

                AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r0992_e0',1000,'u');
                AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r0992_e0',-1000,'l');


                AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r0994_e0',-1000,'l');
                AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'r0994_e0',1000,'u');

                AMFNoBacteroid = addReaction(AMFNoBacteroid,['BS_NewBiomass'],{['BS_Nitrogeneous_compounds[c]'],['BS_Carbohydrates[c]'],['BS_Lipids[c]'],['BS_Lignin[c]'],['BS_Organic_acids[c]'],['BS_Materials[c]'],['BS_ATP[c]'],['BS_Biomass[e]'],['BS_ADP[c]'],['BS_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-19,1,19,19]);
                AMFNoBacteroid = addReaction(AMFNoBacteroid,['M_NewBiomass'],{['M_Nitrogeneous_compounds[c]'],['M_Carbohydrates[c]'],['M_Lipids[c]'],['M_Lignin[c]'],['M_Organic_acids[c]'],['M_Materials[c]'],['M_ATP[c]'],['M_Biomass[e]'],['M_ADP[c]'],['M_Pi[c]']}, ...
                    [-1*S_set(1),-1*S_set(2),-1*S_set(3),-1*S_set(4),-1*S_set(5),-1*S_set(6),-19,1,19,19]);            
                AMFNoBacteroid = addReaction(AMFNoBacteroid,['R_NewBiomass'],{['R_Nitrogeneous_compounds[c]'],['R_Carbohydrates[c]'],['R_Lipids[c]'],['R_Lignin[c]'],['R_Organic_acids[c]'],['R_Materials[c]'],['R_ATP[c]'],['R_Biomass[e]'],['R_ADP[c]'],['R_Pi[c]']}, ...
                    [-1*R_set(1),-1*R_set(2),-1*R_set(3),-1*R_set(4),-1*R_set(5),-1*R_set(6),-19,1,19,19]);


                if b == 1;
                    try
                        AMFNoBacteroid = addReaction(AMFNoBacteroid,['P_uptake_conversion'],{['P_uptake_credit[c]'],['P_uptake[c]']},[-Growth_early{i,n}*NecessaryAMFBiomass 1],0,0,1);
                        AMFNoBacteroid = addReaction(AMFNoBacteroid,['N_uptake_conversion'],{['N_uptake_credit[c]'],['N_uptake[c]']},[-Growth_early{i,n}*NecessaryAMFBiomass 1],0,0,1);                
                        AMFNoBacteroid = addReaction(AMFNoBacteroid,['AMF_Pi_TR'],{['m0137[c0]'],['H[a]'],['P_uptake[c]'],['R_Pi[c]']},[-2*P_levels_early(n)*AMF_P_Benefit -4*P_levels_early(n)*AMF_P_Benefit -1 2*P_levels_early(n)*AMF_P_Benefit]);
                        AMFNoBacteroid = addReaction(AMFNoBacteroid,['AMF_NH4_TR'],{['m0110[c0]'],['N_uptake[c]'],['R_NH4[c]']},[-N_levels_early(i)*AMF_N_Benefit -1 N_levels_early(i)*AMF_N_Benefit]);
                        AMFNoBacteroid = addReaction(AMFNoBacteroid,'R_Im_Pi','reactionFormula','R_ATP[c] + R_H2O[c] -> R_H[h] + 2 R_Pi[h] + R_ADP[c] + R_Pi[c]');
                        AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',N_levels_early(i),'u');
                        AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',P_levels_early(n),'u');
                        Glucose_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_Glucose_TR'}));
                        Palmitate_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_Palmitate_TR'}));
                        CO2_flux = find(contains(AMFNoBacteroid.rxns,{'M_Im_CO2'}));
                        P_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_Pi_TR'}));
                        N_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_NH4_TR'}))

                        AMF_biomass_index = find(contains(AMFNoBacteroid.rxns,{'r1067_c0'}));

                        solution = optimizeCbModel(AMFNoBacteroid,'max','one');
                        if isnan(solution.f);
                            disp('Trying again');
                            solution = optimizeCbModel(AMFNoBacteroid,'max','one');
                            changeCobraSolver('ibm_cplex');
                            if isnan(solution.f);
                                disp('Trying again');
                                changeCobraSolver('gurobi');
                                solution = optimizeCbModel(AMFNoBacteroid,'max','one');
                                changeCobraSolver('ibm_cplex');
                                if isnan(solution.f);
                                    disp('Trying again');
                                    changeCobraSolver('gurobi');
                                    solution = optimizeCbModel(AMFNoBacteroid,'max','one');
                                    changeCobraSolver('ibm_cplex');
                                    if isnan(solution.f);
                                        disp('Trying again');
                                        changeCobraSolver('glpk');
                                        solution = optimizeCbModel(AMFNoBacteroid,'max','one');
                                        changeCobraSolver('ibm_cplex');
                                        if isnan(solution.f);
                                            disp('Trying again');
                                            changeCobraSolver('glpk');
                                            solution = optimizeCbModel(AMFNoBacteroid,'max','one');
                                            changeCobraSolver('ibm_cplex');
                                        end
                                    end
                                end
                            end
                        end

                        Early_RGR_noBacteroidwithAMF{i,n} = solution.f;

                        EarlyRGR_noBacteroidwithAMF_AMFBiomass{i,n} = solution.x(AMF_biomass_index);

                        EarlyRGR_noBacteroidwithAMF_GlucoseFluxes{i,n} = solution.x(Glucose_flux);

                        EarlyRGR_noBacteroidwithAMF_PalmitateFluxes{i,n} = solution.x(Palmitate_flux);

                        EarlyRGR_noBacteroidwithAMF_CO2Fluxes{i,n} = solution.x(CO2_flux);

                        EarlyRGR_noBacteroidwithAMF_PFluxes{i,n} = solution.x(P_flux)*(P_levels_early(n)*2.16);                
                        EarlyRGR_noBacteroidwithAMF_Nfluxes{i,n} = solution.x(N_flux)*(N_levels_early(i)*0.23)
                    catch
                    end
                end
                if b == 2;
                    Mid_RGR_noBacteroidwithAMF{i,n} = 1;

                    MidRGR_noBacteroidwithAMF_AMFBiomass{i,n} = 1;

                    MidRGR_noBacteroidwithAMF_GlucoseFluxes{i,n} = 1;

                    MidRGR_noBacteroidwithAMF_PalmitateFluxes{i,n} = 1;

                    MidRGR_noBacteroidwithAMF_CO2Fluxes{i,n} = 1;

                    MidRGR_noBacteroidwithAMF_PFluxes{i,n} = 1; 
                    MidRGR_noBacteroidwithAMF_Nfluxes{i,n} = 1;
                    
                    %AMF_biomass_index = find(contains(AMFNoBacteroid.rxns,{'r1067_c0'}));
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,['P_uptake_conversion'],{['P_uptake_credit[c]'],['P_uptake[c]']},[-Growth_mid{i,n}*NecessaryAMFBiomass 1],0,0,1);
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,['N_uptake_conversion'],{['N_uptake_credit[c]'],['N_uptake[c]']},[-Growth_mid{i,n}*NecessaryAMFBiomass 1],0,0,1);            
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,['AMF_Pi_TR'],{['m0137[c0]'],['H[a]'],['P_uptake[c]'],['R_Pi[c]']},[-P_levels_mid(n)*AMF_P_Benefit -2*P_levels_mid(n)*AMF_P_Benefit -1 P_levels_mid(n)*AMF_P_Benefit]);
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,['AMF_NH4_TR'],{['m0110[c0]'],['N_uptake[c]'],['R_NH4[c]']},[-N_levels_mid(i)*AMF_N_Benefit -1 N_levels_mid(i)*AMF_N_Benefit]);
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,'R_Im_Pi','reactionFormula','R_ATP[c] + R_H2O[c] -> R_H[h] + 2 R_Pi[h] + R_ADP[c] + R_Pi[c]');               
                    %AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',N_levels_mid(i),'u');
                    %AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',P_levels_mid(n),'u');

                    %AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',N_levels_mid(i),'u');
                    %AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',P_levels_mid(n),'u');
                    %Glucose_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_Glucose_TR'}));
                    %Palmitate_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_Palmitate_TR'}));
                    %CO2_flux = find(contains(AMFNoBacteroid.rxns,{'M_Im_CO2'}));
                    %P_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_Pi_TR'}));
                    %N_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_NH4_TR'}))


                    %solution = optimizeCbModel(AMFNoBacteroid,'max','one',1);
                    %if isnan(solution.f);
                    %    disp('Trying again');
                    %    solution = optimizeCbModel(AMFNoBacteroid,'max','one',0);
                    %    changeCobraSolver('ibm_cplex');
                    %    if isnan(solution.f);
                    %        disp('Trying again');
                    %        changeCobraSolver('gurobi');
                    %        solution = optimizeCbModel(AMFNoBacteroid,'max','one',1);
                    %        changeCobraSolver('ibm_cplex');
                    %        if isnan(solution.f);
                    %            disp('Trying again');
                    %            changeCobraSolver('gurobi');
                    %            solution = optimizeCbModel(AMFNoBacteroid,'max','one',0);
                    %            changeCobraSolver('ibm_cplex');
                    %            if isnan(solution.f);
                    %                disp('Trying again');
                    %               changeCobraSolver('glpk');
                    %                solution = optimizeCbModel(AMFNoBacteroid,'max','one',1);
                    %                changeCobraSolver('ibm_cplex');
                    %                if isnan(solution.f);
                    %                    disp('Trying again');
                    %                    changeCobraSolver('glpk');
                    %                    solution = optimizeCbModel(AMFNoBacteroid,'max','one',0);
                    %                    changeCobraSolver('ibm_cplex');
                    %                end
                    %            end
                    %        end
                    %    end
                    end

                if b == 3;
                    Late_RGR_noBacteroidwithAMF{i,n} = 1;

                    LateRGR_noBacteroidwithAMF_AMFBiomass{i,n} = 1;

                    LateRGR_noBacteroidwithAMF_GlucoseFluxes{i,n} = 1;

                    LateRGR_noBacteroidwithAMF_PalmitateFluxes{i,n} = 1;

                    LateRGR_noBacteroidwithAMF_CO2Fluxes{i,n} = 1;

                    LateRGR_noBacteroidwithAMF_PFluxes{i,n} = 1;     
                    LateRGR_noBacteroidwithAMF_Nfluxes{i,n} = 1;
                    
                    %AMF_biomass_index = find(contains(AMFNoBacteroid.rxns,{'r1067_c0'}));
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,['P_uptake_conversion'],{['P_uptake_credit[c]'],['P_uptake[c]']},[-Growth_late{i,n}*NecessaryAMFBiomass 1],0,0,1);
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,['N_uptake_conversion'],{['N_uptake_credit[c]'],['N_uptake[c]']},[-Growth_late{i,n}*NecessaryAMFBiomass 1],0,0,1);               
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,['AMF_Pi_TR'],{['m0137[c0]'],['H[a]'],['P_uptake[c]'],['R_Pi[c]']},[-P_levels_late(n)*AMF_P_Benefit -2*P_levels_late(n)*AMF_P_Benefit -1 P_levels_late(n)*AMF_P_Benefit]);
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,['AMF_NH4_TR'],{['m0110[c0]'],['N_uptake[c]'],['R_NH4[c]']},[-N_levels_late(i)*AMF_N_Benefit -1 N_levels_late(i)*AMF_N_Benefit]);
                    %AMFNoBacteroid = addReaction(AMFNoBacteroid,'R_Im_Pi','reactionFormula','R_ATP[c] + R_H2O[c] -> R_H[h] + 2 R_Pi[h] + R_ADP[c] + R_Pi[c]');                
                    %AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',N_levels_late(i),'u');
                    %AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',P_levels_late(n),'u');

                    %AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_NH4',N_levels_late(i),'u');
                    %AMFNoBacteroid = changeRxnBounds(AMFNoBacteroid,'R_Im_Pi',P_levels_late(n),'u');
                    %Glucose_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_Glucose_TR'}));
                    %Palmitate_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_Palmitate_TR'}));
                    %CO2_flux = find(contains(AMFNoBacteroid.rxns,{'M_Im_CO2'}));
                    %P_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_Pi_TR'}));
                    %N_flux = find(contains(AMFNoBacteroid.rxns,{'AMF_NH4_TR'}))

                    %solution = optimizeCbModel(AMFNoBacteroid,'max','one',1);
                    %if isnan(solution.f);
                    %    disp('Trying again');
                    %    solution = optimizeCbModel(AMFNoBacteroid,'max','one',0);
                    %    changeCobraSolver('ibm_cplex');
                    %    if isnan(solution.f);
                    %        disp('Trying again');
                    %        changeCobraSolver('gurobi');
                    %        solution = optimizeCbModel(AMFNoBacteroid,'max','one',1);
                    %        changeCobraSolver('ibm_cplex');
                    %        if isnan(solution.f);
                    %            disp('Trying again');
                    %            changeCobraSolver('gurobi');
                    %            solution = optimizeCbModel(AMFNoBacteroid,'max','one',0);
                    %            changeCobraSolver('ibm_cplex');
                    %            if isnan(solution.f);
                    %                disp('Trying again');
                    %                changeCobraSolver('glpk');
                    %                solution = optimizeCbModel(AMFNoBacteroid,'max','one',1);
                    %                changeCobraSolver('ibm_cplex');
                    %                if isnan(solution.f);
                    %                    disp('Trying again');
                    %                    changeCobraSolver('glpk');
                    %                    solution = optimizeCbModel(AMFNoBacteroid,'max','one',0);
                    %                    changeCobraSolver('ibm_cplex');
                    %                end
                    %            end
                    %        end
                    %    end
                    end


                end
            end
        end
    end
