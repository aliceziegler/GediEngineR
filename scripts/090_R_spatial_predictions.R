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
library(raster)
library(stringr)
library(gtools)
library(rnaturalearth)
library(sf)
library(dplyr)

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

read_pred <- T
# corine
corine <- raster(paste0(corine_path, "040_corine_hesse.tif"))

# hessen:
hessen = rnaturalearth::ne_states(country = "Germany", returnclass = c("sf")) %>% dplyr::filter(name == "Hessen") %>% select(name)
hessen = st_cast(hessen, "POLYGON")
hessen <- st_transform(hessen, crs = "+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs ")

#####
### do stuff
#####
#reclassify corine to mask
keep <- c(12, 18, 23, 24, 25) ##hardcode
corine_hess <- mask(corine, hessen)
mask_df <- data.frame(corine = unique(corine_hess), mask = NA)
mask_df$mask[mask_df$corine %in% keep] <- mask_df$corine[mask_df$corine %in% keep]
rclmat <- data.matrix(mask_df, rownames.force = NA)
corine_mask <- reclassify(corine_hess, rclmat)
writeRaster(corine_mask, paste0(corine_path, "090_corine_mask.tif"))

###predict
pred_list <- lapply(seq(lst_rst), function(i){
  if(read_pred == T){
    prediction <- raster(paste0(pred_path, "/", comm_comp, "/", "predictions_", i, ".tif"))
  }else{
  rst <- stack(lst_rst[i])
  # plot(rst)
  prediction <- predict(rst, model)
  writeRaster(prediction, paste0(pred_path, "/", comm_comp, "/", "predictions_", i, ".tif") ,overwrite=T)
  }
  prediction_utm <- projectRaster(prediction, crs = "+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs ") # ngb for categorial
  prediction_rsmpl <- resample(prediction_utm, corine_mask)
  return(prediction_rsmpl)
})
saveRDS(pred_list, paste0(pred_path, "090_pred_list.rds"))

#
#
# mask_list <- lapply(keep, function(corine_i){
#   # corine_i <- 12
#   corine_i_mask <- corine_mask
#   corine_i_mask[corine_i_mask != corine_i] <- NA
#   month_list <- lapply(seq(pred_list), function(month_j){
#     # month_j <- 7
#     # print(month_j)
#     prediction <- pred_list[[month_j]]
#     pred_mask <- mask(prediction, corine_i_mask)
#     pred_df <- data.frame(pai = getValues(pred_mask), month = month_j, corine = corine_i)
#     pred_df <- pred_df[complete.cases(pred_df),]
#     return(pred_df)
#   })
#   # names(month_list) <- paste0("month_", seq(pred_list))
#   names(month_list) <-seq(pred_list)
#   month_df <- do.call("rbind", month_list)
#   return(month_df)
# })
# names(mask_list) <- keep
# pred_pai_df <- do.call("rbind", mask_list)
# lvls <- str_sort(unique(pred_pai_df$month), numeric = TRUE)
# pred_pai_df$month <- factor(pred_pai_df$month, levels = lvls)
#
# saveRDS(pred_pai_df, paste0(out_path, "090_pred_pai_df_", comm_mod, ".rds"))
#
