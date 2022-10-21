# Description: Import data table (csv) created in GEE, homogenize, put into one table and reproject
# Author: Alice Ziegler
# Date:
# 2022-09-01 11:48:16
# to do:

rm(list=ls())

########################################################################################
### Presettings
########################################################################################

#####
### load packages
#####
library(geojsonsf)
library(sf)

#####
### load other stuff
#####
source("scripts/000_R_presettings.R")

#####
### general settings
#####
merge_tables <- T # are there several GEE outputs that need to be merged

#####
### read data
#####
if (merge_tables == T) {
  gedi_files <- list.files(path = paste0(gee_path, "gedi_parts/"), pattern = ".csv", full.names = T, recursive = F)
}else{
  gedi_files <- paste0(gee_path, "gedi_granule_samples_150.csv")
}

###all files: R-studio-Server
Sys.time()## ~ 10 min
gedi_parts_list <- lapply(gedi_files, function(i){
  gee_tbl <- read.csv(file = i) #runtime test: if only one file exists, not slower than opening it directly. check
})
Sys.time()

#######################################################################################
## Do stuff
#######################################################################################
# ###get rid of lists without sen2 columns and of columns "shot_number_within_beam"and "orbit_number" because they do not appear in all 2019-2020
# Sys.time() ## 1min
# gedi_parts_list <- Filter(function(i) ncol(i) != 18, gedi_parts_list)
# # get rid of columns "shot_number_within_beam", "orbit_number" because they are missing in some files (why!?)
# gedi_parts_list <- lapply(gedi_parts_list, function(i){
#   reduced_cols <- i[,!colnames(i) %in% c("shot_number_within_beam", "orbit_number")]
#   return(reduced_cols)
# })
gedi_tbl <- do.call("rbind", gedi_parts_list)
Sys.time()
rm(gedi_parts_list)

#######################################################################################
## add some additional columns
#######################################################################################
### orbit number
gedi_tbl$orbit_ID <- substr(gedi_tbl$shot_number, 1, 5) #see: https://lpdaac.usgs.gov/documents/986/GEDI02_UserGuide_V2.pdf
#time
gedi_tbl$year <- format(as.POSIXct(gedi_tbl$time, format = "%Y-%m-%dT%H:%M:%S"), format = "%Y")
gedi_tbl$month <- format(as.POSIXct(gedi_tbl$time, format = "%Y-%m-%dT%H:%M:%S"), format = "%m")


Sys.time() ###3min
# st_write(gedi_tbl, paste0(gee_path, "030_gedi_merged_raw", comm, ".gpkg"), delete_dsn = TRUE) # takes too much storage (allocate vector -error)
saveRDS(gedi_tbl, file = paste0(gee_path, "030_gedi_merged_raw", comm, ".rds")) #>15min
Sys.time()
##not further without error allocate vector 127.MB on local...working on RServer with 64 mb

# gedi_tbl <- readRDS(file = paste0(gee_path, "030_gedi_merged_raw", comm, ".rds"))
Sys.time() ###5min
#https://gis.stackexchange.com/questions/382058/working-with-geo-of-gee-in-r
gee_wgs <- st_as_sf(data.frame(gedi_tbl, geom=geojson_sf(gedi_tbl$.geo))) ###memory limit for all points on local
rm(gedi_tbl)
# st_write(gee_wgs, paste0(gee_path, "030_gedi_merged_wgs", comm, ".gpkg"), delete_dsn = TRUE)
saveRDS(gee_wgs, file = paste0(gee_path, "030_gedi_merged_wgs", comm, ".rds")) #>15min
Sys.time()

Sys.time() ##20 min
###project to utm 32N
gee_utm <- st_transform(gee_wgs, crs = 25832)
st_write(gee_utm, paste0(gee_path, "030_gedi_merged_utm", comm, ".gpkg"), delete_dsn = TRUE)
saveRDS(gee_utm, file = paste0(gee_path, "030_gedi_merged_utm", comm, ".rds")) #>15min
Sys.time()


