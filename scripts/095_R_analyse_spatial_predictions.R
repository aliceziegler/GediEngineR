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
library(shadowtext)
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
    # ggtitle(paste0("PAI ", plot_comm))+
    theme_bw()+
    xlab("Month")+
    ylab("PAI")+
    # scale_fill_discrete(name = "legend", labels = cor_lab)+
    scale_fill_manual(values = cor_val,
                      labels = cor_lab,
                      name=element_blank())#+
    # scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
    #               labels = trans_format("log10", math_format(10^.x)))
  print(box_pai)
  ggsave(filename = paste0(fig_path, "095_box_pai_spat_pred_", comm_mod, "_", plot_comm, ".pdf"),
         plot = box_pai,
         width = 200, height = 150, units = "mm", dpi = 300)
  return(box_pai)
}

pai_spat_pred_box <-
  plot_pai(pred_pai_df, "spat_pred")


###calculating median per month and doing  correlation test
# shows if yearly dynamic of corine classes is correlated
# general datasets: test_data_21 ist test datensatz
# predicted pixel dataset over hesse: pred_pai_df
cor_classes <- sort(unique(test_data_21$corine))

cor_lst <- lapply(cor_classes, function(class){
  print(class)
  spat_cor <- pred_pai_df[pred_pai_df$corine %in% c(class),]
  spat_cor_agg <- aggregate(pai ~ month, data = spat_cor, FUN= median)
  test_cor <- test_data_21[test_data_21$corine %in% c(class),]
  test_cor_agg <- aggregate(pai ~ month, data = test_cor, FUN= median)
  # if(nrow(test_cor_agg) == 12){
  # cor_test <- cor.test(test_cor_agg$pai, spat_cor_agg$pai)
  # plot(spat_cor_agg)
  # plot(test_cor_agg)
  # }
  if(nrow(test_cor_agg) != 12){
  spat_cor_agg <- spat_cor_agg[spat_cor_agg$month %in% as.numeric(test_cor_agg$month),]
  }
  cor_test <- cor.test(test_cor_agg$pai, spat_cor_agg$pai)
  # plot(spat_cor_agg)
  # plot(test_cor_agg)
  return(cor_test)
})

cor_df_lst <- lapply(cor_lst, function(i){
  # i <- cor_lst[[1]]
  p_val <- i$p.value
  est <- as.numeric(i$estimate)
  df_cor <- data.frame(correlation = est, pvalue = p_val)
})
cor_df <- do.call("rbind", cor_df_lst)
cor_df <- data.frame(corine = cor_classes, cor_df)
write.csv(cor_df, paste0(fig_path, "095_yearly_dynamic_correlation_testdata_spatprediction", comm_mod, ".csv"), row.names = F)



### plot pixel frequency per month and corine

tbl_cor <- table(as.data.frame(pred_pai_df)[,"corine"])
tbl_mon <- table(as.data.frame(pred_pai_df)[,"month"])
tbl_n_cor_mon <- table(as.data.frame(pred_pai_df)[,c("month", "corine")])
write.csv(tbl_n_cor_mon, paste0(fig_path, "095_n_cor_mon_spat_pred_", comm_mod, ".csv"))

tbl_n_cor_mon_long <- as.data.frame(tbl_n_cor_mon)
#
n_cor_mon <-
  ggplot(data = tbl_n_cor_mon_long, mapping = aes(x = month, y = corine, fill = Freq)) +
  geom_tile() +
  geom_shadowtext(size = 3, aes(label = round(Freq, 2))) +
  scale_fill_viridis(discrete = F, breaks  = c(500000, 400000, 300000, 200000, 100000),
                     labels = c("5","4","3","2", "1")) +
  xlab(label= "month")+
    guides(fill=guide_colourbar(title = expression(atop(frequency, ~x10^{5}))))+
    theme_bw()+
    theme(panel.border = element_blank(), panel.grid.major = element_blank(),
          panel.grid.minor = element_blank())+
    scale_y_discrete(expand=c(0,0), labels = cor_lab)+
    scale_x_discrete(expand=c(0,0))
print(n_cor_mon)
ggsave(filename = paste0(fig_path, "095_n_cor_mon_spat_pred__fig", comm_mod, ".pdf"),
       plot = n_cor_mon,
       width = 200, height = 150, units = "mm", dpi = 300)
#
#
# n_cor_mon <-
#   ggplot(data = tbl_n_cor_mon_long, mapping = aes(x = month, y = corine, fill = Freq)) +
#   geom_tile() +
#   geom_text(aes(label = round(Freq, 2))) +
#   scale_fill_viridis(discrete = F) +
#   labs(fill = "frequency")+
#   xlab(label= "month")+
#   theme_bw()+
#   theme(panel.border = element_blank(), panel.grid.major = element_blank(),
#         panel.grid.minor = element_blank())+
#   scale_y_discrete(expand=c(0,0), labels = cor_lab)+
#   scale_x_discrete(expand=c(0,0))
# print(n_cor_mon)
# ggsave(filename = paste0(fig_path, "070_n_cor_mon_fig", comm_mod, ".pdf"),
#        plot = n_cor_mon,
#        width = 200, height = 150, units = "mm", dpi = 300)
