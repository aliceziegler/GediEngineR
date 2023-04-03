# GediEngineR
Workflow to model GEDI PAI with Google Earth Engine and R

Scritps to reproduce the analysis can be found in the **scripts** directory. All data needed for the analysis are freely available and downloading those is part of the scripts. 

## Workflow
* **000_R_presettings.R**
** presettings that are useful in several R scripts and can be "source"ed
* **010_R_gedi_granules.R**
** creates a "list" of GEDI orbits: orbit filename
** Output list has to be manually copied and imported in Google Earth Engine (GEE) as input for 020_GEE_gedi_looper.js
* **020_GEE_gedi_looper.js**
** script to be run in Google Earth Engine
** loads the specified orbit FeatureCollections and extracts Sentinel 1 and 2 information (currently at the point level)
** it produces several export task with roughly 150 orbits to keep export size at a manageable size
** manually adjust path of granule_list.txt input
** manually copy code into new GEE Script 
** ...and back if you change anything. Version control with R and GEE in one github feels too cumbersome to make it efficient. 
** run in GEE and export all different output parts manually via Google Drive to current workstation into data/GEE/
* **030_R_join_geee_tables.R**
** Import data table (csv) created in GEE, homogenize, put into one table and reproject
* **040_R_corine_and_filter.R**
** extracting corine for gedi footprints
** filtering data
* **050_R_prepare_data_for_models.R**
** some restructining and cleaning of data before the actual model calculations
* **060_R_run_model.R**
** actual model comoutation on server 
* **060_slurm_runner.slurm**
** scheduling script for running **060_R_run_model.R** on server
* **070_R_validation.Rmd**
** Markdown script with evaluation and analysis of results. 
** Plotting of results.
* **080_GEE_monthly_composite.R**
** run in Google Earth engine to create monthly composites
* **090_R_spatial_prediction.R**
** spatial prediction on monthly composites
* **095_R_analyze_spatial_predictions.R**
** analysing temporal variablility of spatial predictions
* **100_R_plot_spatial_predictions.R**
** plotting spatial predictions as maps
