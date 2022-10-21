# Description: presettings that are useful in several scripts
# Author: Alice Ziegler
# Date:
# 2022-10-18 09:47:57
# to do:

rm(list=ls())

####################################################################
####################################################################
### stuff to play with
####################################################################
####################################################################
# machine <- "local"
# machine <- "cluster" # MaRC3
machine <- "rstudioserver" # hosted on MaRC3

comm <- "_all_" ## short descriptive comment to use e.g. for file naming

parallelize <- T
core_num <- 20

daterange <- c("2019-03-01","2022-12-31")  #Stand 10.10.2021 granules für 2022 nur bis ca Juni. Außerdem teilweise .png files (was ist das?)

####################################################################
####################################################################
### Don't change anything past this point,
###except you know what you are doing
####################################################################
####################################################################

####################################################################
### general settings for machine
####################################################################

if (machine == "local"){
  proj_path <- "D:/Uni/Projekte/GEDI/"
}else if (machine == "cluster"){
  proj_path <- "/mnt/masc_home/ziegler5/GEDI/"
}else if (machine == "rstudioserver"){
  proj_path <- "~/GEDI/"
}

# if(parallelize == T){
# cl <- makeCluster(core_num, type = "FORK", outfile = paste0(proj_path, "out.txt"))
# registerDoParallel(cl)
# }


####################################################################
### path settings
####################################################################
#data_path #uppermost directory for data
if(!dir.exists(paste0(proj_path, "data/"))){
  dir.create(paste0(proj_path, "data/"))}
data_path <- paste0(proj_path, "data/")
#gee_path #directory to get data into or from Goolge Earth Engine (GEE)
if(!dir.exists(paste0(data_path, "GEE/"))){
  dir.create(paste0(data_path, "GEE/"))}
gee_path <- paste0(data_path, "GEE/")
#corine_path
if(!dir.exists(paste0(data_path, "CORINE/"))){
  dir.create(paste0(data_path, "CORINE/"))}
corine_path <- paste0(data_path, "CORINE/")
#out_path
if(!dir.exists(paste0(proj_path, "out/"))){
  dir.create(paste0(proj_path, "out/"))}
out_path <- paste0(proj_path, "out/")
#####
### study area
#####

# ymax <- 50.924463
# ymin <- 50.77558
# xmax <- 8.835955
# xmin <- 8.460928
#
# study_area <- data.frame(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax) # #xmin, xmax, ymin, ymax
# area_spat_pol <- as(extent(xmin, xmax, ymin, ymax), "SpatialPolygons")
# area_wgs <- as(area_spat_pol, "sf")
# st_crs(area_wgs) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
# area_wgs_m2 <- st_area(area_wgs)
# area_grs <- st_transform (area_wgs, crs = "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs ")
# area_utm <- st_transform(area_wgs,crs = "+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
#
# gedi_daterange <- c("2019-04-01","2019-10-31")
#
# #number of cores for parallel processing
# cl <- 20 #server
# # cl <- 4 #local
#
# copernicus_username = "aliceziegler"
# #####
# ### set paths
# #####
# data_path <- "D:/Uni/Projekte/GEDI/data/" #local
# out_path <- "D:/Uni/Projekte/GEDI/out/"
# fig_path <- "D:/Uni/Projekte/GEDI/figures/"
# # data_path <- "/mnt/sd19006/aziegler/R-Server/GEDI/data/" # remote R-Studio Server
# # out_path <- "/mnt/sd19006/aziegler/R-Server/GEDI/out/"
# # fig_path <- "/mnt/sd19006/aziegler/R-Server/GEDI/figures/"
#
#
# #gedi
# #general
# if(!dir.exists(paste0(data_path, "gedi/"))){
#   dir.create(paste0(data_path, "gedi/"))}
# gedi_path <- paste0(data_path, "gedi/")
# # raw data
# if(!dir.exists(paste0(gedi_path, "rGEDI_2B/"))){
#   dir.create(paste0(gedi_path, "rGEDI_2B/"))}
# gedi_raw_dir <- paste0(gedi_path, "rGEDI_2B/")
# #clipped data
# if(!dir.exists(paste0(gedi_path, "rGEDI_2B_clipped/"))){
#   dir.create(paste0(gedi_path, "rGEDI_2B_clipped/"))}
# gedi_clip_dir <- paste0(gedi_path, "rGEDI_2B_clipped/") # for clip of whole study area
#
# #corine
# if(!dir.exists(paste0(data_path, "CORINE/"))){
#   dir.create(paste0(data_path, "CORINE/"))}
# corine_path <- paste0(data_path, "CORINE/")
#
# #model - path for data that is used for model input
# if(!dir.exists(paste0(data_path, "modeling/"))){
#   dir.create(paste0(data_path, "modeling/"))}
# model_path <- paste0(data_path, "modeling/")
#
# #sentinel2
# if(!dir.exists(paste0(data_path, "sentinel2/"))){
#   dir.create(paste0(data_path, "sentinel2/"))}
# sen2_path <- paste0(data_path, "sentinel2/")
#
# sen2_input_path <- paste0(sen2_path, "_datasets/Sentinel-2")
#
# #sentinel1
# if(!dir.exists(paste0(data_path, "sentinel1/"))){
#   dir.create(paste0(data_path, "sentinel1/"))}
# sen1_path <- paste0(data_path, "sentinel1/")
#
# sen1_input_path <- paste0(sen1_path, "_datasets/Sentinel-1/")
#
# #prediction stack path
# if(!dir.exists(paste0(data_path, "prediction/"))){
#   dir.create(paste0(data_path, "prediction/"))}
# pred_path <- paste0(data_path, "prediction/")
#
# #cv_model_path - output of cv model
# if(!dir.exists(paste0(out_path, "cvmodel/"))){
#   dir.create(paste0(out_path, "cvmodel/"))}
# cvmodel_path <- paste0(out_path, "cvmodel/")
#
# #validation path
# if(!dir.exists(paste0(cvmodel_path, "validation/"))){
#   dir.create(paste0(cvmodel_path, "validation/"))}
# val_path <- paste0(cvmodel_path, "validation/")
#
# ##figure path
# #check if directory for output exists
# if(!dir.exists(paste0(fig_path))){
#   dir.create(paste0(fig_path))
# }
#
# #pred_outpath
# if(!dir.exists(paste0(out_path, "predictions/"))){
#   dir.create(paste0(out_path, "predictions/"))}
# pred_outpath <- paste0(out_path, "predictions/")
#
#
# #gee_folder
# if(!dir.exists(paste0(data_path, "GEE/"))){
#   dir.create(paste0(data_path, "GEE/"))}
# gee_path <- paste0(data_path, "GEE/")
