################################################################################
#### 1 Pre #####################################################################
################################################################################
getwd() 

## 1.1 Packages

install.packages("readxl")        #Read Excel
install.packages("zoo")           #Quarterly Data Convert
install.packages("ggplot2")       #Plot
install.packages("dplyr")         #Summary Table + Data Splitting
install.packages("mFilter")       #HP-filtering + BK-filtering (FYI, not used)
install.packages("pracma")        #detrending

library(readxl)
library(zoo)
library(ggplot2)
library(dplyr)
library(mFilter)
library(pracma)

## 1.2 Load Data
 
DTA <- read_excel("/Users/fynnlohre/Desktop/R/Data_Basis_2.xlsx")
DTA <- na.omit(DTA)

## 1.3 Data Cleaing

DTA$Y <- DTA$Y/1000
DTA$C <- DTA$C/1000
DTA$G <- DTA$G/1000
DTA$I <- DTA$I/1000

TS <- as.zoo(DTA[, -1], order.by = as.yearqtr(DTA$Year, format = "%Y-Q%q"))
print(TS)

log_TS <- log(TS)
print(log_TS)

DTA$I_Y <- DTA$I/DTA$Y
DTA$C_Y <- DTA$C/DTA$Y
DTA$G_Y <- DTA$G/DTA$Y

#In case we want to store every TS on its own
#GDP <- data.frame(Year = DTA$Year, Age = DTA$Y)
#GDP_TS <- as.zoo(GDP[, -1], order.by = as.yearqtr(GDP$Year, format = "%Y-Q%q"))
#print(GDP_TS)


################################################################################
#### 2 Excercise I #############################################################
################################################################################
# Part A ----------------------------------------------------------------------#
## 2.1 Plot Time Series

par(mfrow = c(2,2))

plot.ts(TS[,"Y"], main = "GDP\n(1995-Q1 - 2022-Q4)", 
                  ylab = "GDP in billion euro", 
                  xlab ="",
                  xlim = c(1995, 2022))

plot.ts(TS[,"C"], main = "Consumption\n(1995-Q1 - 2022-Q4)", 
                  ylab = "Consumption in billion euro",
                  xlab ="",
                  xlim = c(1995, 2022))

plot.ts(TS[,"I"], main = "Investment\n(1995-Q1 - 2022-Q4)", 
                  ylab = "Investment in billion euro",
                  xlab ="",
                  xlim = c(1995, 2022))

plot.ts(TS[,"G"], main = "Government Expenditure\n(1995-Q1 - 2022-Q4)", 
                  ylab = "Government Expenditure in billion euro",
                  xlab ="",
                  xlim = c(1995, 2022))

## 2.2 Mean of C/Y G/Y I/Y

summary_table <- DTA %>%
  summarise(
    Mean_I_Y = mean(I_Y),
    Mean_C_Y = mean(C_Y),
    Mean_G_Y = mean(G_Y)
  )


# Part B ----------------------------------------------------------------------#
## 2.3 Cyclical Component -> Linear Detrending 

ts_detrended <- detrend(log_TS)
plot(ts_detrended, main = "Detrended Time Series")

par(mfrow = c(2,2))

plot.ts(ts_detrended[,"Y"], main = "GDP\n(1995-Q1 - 2022-Q4)", 
                            ylab = "Cyclical component", 
                            xlab ="",
                            xlim = c(1995, 2022),
                            ylim = c(-max(abs(ts_detrended[,"Y"])), max(abs(ts_detrended[,"Y"]))))
abline(h = 0, col = "black")

plot.ts(ts_detrended[,"C"], main = "Consumption\n(1995-Q1 - 2022-Q4)", 
                            ylab = "Cyclical component",
                            xlab ="",
                            xlim = c(1995, 2022),
                            ylim = c(-max(abs(ts_detrended[,"C"])), max(abs(ts_detrended[,"C"]))))
abline(h = 0, col = "black")

plot.ts(ts_detrended[,"I"], main = "Investment\n(1995-Q1 - 2022-Q4)", 
                            ylab = "Cyclical component",
                            xlab ="",
                            xlim = c(1995, 2022),
                            ylim = c(-max(abs(ts_detrended[,"I"])), max(abs(ts_detrended[,"I"]))))
abline(h = 0, col = "black")

plot.ts(ts_detrended[,"G"], main = "Government Expenditure\n(1995-Q1 - 2022-Q4)", 
                            ylab = "Cyclical component",
                            xlab ="",
                            xlim = c(1995, 2022),
                            ylim = c(-max(abs(ts_detrended[,"G"])), max(abs(ts_detrended[,"G"]))))
abline(h = 0, col = "black")




# Part C ----------------------------------------------------------------------#
## 2.4 Table Business Cycle Statistics 

#SD
sd_Y <- sd(ts_detrended$Y)
sd_C <- sd(ts_detrended$C)
sd_I <- sd(ts_detrended$I)
sd_G <- sd(ts_detrended$G)

#SD_i_Y/SD_Y
sd_C_Y <- sd_C/sd_Y
sd_G_Y <- sd_G/sd_Y
sd_I_Y <- sd_I/sd_Y

#Contemporaneous correlations
n_vars <- ncol(ts_detrended)
ccf_matrix <- matrix(0, nrow = n_vars, ncol = n_vars)
for (i in 1:n_vars) {
  for (j in 1:n_vars) {
    ccf_result <- ccf(ts_detrended[,i], ts_detrended[,j], lag.max = 0)
    ccf_matrix[i,j] <- ccf_result$acf[1]
  }
}
colnames(ccf_matrix) <- rownames(ccf_matrix) <- colnames(TS)
print(ccf_matrix)

## 2.5 Time Series Split
#Split the time series at 2012-Q1
TS_split <- split(log_TS, f = ifelse(time(log_TS) < 2008.00, 1, 2))

#Extract the two parts
TS_part1 <- TS_split[[1]]
TS_part2 <- TS_split[[2]]

## 2.6 Summary for Part I + Detrending 
ts_detrended <- detrend(TS_part1)

#SD
sd_Y <- sd(ts_detrended$Y)
sd_C <- sd(ts_detrended$C)
sd_I <- sd(ts_detrended$I)
sd_G <- sd(ts_detrended$G)

#SD_i_Y/SD_Y
sd_C_Y <- sd_C/sd_Y
sd_G_Y <- sd_G/sd_Y
sd_I_Y <- sd_I/sd_Y

#Contemporaneous correlations
n_vars <- ncol(ts_detrended)
ccf_matrix <- matrix(0, nrow = n_vars, ncol = n_vars)
for (i in 1:n_vars) {
  for (j in 1:n_vars) {
    ccf_result <- ccf(ts_detrended[,i], ts_detrended[,j], lag.max = 0)
    ccf_matrix[i,j] <- ccf_result$acf[1]
  }
}
colnames(ccf_matrix) <- rownames(ccf_matrix) <- colnames(TS)
print(ccf_matrix)

## 2.7 Summary for Part II + Detrending 
ts_detrended <- detrend(TS_part2)

#SD
sd_Y <- sd(ts_detrended$Y)
sd_C <- sd(ts_detrended$C)
sd_I <- sd(ts_detrended$I)
sd_G <- sd(ts_detrended$G)

#SD_i_Y/SD_Y
sd_C_Y <- sd_C/sd_Y
sd_G_Y <- sd_G/sd_Y
sd_I_Y <- sd_I/sd_Y

#Contemporaneous correlations
n_vars <- ncol(ts_detrended)
ccf_matrix <- matrix(0, nrow = n_vars, ncol = n_vars)
for (i in 1:n_vars) {
  for (j in 1:n_vars) {
    ccf_result <- ccf(ts_detrended[,i], ts_detrended[,j], lag.max = 0)
    ccf_matrix[i,j] <- ccf_result$acf[1]
  }
}
colnames(ccf_matrix) <- rownames(ccf_matrix) <- colnames(TS)
print(ccf_matrix)
