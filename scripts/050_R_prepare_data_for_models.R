# Description:
# Author: Alice Ziegler
# Date:
# 2022-09-26 15:16:25
# to do:

rm(list=ls())

########################################################################################
### Presettings
########################################################################################
#####
### load packages & stuff
#####
library(tidyr)
library(stringr)
source("scripts/000_R_presettings.R")

#####
### general settings
#####
out_21 <- T
sample <- T
sample_size <- 150000
comm_filt <- paste0(comm, "no2022_inclMix_")
comm_mod <- paste0(comm_filt, "val_21_total")

#####
### read data
#####
data <- readRDS(file = paste0(gee_path, "040_filt_buff", comm_filt, ".rds"))

#####
### general settings
#####
#####
### predictor variables
#####
##moved to 520
variables <- names(data)[c(which(names(data) == "B2") : which(names(data) == "NDVI"),
                           which(names(data) == "VH"): which(names(data) == "VVsubVH")
)]



########################################################################################
### Do stuff
########################################################################################
if (sample == T){
set.seed(100)
data <- data[sample(nrow(data), size = sample_size, replace = F), ]
data <- data[order(data$id_after_filter),]
}

if(out_21 <- T){
  data_2021 <- data[as.Date(data$time) >= as.Date("2021-01-01"),]
    data_train <- data[as.Date(data$time) < as.Date("2021-01-01"),]
}

saveRDS(data,  file = paste0(gee_path, "050_data_train_and_test", comm_mod, ".rds"))
saveRDS(data_train,  file = paste0(gee_path, "050_data_train", comm_mod, ".rds"))
saveRDS(data_2021,  file = paste0(gee_path, "050_data_test", comm_mod, ".rds"))



