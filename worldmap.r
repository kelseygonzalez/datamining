# from https://stackoverflow.com/questions/11225343/how-to-create-a-world-map-in-r-with-specific-countries-filled-in


rm(list=ls())
load("LifeExpectancyData_all_cat.Rdata")
library(rworldmap)
library(tidyverse)

#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 

#### First Example 

theCountries <- c("DEU", "COD", "BFA")
# These are the ISO3 names of the countries you'd like to plot in red

malDF <- data.frame(country = c("DEU", "COD", "BFA"),
                    malaria = c(1, 1, 1))
# malDF is a data.frame with the ISO3 country names plus a variable to
# merge to the map data

malMap <- joinCountryData2Map(malDF, joinCode = "ISO3",
                              nameJoinColumn = "country")
# This will join your malDF data.frame to the country map data

mapCountryData(malMap, nameColumnToPlot="malaria", catMethod = "categorical",
               missingCountryCol = gray(.8))
# And this will plot it, with the trick that the color palette's first
# color is red

#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 

#### Second Example 
malDF <- data.frame(country = c("DEU", "COD", "BFA"),
                    malaria = c(1, 1, 2))

## Re-merge
malMap <- joinCountryData2Map(malDF, joinCode = "ISO3",
                              nameJoinColumn = "country")

## Specify the colourPalette argument
mapCountryData(malMap, nameColumnToPlot="malaria", catMethod = "categorical",
               missingCountryCol = gray(.8), colourPalette = c("red", "blue"))



#### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### #### 
#### Our Data 
malDF <- data %>% filter(Year == 2015) %>% select(Country, Life) %>% as.data.frame()
malMap <- joinCountryData2Map(malDF, joinCode = "NAME",
                              nameJoinColumn = "Country")

## Specify the colourPalette argument
mapCountryData(malMap, nameColumnToPlot="Life", catMethod = "categorical",
               missingCountryCol = gray(.8), colourPalette = c("red", "blue", "green"))

