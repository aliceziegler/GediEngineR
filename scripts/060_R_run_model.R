# Description: modeling - can be run on server (marc3)
# Author: Alice Ziegler
# Date:
# 2022-10-10 14:15:59
# to do:

rm(list=ls())

########################################################################################
### Presettings
########################################################################################

#####
### load packages & stuff
#####
library(CAST)
library(caret)
library(randomForest)
library(ranger)
library(tidyr)
library(doParallel)
library(sf)

#####
### general settings
#####
# machine <- "local"
machine <- "cluster"


if (machine == "cluster"){
  setwd("/mnt/masc_home/ziegler5/GEDI/GediEngineR/") # as .Rproj path is not available
  source("scripts/000_R_presettings.R")
} else {
  source("scripts/000_R_presettings.R")
}

comm_filt <- paste0(comm, "no2022_inclMix_")
# comm_mod <- paste0(comm_filt, "val_21_total_balanced_")
# comm_mod <- paste0(comm_filt, "val_21_total_balanced_150000")
# comm_mod <- paste0(comm_filt, "val_21_total_balanced_150000_props")


#####
### read data
#####

data_smpl <- readRDS(file = paste0(gee_path, "050_data_train", comm_mod, ".rds"))

variables <- names(data_smpl)[c(which(names(data_smpl) == "B2") : which(names(data_smpl) == "NDVI"),
                           which(names(data_smpl) == "VH"): which(names(data_smpl) == "VVsubVH")
)]

########################################################################################
### Do stuff
########################################################################################

# create 20 folds and take out complete orbits
folds <- CreateSpacetimeFolds(x = data_smpl, spacevar = "orbit_ID", k = 20, seed = 100)

preds <- st_drop_geometry(data_smpl)[,variables]
resp <- data_smpl$pai

###parallel modeling
if (parallelize == T){
  cl <- makeCluster(core_num, type = "FORK", outfile = paste0(out_path, "out.txt"))
  registerDoParallel(cl)
}
Sys.time()
spatial_model <- ffs(preds, resp,
                     method = "ranger",
                     num.trees = 50,
                     num.threads = 1,
                     importance = "impurity",
                     metric = "RMSE",
                     seed = 100,
                     trControl= trainControl(method = "cv", index = folds$index,
                                             indexOut = folds$indexOut, savePredictions = T))
Sys.time()
saveRDS(spatial_model, file = paste0(out_path, "060_test_model", comm_mod, ".rds"))
