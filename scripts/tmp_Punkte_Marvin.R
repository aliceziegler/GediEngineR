###


rm(list=ls())

########################################################################################
### Presettings
########################################################################################

#####
### load packages & stuff
#####
source("scripts/000_R_presettings.R")

comm_filt <- paste0(comm, "no2022_inclMix_")
comm_mod <- paste0(comm_filt, "val_21_total")
#####
### read data
#####

data_smpl <- readRDS(file = paste0(gee_path, "050_data_train_and_test", comm_mod, ".rds"))

variables <- names(data_smpl)[c(which(names(data_smpl) == "B2") : which(names(data_smpl) == "NDVI"),
                                which(names(data_smpl) == "VH"): which(names(data_smpl) == "VVsubVH")
)]


set.seed(100)
data_ML <- data_smpl[sample(nrow(data_smpl), size = 20000, replace = F), ]
data_ML <- data_ML[order(data_ML$id_after_filter),]
saveRDS(data_ML,  file = paste0(gee_path, "data_marvin.rds"))
