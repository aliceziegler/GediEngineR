# Description: Find GEdi Data for area and time range and write into file taht is readable form GEE
# Author: Alice Ziegler
# Date:
# 2022-09-08 15:54:02
# to do:

rm(list=ls())

########################################################################################
### Presettings
########################################################################################

#####
### load packages
#####
library(rGEDI)
library(readr)
library(rnaturalearth)
library(sf)
library(dplyr)

#####
### load other stuff
#####
source("scripts/000_R_presettings.R")

#####
### general settings
#####
# for testing
# xmax <- 8.6
# xmin <- 8.460928
# ymax <- 50.85
# ymin <- 50.77558

# hessen:
hessen = rnaturalearth::ne_states(country = "Germany", returnclass = c("sf")) %>% dplyr::filter(name == "Hessen") %>% select(name)
hessen = st_cast(hessen, "POLYGON")
bbox <- st_bbox(hessen)

xmin <- bbox$xmin
xmax <- bbox$xmax
ymin <- bbox$ymin
ymax <- bbox$ymax

version <- "002"

#####
### read data
#####

########################################################################################
### Do stuff
########################################################################################

orbs <- gedifinder(product="GEDI02_B", ymax, xmin, ymin, xmax, version, daterange)

asset_info_lst <- lapply(orbs, function(o){
  asset <- substr(o, 70, nchar(orbs)-3)
})
saveRDS(asset_info_lst, file = paste0(gee_path, "asset_list.rds"))
asset_info <- do.call("rbind", asset_info_lst)


# to avoid appending to an existing file
if (file.exists(paste0(gee_path, "granule_list_comma.txt"))) {
    file.remove(paste0(gee_path, "granule_list_comma.txt"))}
if (file.exists(paste0(gee_path, "granule_list.txt"))) {
    file.remove(paste0(gee_path, "granule_list.txt"))}

cat(paste0("exports.granules = ["), file = paste0(gee_path, "granule_list_comma.txt"), sep = "\n", append = TRUE) #opening complete list with "["
# groups_list <- lapply(seq(ceiling(nrow(asset_info)/150)), function(j){
for(j in 1:ceiling(nrow(asset_info)/150)){
    from <- j*150 - 150
    if (j==1){
        from <- 1
    }
    to <-  j * 150
    if (to > nrow(asset_info)){
        to <- nrow(asset_info)
    }
    # print(from)
    # print(to)
#     return(data.frame(from = from, to = to))
#
#
# #}
# })
# groups <- do.call("rbind", groups_list)
cat(paste0("["), file = paste0(gee_path, "granule_list_comma.txt"), sep = "\n", append = TRUE) # eine "[" im DOkument]

 # for (i in nrow(asset_info)){
for (i in seq(from, to)){
  res_string = paste0("['LARSE/GEDI/GEDI02_B_002/",
                      asset_info[i],
                      "']")
# if file ends with ".png" delete (it seems that data for those days doesn'T exist (see(https://e4ftl01.cr.usgs.gov/GEDI/GEDI02_B.002/) and
  # .pngs only show where data "should" be taken. can find pngs only for other files))
  if (grepl(".png']", res_string)){
      next
  }

  cat(paste0(res_string, ","), file = paste0(gee_path, "granule_list_comma.txt"), sep = "\n", append = TRUE)    #"[
                                                                                                                # ['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019108093620_O01965_02_T05338_02_003_01_V002'],"
}
# ##remove comma at the end of each sublist
read <- read_file(paste0(gee_path, "granule_list_comma.txt"))
no_comma <- substring(read,1, nchar(read)-3)
no_comma <- gsub("\r", "", no_comma)
cat(no_comma, file = paste0(gee_path, "granule_list_comma.txt"), sep = "") # "[[xyz].[xyz], ...[xyz]" # no komma at the end of 1sublist


cat(paste0("],"), file = paste0(gee_path, "granule_list_comma.txt"), sep = "\n", append = TRUE) # closing sublist with "]"

}
###read delete last comma and write
read <- read_file(paste0(gee_path, "granule_list_comma.txt"))
no_comma <- substring(read,1, nchar(read)-3)
no_comma <- gsub("\r", "", no_comma)
cat(no_comma, file = paste0(gee_path, "granule_list.txt"), sep = "")
cat(paste0("]"), file = paste0(gee_path, "granule_list.txt"), sep = "\n", append = TRUE) # closing complete list with "]"

file.remove(paste0(gee_path, "granule_list_comma.txt"))

###next: manually import table into gee
