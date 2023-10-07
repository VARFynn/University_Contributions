data2015 <- read.csv("completedata2015_new.csv")
data2015 <- completedata2015_new
summary(data2015)
head(data2015)
install.packages("BMA")
library(BMA)
attach(data2015)
predictors <- as.matrix(cbind(DirectBorder, SecondaryBorder, Nato, OKVS, BRICS, electdem_vdem_owid,Neutrality, dist, `GDP growth`, Soviet))
head(predictors)
bma1 <- bicreg(predictors, data2015$pct2021)
summary(bma1)
bma1
bma1$ols

