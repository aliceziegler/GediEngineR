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
library(RColorBrewer)
library(animation)
library(gtools)
library(gridExtra)
library(ggpubr)

source("scripts/000_R_presettings.R")

#####
### general settings
#####
comm_filt <- paste0(comm, "no2022_inclMix_")
# comm_filt <- paste0(comm, "no2022_onlynight")
comm_mod <- paste0(comm_filt, "val_21_total")
comm_comp <- "median"

# month_nm <- c("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december")


plot_cor <- F

#####
### read data
#####
lst_preds <- list.files(paste0(pred_path, "/", comm_comp, "/"), pattern = ".tif$", full.names = T)
lst_preds <- mixedsort(lst_preds) #sort so that files with 10, 11, 12 are sorted at the end


# corine
corine <- raster(paste0(corine_path, "040_corine_hesse.tif"))

# hessen:
hessen = rnaturalearth::ne_states(country = "Germany", returnclass = c("sf")) %>% dplyr::filter(name == "Hessen") %>% select(name)
hessen = st_cast(hessen, "POLYGON")
hessen_utm <- as_Spatial(st_transform(hessen, crs = crs(corine)))


########################################################################################
### Do stuff
########################################################################################



###################
### plotting corine
####################

if (plot_cor == T){
  #
  # breaks_x <- c(464839.928, 478858.769)#471811.712, , 485905.839)
  # breaks_y <- c(5627660.767, 5638823.664)
  # labels_x <- c("8°30.0'", "8°42.0'")
  # labels_y <- c("50°48.0'", "50°54.0'")


  gg_cor <-
    ggR(corine, forceCat = TRUE, geom_raster = TRUE)+
    scale_fill_manual(values = c("0" = "white", "12" = "lightgoldenrod3","18" = "darkorange","23" = "darkolivegreen1",
                                 "24" = "springgreen3","25" = "forestgreen"),
                      labels = c("other", "arable land", "pastures", "broad-leaved", "coniferous", "mixed forest"))+
    # scale_x_continuous(name = "Longitude", expand = c(0,0), breaks = breaks_x, labels = labels_x)+
    # scale_y_continuous(name = "Latitude", expand = c(0,0), breaks = breaks_y, labels = labels_y)+#n.breaks = 3)+
    geom_polygon(mapping = aes(x = long, y = lat),data = hessen_utm, color = "black", fill = NA, size = 1)+ #(0.1)
    theme(panel.grid = element_line(color = "grey80"),
          axis.text.y = element_text(angle = 90, hjust = 0.5, colour = "black", size = 6),
          axis.text.x = element_text(colour = "black", size = 6),
          axis.title.x = element_text(size = 8),
          axis.title.y = element_text(size = 8),
          # plot.title = element_text(size = 5, margin = margin(-0.5,0,0,0)),
          legend.text = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.key.size = unit(0.25, "cm"),
          axis.ticks = element_line(size = 0.25),
          axis.ticks.length = unit(0.15, "cm"))+
    # plot.margin = unit(c(0.25,-0.6,-0.35,-0.6), "cm"))+
    guides(fill=guide_legend(title="land cover"))

  ggsave(file.path(paste0(fig_path, "100_corine_map.png")),
         plot = gg_cor,
         width = 150, height = 80, units = "mm",
         dpi = 300)
  ggsave(file.path(paste0(fig_path, "100_corine_map.pdf")),
         plot = gg_cor,
         width = 150, height = 80, units = "mm",
         dpi = 300)
}




#####
### plotting predictions
#####
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
  # ggtitle(paste0("month_", i)) +
  ggtitle(month.name[i]) +
  geom_sf(data = hessen, fill = NA, color = "red")+
  labs(fill = "PAI")+
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  # # geom_polygon(mapping = aes(x = long, y = lat, group = group),data = overlay_df, color = "red", fill = NA)+
  # geom_polygon(mapping = aes(x = long, y = lat, group = group),data = exmpl_df, color = "black", fill = NA, size = 0.4)+ #(0.1)
  # geom_text(mapping = aes(x = X, y = Y, label = area), data = pred_exmpl_labels, colour = "black", fontface = "bold", size = 4)+ #size = 1.8,
  theme(panel.background = element_blank(), #panel.grid = element_line(color = "grey80"),
        axis.text.y = element_text(angle = 90, hjust = 0.5, colour = "black", size = 6),
       axis.text.x = element_text(colour = "black", size = 6),
       axis.title.x = element_blank(),
        axis.title.y = element_text(size = 6),
        plot.title = element_text(size = 10, face = "bold"), #margin = margin(-0.5,0,0,0),
        legend.text = element_text(size = 6),
        legend.title = element_text(size = 10),
        legend.key.size = unit(0.5, "cm"),
        axis.ticks = element_line(size = 0.02),
        axis.ticks.length = unit(0.05, "cm"),
        plot.margin = unit(c(0.4 , -1.2,-0.6,-1.0), "cm"))
print(map_plot)
  ggsave(filename = paste0(fig_path, "100_map_prediction_month_", i, "_", comm_mod, "_", comm_comp, ".pdf"),
  plot = map_plot,
  width = 200, height = 150, units = "mm", dpi = 300)

  ggsave(filename = paste0(fig_path, "100_map_prediction_month_", i, "_", comm_mod, "_", comm_comp, ".png"),
         plot = map_plot,
         width = 200, height = 150, units = "mm", dpi = 300)

return(map_plot)
})


# ###
# plot_grid <-
#   ggpubr::ggarrange(plotlist = plot_list[c(3,5,7,9)], ncol= 4, nrow = 1, # widths = (1,1,1,1), #heights = c(1,1,1,0.2),
#                     common.legend = T, legend = c("bottom", "left"))
#                    # ,        font.label = list(size = 3))

plot_grid <-
  ggpubr::ggarrange(plotlist = list(plot_list[[3]],
                                    #to add space, so spaces are equal.
                                    #most left plot needs more space because y-axis belongs to that plot
                                    ggparagraph(text=" ", face = "italic", size = 2, color = "black"),
                                    plot_list[[5]] + rremove("ylab") + rremove("y.text") + rremove("y.ticks"),
                                    plot_list[[7]] + rremove("ylab") + rremove("y.text") + rremove("y.ticks"),
                                    plot_list[[9]] + rremove("ylab") + rremove("y.text") + rremove("y.ticks")),
                    ncol= 5, nrow = 1, widths = c(1, 0.03,1,1,1), #heights = c(1,1,1,0.2),
                    common.legend = T, legend = "right") +
  theme(plot.margin = margin(0,0,1,0, "cm"))
# ,        font.label = list(size = 3))

ggsave(filename = paste0(fig_path, "100_plot_grid_3_5_7_9", "_", comm_mod, "_", comm_comp, ".pdf"),
       plot = plot_grid,
       width = 270, height = 100, units = "mm", dpi = 300)

ggsave(filename = paste0(fig_path, "100_plot_grid_3_5_7_9", "_", comm_mod, "_", comm_comp, ".png"),
       plot = plot_grid,
       width = 270, height = 100, units = "mm", dpi = 300)


### animation

animation::saveGIF(
  expr = {
    plot(plot_list[[1]])
    plot(plot_list[[2]])
    plot(plot_list[[3]])
    plot(plot_list[[4]])
    plot(plot_list[[5]])
    plot(plot_list[[6]])
    plot(plot_list[[7]])
    plot(plot_list[[8]])
    plot(plot_list[[9]])
    plot(plot_list[[10]])
    plot(plot_list[[11]])
    plot(plot_list[[12]])
    },
  movie.name = paste0("prediction_", comm_comp, ".gif")
)

