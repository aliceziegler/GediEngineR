rm(list=ls())
#####
### TO DO
#####


#####
### load packages & stuff
#####
library(raster)
library(tidyverse) #Loads ggplot2 as well
library(here)      #Path management
library(RStoolbox)
library(CAST)
library(viridis)

source("scripts/000_R_presettings.R")
#####
### general settings
#####
comm_filt <- paste0(comm, "no2022_inclMix_")
# comm_filt <- paste0(comm, "no2022_onlynight")
comm_mod <- paste0(comm_filt, "val_21_total")
# comm_mod <- paste0(comm_filt, "val_21_total_balanced_")
# comm_mod <- paste0(comm_filt, "val_21_total_balanced_150000")
# comm_mod <- paste0(comm_filt, "val_21_total_balanced_150000_props")

model <- readRDS(file = paste0(out_path, "060_test_model", comm_mod, ".rds"))
lst_rst <- list.files(paste0(pred_path, "median_composites"), pattern = ".tif", full.names = T)

rst_list <- lapply(seq(lst_rst), function(i){

  rst <- stack(lst_rst[i])

  plot_rst <- ggRGB(rst, r = 9, g = 5, b = 1, stretch = "lin")+
    ggtitle (i)
  ggsave(filename = paste0(fig_path, "temp_wies_rgb_month_", i, "_", ".png"),
         plot = plot_rst,
         width = 200, height = 150, units = "mm", dpi = 300)


  # plotRGB(rst, r=9, g=5, b=1, stretch = "lin")


    prediction <- predict(rst,model)
    writeRaster(prediction, paste0(pred_path, "Wies_R_pred_", i, ".tif") ,overwrite=T)

      # # cl <- makeCluster(6)
      # # registerDoParallel(cl)
      # AOA <- aoa(rst, model)
      # writeRaster(AOA, paste0(pred_path, "Wies_R_AOA_pred_", i, ".tif"),overwrite=T)
      #
      #
      # AOA_plot <-
      #   ggR(AOA, geom_raster = TRUE) +
      #   scale_fill_viridis(limits = c(0, 3.5), oob = scales::squish)+
      #   ggtitle(paste0("month_", i)) +
      #   theme(panel.background = element_blank(), #panel.grid = element_line(color = "grey80"),
      #         axis.text.y = element_text(angle = 90, hjust = 0.5, colour = "black", size = 6),
      #         axis.text.x = element_text(colour = "black", size = 6),
      #         axis.title.x = element_text(size = 6),
      #         axis.title.y = element_text(size = 6),
      #         plot.title = element_text(size = 10, face = "bold"), #margin = margin(-0.5,0,0,0),
      #         legend.text = element_text(size = 6),
      #         legend.title = element_text(size = 10),
      #         legend.key.size = unit(0.5, "cm"),
      #         axis.ticks = element_line(size = 0.02),
    #         axis.ticks.length = unit(0.05, "cm"),
    #         plot.margin = unit(c(0.4 , -1.2,-0.6,-1.0), "cm"))
    #
    # ggsave(filename = paste0(fig_path, "temp_wies_AOA_month_", i, "_", ".png"),
    #        plot = AOA_plot,
    #        width = 200, height = 150, units = "mm", dpi = 300)
    print(paste0("calc_", i))
    return(list(rst, prediction))
    print(paste0("write", i))

})

animation::saveGIF(
  expr = {
    plot(rst_list[[1]][[2]], main = 1)
    plot(rst_list[[2]][[2]], main = 2)
    plot(rst_list[[3]][[2]], main = 3)
    plot(rst_list[[4]][[2]], main = 4)
    plot(rst_list[[5]][[2]], main = 5)
    plot(rst_list[[6]][[2]], main = 6)
    plot(rst_list[[7]][[2]], main = 7)
    plot(rst_list[[8]][[2]], main = 8)
    plot(rst_list[[9]][[2]], main = 9)
    plot(rst_list[[10]][[2]], main = 10)
    plot(rst_list[[11]][[2]], main = 11)
    plot(rst_list[[12]][[2]], main = 12)
  },
  movie.name = paste0("pred_wies.gif")
)





animation::saveGIF(
  expr = {
    plot(ggRGB(rst_list[[1]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (1))
    plot(ggRGB(rst_list[[2]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (2))
      plot(ggRGB(rst_list[[3]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (3))
      plot(ggRGB(rst_list[[4]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (4))
      plot(ggRGB(rst_list[[5]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (5))
      plot(ggRGB(rst_list[[6]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (6))
      plot(ggRGB(rst_list[[7]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (7))
      plot(ggRGB(rst_list[[8]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (8))
      plot(ggRGB(rst_list[[9]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (9))
      plot(ggRGB(rst_list[[10]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (10))
      plot(ggRGB(rst_list[[11]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (11))
      plot(ggRGB(rst_list[[12]][[1]], r = 9, g = 5, b = 1, stretch = "lin")+
      ggtitle (12))


  },
  movie.name = paste0("rst_wies.gif")
)






corine <- raster(paste0(corine_path, "040_corine_hesse.tif"))
c <- projectRaster(corine, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
c <- crop(c, rst_list[[1]])
gg_cor <-
  ggR(c, forceCat = TRUE, geom_raster = TRUE)+
  scale_fill_manual(values = c("0" = "white", "12" = "lightgoldenrod3","18" = "darkorange","23" = "darkolivegreen1",
                               "24" = "springgreen3","25" = "forestgreen"),
                    labels = c("other", "arable land", "pastures", "broad-leaved", "coniferous", "mixed forest"))+
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

ggsave(filename = paste0(fig_path, "temp_wies_corine.png"),
       plot = gg_cor,
       width = 200, height = 150, units = "mm", dpi = 300)

plot(gg_cor)
