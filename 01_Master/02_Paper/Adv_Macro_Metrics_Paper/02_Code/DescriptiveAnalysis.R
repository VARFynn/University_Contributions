#### Descriptive Analysis - Macrometrics 2023
### Fynn Lohre - Lucas Unterweger - Sophia Oberbrinkmann

## Load neccessary packages
library(readxl)
library(tidyverse)
library(ggplot2)
library(ggthemes)
library(rgdal) 
library(cartography)

### Create Data set for map
totaldata2 <- totaldata %>%
  filter(iso2 %in% nuts0.spdf$id) %>%
  select(Country.x, pct2021, iso2) %>%
  rename(Country = Country.x) %>%
  add_row(Country = "Iceland",iso2 = "IS", pct2021 = 0) %>% # Some adjustemts are necessary to clean up data missmatch
  add_row(Country = "United Kingdom",iso2 = "UK", pct2021 = 2.1615719) %>%
  add_row(Country = "Lichtenstein",iso2 = "LI", pct2021 = 0) %>%
  rename(id = iso2) %>%
  arrange(match(id, nuts0.spdf$id))

pct <- as.numeric(totaldata2$pct2021) # Add the data on military spending to the data frame
nuts0.df2 <- cbind(nuts0.df, pct)
data(nuts2006)

choroLayer(spdf = nuts0.spdf, df = nuts0.df2, var = "pct" , legend.pos = "right", # Plot Map
           legend.title.txt = "% of GDP (2021)",
           legend.frame = TRUE,
           legend.values.rnd = 2,
           breaks = c(0,1,1.5,2,2.5,4),
           col = carto.pal(pal1 = "red.pal", n1=6))
title("Military Expenditure in % of GDP in 2021") # Add Title to Plot

## Basic Plots
### Different Measures of Distance
totaldata <- read.csv("../02_Raw_Data/completedata.csv") %>%
  rename(Country = Country.x) %>%
  mutate(db = DirectBorder) %>%
  mutate(sb = SecondaryBorder*2) %>%
  mutate(tb = sb+db) %>%
  mutate(Nato = as.factor(Nato)) %>%
  mutate(continent = as.factor(continent)) %>%
  mutate(DirectBorder = as.factor(DirectBorder)) %>%
  mutate(SecondaryBorder = as.factor(SecondaryBorder)) %>%
  mutate(tb = as.factor(tb))

ggplot(totaldata, aes(x=dist, y=pct2021, color = continent))+
  geom_point()+
  #geom_label(label=totaldata$Country, 
  #           nudge_x = 0.25, nudge_y = 0.25, 
  #           check_overlap = T)+
  xlab("Distance to Moscow in km")+
  ylab("Military Expenditure in % of GDP (2021)")+
  labs(title = "Relationship between Military Expenditure and Distance to Moscow", subtitle = "as % of GDP in 2021")+
  scale_color_discrete(name = "Continent")+
  theme_minimal()

ggplot(totaldata, aes(x=electdem_vdem_owid, y=pct2021, color = continent))+
  geom_point()+
  #geom_label(label=totaldata$Country, 
  #           nudge_x = 0.25, nudge_y = 0.25, 
  #           check_overlap =  T)+
  xlab("Value of the V-dem index")+
  ylab("Military Expenditure in % of GDP (2021)")+
  labs(title = "Relationship between Military Expenditure and the V-Dem Index of a Country", subtitle = "as % of GDP in 2021")+
  scale_color_discrete(name = "Continent")+
  theme_minimal()

### Distribution pre Border Relationship
ggplot(filter(totaldata), aes(y=pct2021, color=tb)) +
  geom_boxplot()+
  ylab("Military Expenditure in % of GDP (2021)")+
  labs(title = "Distribution of Military Expenditure based on Border Group in Europe", subtitle = "2 = Secondary Border; 1 = Direct Border, 0 = At least two countries apart")+
  scale_color_discrete(name="Border Relationship")+
  theme_minimal()