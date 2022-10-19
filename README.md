# GediEngineR
Workflow to model GEDI PAI with Google Earth Engine and R

## Workflow
* **000_R_presettings**
** presettings that are useful in several R scripts and can be "source"ed
* **010_R_gedi_granules**
** creates a "list" of GEDI orbits: orbit filename
** Output list has to be manually copied and imported in Google Earth Engine (GEE) as input for 020_GEE_gedi_looper.js
* **020_GEE_gedi_looper**
** loads the specified orbit FeatureCollections and extracts Sentinel 1 and 2 information (currently at the point level)
** it produces several export task with roughly 150 orbits to keep export size at a manageable size
** manually adjust path of granule_list.txt input
** manually copy code into new GEE Script 
** ...and back if you change anything. Version control with R and GEE in one github is not implemented, yet and feels too cumbersome to put work into it right now. 
** run in GEE and export all different output parts manually via Google Drive to current workstation into data/GEE/
* **030_R_join_geee_tables**
** Import data table (csv) created in GEE, homogenize, put into one table and reproject
