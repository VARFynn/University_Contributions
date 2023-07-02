################################################################################
#### Excercise II - Assignment I, Adv. Macroeconomics II  ######################
#### © Fynn Lohre (@VARFynn on Github);                   ######################
####   Max Heinze (@maxmheinze on Github);                ######################
####   Gustav Pirich (@gustavpirich on Github);           ######################      
################################################################################


################################################################################
#### 1. Pre ####################################################################
################################################################################
mrw                  <- read.csv("./mrw.csv")
Countries.Continents <- read.csv("./Countries-Continents.csv")
pacman::p_load("tidyverse", "stargazer")

# Creating Data Sata for with Continents
mrw_join <- left_join(mrw, Countries.Continents %>% rename("country" = "Country"))

mrw_join_Africa <- mrw_join %>% 
  fill(Continent) %>%
  mutate(Africa_dummy = ifelse(Continent == "Africa", 1, 0))

################################################################################
#### 2. Replicating Table VI ###################################################
################################################################################
 
mrw$log_ngd         <- log((mrw$popgrowth/100) + 0.05)
mrw$log_school      <- log(mrw$school/100)
mrw$log_gdp_growth  <- I(log(mrw$rgdpw85) - log(mrw$rgdpw60))

# Non-Oil Countries
c1 <- lm(log_gdp_growth ~ log(rgdpw60) + I(log(i_y/100) - log_ngd) + I(log_school - log_ngd),
   data = mrw %>% filter(n == 1))
summary(c1)

# Intermediate Countries
c2 <- lm(log_gdp_growth ~ log(rgdpw60) + I(log(i_y/100) - log_ngd) + I(log_school - log_ngd),
         data = mrw %>% filter(i == 1))
summary(c2)

# OECD Countries
c3 <- lm(log_gdp_growth ~ log(rgdpw60) + I(log(i_y/100) - log_ngd) + I(log_school - log_ngd),
         data = mrw %>% filter(o == 1))
summary(c3)


stargazer(c1, c2, c3, type = "latex",
          column.labels = c("Non-oil", 
                            "Intermediate", 
                            "OECD"),
          covariate.labels = c("log(Y60)",
                               "log(I/GDP) - log(n + g + ∂)", 
                               "log(SCHOOL) - log(n + g + ∂)",
                               "CONSTANT"),
          dep.var.labels = "log difference GDP per working-age-person 1960-1985",
          omit.stat = c("f", 
                        "rsq", 
                        "ser"),
          title = "Table VI",
          digits = 3,
          style = "qje")


################################################################################
#### 3. Human Capital Effect ###################################################
################################################################################

## Table 5

# Non-oil Countries
d1 <- lm(log_gdp_growth ~ log(rgdpw60) + log(i_y/100) + log_school + log_ngd,
         data = mrw %>% filter(n == 1))
summary(d1)

# Intermediate Countries
d2 <- lm(log_gdp_growth ~ log(rgdpw60) + log(i_y/100) + log_school + log_ngd,
         data = mrw %>% filter(i == 1))
summary(d2)

# OECD Countries
d3 <- lm(log_gdp_growth ~ log(rgdpw60) + log(i_y/100) + log_school + log_ngd,
         data = mrw %>% filter(o == 1))
summary(d3)



#-------Excluded --------#
# Are the restrictions based on model 6 
#linearHypothesis(d1, "log(i_y/100) + log_ngd + log_school = 0")
#linearHypothesis(d2, "log(i_y/100) + log_ngd + log_school = 0")
#linearHypothesis(d3, "log(i_y/100) + log_ngd + log_school = 0")
# Linear hypothesis test
#hypothesis.matrix3 <- matrix(c(0, 0, 1, 1,1) , nrow=1 , ncol =5)
#lh1 <- linearHypothesis(d1, hypothesis.matrix3, rhs=0)
#lh2 <- linearHypothesis(d2, hypothesis.matrix3, rhs=0)
#lh3 <- linearHypothesis(d3, hypothesis.matrix3, rhs=0)



# Lambda: We use the Coefficient on ly60 (See Theory Part of Paper, p. 423 f.)
lambda_o = -(log(1 + coef(c1)[2])/25)
lambda_i = -(log(1 + coef(c2)[2])/25)
lambda_oecd = -(log(1 + coef(c3)[2])/25)

se_1 <- sqrt(diag(vcov(c1)))["log(rgdpw60)"]

lambda_se = log(1 + se_1)/25


# Values of alpha and beta implied (Equation (16) of the Paper)
alpha_o = coef(c1)[3]/(-coef(c1)[2] + coef(c1)[3] + coef(c1)[4])
beta_o = (coef(c1)[4])/(-coef(c1)[2] + coef(c1)[3] + coef(c1)[4])

alpha_i = coef(c1)[3]/(-coef(c1)[2] + coef(c1)[3] + coef(c1)[4])
beta_i = (coef(c1)[4])/(-coef(c1)[2] + coef(c1)[3] + coef(c1)[4])

alpha_oecd = coef(c1)[3]/(-coef(c1)[2] + coef(c1)[3] + coef(c1)[4])
beta_oecd = (coef(c1)[4])/(-coef(c1)[2] + coef(c1)[3] + coef(c1)[4])

## Testing the hypothesis whether the effect is different

# All 122 Countries
a1 <- lm(log_gdp_growth ~ log(rgdpw60) + I(log(i_y/100) - log_ngd) + I(log_school - log_ngd)  + Africa_dummy:I(log_school - log_ngd),
         data = mrw_join_Africa)
summary(a1)

# Non-oil Countries
a2 <- lm(log_gdp_growth ~ log(rgdpw60) + I(log(i_y/100) - log_ngd) +  I(log_school - log_ngd) + Africa_dummy:I(log_school - log_ngd),
         data = mrw_join_Africa %>% filter(n == 1))
summary(a2)

# Intermediate Countries
a3 <- lm(log_gdp_growth ~ log(rgdpw60) + I(log(i_y/100) - log_ngd) +  I(log_school - log_ngd) + Africa_dummy:I(log_school - log_ngd),
         data = mrw_join_Africa %>% filter(i == 1))
summary(a3)

# African Countries
a4 <- lm(log_gdp_growth ~ log(rgdpw60) + I(log(i_y/100) - log_ngd) +  I(log_school - log_ngd),
         data = mrw_join_Africa %>% filter(Continent == "Africa"))
summary(a4)

stargazer(a1, a2, a3, type = "text",
          column.labels = c("All 122 countries", 
                            "Non-oil", 
                            "Intermediate"),
          covariate.labels = c("log(Y60)",
                               "log(I/GDP) - log(n + g + ∂)", 
                               "log(SCHOOL) - log(n + g + ∂)",
                               "log(SCHOOL) - log(n + g + ∂):AFRICA",
                               "CONSTANT"),
          dep.var.labels = "log difference GDP per working-age-person 1960-1985",
          omit.stat = c("f", 
                        "rsq", 
                        "ser"),
          title = "Table VI",
          digits = 3,
          style = "qje")

# Lambda: We use the Coefficient on ly60 (See Theory Part of Paper, p. 423 f.)
lambda_africa_full = -(log(1 + coef(a1)[2])/25)
lambda_africa_o = -(log(1 + coef(a2)[2])/25)
lambda_africa_i = -(log(1 + coef(a3)[2])/25)


################################################################################
#### 4. Income Convergence Difference ##########################################
################################################################################

## Regression with introduced Interaction term (Africa_dummy:log(rgdpw60) to 
## capture the possible differences between African and Non-African Countries

# All Countries 
e1 <- lm(log_gdp_growth ~ log(rgdpw60) + Africa_dummy:log(rgdpw60) + I(log(i_y/100) - log_ngd) + I(log_school - log_ngd),
         data = mrw_join_Africa)
summary(e1)

# Non-Oil
e2 <- lm(log_gdp_growth ~ log(rgdpw60) +  Africa_dummy:log(rgdpw60) + I(log(i_y/100) - log_ngd) + I(log_school - log_ngd),
         data = mrw_join_Africa %>% filter(n == 1))
summary(e2)

# Intermediate
e3 <- lm(log_gdp_growth ~ log(rgdpw60) + Africa_dummy:log(rgdpw60) + I(log(i_y/100) - log_ngd) + I(log_school - log_ngd),
         data = mrw_join_Africa %>% filter(i == 1))
summary(e3)

stargazer(e1, e2, e3, type = "latex",
          column.labels = c("All 122 countries", 
                             "Non-oil", 
                             "Intermediate"),
          covariate.labels = c("log(Y60)",
                               "log(I/GDP) - log(n + g + ∂)", 
                               "log(SCHOOL) - log(n + g + ∂)",
                               "log(Y60):Africa",
                               "CONSTANT"),
          dep.var.labels = "log difference GDP per working-age-person 1960-1985",
          omit.stat = c("f", 
                        "rsq", 
                        "ser"),
          title = "",
          digits = 3,
          style = "qje")


## Difference in Income Convergence Non-Africa (nA) vs. Africa (A) 
## - Calculating the Lambda 

# All Countries
lambda_nA = -(log(1 + coef(e1)[2])/25)
lambda_A = -(log(1 + (coef(e1)[2]+coef(e1)[5]))/25)

# Non-Oil
lambda_nA2 = -(log(1 + coef(e2)[2])/25)
lambda_A2 = -(log(1 + (coef(e2)[2]+coef(e2)[5]))/25)
