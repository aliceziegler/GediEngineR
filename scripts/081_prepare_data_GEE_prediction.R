library(sf)
data <- readRDS("D:/Uni/Projekte/GEDI/data/GEE/small_data.rds")
colnames(data)[colnames(data) == "system.index"] <- "system_index"
colnames(data)[colnames(data) == ".geo"] <- "_geo"


data_train <- data[data$year != 2021,]
data_test <- data[data$year == 2021,]
# write.table(data, "D:/Uni/Projekte/GEDI/data/GEE/small_data.csv", row.names = F, sep = ";")
# write.table(data_train, "D:/Uni/Projekte/GEDI/data/GEE/small_data_train.csv", row.names = F, sep = ";")
# write.table(data_test, "D:/Uni/Projekte/GEDI/data/GEE/small_data_test.csv", row.names = F, sep = ";")

model <- readRDS("D:/Uni/Projekte/GEDI/out/060_test_model_all_1col_no2022_inclMix_val_21_total.rds")


rd <- read.csv("D:/Uni/Projekte/GEDI/data/GEE/small_data_train.csv", sep = ";")

