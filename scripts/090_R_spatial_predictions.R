rm(list=ls())
#####
### TO DO
#####



#####
### COMMENT
#####
#Need to download compsites manually created in GEE with skript 080_GEE_monthly_composites.js

#####
### load packages & stuff
#####
# library(raster)
# library(tidyverse) #Loads ggplot2 as well
# library(here)      #Path management
# library(RStoolbox)
# library(CAST)
# library(viridis)
library(gtools)

source("scripts/000_R_presettings.R")
#####
### general settings
#####
comm_filt <- paste0(comm, "no2022_inclMix_")
comm_mod <- paste0(comm_filt, "val_21_total")
comm_comp <- "median"

#create path for predictions
if(!dir.exists(paste0(pred_path, "/", comm_comp))){
  dir.create(paste0(pred_path, "/", comm_comp))}

#####
### read data
#####

model <- readRDS(file = paste0(out_path, "060_test_model", comm_mod, ".rds"))

lst_rst <- list.files(paste0(gee_path, "composites/", comm_comp), pattern = ".tif", full.names = T)
lst_rst <- mixedsort(lst_rst) #sort so that files with 10, 11, 12 are sorted at the end



#####
### do stuff
#####

pred_list <- lapply(seq(lst_rst), function(i){
  rst <- stack(lst_rst[i])
  # plot(rst)
  prediction <- predict(rst, model)
  writeRaster(prediction, paste0(pred_path, "/", comm_comp, "/", "predictions_", i, ".tif") ,overwrite=T)
  return(prediction)
})

