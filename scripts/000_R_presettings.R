# Description: presettings that are useful in several scripts
# Author: Alice Ziegler
# Date:
# 2022-10-18 09:47:57
# to do:

rm(list=ls())

####################################################################
####################################################################
### stuff to play with
####################################################################
####################################################################
machine <- "local"
# machine <- "cluster" # MaRC3
# machine <- "rstudioserver" # hosted on MaRC3

comm <- "_all_1col_" ## short descriptive comment to use e.g. for file naming

parallelize <- T
core_num <- 20

daterange <- c("2019-03-01","2021-12-31")  #Stand 10.10.2021 granules für 2022 nur bis ca Juni. Außerdem teilweise .png files (was ist das?)

##plotting settings
cor_val <- c("12" = "lightgoldenrod3","18" = "darkorange", "23" = "darkolivegreen1",
             "24" = "springgreen3","25" = "forestgreen") #for values in scale fill manual
cor_lab <- c("arable land", "pasture", "broad leaved", "coniferous", "mixed forest")


####################################################################
####################################################################
### Don't change anything past this point,
###except you know what you are doing
####################################################################
####################################################################

####################################################################
### general settings for machine
####################################################################

if (machine == "local"){
  proj_path <- "D:/Uni/Projekte/GEDI/"
}else if (machine == "cluster"){
  proj_path <- "/mnt/masc_home/ziegler5/GEDI/"
}else if (machine == "rstudioserver"){
  proj_path <- "~/GEDI/"
}

# if(parallelize == T){
# cl <- makeCluster(core_num, type = "FORK", outfile = paste0(proj_path, "out.txt"))
# registerDoParallel(cl)
# }


####################################################################
### path settings
####################################################################
#data_path #uppermost directory for data
if(!dir.exists(paste0(proj_path, "data/"))){
  dir.create(paste0(proj_path, "data/"))}
data_path <- paste0(proj_path, "data/")
#gee_path #directory to get data into or from Goolge Earth Engine (GEE)
if(!dir.exists(paste0(data_path, "GEE/"))){
  dir.create(paste0(data_path, "GEE/"))}
gee_path <- paste0(data_path, "GEE/")
#corine_path
if(!dir.exists(paste0(data_path, "CORINE/"))){
  dir.create(paste0(data_path, "CORINE/"))}
corine_path <- paste0(data_path, "CORINE/")
#out_path
if(!dir.exists(paste0(proj_path, "out/"))){
  dir.create(paste0(proj_path, "out/"))}
out_path <- paste0(proj_path, "out/")
#figure path
if(!dir.exists(paste0(proj_path, "fig/"))){
  dir.create(paste0(proj_path, "fig/"))}
fig_path <- paste0(proj_path, "fig/")
#pred_path
if(!dir.exists(paste0(out_path, "predictions/"))){
  dir.create(paste0(out_path, "predictions/"))}
pred_path <- paste0(out_path, "predictions/")
# sen3_path
if(!dir.exists(paste0(data_path, "Sen3/"))){
  dir.create(paste0(data_path, "Sen3/"))}
sen3_path <- paste0(data_path, "Sen3/")
