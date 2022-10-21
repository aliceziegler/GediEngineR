# Description: testing why in script 030_join tables some orbit have orbit numbers and some don't...
# Author: Alice Ziegler
# Date:
# 2022-09-01 11:48:16
# to do:

rm(list=ls())

########################################################################################
### Presettings
########################################################################################

#####
### load packages
#####
library(geojsonsf)
library(sf)

#####
### load other stuff
#####
source("scripts/000_R_presettings.R")

#####
### general settings
#####
merge_tables <- T # are there several GEE outputs that need to be merged

#####
### read data
#####
if (merge_tables == T) {
  gedi_files <- list.files(path = paste0(gee_path, "gedi_parts/"), full.names = T)
}else{
  gedi_files <- paste0(gee_path, "gedi_granule_samples_150.csv")
}

###all files: R-studio-Server
Sys.time()##
gedi_parts_list <- lapply(gedi_files, function(i){
  gee_tbl <- read.csv(file = i) #runtime test: if only one file exists, not slower than opening it directly. check
})
Sys.time()

#example with $orbit_number and $shot-number_within_beam: [[1]], without: [[2]]
with <- gedi_parts_list[[1]]
with$date <- as.Date(with$time)
unique(with$date)

without <- gedi_parts_list[[8]]
without$date <- as.Date(without$time)
unique(without$date)


# gee <- gee[format(as.POSIXct(gee$time, format = "%Y-%m-%dT%H:%M:%S"), format = "%Y") != 2022,]

# ###weird problem. Only 2021 and 2022
# c <- gedi_parts_list[[8]][gedi_parts_list[[8]]$time %in% c("2020-12-26T23:00:00", "2020-12-27T23:00:00", "2020-12-28T23:00:00",
#                                                       "2020-12-30T23:00:00", "2020-12-31T23:00:00") , "shot_number_within_beam"]
# a <- unique(gedi_parts_list[[8]]$time)
# b <- a[!a %in% c("2020-12-26T23:00:00", "2020-12-27T23:00:00", "2020-12-28T23:00:00",
#                  "2020-12-30T23:00:00", "2020-12-31T23:00:00")]
# d <- gedi_parts_list[[8]][gedi_parts_list[[8]]$time %in% b , "shot_number_within_beam"]
