# Description: analysis of spatial prediction
# Author: Alice Ziegler
# Date:
# 2022-12-19 15:17:07
# to do:

rm(list=ls())

########################################################################################
### Presettings
########################################################################################

#####
### load packages & stuff
#####
library(raster)
library(ggplot2)
library(scales)
library(stringr)
library(viridis)
source("scripts/000_R_presettings.R")

#####
### general settings
#####
keep <- c(12, 18, 23, 24, 25) ##hardcode
comm_filt <- paste0(comm, "no2022_inclMix_")
comm_mod <- paste0(comm_filt, "val_21_total")


#####
### read data
#####
corine_mask <- raster(paste0(corine_path, "090_corine_mask.tif"))
pred_list <- readRDS(paste0(pred_path, "090_pred_list.rds"))
test_data_21 <- readRDS(file = paste0(gee_path, "050_data_test", comm_mod, ".rds")) # 2021



########################################################################################
### Do stuff
########################################################################################


mask_list <- lapply(keep, function(corine_i){
  # corine_i <- 12
  corine_i_mask <- corine_mask
  corine_i_mask[corine_i_mask != corine_i] <- NA
  month_list <- lapply(seq(pred_list), function(month_j){
    # month_j <- 7
    # print(month_j)
    prediction <- pred_list[[month_j]]
    pred_mask <- mask(prediction, corine_i_mask)
    pred_df <- data.frame(pai = getValues(pred_mask), month = month_j, corine = corine_i)
    pred_df <- pred_df[complete.cases(pred_df),]
    return(pred_df)
  })
  # names(month_list) <- paste0("month_", seq(pred_list))
  names(month_list) <-seq(pred_list)
  month_df <- do.call("rbind", month_list)
  return(month_df)
})
names(mask_list) <- keep
pred_pai_df <- do.call("rbind", mask_list)
lvls <- str_sort(unique(pred_pai_df$month), numeric = TRUE)
pred_pai_df$month <- factor(pred_pai_df$month, levels = lvls)

saveRDS(pred_pai_df, paste0(out_path, "090_pred_pai_df_", comm_mod, ".rds"))


## plot boxplot pai by corine and month
plot_pai <- function(dat, plot_comm){
  box_pai <- ggplot(dat, aes(x=month, y=pai, fill = as.character(corine))) +
    geom_boxplot()+
    ggtitle(paste0("PAI ", plot_comm))+
    theme_bw()+
    xlab("Date")+
    ylab("PAI")+
    scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))
  print(box_pai)
  ggsave(filename = paste0(fig_path, "095_box_pai_spat_pred_", comm_mod, "_", plot_comm, ".pdf"),
         plot = box_pai,
         width = 200, height = 150, units = "mm", dpi = 300)
  return(box_pai)
}

pai_spat_pred_box <- plot_pai(pred_pai_df, "spat_pred")
###ttest 2021- spat 2021
sample_spat_pred <- sample(pred_pai_df$pai, nrow(test_data_21))
a <- t.test(test_data_21$pai, sample_spat_pred, paired = T)
###ttest 2021-spat 2021 forest
frst_21_test <- test_data_21$pai[test_data_21$corine %in% c(23,24,25)]
frst_21_spat <- sample(pred_pai_df$pai[pred_pai_df$corine %in% c(23,24,25)], size = length(frst_21_test))
b <- t.test(frst_21_spat, frst_21_test, paired = T)

### plot pixel frequency per month and corine

tbl_cor <- table(as.data.frame(pred_pai_df)[,"corine"])
tbl_mon <- table(as.data.frame(pred_pai_df)[,"month"])
tbl_n_cor_mon <- table(as.data.frame(pred_pai_df)[,c("month", "corine")])
write.csv(tbl_n_cor_mon, paste0(fig_path, "095_n_cor_mon_spat_pred_", comm_mod, ".csv"))

tbl_n_cor_mon_long <- as.data.frame(tbl_n_cor_mon)

n_cor_mon <-
  ggplot(data = tbl_n_cor_mon_long, mapping = aes(x = month, y = corine, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = round(Freq, 2))) +
  scale_fill_viridis(discrete = F) +
  xlab(label= "month")
print(n_cor_mon)
ggsave(filename = paste0(fig_path, "095_n_cor_mon_spat_pred__fig", comm_mod, ".pdf"),
       plot = n_cor_mon,
       width = 200, height = 150, units = "mm", dpi = 300)
