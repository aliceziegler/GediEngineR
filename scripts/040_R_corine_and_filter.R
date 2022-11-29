# Description: Import data table (csv) from GEE and extract corine
# Author: Alice Ziegler
# Date:
# 2022-09-01 11:48:16
# to do:
# * check threshold for cutoff of corine classes for final dataset (should mixed forest be included) could also be jusified in terms of content

rm(list=ls())

########################################################################################
### Presettings
########################################################################################

#####
### load packages
#####
library(raster)
library(stringr)
library(data.table)
library(plyr)
library(terra)
library(sf)
source("scripts/000_R_presettings.R")
# !!!corine raster needs to be downloaded manually!!!
#####
### general settings
#####
no_2022 <- T
only_night <- F
comm_filt <- paste0(comm, "")
#####
### read data
#####
corine <- raster(paste0(corine_path,
                        "83684d24c50f069b613e0dc8e12529b893dc172f/u2018_clc2018_v2020_20u1_raster100m/",
                        "u2018_clc2018_v2020_20u1_raster100m/DATA/U2018_CLC2018_V2020_20u1.tif"))
gee <- readRDS(file = paste0(gee_path, "030_gedi_merged_utm", comm, ".rds")) #3min



########################################################################################
### Do stuff
########################################################################################

#####
### get rid of all rows with NAs in predictor variables
#####

### predictor variables
variables <- names(gee)[c(which(names(gee) == "B2") : which(names(gee) == "NDVI"),
                           which(names(gee) == "VH"): which(names(gee) == "VVsubVH")
)]
###filter out na
gee <- gee[!as.logical(rowSums(is.na(gee[,variables]))), ]


########################################################################################
### different filters to play with
########################################################################################
if(no_2022 == T){ # ~3 min
  # gee <- gee[format(as.POSIXct(gee$time, format = "%Y-%m-%dT%H:%M:%S"), format = "%Y") != 2022,]
  gee <- gee[gee$year != 2022,]
}

if(only_night == T){
  gee <- gee[gee$solar_elevation < 0,]
}

########################################################################################
### general workflow/ corine extraction
########################################################################################

#####
### reproject and crop corine
#####
crs(corine) <- "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs " #EPSG 3035 as stated in corine documentation
gee_epsg3035 <- st_transform(gee, crs = 3035)
corine_crop_epsg3035 <- crop(corine, gee_epsg3035)
corine_utm <- projectRaster(corine_crop_epsg3035, crs = "+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs ", method = "ngb") # ngb for categorial
# writeRaster(corine_utm, filename = paste0(corine_path, "040_corine_hesse.tif"))
rm(gee_epsg3035)
#####
### extract
#####
gee$corine <- extract(corine_utm, gee)
gee$corine_factor <- as.factor(gee$corine)
#####
### check if corine values are different for one buffered gedi Point
#####
corine_stats <- ddply(gee, c("shot_number"),
                      summarise,
                      pix_per_beam = sum(!is.na(corine)),
                      corine_sd = sd(corine, na.rm = T))
corine_stats$corine_sd[is.na(corine_stats$corine_sd)] <- 0 #NAs mean only 1 value. -> needs to be kept in!

gee_c <- merge(gee, corine_stats, by = "shot_number")

rm(gee)
### filter out beams that have corine sd > 0 (meaning on 2 different lcc)
gee_c <- gee_c[gee_c$corine_sd == 0,]

###SCL: buffer (1000m) around all pixels that are tagged clouds (8,9,10) and cloud shadows (2,3)

# buffer_scl <- st_buffer(gee_c[gee_c$SCL %in% c(2, 3, 8, 9, 10),], dist = 1000)
# gee_in_buff <- st_filter(gee_c, buffer_scl)
# gee_scl <- gee_c[!(gee_c$system.index %in% gee_in_buff$system.index),]

###tag points as 12 (SCLBuffer) if they lie within a buffer in their orbit

filt_buff_list <- lapply(unique(gee_c$orbit_ID), function(i){
 orbit <- gee_c[gee_c$orbit_ID == i,]
 buffer_scl <- st_buffer(orbit[orbit$SCL %in% c(2, 3, 8, 9, 10),], dist = 1000)
 gee_in_buff <- st_filter(orbit, buffer_scl)
 gee_scl <- orbit[!(orbit$system.index %in% gee_in_buff$system.index),]
 return(gee_scl)
})
filt_buff <- do.call("rbind", filt_buff_list)
rm(gee_c)
###filter out additional points that belong to the belong to the classes that will be filtered out (1,2,3,8,9,10,11)
filt_buff <- filt_buff[!(filt_buff$SCL %in% c(1,2,3,8,9,10,11)),]

saveRDS(filt_buff, file = paste0(gee_path, "040_filt_buff", comm_filt, "_interim.rds"))
#####
### filter out small corine classes
#####
# # ==> cutoff bei 10% der größten gruppe...###dabei fällt Mischwald raus...das ist inhaltlich nicht sinnvoll
# # die ersten 5 klassen sind 23,12,18,24,25 (broad-leaved forest, non-irrigated arable land, pastures, coniferous forest, mixed forest)
# frq_cor <- as.data.frame(table(filt_buff$corine))
# frq_order <- frq_cor[order(frq_cor$Freq, decreasing = T),]
# # ###zwischentest mit probedaten
# # b$id <- c(1:nrow(b))
# # plot(b$Freq ~ b$id)
# cors <- droplevels(frq_order[frq_order$Freq >= max(frq_order$Freq)*0.1,"Var1"])
# ###check if this thresholdis ok for end dataset###dabei fällt Mischwald raus...das ist inhaltlich nicht sinnvoll
cors <- c(23,12,18,24,25)
filt_buff <- filt_buff[filt_buff$corine %in% cors,]

#####
### remove outliers
#####
### get upper 0.1% quantile for pai and all variables (dotnt't need lower, as 0 is plausible)
quants <- lapply(c(variables, "pai"), function(i){
  # i <- "pai"
  quant <- quantile(st_drop_geometry(filt_buff)[,i], probs = c(0.999))
  return(quant)
})
names(quants) <- c(variables, "pai")
for(j in c(variables, "pai")){
  # j <- variables[1]
    filt_buff <- filt_buff[st_drop_geometry(filt_buff)[j] <= quants[[j]],]
}

#####
### set id for new points
#####

filt_buff$id_after_filter <- c(1:nrow(filt_buff))

st_write(filt_buff, paste0(gee_path, "040_filt_buff", comm_filt, ".gpkg"), delete_dsn = TRUE)
saveRDS(filt_buff, file = paste0(gee_path, "040_filt_buff", comm_filt, ".rds"))
# filt_buff <- readRDS(file = paste0(gee_path, "040_filt_buff", comm_filt, ".rds"))
