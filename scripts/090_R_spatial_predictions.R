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

#
# pred_list <- lapply(seq(lst_rst), function(i){
#   prediction <- raster(paste0(pred_path, "/", comm_comp, "/", "predictions_", i, ".tif"))
#
#
#   # map_plot <-
#   ggR(prediction, geom_raster = TRUE) +
#     scale_fill_viridis(limits = c(0, 3.5), oob = scales::squish)+
#     ggtitle(paste0("month_", i)) +
#     theme(panel.background = element_blank(), #panel.grid = element_line(color = "grey80"),
#           axis.text.y = element_text(angle = 90, hjust = 0.5, colour = "black", size = 6),
#           axis.text.x = element_text(colour = "black", size = 6),
#           axis.title.x = element_text(size = 6),
#           axis.title.y = element_text(size = 6),
#           plot.title = element_text(size = 10, face = "bold"), #margin = margin(-0.5,0,0,0),
#           legend.text = element_text(size = 6),
#           legend.title = element_text(size = 10),
#           legend.key.size = unit(0.5, "cm"),
#           axis.ticks = element_line(size = 0.02),
#           axis.ticks.length = unit(0.05, "cm"))
#   print(map_plot)
#   ggsave(filename = paste0(fig_path, "temp_wies_map_prediction_month_", i, "_", comm_mod, "_", ".pdf"),
#          plot = map_plot,
#          width = 200, height = 150, units = "mm", dpi = 300)
#
#   ggsave(filename = paste0(fig_path, "temp_wies_map_prediction_month_", i, "_", comm_mod, "_", ".png"),
#          plot = map_plot,
#          width = 200, height = 150, units = "mm", dpi = 300)
#   return(map_plot)
# })
#
# animation::saveGIF(
#   expr = {
#     plot(pred_list[[1]])
#     plot(pred_list[[2]])
#     plot(pred_list[[3]])
#     plot(pred_list[[4]])
#     plot(pred_list[[5]])
#     plot(pred_list[[6]])
#     plot(pred_list[[7]])
#     plot(pred_list[[8]])
#     plot(pred_list[[9]])
#     plot(pred_list[[10]])
#     plot(pred_list[[11]])
#     plot(pred_list[[12]])
#   },
#   movie.name = paste0("temp_wies_prediction_", comm_viz, ".gif")
# )
#
#
