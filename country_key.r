rm(list=ls())
suppressPackageStartupMessages(require(dplyr))
load("LifeExpectancyData2.Rdata")





require(dplyr)
# from https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes
library(RCurl)
ISO3166 <- read.csv(text = (getURL("https://raw.githubusercontent.com/lukes/ISO-3166-Countries-with-Regional-Codes/master/all/all.csv")))

countries <- as.data.frame(unique(data2$Country))
colnames(countries) <- "Country" 
countries$Country <- as.character(countries$Country)
ISO3166$name <- as.character(ISO3166$name)
dfcountry <- left_join(x = countries, 
                   y = ISO3166, 
                   by = c("Country" = "name"))


data2 <- left_join(x = data2,
                   y = dfcountry[,c("Country","region")], 
                   by = c("Country" = "Country"))


test3 <- array(split(data2, data2$Year))

rollup <- data2 %>% group_by(Year,region) %>% summarise(meancontinent = mean(`Life expectancy`))
continentcuboid <- array(split(rollup, rollup$Year))


apply(c("Life expectancy", "Adult Mortality", "infant deaths"), FUN=function(x) mean(x, na.rm=TRUE)))