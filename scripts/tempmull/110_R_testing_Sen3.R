# Description: Sen 3
# Author: Alice Ziegler
# Date:
# 2022-11-24 15:23:10
# to do:

rm(list=ls())

########################################################################################
### Presettings
########################################################################################

#####
### load packages & stuff
#####
library(raster)
library(rnaturalearth)
library(dplyr)
library(sf)
library(ggplot2)
library(RStoolbox)
library(ncdf4)
library(stars)

source("scripts/000_R_presettings.R")

#####
### general settings
#####

#####
### read data
#####
sen3_tiff_list <- list.files(sen3_path, pattern = ".tiff", recursive = T, full.names = T)
sen3_nc_list <- list.files(sen3_path, pattern = ".nc", recursive = T, full.names = T)
# hessen:
hessen = rnaturalearth::ne_states(country = "Germany", returnclass = c("sf")) %>% dplyr::filter(name == "Hessen") %>% select(name)
hessen = st_cast(hessen, "POLYGON")
bbox <- st_bbox(hessen)
########################################################################################
### Do stuff
########################################################################################
a <- raster(sen3_tiff_list[1])
b <- crop(a, hessen)
c <- projectRaster(b, crs = "+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
c


ggR(b, geom_raster = TRUE) +
  geom_sf(data = hessen, fill =NA, color = "red")

###netcdf
z <- nc_open(sen3_nc_list[1])
lai.array <- ncvar_get(z, "LAI") # store the data in a 3-dimensional array
dim(ndvi.array)

y <- read_ncdf(sen3_nc_list[1], var="LAI")
nc.crop <- st_crop(z,hessen)
