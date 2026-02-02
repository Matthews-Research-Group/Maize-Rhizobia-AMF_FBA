# Maize-Rhizobia-AMF_FBA

***
## Description
Model files, analysis scripts, datasets, and figure generation scripts for the Maize-Rhizobia-AMF FBA study.
## Files 
### Models
1. *ArabidopsisCoreModel.xml* - Arabidopsis thaliana core metabolism reconstruction (from: 10.1104/pp.114.235358)
2. *BdiazoModel.xml* - Bradyrhizobium diazoefficiens metabolic reconstruction (from: 10.1039/C6MB00553E)
3. *iRi1574.xml* - Rhizophagus irregularis metabolic reconstruction (from: 10.1128/msystems.01216-21)
4. *NVary_results.zip* - Monte Carlo sampling results for estimating variation in growth rate benefits.
### Scripts and Functions
1. *Main_Analysis_Script.m* - MATLAB analysis script to run all four models with default parameter values.
2. *run_analysis.m* - MATLAB function that actually runs the analysis.
3. *run_analysis_abbrev_corrected.m* - Same as above, but leaves out some analyses that are not used in the study.
4. *run_analysis_abbrev_BiomassCorrection.m* - Same as above, but incorporates the ability to add an additional sink for phosphorous, to represent changes in P content between AMF- and AMF+ plants.
5. *Analysis_Script_JRRV1_parallel.m* - MATLAB analysis script to run sensitivity analysis on all four models.
6. *assignResults.m* - MATLAB function that helps with generating results files.
7. *modifyGlobalVariable.m* - MATLAB function that modifies base parameter values.
8. *Plotting.ipynb* - Generates all plots except for sensitivity analysis.
9. *Sens_plotting.ipynb* - Generates sensitivity analysis figure
10. *Summarization_Code_Updated.m* - Summarizes Monte Carlo results from the Monte Carlo results files.
### Datasets
#### Figure plotting datasets
1. *AMF_Heatmap_Data_Updated620.xlsx* - Results for the AMF growth rate improvement heatmap (seedling time point)
2. *AMF_Heatmap_Data_Late_Updated620.xlsx* - Results for the AMF growth rate improvement heatmap (silking time point)
3. *AMF_Heatmap_Data_Mid_Updated620.xlsx* - Results for the AMF growth rate improvement heatmap (jointing time point)
4. *AMF_Late_PercentAllocation_Updated620.xlsx* - Results for the AMF carbon allocation heatmap (silking time point)
5. *AMF_Mid_PercentAllocation_Updated620.xlsx* - Results for the AMF carbon allocation heatmap (jointing time point)
6. *AMF_Seedling_PercentAllocation_Updated620.xlsx* - Results for the AMF carbon allocation heatmap (seedling time point)
7. *Early_Additive_Updated620.xlsx* - Additive growth benefit in the AMF+nodule model (seedling time point)
8. *Early_Modeled_Updated620.xlsx* - Modeled growth benefit in the AMF+nodule model (seedling time point)
9. *Early_Synergy_Updated620.xlsx* - Calculated synergy in the AMF+nodule model (seedling time point)
10. *Late_Additive_Updated620.xlsx* - Additive growth benefit in the AMF+nodule model (silking time point)
11. *Late_Modeled_Updated620.xlsx* - Modeled growth benefit in the AMF+nodule model (silking time point)
12. *Late_Synergy_Updated620.xlsx* - Calculated synergy in the AMF+nodule model (silking time point)
13. *Mid_Additive_Updated620.xlsx* - Additive growth benefit in the AMF+nodule model (jointing time point)
14. *Mid_Modeled_Updated620.xlsx* - Modeled growth benefit in the AMF+nodule model (jointint time point)
15. *Mid_Synergy_Updated620.xlsx* - Calculated synergy in the AMF+nodule model (jointing time point)
16. *Plotting_Benefits_Nodule.xlsx* - Nodule-mediated growth benefits across N availability
17. *LowNHighP_Corrected.zip* - Monte Carlo results for generating the 95% confidence interval of RGR benefits in the comparison between model predictions and empirical results in low N high P conditions, accounting for observed increases in biomass P concentration.
18. *HighNHighP_NotCorrected.zip* - Monte Carlo results for generating the 95% confidence interval of RGR benefits in the comparison between model predictions and empirical results in high N high P conditions, not accounting for observed increases in biomass P concentration.
19. *HighNHighP_Corrected.zip* - Monte Carlo results for generating the 95% confidence interval of RGR benefits in the comparison between model predictions and empirical results in high N high P conditions, accounting for observed increases in biomass P concentration.
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
	
