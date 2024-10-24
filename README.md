# Maize-Rhizobia-AMF_FBA

***
## Description
Model files, analysis scripts, datasets, and figure generation scripts for the Maize-Rhizobia-AMF FBA study.
## Files 
### Models
1. *ArabidopsisCoreModel.xml* - Arabidopsis thaliana core metabolism reconstruction (from: 10.1104/pp.114.235358)
2. *BdiazoModel.xml* - Bradyrhizobium diazoefficiens metabolic reconstruction (from: 10.1039/C6MB00553E)
3. *iRi1574.xml* - Rhizophagus irregularis metabolic reconstruction (from: 10.1128/msystems.01216-21)
### Scripts and Functions
1. *RunSingle.m* - MATLAB analysis script to run all four models with default parameter values.
2. *run_analysis.m* - MATLAB function that actually runs the analysis.
3. *run_analysis_abbrev.m* - Same as above, but leaves out some analyses that are not used in the study.
4. *Analysis_Script_JRRV1_parallel.m* - MATLAB analysis script to run sensitivity analysis on all four models.
5. *assignResults.m* - MATLAB function that helps with generating results files.
6. *modifyGlobalVariable.m* - MATLAB function that modifies base parameter values.
7. *Plotting.ipynb* - Generates all plots except for sensitivity analysis.
8. *Sens_plotting.ipynb* - Generates sensitivity analysis figure
### Datasets
#### Figure plotting datasets
1. *AMF_Heatmap_Data.xlsx* - Results for the AMF growth rate improvement heatmap (seedling time point)
2. *AMF_Heatmap_Data_Late.xlsx* - Results for the AMF growth rate improvement heatmap (silking time point)
3. *AMF_Heatmap_Data_Mid.xlsx* - Results for the AMF growth rate improvement heatmap (jointing time point)
4. *AMF_Late_PercentAllocation.xlsx* - Results for the AMF carbon allocation heatmap (silking time point)
5. *AMF_Mid_PercentAllocation.xlsx* - Results for the AMF carbon allocation heatmap (jointing time point)
6. *AMF_Seedling_PercentAllocation.xlsx* - Results for the AMF carbon allocation heatmap (seedling time point)
7. *Early_Additive.xlsx* - Additive growth benefit in the AMF+nodule model (seedling time point)
8. *Early_Modeled.xlsx* - Modeled growth benefit in the AMF+nodule model (seedling time point)
9. *Early_Synergy.xlsx* - Calculated synergy in the AMF+nodule model (seedling time point)
10. *Late_Additive.xlsx* - Additive growth benefit in the AMF+nodule model (silking time point)
11. *Late_Modeled.xlsx* - Modeled growth benefit in the AMF+nodule model (silking time point)
12. *Late_Synergy.xlsx* - Calculated synergy in the AMF+nodule model (silking time point)
13. *Mid_Additive.xlsx* - Additive growth benefit in the AMF+nodule model (jointing time point)
14. *Mid_Modeled.xlsx* - Modeled growth benefit in the AMF+nodule model (jointint time point)
15. *Mid_Synergy.xlsx* - Calculated synergy in the AMF+nodule model (jointing time point)
16. *NoduleBenefitsTable.xlsx* - Nodule-mediated growth benefits across N availability
#### Full results files and sensitivity analysis inputs
1. *results_AMFGAM.mat* - Full results for AMF GAM parameter.
2. *results_AMFNGAM.mat* - Full results for the AMF NGAM parameter.
3. *results_AMF_N_Benefit.mat* - Full results for the AMF N Benefit parameter.
4. *results_AMF_P_Benefit.mat* - Full results for the AMF P Benefit parameter.
5. *results_BacteroidNGAM.mat* - Full results for the Bacteroid NGAM parameter.
6. *results_NecessaryAMFBiomass.mat* - Full results for the Necessary AMF Biomass parameter.
7. *results_NoduleProportion.mat* - Full results for the Nodule Proportion parameter.
8. *results_PlantGAM.mat* - Full results for the Plant GAM parameter.
9. *results_PlantNGAM.mat* - Full results for the Plant NGAM parameter.
10. *results_RootNGAM.mat* - Full results for the Root NGAM parameter.
11. *results_RootProportion.mat* - Full results for the Root Proportion parameter.
12. *results_TransportCost.mat* - Full results for the Transport Cost parameter.
	
