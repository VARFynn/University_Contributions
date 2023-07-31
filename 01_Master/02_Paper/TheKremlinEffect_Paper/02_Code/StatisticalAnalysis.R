#### Statistical Analysis - Macrometrics 2023
### Fynn Lohre - Lucas Unterweger - Sophia Oberbrinkmann

## Necessary Packages
rm(list=ls())
library(brms)
library(tidyverse)
library(bayesplot)
library(ggplot2)

## Get Data
totaldata <- read.csv("../02_Raw_Data/completedata.csv")
  

## Sample OLS Estimation
mod_basic <- lm(pct2021 ~ dist, data=totaldata)
summary(mod_basic)

mod_extensive <- lm(pct2021 ~ dist+Nato+BRICS+OKVS+continent+DirectBorder+SecondaryBorder, data=totaldata)
summary(mod_extensive)

##### Bayesian Analysis
#### Model 1 - Every Covariate 
fit.mod1 <- brm(pct2021 ~ dist+Nato+BRICS+OKVS+continent+DirectBorder+SecondaryBorder+electdem_vdem_owid,
                data = totaldata,
                prior = c(prior(normal(0, 1), class = b),
                          prior(inv_gamma(2, 1), class = sigma)),
                save_pars = save_pars(all = TRUE),
                sample_prior="yes",
                chains=2,
                iter=1000,
                warmup = 500)
fit.mod1
coefs_mod1 <- fixef(fit.mod1)
mcmc_areas(fit.mod1, pars = c("b_dist"), prob=0.975) + ggtitle("Posterior Distribution of the Distance Parameter (Model 1)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")+xlim(-.0004,.00005)
mcmc_areas(fit.mod1, pars = parnames(fit.mod1)[6:9], prob=0.975) + ggtitle("Posterior Distribution of the Continent Parameters (Model 1)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")
mcmc_areas(fit.mod1, pars = parnames(fit.mod1)[3:5], prob=0.975) + ggtitle("Posterior Distribution of the Alliances Parameters (Model 1)") + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")
mcmc_areas(fit.mod1, pars = parnames(fit.mod1)[10:11], prob=0.975) + ggtitle("Posterior Distribution of the Border Relationship Parameters (Model 1)") + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")
mcmc_areas(fit.mod1, pars = parnames(fit.mod1)[12], prob=0.975) + ggtitle("Posterior Distribution of the Parameter related to the V-Dem Index (Model 1)") + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")


#### Model 2 - Every Covariate except electdem_vdem_owid ("just physical distance")
fit.mod2 <- brm(pct2021 ~ dist+Nato+BRICS+OKVS+continent+DirectBorder+SecondaryBorder,
                data = totaldata,
                prior = c(prior(normal(0, 1), class = b),
                          prior(inv_gamma(2, 1), class = sigma)),
                save_pars = save_pars(all = TRUE),
                sample_prior="yes",
                chains=2,
                iter=1000,
                warmup = 500)
fit.mod2
coefs_mod2 <- fixef(fit.mod1)
mcmc_areas(fit.mod2, pars = c("b_dist"), prob=0.95) + ggtitle("Posterior Distribution of the Distance Parameter (Model 2)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")+xlim(-.0004,.00005)
mcmc_areas(fit.mod2, pars = parnames(fit.mod2)[6:9], prob=0.95) + ggtitle("Posterior Distribution of the Continent Parameters (Model 2)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")
mcmc_areas(fit.mod2, pars = parnames(fit.mod2)[3:5], prob=0.95) + ggtitle("Posterior Distribution of the Alliances Parameters (Model 2)") + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")
mcmc_areas(fit.mod2, pars = parnames(fit.mod2)[10:11], prob=0.95) + ggtitle("Posterior Distribution of the Border Relationship Parameters (Model 2)") + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")

#### Model 3 - Only Distance
fit.mod3 <- brm(pct2021 ~ dist,
                data = totaldata,
                prior = c(prior(normal(0, 1), class = b),
                          prior(inv_gamma(2, 1), class = sigma)),
                save_pars = save_pars(all = TRUE),
                sample_prior="yes",
                chains=2,
                iter=1000,
                warmup = 500)
mcmc_areas(fit.mod3, pars = c("b_dist"), prob=0.95) + ggtitle("Posterior Distribution of the Distance Parameter (Model 3)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")+xlim(-.0004,.00005)

#### Model 4 - No Distance
fit.mod4 <- brm(pct2021 ~ Nato+BRICS+OKVS+continent+DirectBorder+SecondaryBorder,
                data = totaldata,
                prior = c(prior(normal(0, 1), class = b),
                          prior(inv_gamma(2, 1), class = sigma)),
                save_pars = save_pars(all = TRUE),
                sample_prior="yes",
                chains=2,
                iter=1000,
                warmup = 500)
mcmc_areas(fit.mod4, pars = parnames(fit.mod4)[1:10], prob=0.95) + ggtitle("Posterior Distribution of all Parameters (Model 4)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")



#### Model Weights
model_weights(fit.mod1, fit.mod2, fit.mod3, fit.mod4, weights = "waic")


#### Robustness Check
totaldata_2005 <- read.csv("../02_Raw_Data/completedata2005.csv")
totaldata_2015 <- read.csv("../02_Raw_Data/completedata2015.csv")

fit.mod1_2005 <- brm(pct2021 ~ dist+Nato+BRICS+OKVS+continent+DirectBorder+SecondaryBorder+electdem_vdem_owid,
                data = totaldata_2005,
                prior = c(prior(normal(0, 1), class = b),
                          prior(inv_gamma(2, 1), class = sigma)),
                save_pars = save_pars(all = TRUE),
                sample_prior="yes",
                chains=2,
                iter=1000,
                warmup = 500)
fit.mod1_2005
coefs_mod1 <- fixef(fit.mod1_2005)
mcmc_areas(fit.mod1_2005, pars = c("b_dist"), prob=0.975) + ggtitle("Posterior Distribution of the Distance Parameter (Model 1, 2005)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")+xlim(-.0004,.00005)
mcmc_areas(fit.mod1_2005, pars = parnames(fit.mod1_2005)[3:12], prob=0.975) + ggtitle("Posterior Distribution of the Parameters (Model 1, 2005)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")

fit.mod1_2015 <- brm(pct2021 ~ dist+Nato+BRICS+OKVS+continent+DirectBorder+SecondaryBorder+electdem_vdem_owid,
                data = totaldata_2015,
                prior = c(prior(normal(0, 1), class = b),
                          prior(inv_gamma(2, 1), class = sigma)),
                save_pars = save_pars(all = TRUE),
                sample_prior="yes",
                chains=2,
                iter=1000,
                warmup = 500)
fit.mod1_2015
coefs_mod1 <- fixef(fit.mod1_2015)
mcmc_areas(fit.mod1_2015, pars = c("b_dist"), prob=0.975) + ggtitle("Posterior Distribution of the Distance Parameter (Model 1, 2015)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")+xlim(-.0004,.00005)
mcmc_areas(fit.mod1_2015, pars = parnames(fit.mod1_2005)[3:12], prob=0.975) + ggtitle("Posterior Distribution of the Parameters (Model 1, 2015)")  + theme_minimal() + geom_vline(xintercept=0, color="red", lty = "dashed", size=1.2) + ylab("Parameters")
