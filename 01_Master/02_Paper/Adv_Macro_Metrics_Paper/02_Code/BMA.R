data2015 <- read.csv("completedata2015_new.csv")
install.packages("dplyr")
library(dplyr)
data2015 <- completedata2015_new
summary(data2015)
head(data2015)
install.packages("BMA")
library(BMA)
attach(data2015)
predictors <- as.matrix(cbind(continent, DirectBorder, SecondaryBorder, Nato, OKVS, BRICS, electdem_vdem_owid,Neutrality, dist, `GDP growth`, Soviet))
head(predictors)
bma1 <- bicreg(predictors, data2015$pct2021)
summary(bma1)
bma1
bma1$ols
plot(bma1, mfrow=c(2,4))

data_NATO <- completedata2015_Nato
attach(data_NATO)
predictors_NATO <- as.matrix(cbind(DirectBorder, SecondaryBorder, OKVS, BRICS, electdem_vdem_owid, Neutrality, dist, `GDP growth`, Soviet))
bmaNATO <- bicreg(predictors_NATO, data_NATO$pct2021)
summary(bmaNATO)

data_EU <- completedata2015_EU
attach(data_EU)
predictors_EU <- as.matrix(cbind(DirectBorder, SecondaryBorder, Nato, OKVS, BRICS, electdem_vdem_owid, Neutrality, dist, `GDP growth`, Soviet))
bmaEU <- bicreg(predictors_EU, data_EU$pct2021)
summary(bmaEU)
