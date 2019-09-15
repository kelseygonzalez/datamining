library(readr)
setwd("C:/Users/ckgon/Google Drive/2019/3 Fall 2019/Data Mining/Datasets/")
data <-read_csv("LifeExpectancyData.csv", col_names = TRUE, na="")
save(data, file="LifeExpectancyData.Rdata")
