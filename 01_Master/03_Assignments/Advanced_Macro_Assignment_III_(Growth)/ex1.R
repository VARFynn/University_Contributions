
# Header ------------------------------------------------------------------

pacman::p_load(
  tidyverse,
  readxl,
  stargazer
)



# Read in Data ------------------------------------------------------------

pwt <- read_xlsx("pwt1001.xlsx", sheet = "Data")


# Unconditional Convergence -----------------------------------------------

unconcon_6090 <- pwt %>%
  select(countrycode, year, rgdpe, pop) %>%
  filter(year %in% c(1960,1990)) %>%
  group_by(countrycode) %>%
  filter(sum(is.na(rgdpe)) < 1) %>%
  mutate(rgdpe = rgdpe / pop) %>%
  select(-pop) %>%
  mutate(ygrowth = (log(last(rgdpe)) - log(first(rgdpe))) / 30) %>%
  filter(year == 1960) %>%
  select(-year)

unconcon_6090_reg <- lm(ygrowth ~ log(rgdpe), data = unconcon_6090)

unconcon_9019 <- pwt %>%
  select(countrycode, year, rgdpe, pop) %>%
  filter(year %in% c(1990,2019)) %>%
  group_by(countrycode) %>%
  filter(sum(is.na(rgdpe)) < 1) %>%
  mutate(rgdpe = rgdpe / pop) %>%
  select(-pop) %>%
  mutate(ygrowth = (log(last(rgdpe)) - log(first(rgdpe))) / 29) %>%
  filter(year == 1990) %>%
  select(-year)

unconcon_9019_reg <- lm(ygrowth ~ log(rgdpe), data = unconcon_9019)


stargazer(unconcon_6090_reg, unconcon_9019_reg, type = "latex", column.labels = c("1960--1990", "1990--2019"))


plot(unconcon_6090$ygrowth ~ log(unconcon_6090$rgdpe), main = "Unconditional Convergence, 1960–1990")
abline(unconcon_6090_reg, col = "red")

plot(unconcon_9019$ygrowth ~ log(unconcon_9019$rgdpe), main = "Unconditional Convergence, 1990–2019")
abline(unconcon_9019_reg, col = "red")



# Conditional Convergence -------------------------------------------------

concon_6090 <- pwt %>%
  select(countrycode, year, rgdpe, pop, csh_i) %>%
  filter(year %in% 1960:1990) %>%
  group_by(countrycode) %>%
  mutate(csh_i = mean(csh_i),
         rgdpe = rgdpe / pop,
         ygrowth = (log(last(rgdpe)) - log(first(rgdpe))) / 30,
         pgrowth = (log(last(pop)) - log(first(pop))) / 30) %>%
  filter(year %in% c(1960, 1990)) %>%
  filter(sum(is.na(rgdpe)) < 1) %>%
  filter(year == 1960) %>%
  select(-pop, -year) 

concon_6090_reg <- lm(ygrowth ~ log(rgdpe) + csh_i + pgrowth, data = concon_6090)


concon_9019 <- pwt %>%
  select(countrycode, year, rgdpe, pop, csh_i) %>%
  filter(year %in% 1990:2019) %>%
  group_by(countrycode) %>%
  mutate(csh_i = mean(csh_i),
         rgdpe = rgdpe / pop,
         ygrowth = (log(last(rgdpe)) - log(first(rgdpe))) / 29,
         pgrowth = (log(last(pop)) - log(first(pop))) / 29) %>%
  filter(year %in% c(1990, 2019)) %>%
  filter(sum(is.na(rgdpe)) < 1) %>%
  filter(year == 1990) %>%
  select(-pop, -year) 

concon_9019_reg <- lm(ygrowth ~ log(rgdpe) + csh_i + pgrowth, data = concon_9019)

stargazer(concon_6090_reg, concon_9019_reg, type = "latex", column.labels = c("1960--1990", "1990--2019"))

