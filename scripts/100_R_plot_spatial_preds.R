# Description: plot spatial predictions from GEE
# Author: Alice Ziegler
# Date:
# 2022-11-18 12:00:04
# to do:

rm(list=ls())

########################################################################################
### Presettings
########################################################################################

#####
### load packages & stuff
#####
library(raster)
library(RStoolbox)
library(ggplot2)
library(viridis)
library(dplyr)
library(rnaturalearth)
library(sf)
source("scripts/000_R_presettings.R")

#####
### general settings
#####
comm_filt <- paste0(comm, "no2022_inclMix_")
# comm_filt <- paste0(comm, "no2022_onlynight")
comm_mod <- paste0(comm_filt, "val_21_total")


#####
### read data
#####
lst_preds <- list.files(pred_path, pattern = ".tif", full.names = T)

# hessen:
hessen = rnaturalearth::ne_states(country = "Germany", returnclass = c("sf")) %>% dplyr::filter(name == "Hessen") %>% select(name)
hessen = st_cast(hessen, "POLYGON")
########################################################################################
### Do stuff
########################################################################################

plot_list <- lapply(seq(lst_preds), function(i){

rst <- raster(lst_preds[i])


map_plot <-
  ggR(rst, geom_raster = TRUE) +
  # scale_fill_gradientn(name = "PAI", colors = LAI_col(25))+
  # scale_fill_gradientn(name = "PAI", colors = scico_pal(100), na.value = "white")+
    scale_fill_viridis(limits = c(0, 3.5), oob = scales::squish)+
  # scale_fill_scico(palette = "batlow", aesthetics = "colour", alpha = NULL,
  # begin = 0,
  # end = 1,
  # direction = 1)+
  # scale_fill_material(name = "PAI", "green")+
  # scale_fill_viridis(name = "PAI", option="inferno")+
  # scale_x_continuous(name = "Longitude", expand = c(0,0), breaks = breaks_x, labels = labels_x)+
  # scale_y_continuous(name = "Latitude", expand = c(0,0), breaks = breaks_y, labels = labels_y)+#n.breaks = 3)+
  ggtitle(paste0("month_", i)) +
  geom_sf(data = hessen, fill =NA, color = "red")+
  # # geom_polygon(mapping = aes(x = long, y = lat, group = group),data = overlay_df, color = "red", fill = NA)+
  # geom_polygon(mapping = aes(x = long, y = lat, group = group),data = exmpl_df, color = "black", fill = NA, size = 0.4)+ #(0.1)
  # geom_text(mapping = aes(x = X, y = Y, label = area), data = pred_exmpl_labels, colour = "black", fontface = "bold", size = 4)+ #size = 1.8,
  theme(panel.background = element_blank(), #panel.grid = element_line(color = "grey80"),
        axis.text.y = element_text(angle = 90, hjust = 0.5, colour = "black", size = 6),
        axis.text.x = element_text(colour = "black", size = 6),
        axis.title.x = element_text(size = 6),
        axis.title.y = element_text(size = 6),
        plot.title = element_text(size = 10, face = "bold"), #margin = margin(-0.5,0,0,0),
        legend.text = element_text(size = 6),
        legend.title = element_text(size = 10),
        legend.key.size = unit(0.5, "cm"),
        axis.ticks = element_line(size = 0.02),
        axis.ticks.length = unit(0.05, "cm"),
        plot.margin = unit(c(0.4 , -1.2,-0.6,-1.0), "cm"))
# print(map_plot)
  ggsave(filename = paste0(fig_path, "070_map_prediction_month_", i, "_", comm_mod, ".pdf"),
  plot = map_plot,
  width = 200, height = 150, units = "mm", dpi = 300)
return(map_plot)
})
