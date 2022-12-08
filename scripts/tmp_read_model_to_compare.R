# Description: Read models and compare
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

source("scripts/000_R_presettings.R")
# !!!corine raster needs to be downloaded manually!!!
#####
### general settings
#####

####################################################################
####################################################################
### do it
####################################################################
####################################################################
lst_models <- list.files(out_path, pattern = ".rds", full.names = T)
lst_models

lapply(lst_models, function(i){
  a <- readRDS(i)
  print(i)
  print(a)
})
