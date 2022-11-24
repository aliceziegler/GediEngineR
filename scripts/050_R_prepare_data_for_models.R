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
library(dplyr)
library(sf)
source("scripts/000_R_presettings.R")

#####
### general settings
#####
out_21 <- T
random_sample <- F
balanced_sample <- F
min_same_size_sample <- F
proportion_sample <- T
sample_size <- 150000
comm_filt <- paste0(comm, "no2022_inclMix_")
comm_mod <- paste0(comm_filt, "val_21_total_balanced_150000_props")

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
if (random_sample == T){
set.seed(100)
data <- data[sample(nrow(data), size = sample_size, replace = F), ]
data <- data[order(data$id_after_filter),]
}

if (balanced_sample == T){
  set.seed(100)
  freq_by_group <- st_drop_geometry(data) %>%
    group_by(corine, month) %>%
    summarise(n = n())
  temp_freq_df <- freq_by_group[freq_by_group$n < sample_size/nrow(freq_by_group),] #which corine-month combinations do not have the minimum amount of points
  temp_freq_df$cormon <- paste0(temp_freq_df$corine, temp_freq_df$month)
  data_temp <- data.frame(data, cormon = paste0(data$corine, data$month))
  min_df <- data_temp[data_temp$cormon %in% temp_freq_df$cormon,]
  data_temp <- data_temp[!data_temp$id_after_filter %in% min_df$id_after_filter,]
  data_temp <- data_temp %>% group_by(corine, month) %>% slice_sample(n=sample_size/nrow(freq_by_group))
  data  <- rbind(data_temp[, !names(data_temp) %in% "cormon", drop = F], min_df[,!names(min_df) %in% "cormon", drop = F])

}

if (min_same_size_sample == T){   ###all samples same size with number of samples as frequency in smallest group
  set.seed(100)
  freq_by_group <- st_drop_geometry(data) %>%
    group_by(corine, month) %>%
    summarise(n = n())
  min_freq <- min(freq_by_group$n)
  data <- data %>% group_by(corine, month) %>% slice_sample(n=min_freq)
}

if (proportion_sample == T){ #sample _size with proportions the same as in original dataset
  set.seed(100)
  freq_by_group <- st_drop_geometry(data) %>%
    group_by(corine, month) %>%
    summarise(n = n())
  freq_by_group$cormon <- paste0(freq_by_group$corine, freq_by_group$month)
  sum_n <- sum(freq_by_group$n)
  freq_by_group$proportion <- freq_by_group$n/sum_n
  freq_by_group$sampl_n <- round(sample_size*freq_by_group$proportion)
  data_temp <- data.frame(data, cormon = paste0(data$corine, data$month))
  smpl_df_lst <- lapply(seq(nrow(freq_by_group)), function(x){
    sub_df <- data_temp[data_temp$cormon == freq_by_group$cormon[x],]
    sub_df_smpl <- sub_df %>% group_by(corine, month) %>% slice_sample(n=freq_by_group$sampl_n[x])
    return(sub_df_smpl)
  })
  smpl_df <- do.call("rbind", smpl_df_lst)
  data  <- smpl_df[, !names(smpl_df) %in% "cormon", drop = F]
}



if(out_21 <- T){
  data_2021 <- data[as.Date(data$time) >= as.Date("2021-01-01"),]
    data_train <- data[as.Date(data$time) < as.Date("2021-01-01"),]
}

saveRDS(data,  file = paste0(gee_path, "050_data_train_and_test", comm_mod, ".rds"))
saveRDS(data_train,  file = paste0(gee_path, "050_data_train", comm_mod, ".rds"))
saveRDS(data_2021,  file = paste0(gee_path, "050_data_test", comm_mod, ".rds"))



