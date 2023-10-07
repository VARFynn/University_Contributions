## Macroeconometrics Assignment #1 
## Miriam Frauenlob, Katharina König. Fynn Lohre
## Due Date: 19. Apr. 2023 

#------------------------------------------------------------------------------#
#Define Working Path here & save every file within this folder
#------------------------------------------------------------------------------#
setwd("/Users/fynnlohre/Desktop/R/")
#setwd("C:/Users/Fynn/Documents/Programming/R/WU/Macroeconometrics)
#sedwd("C:/Users/miria/Desktop/SoSe2023/Macroeconometrics/1st assignment/")
#sedwd("C:/Users/kathi/Desktop/SemesterII/Macroeconometrics/1st assignment/")

getwd() 

################################################################################
#### 1 Pre #####################################################################
################################################################################

install.packages("urca")                                                        # Unit Roots
install.packages("tseries")                                                     # Time Series Analysis 
install.packages("tseries")                                                     # Time Series Analysis 
install.packages ("forecast")                                                   # Forecasts
install.packages("vars")                                                        # VAR Modelling

library(tidyr)
library(dplyr)
library(ggplot2)
library(stats)
library(urca)
library(tseries)
library(forecast)
library(vars)


################################################################################
#### 2 Excercise I #############################################################
################################################################################

#------------------------------------------------------------------------------#
# Note: If Excel stores the data as 01/01/1995 but displays 1/1/95, R loads the 
# visible data and not the stored. Hence, in this case, the code won't work. 
# This can happen everytime if Excel was reopened on MacOS.
#------------------------------------------------------------------------------#

timeseries        <-  read.csv("current.csv")
timeseries        <-  timeseries[-1,]                                           # Remove first line of timeseries, as it only gives us the specifications
timeseries[,-1]   <-  sapply(timeseries[,-1], as.numeric)                       # Transform to numeric
timeseries[,1]    <-  as.Date(timeseries[,1],format="%m/%d/%Y")                 # Change date for a format ggplot2 can work with 

is.na(timeseries)                                                               # Returns a matrix of logical values indicating whether each element in timeseries is missing (NA) or not
sum(is.na(timeseries))                                                          # Calculates the total number of missing values in timeseries by summing up all the TRUE values in the matrix returned by is.na()

#------------------------------------------------------------------------------#
## First Bullet: Function 
#------------------------------------------------------------------------------#

transformation<-function(v){
    logv              <-  log(v)                                                # Log-transformed Time Series
    logdiff           <-  log(v)-lag(log(v))                                    # Month-on-Month Growth
    logdiffyearly     <-  log(v)-lag(log(v),n=12)                               # Year-on-Year Growth   
    laglogdiffyearly  <-  lag(logdiffyearly)                                    # First Lag of Year-on-Year Growth

    res<-data.frame(series=v,
                    logseries=logv,                      
                    monthlygr=logdiff,
                    yearlygr=logdiffyearly, 
                    lag_yearlygr=laglogdiffyearly)
  
  return(res)
}

# Test Function
transformation(timeseries$RETAILx)    


#------------------------------------------------------------------------------#
## Second Bullet: Industrial Production + Yearly Growthrate
#------------------------------------------------------------------------------#

# Apply Transformation Function
industrial_production       <-  data.frame(transformation(timeseries$INDPRO))
industrial_production$date  <-  timeseries$sasdate


# Plot of the log of the timeseries
logseries2  <- ts(industrial_production$logseries, 
                  frequency = 12, 
                  start = c(1959,1,1))                                          # Construct TS formatted as TS (Important for further Bullet Points)

plot(logseries2, xlim = c(1960, 2023), 
                  main = "US Industrial Production (logarithmized)", 
                  xlab = "Year", 
                  ylab = "Value")

# Plot of the yearly growthrates
yearlygr2 <- ts(industrial_production$yearlygr, 
                  frequency = 12, 
                  start = c(1959,1,1))                                          # Construct TS formatted as TS (Important for further Bullet Points)

plot(yearlygr2, xlim = c(1960, 2023), 
                  main = "Yearly Growthrate US Industrial Production", 
                  xlab = "Year", 
                  ylab = "Value") 


#------------------------------------------------------------------------------#
## Third Bullet: Autocorrelation + Dickey Fuller
#------------------------------------------------------------------------------#
is.na(logseries2)
na.rm(logseries2)

# Logseries
acf(na.omit(logseries2))                                                        # ACF Plot

tseries::adf.test(na.omit(logseries2))                                          # Result: The Dickey Fuller test implies that this timeseries is not stationary

summary(ur.df(na.omit(logseries2),
              type="drift",
              selectlags = c("BIC")))                                           # Result: The Dickey Fuller test with a trend implies that this timeseries is not stationary

summary(ur.df(na.omit(logseries2),
              type="trend", 
              selectlags=c("BIC")))                                             # Result: Here, we can reject the null hypothesis of the presence of a unit root at the 5% and 10% levels, but we can reject it at the 1% level
                                                                                # Hence, the timeseries might be statioanry - we need more/other tes

# Yearly Growthrate 
acf(na.omit(yearlygr2))                                                         # ACF Plot

tseries::adf.test(na.omit(yearlygr2))                                           # Result: The Dickey Fuller test implies that this timeseries is stationary

summary(ur.df(na.omit(yearlygr2),
              type="drift",
              selectlags = c("BIC")))                                           # Result: The Dickey Fuller test implies that this timeseries is stationary

summary(ur.df(na.omit(yearlygr2),
              type="trend",
              selectlags=c("BIC")))                                             # Result The Dickey Fuller test implies that this timeseries is stationary
                                                                                # Result: The Dickey Fuller test implies that this timeseries is stationary

#------------------------------------------------------------------------------#      
## Fourth Bullet: AR Model of Yearly Growthrate
#------------------------------------------------------------------------------#

AR_model <- ar.ols(na.omit(yearlygr2))                                          # Fit the AR model; By default, the AR model includes 26 lags

forecast_values <- forecast(AR_model, 
                            h = 12, 
                            level = c(95, 99))                                  # Generate a forecast for 12 periods ahead with both 95% and 99% confidence intervals

plot(forecast_values, xlim = c(1960, 2024), 
                      main = "Yearly Growthrate + AR(26) Forecast", 
                      xlab = "Year", 
                      ylab = "Value")                                           # Plot the forecast values for the full range

plot(forecast_values, xlim = c(2020, 2024), 
                      main = "Yearly Growthrate (2020+) + AR(26) Forecast", 
                      xlab = "Year", 
                      ylab = "Value")                                           # Plot the forecast values for the range since 2020

lines(window(yearlygr2, start = c(2020, 1)), 
                        col = "black", 
                        lty = 1)                                                # Data line for legend

lines(forecast_values$lower[, "95%"], col = "gray", lty = 2)                    # CI line for legend
lines(forecast_values$upper[, "95%"], col = "gray", lty = 2)                    # CI line for legend
lines(forecast_values$lower[, "99%"], col = "red", lty = 2)                     # CI line for legend
lines(forecast_values$upper[, "99%"], col = "red", lty = 2)                     # CI line for legend

legend("bottomright", 
       legend = c("Forecast", 
                  "95% Confidence Interval",
                  "99% Confidence Interval"), 
       col = c("blue", "gray", "red"), 
       lty = c(1, 2, 2))                                                        # Add legend




#------------------------------------------------------------------------------#
## Fifth Bullet (Bonus): Function that computes RSME of a given AR model 
## based on lag order and holdout period
#------------------------------------------------------------------------------#

# Function
compute_RMSE        <-  function(ts, lag_order, holdout_period) {
  ts_no_holdout     <-  ts[1:(length(ts) - holdout_period)]                     # Remove holdout period from the end of the time series
  
  AR_model          <-  ar(ts_no_holdout, 
                           order.max = lag_order, 
                           aic = TRUE)                                          # Fit the AR model with the specified  Lag Order
  
  forecast_values   <- predict(AR_model,
                             n.ahead = holdout_period)                          # Generate forecasts for the holdout period
  
  predicted_values  <- forecast_values$pred                                     # Predicted Value       
  
  realized_values   <- ts[(length(ts) - 
                             holdout_period + 1):length(ts)]                    # Realized Values 
  
  RMSE              <- sqrt(mean((predicted_values - 
                                    realized_values)^2))                        # Compute RMSE based on predicted and realized values
  
  return(RMSE)
}

# Test Function
RMSE_6_6    <- compute_RMSE(na.omit(yearlygr2), 6, 6)                           # Compute for 6-month holdout period and 6 lags
RMSE_6_12   <- compute_RMSE(na.omit(yearlygr2), 6, 12)                          # Compute for 6-month holdout period and 12 lags
RMSE_12_12  <- compute_RMSE(na.omit(yearlygr2), 12, 12)                         # Compute for 12-month holdout period and 12 lags

print(paste0("RMSE for 6-month holdout period with 6 lags: ", RMSE_6_6))
print(paste0("RMSE for 6-month holdout period with 12 lags: ", RMSE_6_12))
print(paste0("RMSE for 12-month holdout period with 12 lags: ", RMSE_12_12))

#------------------------------------------------------------------------------#
# RMSE of 6_6 < RMSE 6_12 < RMSE 12_12 -> lower forecasting horizon
# leads to higher predicitive performance -> would choose RMSE of 6_6
#------------------------------------------------------------------------------#

################################################################################
#### 2 Excercise II ############################################################
################################################################################

data_kilian_park_2009         <-  read.table("data_kilian_park_2009.txt", 
                                             quote="\"", comment.char="")

names(data_kilian_park_2009)  <-  c("OilProd","EconAct","PriceOil","GrowthDiv")


#------------------------------------------------------------------------------#
## First Bullet Point: Estimation Var
#------------------------------------------------------------------------------#


VAR_model <- VAR(data_kilian_park_2009, p=24, type="const")                       #Estimating VAR with  24 lags and including a constant term
print(VAR_model)


#------------------------------------------------------------------------------#
## Second Bullet: Compute Impulse Response Function (+ Figure 1 & 3)
#------------------------------------------------------------------------------#

# Shock on global supply of of crude oil (''oil supply shock'') 
# Referred to as ''epsilon_{1t}"
# S = Supply 
IRF_S             <-          irf(VAR_model, 
                                  impulse = "OilProd",                          # Shock in the Oil Production
                                  response = "PriceOil",                        # Variable of interest: Oil Price
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = FALSE,                           # IRF should not be calculated as a cumulative response over time, but rather as a direct response at each time point
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)


for (i in 1:nrow(IRF_S$irf$OilProd)) {                                          # Signs need to be inverted as it's a negative shock
  
  IRF_S$irf$OilProd[i,]       <-    IRF_S$irf$OilProd[i,]   * (-1)
  IRF_S$Upper$OilProd[i,]     <-    IRF_S$Upper$OilProd[i,] * (-1)
  IRF_S$Lower$OilProd[i,]     <-    IRF_S$Lower$OilProd[i,] * (-1)
  
}

# Shock to the global demand driven by global economic acitivty (''aggregate demand shock'')
# Referred to as ''epsilon_{2t}''
# AD = Aggregated Demand
IRF_AD         <-             irf(VAR_model, 
                                  impulse = "EconAct",                          # Shock in the Economic Activity
                                  response = "PriceOil",                        # Variable of interest: Oil Price
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = FALSE,                           # IRF should not be calculated as a cumulative response over time, but rather as a direct response at each time point
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)

# Shifts in precautionary demand in response to uncertainty (''oil specific demand shock'')
# Referred to as ''epsilon_{3t}''
# OSD = Oil Specific Demand
IRF_OSD        <-             irf(VAR_model, 
                                  impulse = "PriceOil",                         # Shift in Precautionary Demand
                                  response = "PriceOil",                        # Variable of interest: Oil Price
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = FALSE,                           # IRF should not be calculated as a cumulative response over time, but rather as a direct response at each time point
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)



# Figure 1

plot(IRF_S, 
     ylim = c(-6, 12), 
     yaxp = c(-6, 12, 6),
     xlim = c(1, 15), 
     xaxp = c(0, 15, 3),
     main = "Oil supply shock",
     ylab = "Real price of oil")                                                # Plot #1 Part

plot(IRF_AD, 
     ylim = c(-6, 12), 
     yaxp = c(-6, 12, 6),
     xlim = c(1, 15), 
     xaxp = c(0, 15, 3),
     main = "Aggregate demand shock",
     ylab = "Real price of oil")                                                # Plot #2 Part

plot(IRF_OSD, 
     ylim = c(-6, 12), 
     yaxp = c(-6, 12, 6),
     xlim = c(1, 15), 
     xaxp = c(0, 15, 3),
     main = "Oil-specific demand shock",
     ylab = "Real price of oil")                                                # Plot #3 Part


# Lower Pangel Figure 3  
#Oil supply shock

IRF_S2          <-            irf(VAR_model, 
                                  impulse = "OilProd",                          # Shock in the Oil Production
                                  response = "GrowthDiv",                       # Variable of interest: Cumulative Real Dividens (Percent)
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = TRUE,                            # IRF must be calculated as a cumulative response over time
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)
                    
for (i in 1:nrow(IRF_S2$irf$OilProd)) {                                         # Signs need to be inverted as it's a negative shock
  
  IRF_S2$irf$OilProd[i,]       <-    IRF_S2$irf$OilProd[i,]   * (-1)
  IRF_S2$Upper$OilProd[i,]     <-    IRF_S2$Upper$OilProd[i,] * (-1)
  IRF_S2$Lower$OilProd[i,]     <-    IRF_S2$Lower$OilProd[i,] * (-1)

}

#Aggregate demand shock
IRF_AD2         <-            irf(VAR_model, 
                                  impulse = "EconAct",                          # Shock in the Economic Activity 
                                  response = "GrowthDiv",                       # Variable of interest: Cumulative Real Dividens (Percent) 
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = TRUE,                            # IRF must be calculated as a cumulative response over time
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)

#Oil-specific demand shock
IRF_OSD2        <-            irf(VAR_model, 
                                  impulse = "PriceOil",                         # Shock in the Oil Price 
                                  response = "GrowthDiv",                       # Variable of interest: Cumulative Real Dividens (Percent) 
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = TRUE,                            # IRF must be calculated as a cumulative response over time
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)

#Figure 3 (Lower Part)
plot(IRF_S2, 
     ylim = c(-3,3), 
     xlim = c(1, 15),
     xaxp = c(0, 15, 3),
     main="Oil supply shock", 
     ylab="Cumulative Real Dividends (Percent)")                                # Plot #1 Part


plot(IRF_AD2, 
     ylim = c(-3,3), 
     xlim = c(1, 15),
     xaxp = c(0, 15, 3),                                    
     main = "Aggregate demand shock", 
     ylab = "Cumulative Real Dividends (Percent)")                              # Plot #2 Part    

plot(IRF_OSD2, 
     ylim = c(-3,3), 
     xlim = c(1, 15),
     xaxp = c(0, 15, 3),
     main = "Oil-specific demand shock", 
     ylab = "Cumulative Real Dividends (Percent)")                              # Plot #3 Part 


#------------------------------------------------------------------------------#
## Third Bullet: Forecast Error Variance Decomposition (+ Table 2)
#------------------------------------------------------------------------------#

fevd                  <-    fevd(VAR_model, n.ahead = 20)                       # Forecast error variance decomposition 
GrowthDiv_fevd        <-    fevd[["GrowthDiv"]] * 100                           # * 100 see decomposed percentage, similar to Table 2 
GrowthDiv_fevd_rows   <-    GrowthDiv_fevd[c(1, 2, 3, 12), ]                    # Extract the needed rows of Horizon 1,2,3,12
print(GrowthDiv_fevd_rows)                                                      # Table 2


#------------------------------------------------------------------------------#
# The Infinity Case is excluded, just increase the Horizon step by step 
# until the value converges. For performance reasons, this step is excluded 
# from the final R code. 
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
## Fourth Bullet: Alternative US stock market data 
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# We used the Fred-MD Data ''curent.csv'' which was already stored as 
# data/time series in part I. If you skipped that part, see line 46
#------------------------------------------------------------------------------#

# Data Preparation to create Adjusted Data Set (Adjust_Data)
summary(timeseries$S.P.500)                                                     # S.P.500 Variable from Fred-MD to evaluate stock market returns 
S.P.500      <-  data.frame(transformation(timeseries$S.P.500))[170:576, ]      # Transformation to get growth rates

summary(timeseries$CPIAUCSL)                                                    # CPI Variable from Fred-MD to evaluate REAL stock market returns
CPI         <-  data.frame(transformation(timeseries$CPIAUCSL)) [170:576, ]     # Transformation to get growth rates

Returns     <-  data.frame((S.P.500$monthlygr - CPI$monthlygr)*100)             # Creating REAL stock market returns


Adjust_Data <-  data.frame( OilProd   = data_kilian_park_2009$OilProd,
                            EconAct   = data_kilian_park_2009$EconAct,
                            PriceOil  = data_kilian_park_2009$PriceOil,
                            Returns    = Returns[, 1])

# Var  
VAR_model_2 <- VAR(Adjust_Data, p=24, type="const")                              #Estimating VAR with  24 lags and including a constant term
print(VAR_model_2)

# Shock on global supply of of crude oil (''oil supply shock'') 
# Referred to as ''epsilon_{1t}"
# S = Supply 
IRF_S_2             <-          irf(VAR_model_2, 
                                  impulse = "OilProd",                          # Shock in the Oil Production
                                  response = "PriceOil",                        # Variable of interest: Oil Price
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = FALSE,                           # IRF should not be calculated as a cumulative response over time, but rather as a direct response at each time point
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)


for (i in 1:nrow(IRF_S_2$irf$OilProd)) {                                        # Signs need to be inverted as it's a negative shock
  
  IRF_S_2$irf$OilProd[i,]       <-    IRF_S_2$irf$OilProd[i,]   * (-1)
  IRF_S_2$Upper$OilProd[i,]     <-    IRF_S_2$Upper$OilProd[i,] * (-1)
  IRF_S_2$Lower$OilProd[i,]     <-    IRF_S_2$Lower$OilProd[i,] * (-1)
  
}

# Shock to the global demand driven by global economic acitivty (''aggregate demand shock'')
# Referred to as ''epsilon_{2t}''
# AD = Aggregated Demand
IRF_AD_2         <-             irf(VAR_model_2, 
                                  impulse = "EconAct",                          # Shock in the Economic Activity
                                  response = "PriceOil",                        # Variable of interest: Oil Price
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = FALSE,                           # IRF should not be calculated as a cumulative response over time, but rather as a direct response at each time point
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)

# Shifts in precautionary demand in response to uncertainty (''oil specific demand shock'')
# Referred to as ''epsilon_{3t}''
# OSD = Oil Specific Demand
IRF_OSD_2        <-             irf(VAR_model_2, 
                                  impulse = "PriceOil",                         # Shift in Precautionary Demand
                                  response = "PriceOil",                        # Variable of interest: Oil Price
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = FALSE,                           # IRF should not be calculated as a cumulative response over time, but rather as a direct response at each time point
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)

# Figure 1

plot(IRF_S_2, 
     ylim = c(-6, 12), 
     yaxp = c(-6, 12, 6),
     xlim = c(1, 15), 
     xaxp = c(0, 15, 3),
     main = "Oil supply shock",
     ylab = "Real price of oil")                                                # Plot #1 Part

plot(IRF_AD_2, 
     ylim = c(-6, 12), 
     yaxp = c(-6, 12, 6),
     xlim = c(1, 15), 
     xaxp = c(0, 15, 3),
     main = "Aggregate demand shock",
     ylab = "Real price of oil")                                                # Plot #2 Part

plot(IRF_OSD_2, 
     ylim = c(-6, 12), 
     yaxp = c(-6, 12, 6),
     xlim = c(1, 15), 
     xaxp = c(0, 15, 3),
     main = "Oil-specific demand shock",
     ylab = "Real price of oil")                                                # Plot #3 Part

# Upper Panel Figure 3  
#Oil supply shock

IRF_S2_2          <-            irf(VAR_model_2, 
                                  impulse = "OilProd",                          # Shock in the Oil Production
                                  response = "Returns",                         # Variable of interest: Now Stock Market Returns
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = TRUE,                            # IRF must be calculated as a cumulative response over time
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)

for (i in 1:nrow(IRF_S2_2$irf$OilProd)) {                                         # Signs need to be inverted as it's a negative shock
  
  IRF_S2_2$irf$OilProd[i,]       <-    IRF_S2_2$irf$OilProd[i,]   * (-1)
  IRF_S2_2$Upper$OilProd[i,]     <-    IRF_S2_2$Upper$OilProd[i,] * (-1)
  IRF_S2_2$Lower$OilProd[i,]     <-    IRF_S2_2$Lower$OilProd[i,] * (-1)
  
}

#Aggregate demand shock
IRF_AD2_2         <-            irf(VAR_model_2, 
                                  impulse = "EconAct",                          # Shock in the Economic Activity 
                                  response = "Returns",                         # Variable of interest: Now Stock Market Returns 
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = TRUE,                            # IRF must be calculated as a cumulative response over time
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)

#Oil-specific demand shock
IRF_OSD2_2        <-            irf(VAR_model_2, 
                                  impulse = "PriceOil",                         # Shock in the Oil Price 
                                  response = "Returns",                         # Variable of interest: Now Stock Market Returns 
                                  boot = TRUE,                                  # Bootstrapped SE should account for any potential distr. assumptions or biases
                                  cumulative = TRUE,                            # IRF must be calculated as a cumulative response over time
                                  n.ahead = 15)                                 # IRF will be computed for 15 time periods ahead (as in Figure 1)
#Upper Panel Figure 3
plot(IRF_S2_2, 
     ylim = c(-3,3), 
     xlim = c(1, 15),
     xaxp = c(0, 15, 3),
     main ="Oil supply shock", 
     ylab ="Cumulative Real Stock Returns (Percent)")                           # Plot #1 Part
      
plot(IRF_AD2_2,       
     ylim = c(-3,3),      
     xlim = c(1, 15),     
     xaxp = c(0, 15, 3),                                          
     main = "Aggregate demand shock",       
     ylab = "Cumulative Real Stock Returns (Percent)")                          # Plot #2 Part    
      
plot(IRF_OSD2_2, 
     ylim = c(-3,3), 
     xlim = c(1, 15),
     xaxp = c(0, 15, 3),
     main = "Oil-specific demand shock", 
     ylab = "Cumulative Real Stock Returns (Percent)")                          # Plot #3 Part 


# Table 1 (Upper Part)
fevd                  <-    fevd(VAR_model_2, n.ahead = 20)                     # Forecast error variance decomposition 
Returns_fevd          <-    fevd[["Returns"]] * 100                             # * 100 see decomposed percentage, similar to Table 2 
Returns_fevd_rows     <-    Returns_fevd[c(1, 2, 3, 12), ]                      # Extract the needed rows of Horizon 1,2,3,12
print(Returns_fevd_rows)                                                        # Table 1

# End -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
