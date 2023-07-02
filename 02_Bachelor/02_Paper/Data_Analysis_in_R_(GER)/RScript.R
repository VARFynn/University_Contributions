################################################################################
################################ Seminararbeit #################################
################################################################################

# Thema: Erfolg von Entrepreneurship Trainings in Entwicklungsländern (Togo)                                                                      
# Prüfende: Tabea Brüning, M. Sc.
# Abgabedatum: 15/09/2021

# Von Luisa Esser (3036162) und Fynn Lohre (3035850)

#RQ1: Welchen Effekt hat PI Training im Vergleich zu traditionellem Business 
#Training auf unternehmerischen Erfolg und inwiefern werden die Effekte von der
#individuellen Risikopräferenz moderiert?
 
#Hypothese I: Replikation Campos + Robustheitschecks
#Hypothese II: Moderator Risk


################################################################################
#### 1 Präambel ################################################################
################################################################################

### Jegliche Vorbereitungen für die Arbeit mit den Daten ###

## 1.1 Benötigte Pakete
install.packages("haven")     # Loading Data
install.packages("dplyr")     # Veränderung und Darstellung der Variablen
install.packages("psych")     # Funktionen: describe(), describeBy()
install.packages("labelled")  # Funktionen: var_label()
install.packages("ggplot2")   # Funktionen: ggplot(), afex_plot(), plot()
install.packages ("reshape")  # Funktionen: rename
install.packages ("estimatr") # Heteroskedastie Robuste Standardfehler
install.packages("matrixStats") # Funktionen: rowMedians()
install.packages ("broom")    # Convert regressions into "tidy" data
install.packages ("dplyr")    # Funktionen: Mutate()
install.packages("stargazer") # Export Tables into LaTex
install.packages("margins")   # Marginal Effects
install.packages("sandwich")  # HC1
install.packages("lmtest")    # Output HC1 With Stargazer
install.packages("pscl")      # Pseudo R2
install.packages("ggridges")  # Graph


library(dplyr)
library(psych)  
library(labelled)
library(ggplot2)
library(haven)
library(reshape)
library(estimatr)
library(matrixStats)
library(broom)
library(dplyr)
library(stargazer)
library(margins)
library(sandwich)
library(lmtest) 
library(pscl)
library(ggridges)


## 1.2 Daten laden 
rm(list = ls())
getwd()                                                     
setwd("C:/Users/Fynn/Desktop/R")                                                 ################## Hier ANPASSEN, sonst Fehlermeldung ###################################
master <- read_dta("C:/Users/Fynn/Desktop/R/Master_data.dta",                    ################## Hier ANPASSEN, sonst Fehlermeldung ###################################
                   encoding = "latin1")

                 
## 1.3 Datensatz Formatieren



# Erstellen Dataframe Seminararbeit (SA) mit allen relevanten Variablen:
#General------------------------------------------------------------------------
#RT_bl:             Risk attitude - discrete - [1:8]          -> Risk
#RT_bl_miss:        Dummy variable if RT_bl is missing        -> Risk_D
#female             Dummy variable for  female                -> Female
#id_ent             Company ID                                -> ID                         
#assign_group       Zugewiesene Gruppe eines Entrepreneurs    -> Group
#sector             Sektor                                    -> Sector
#bl_age             Age of respondent                         -> Age_E                      
#bl_years_schooling Average years of education                -> Edu                        
#bl_firm_age        Age of firm (years)                       -> Age_F                     
#Profits------------------------------------------------------------------------
##not winsorized##
#bl_profits_lm      Profits last month                        -> bl_profits 
#bl_profits_lm_miss Dummy if missing                          -> bl_profits_D
#fu1_profits_lm     CPI adjusted Profits at T1                -> fu1_profits
#fu2_profits_lm     CPI adjusted Profits at T2                -> fu2_profits
#fu3_profits_lm     CPI adjusted Profits at T3                -> fu3_profits
#fu4_profits_lm     CPI adjusted Profits at T4                -> fu4_profits
##winsorized##
#win_bl_profits_lm  Winsorized Profits last month             -> W_bl_profits
#win_bl_profits_lm_miss Dummy if missing                      -> W_bl_profits_D
#win_fu1_profits_lm Winsorized CPI adjusted Profits at T1     -> W_fu1_profits
#win_fu2_profits_lm Winsorized CPI adjusted Profits at T2     -> W_fu2_profits
#win_fu3_profits_lm Winsorized CPI adjusted Profits at T3     -> W_fu3_profits
#win_fu4_profits_lm Winsorized CPI adjusted Profits at T4     -> W_fu4_profits
#Sales--------------------------------------------------------------------------
##not winsorized##
#bl_sales_lm        Revenue last month                        -> bl_revenue
#fu1_sales_lm       CPI adjusted Revenue at T1                -> fu1_revenue
#fu2_sales_lm       CPI adjusted Revenue at T2                -> fu2_revenue
#fu3_sales_lm       CPI adjusted Revenue at T3                -> fu3_revenue
#fu4_sales_lm       CPI adjusted Revenue at T4                -> fu4_revenue
##winsorized##
#win_bl_sales_lm    Winsorized Revenue last month             -> W_bl_revenue
#win_fu1_sales_lm   Winsorized CPI adjusted Revenue at T1     -> W_fu1_revenue
#win_fu2_sales_lm   Winsorized CPI adjusted Revenue at T2     -> W_fu2_revenue
#win_fu3_sales_lm   Winsorized CPI adjusted Revenue at T3     -> W_fu3_revenue
#win_fu4_sales_lm   Winsorized CPI adjusted Revenue at T4     -> W_fu4_revenue
#Indices------------------------------------------------------------------------    
#bl_business_practices      Overall business practices             -> BusPra
#bl_business_practice_miss  Dummy if missing                       -> BusPra_D
#bl_marketing_index         Customer service and marketing         -> Mark
#bl_marketing_index_miss    Dummy if missing                       -> Mark_D
#bl_record_index            Record keeping and fin. management     -> Rec
#bl_record_index_miss       Dummy if missing                       -> Rec_D          
#bl_operations_index        Operations and perf. management pract. -> Oper
#bl_operations_index_miss   Dummy if missing                       -> Oper_D
#bl_information_index       Seeking inform. and new opportunities  -> Inform
#bl_information_index_miss  Dummy if missing                       -> Inform_D
#bl_avg_z_hyp_cs4a          Innovation index                       -> Innov
#bl_avg_z_hyp_cs4a_miss     Dummy if missing                       -> Innov_D
#bl_avg_z_hyp_cs4c          Access to finance                      -> AccFin
#bl_avg_z_hyp_cs4c_miss     Dummy if missing                       -> AccFin_D
#bl_avg_z_hyp_b5            Gender attitudes                       -> GenAtt
#bl_avg_z_hyp_b5_miss       Dummy if missing                       -> GenAtt_D
#bl_avg_z_hyp_cs4e          Networking                             -> Netw
#bl_avg_z_hyp_cs4e_miss     Dummy if missing                       -> Netw_D     
#Other--------------------------------------------------------------------------    
#PI_bl          Personal initiative             -> PersIn
#PI_bl_miss     Dummy if missing                -> PersIn_D
#PFE_bl         Passion for Entrepreneurship    -> PassEnt
#PFE_bl_miss    Dummy if missing                -> PassEnt_D


SA <- data.frame(Risk=master$RT_bl, Risk_D=master$RT_bl_miss, 
                 Female=master$female, ID=master$id_ent,
                 Sector=master$sector,
                 Age_E=master$bl_age,
                 Edu=master$bl_years_schooling,
                 Age_F=master$bl_firm_age,
                 Group=master$assign_group,
                 bl_profits=master$bl_profits_lm,
                 bl_profits_D=master$bl_profits_lm_miss,
                 fu1_profits=master$fu1_profits_lm,
                 fu2_profits=master$fu2_profits_lm,
                 fu3_profits=master$fu3_profits_lm,
                 fu4_profits=master$fu4_profits_lm,
                 W_bl_profits=master$win_bl_profits_lm,
                 W_bl_profits_D=master$win_bl_profits_lm_miss,
                 W_fu1_profits=master$win_fu1_profits_lm,
                 W_fu2_profits=master$win_fu2_profits_lm,
                 W_fu3_profits=master$win_fu3_profits_lm,
                 W_fu4_profits=master$win_fu4_profits_lm,
                 bl_revenue=master$bl_sales_lm,
                 fu1_revenue=master$fu1_sales_lm,
                 fu2_revenue=master$fu2_sales_lm,
                 fu3_revenue=master$fu3_sales_lm,
                 fu4_revenue=master$fu4_sales_lm,
                 W_bl_revenue=master$win_bl_sales_lm,
                 W_fu1_revenue=master$win_fu1_sales_lm,
                 W_fu2_revenue=master$win_fu2_sales_lm,
                 W_fu3_revenue=master$win_fu3_sales_lm,
                 W_fu4_revenue=master$win_fu4_sales_lm,
                 BusPra=master$bl_business_practice,
                 BusPra_D=master$bl_business_practice_miss,
                 Mark=master$bl_marketing_index,
                 Mark_D=master$bl_marketing_index_miss,
                 Rec=master$bl_record_index,
                 Rec_D=master$bl_record_index_miss,
                 Oper=master$bl_operations_index,
                 Oper_D=master$bl_operations_index_miss,
                 Inform=master$bl_information_index,
                 Inform_D=master$bl_information_index_miss,
                 Innov=master$bl_avg_z_hyp_cs4a,
                 Innov_D=master$bl_avg_z_hyp_cs4a_miss,
                 AccFin=master$bl_avg_z_hyp_cs4c,
                 AccFin_D=master$bl_avg_z_hyp_cs4c_miss,
                 GenAtt=master$bl_avg_z_hyp_b5,
                 GenAtt_D=master$bl_avg_z_hyp_b5_miss,
                 Netw=master$bl_avg_z_hyp_cs4e,
                 Netw_D=master$bl_avg_z_hyp_cs4e_miss,
                 PersIn=master$PI_bl,
                 PersIn_D=master$PI_bl_miss,
                 PassEnt=master$PFE_bl,
                 PassEnt_D=master$PFE_bl_miss
                 )

# Variablen umkodieren
SA$bt_D <- ifelse(SA$Group == 1 , 1, 0)

SA$pi_D <- ifelse(SA$Group == 2 , 1, 0)

SA$Group_factor <- factor(SA$Group, levels = c(1,2,3),labels 
           = c("Traditional Business Training", "PI Training", "Control Group"))

SA$Group_factor = relevel (SA$Group_factor, "Control Group")
SA$Group <- NULL
SA <-rename(SA,c(Group_factor="Group"))

SA$Sector_factor <- factor(SA$Sector, levels = c(1,2,3),labels 
                          = c("Produktion", "Handel", "Andere"))
SA$Sector_factor = relevel (SA$Sector_factor, "Andere")
SA$Sector<- NULL
SA<-rename(SA,c(Sector_factor="Sector"))

# Erstellen neuer Variablen für die Regressionen
#Median:
SA$Med_W_profits = rowMedians(as.matrix(SA[,c(16:19)]),na.rm = TRUE)
SA$Med_profits = rowMedians(as.matrix(SA[,c(10:13)]),na.rm = TRUE)
SA$Med_W_revenue= rowMedians(as.matrix(SA[,c(26,27,28,29)]),na.rm = TRUE)
SA$Med_revenue = rowMedians(as.matrix(SA[,c(21,22,23,24)]),na.rm = TRUE)

#Note: Da das Ziel ist möglichst viele Datenpunkte zu erhalten, wurden Missings  
#bei der Berechnung des Medians exludiert. Dies kann durchaus kritisiert werden,
#jedoch könnten beide Versionen zu Verzerrungen führen.


#Differenz:

#Note: Hier hätten wir tatsächlich lieber eine Ratio erstellt. Allerdings bringt
#dies zwei Probleme mit sich: Negative Werte und 0en. Deshalb wurde eine
#Differenz gebildet um diese Probleme zu umgehen.

SA <- mutate(SA, W_profits_Diff = (Med_W_profits - W_bl_profits),
             profits_Diff = (Med_profits - bl_profits),
             revenue_Diff = (Med_revenue - bl_revenue),
             W_revenue_Diff = (Med_W_revenue - W_bl_revenue))

#Dummy Variable for "above the median"
obs_control <- filter (SA, Group == "Control Group")

median(obs_control$W_profits_Diff, na.rm= TRUE)                                 #Median Delta: 4362.523
median(obs_control$profits_Diff, na.rm= TRUE)                                   #Median Delta: 4362.523
median(obs_control$W_revenue_Diff, na.rm= TRUE)                                 #Median Delta: 4144.686
median(obs_control$revenue_Diff, na.rm= TRUE)                                   #Median Delta: 4144.685

SA$successful_W_profits <- ifelse(SA$W_profits_Diff>4362.523,1,0)
SA$successful_profits <- ifelse(SA$profits_Diff>4362.523,1,0)
SA$successful_W_revenue <- ifelse(SA$W_revenue_Diff>4144.686,1,0)
SA$successful_revenue <- ifelse(SA$revenue_Diff>4144.685,1,0)

# Variablen Label
var_label(SA$Risk) <-  "Risk attitude - Diskrete/Ordinal - [1:8]"
var_label(SA$Risk_D) <- "Dummy variable if Risk is missing"
var_label(SA$Female) <- "Dummy variable for female"
var_label(SA$ID) <- "Company ID"
var_label(SA$Group) <- "Entrepreneur's Group"
var_label(SA$Sector) <- "Sector"
var_label(SA$Age_E) <- "Age of respondent"
var_label(SA$Edu) <- "Average years of education"
var_label(SA$Age_F) <- "Age of firm (years)"
var_label(SA$bl_profits) <- "Profits last month "
var_label(SA$bl_profits_D) <- "Dummy if missing"
var_label(SA$fu1_profits) <- "CPI adjusted Profits at T1 "
var_label(SA$fu2_profits) <- "CPI adjusted Profits at T2"
var_label(SA$fu3_profits) <- "CPI adjusted Profits at T3"
var_label(SA$fu4_profits) <- "CPI adjusted Profits at T4"
var_label(SA$W_bl_profits) <- "Winsorized Profits last month"
var_label(SA$W_bl_profits_D) <- "Dummy if missing"
var_label(SA$W_fu1_profits) <- "Winsorized CPI adjusted Profits at T1"
var_label(SA$W_fu2_profits) <- "Winsorized CPI adjusted Profits at T2"
var_label(SA$W_fu3_profits) <- "Winsorized CPI adjusted Profits at T3"
var_label(SA$W_fu4_profits) <- "Winsorized CPI adjusted Profits at T4"
var_label(SA$bl_revenue) <- "Revenue last month "
var_label(SA$fu1_revenue) <- "CPI adjusted Revenue at T1 "
var_label(SA$fu2_revenue) <- "CPI adjusted Revenue at T2"
var_label(SA$fu3_revenue) <- "CPI adjusted Revenue at T3"
var_label(SA$fu4_revenue) <- "CPI adjusted Revenue at T4"
var_label(SA$W_bl_revenue) <- "Winsorized Revenue last month"
var_label(SA$W_fu1_revenue) <- "Winsorized CPI adjusted Revenue at T1"
var_label(SA$W_fu2_revenue) <- "Winsorized CPI adjusted Revenue at T2"
var_label(SA$W_fu3_revenue) <- "Winsorized CPI adjusted Revenue at T3"
var_label(SA$W_fu4_revenue) <- "Winsorized CPI adjusted Revenue at T4"
var_label(SA$BusPra) <- "Overall business practices"
var_label(SA$BusPra_D) <- "Dummy if missing"
var_label(SA$Mark) <- "Customer service and marketing"
var_label(SA$Mark_D) <- "Dummy if missing"
var_label(SA$Rec) <- "Record keeping and financial management"
var_label(SA$Rec_D) <- "Dummy if missing"
var_label(SA$Oper) <- "Operations and performance management practices"       
var_label(SA$Oper_D) <- "Dummy if missing"
var_label(SA$Inform) <- "Seeking information and new opportunities"
var_label(SA$Inform_D) <- "Dummy if missing"
var_label(SA$Innov) <- "Innovation index"
var_label(SA$Innov_D) <- "Dummy if missing"
var_label(SA$AccFin) <- "Access to finance"
var_label(SA$AccFin_D) <- "Dummy if missing"
var_label(SA$GenAtt) <- "Gender attitudes"
var_label(SA$GenAtt_D) <- "Dummy if missing"
var_label(SA$Netw) <- "Networking"
var_label(SA$Netw_D) <- "Dummy if missing"
var_label(SA$PersIn) <- "Personal Initiative"
var_label(SA$PersIn_D) <- "Dummy if missing"
var_label(SA$PassEnt) <- "Passion for Entrepreneurship"
var_label(SA$PassEnt_D) <- "Dummy if missing"
var_label(SA$Med_W_profits) <- "Median Profits FU winsorized"
var_label(SA$Med_profits) <- "Median Profits FU"
var_label(SA$Med_W_revenue) <- "Median Revenue FU winsorized"
var_label(SA$Med_revenue) <- "Median Revenue FU"
var_label(SA$W_profits_Diff) <- "Diff between Median Profits FU and BL winsorized"
var_label(SA$W_revenue_Diff) <- "Diff between Median Revenue FU and BL winsorized"
var_label(SA$profits_Diff) <- "Diff between Median Profits FU and BL"
var_label(SA$revenue_Diff) <- "Diff between Median Revenue FU and BL"
var_label(SA$successful_W_profits) <- "Above the Median Profit Difference winsorized"
var_label(SA$successful_profits) <- "Above the Median Profit Difference"
var_label(SA$successful_W_revenue) <- "Above the Median Revenue Difference winsorized"
var_label(SA$successful_revenue) <- "Above the Median Revenue Difference"
var_label(SA$pi_D) <- "Dummy for PI Training"
var_label(SA$bt_D) <- "Dummy for Traditional Business Training"

# Subdatensätze

#Missings
sapply(SA, function(x) sum(is.na(x)))                                             

SA <- filter (SA, Risk_D == 0, bl_profits_D == 0,
              BusPra_D == 0, Mark_D == 0, Rec_D == 0, Oper_D == 0,
              Inform_D == 0, Innov_D == 0, AccFin_D == 0, GenAtt_D == 0)

SA <- filter(SA,!is.na(SA$Med_W_revenue))                                       #8 Missings bei Profits & Revenue rauswerfen

#Filter
obs_female <- filter(SA, Female == 1)                                               
obs_bt <- filter(SA, Group == "Traditional Business Training")
obs_pi <- filter(SA, Group == "PI Training")
obs_control <- filter (SA, Group == "Control Group")

obs_bt_control <- filter(SA,Group != "PI Training")
obs_pi_control <- filter(SA,Group != "Traditional Business Training")


controls <- subset(SA, select = c(Risk, Age_E, Edu, Age_F, BusPra, Mark, Rec,
                                  Oper, Inform, Innov, AccFin, GenAtt, Netw,
                                  PersIn, PassEnt))                                  
                                                                                     
relevant <- subset(SA, select = c(pi_D, bt_D, Med_W_profits, Med_W_revenue, 
                                  W_profits_Diff, W_revenue_Diff, 
                                  successful_W_profits, successful_W_revenue,
                                  Risk, Female, Age_E))                                                                                     
                                            

relevantb <- subset(obs_bt, select = c(pi_D, bt_D, Med_W_profits, Med_W_revenue, 
                                  W_profits_Diff, W_revenue_Diff, 
                                  successful_W_profits, successful_W_revenue,
                                  Risk, Female, Age_E))      

relevantp <- subset(obs_pi, select = c(pi_D, bt_D, Med_W_profits, Med_W_revenue, 
                                      W_profits_Diff, W_revenue_Diff, 
                                      successful_W_profits, successful_W_revenue,
                                      Risk, Female, Age_E))      

relevantc <- subset(obs_control, select = c(pi_D, bt_D, Med_W_profits, Med_W_revenue, 
                                       W_profits_Diff, W_revenue_Diff, 
                                       successful_W_profits, successful_W_revenue,
                                       Risk, Female, Age_E))    
################################################################################
#### 2 Deskriptive Analyse #####################################################
################################################################################

### Deskriptive Aufarbeitung des Datensatzes

## 2.1 Deskriptive Auswertung der relevanten Daten
summary(SA)
summary(obs_bt)
summary(obs_pi)
summary(obs_control)

describe(SA$Female)                                                                    
describeBy(SA$Risk, SA$Female)
describeBy(obs_pi$Risk, obs_pi$Female)
describeBy(obs_control$Risk, obs_control$Female)
describeBy(obs_bt$Risk, obs_bt$Female)
describe(SA$Netw)
summary(SA$Netw)

# Output relevanter Tabellen
stargazer(controls)
stargazer(relevant)
stargazer(relevantc)
stargazer(relevantb)
stargazer(relevantp)


# Korrelationen der Kontrollvariablen                                           
cor <- cor(controls, use="complete.obs")                                                  #Ausschluss Vollk. Multikoll.
stargazer(cor)


## 2.2 Graphen 

# Gruppenunterschiede Risiko

describe(obs_bt$Risk)
#mean:  4.68  SD 2.26
describe(obs_pi$Risk)
#mean:  4.85 SD 2,38
describe(obs_control$Risk)
#mean: 4.55 2.32

data <- data.frame(
  name=c(1, 2, 3),
  value=c(4.53, 4.68, 4.85),
  sd=c(2.34, 2.26,2.38)
)

data$name <- factor(data$name, levels = c(1,2,3),labels 
                          = c("Kontrollgruppe","TB", "PI"))

pdf(file="C:/Users/Fynn/Desktop/LaTex/Tabea/Risk.pdf")                          ################## Hier ANPASSEN, sonst Fehlermeldung ###################################

ggplot(data, aes(fill=name)) +
  geom_bar( aes(x=name, y=value), stat="identity", alpha=1.2, 
                 color = "black", width=0.7) +
  geom_errorbar( aes(x=name, ymin=value-sd, ymax=value+sd), width=0.3, 
                 color="black", alpha=0.6, size=0.8)+
  ggtitle("Risikoneigung der Unternehmer:innen \n nach Art des Trainings") +
  xlab("Art des Trainings") + ylab("Mittelwert Risikoneigung")  + theme_bw() +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) +
  theme(text = element_text(size = 16)) 

dev.off()

# Proits - time course

time <- data_frame(
  ProfitsF= c(median(SA$W_bl_profits, na.rm= TRUE ),
              median(SA$W_fu1_profits, na.rm= TRUE ),
              median(SA$W_fu2_profits, na.rm= TRUE ),
              median(SA$W_fu3_profits, na.rm= TRUE ),
              median(SA$W_fu4_profits, na.rm= TRUE )),
  Time= c("1","2","3","4","5"),
  ProfitsC= c(median(obs_control$W_bl_profits, na.rm= TRUE ),
              median(obs_control$W_fu1_profits, na.rm= TRUE ),
              median(obs_control$W_fu2_profits, na.rm= TRUE ),
              median(obs_control$W_fu3_profits, na.rm= TRUE ),
              median(obs_control$W_fu4_profits, na.rm= TRUE )),
  ProfitsB= c(median(obs_bt$W_bl_profits, na.rm= TRUE ),
              median(obs_bt$W_fu1_profits, na.rm= TRUE ),
              median(obs_bt$W_fu2_profits, na.rm= TRUE ),
              median(obs_bt$W_fu3_profits, na.rm= TRUE ),
              median(obs_bt$W_fu4_profits, na.rm= TRUE )),
  ProfitsPI= c(median(obs_pi$W_bl_profits, na.rm= TRUE ),
              median(obs_pi$W_fu1_profits, na.rm= TRUE ),
              median(obs_pi$W_fu2_profits, na.rm= TRUE ),
              median(obs_pi$W_fu3_profits, na.rm= TRUE ),
              median(obs_pi$W_fu4_profits, na.rm= TRUE ))
)


time$Time <- factor(time$Time, levels = c(1,2,3,4,5),labels 
                    = c("BL","FU1","FU2", "FU3", "FU4"))
colors <- c("Business Training" = "darkred", "Kontrollgruppe" = "orange", 
            "PI Training" = "steelblue", "Insgesamt" = "black")

pdf(file="C:/Users/Fynn/Desktop/LaTex/Tabea/Time1.pdf", width=10,height=5)       ################## Hier ANPASSEN, sonst Fehlermeldung ###################################

 ggplot(time, aes(x=Time, group=4)) +
      geom_line(aes(y = ProfitsB, color = "TB Training"),  stat="identity",
                         linetype = 2,lwd = 1.025, alpha = 0.9) + 
               geom_point(aes(y = ProfitsB), color = "darkred", size=2 ) +
   
      geom_line(aes(y = ProfitsPI, color="PI Training"),  stat="identity",
                         linetype = 2, lwd = 1.025, alpha = 0.9)+
               geom_point(aes(y = ProfitsPI), color = "steelblue", size=2 )+
               
      geom_line(aes(y = ProfitsC, color="Kontrollgruppe"),  stat="identity", 
                         linetype = 2, lwd = 1.025, alpha = 0.9) +
               geom_point(aes(y = ProfitsC), color = "orange", size=2 )+
   
      geom_line(aes(y = ProfitsF, color="Insgesamt"),  stat="identity", 
                         lwd = 1.3) + theme_bw() +
               geom_point(aes(y = ProfitsF), color = "black", size=2 )+
   
                labs(x = "Zeitpunkt",
                y = "Median-Gewinn (In CFA)",
                color = "Legende") +
                scale_color_manual(values = colors)+
                 ggtitle("Median-Gewinn im Zeitverlauf") +
   
      theme(legend.position = "bottom", plot.title = element_text(hjust = 0.5)) +
      theme(text = element_text(size = 16)) + 
      scale_y_continuous(labels=function(x) format(x, big.mark = ","))
               
dev.off()

# Unterschied Median und Mittelwert

time <- data_frame(
  ProfitsF= c(mean(SA$W_bl_profits, na.rm= TRUE ),
              mean(SA$W_fu1_profits, na.rm= TRUE ),
              mean(SA$W_fu2_profits, na.rm= TRUE ),
              mean(SA$W_fu3_profits, na.rm= TRUE ),
              mean(SA$W_fu4_profits, na.rm= TRUE )),
  Time= c("1","2","3","4","5"),
  ProfitsC= c(mean(obs_control$W_bl_profits, na.rm= TRUE ),
              mean(obs_control$W_fu1_profits, na.rm= TRUE ),
              mean(obs_control$W_fu2_profits, na.rm= TRUE ),
              mean(obs_control$W_fu3_profits, na.rm= TRUE ),
              mean(obs_control$W_fu4_profits, na.rm= TRUE )),
  ProfitsB= c(mean(obs_bt$W_bl_profits, na.rm= TRUE ),
              mean(obs_bt$W_fu1_profits, na.rm= TRUE ),
              mean(obs_bt$W_fu2_profits, na.rm= TRUE ),
              mean(obs_bt$W_fu3_profits, na.rm= TRUE ),
              mean(obs_bt$W_fu4_profits, na.rm= TRUE )),
  ProfitsPI= c(mean(obs_pi$W_bl_profits, na.rm= TRUE ),
               mean(obs_pi$W_fu1_profits, na.rm= TRUE ),
               mean(obs_pi$W_fu2_profits, na.rm= TRUE ),
               mean(obs_pi$W_fu3_profits, na.rm= TRUE ),
               mean(obs_pi$W_fu4_profits, na.rm= TRUE ))
)

time$Time <- factor(time$Time, levels = c(1,2,3,4,5),labels 
                    = c("BL","FU1","FU2", "FU3", "FU4"))
colors <- c("TB Training" = "darkred", "Kontrollgruppe" = "orange", 
            "PI Training" = "steelblue", "Insgesamt" = "black")

pdf(file="C:/Users/Fynn/Desktop/LaTex/Tabea/Time2.pdf", width=10,height=5)       ################## Hier ANPASSEN, sonst Fehlermeldung ###################################

ggplot(time, aes(x=Time, group=4)) +
  geom_line(aes(y = ProfitsB, color = "TB Training"),  stat="identity",
            linetype = 2,lwd = 1.025, alpha = 0.9) + 
  geom_point(aes(y = ProfitsB), color = "darkred", size=2 ) +
  
  geom_line(aes(y = ProfitsPI, color="PI Training"),  stat="identity",
            linetype = 2, lwd = 1.025, alpha = 0.9)+
  geom_point(aes(y = ProfitsPI), color = "steelblue", size=2 )+
  
  geom_line(aes(y = ProfitsC, color="Kontrollgruppe"),  stat="identity", 
            linetype = 2, lwd = 1.025, alpha = 0.9) +
  geom_point(aes(y = ProfitsC), color = "orange", size=2 )+
  
  geom_line(aes(y = ProfitsF, color="Insgesamt"),  stat="identity", 
            lwd = 1.3) + theme_bw() +
  geom_point(aes(y = ProfitsF), color = "black", size=2 )+
  
  labs(x = "Zeitpunkt",
       y = "Mittelwert Gewinn (in CFA)",
       color = "Legende") +
  scale_color_manual(values = colors)+
  ggtitle("Mittlerer Gewinn im Zeitverlauf") +
  
  theme(legend.position = "bottom", plot.title = element_text(hjust = 0.5)) +
  theme(text = element_text(size = 16))+ 
  scale_y_continuous(labels=function(x) format(x, big.mark = ","))

dev.off()


# Revenue - time course

time <- data_frame(
  ProfitsF= c(median(SA$W_bl_revenue, na.rm= TRUE ),
              median(SA$W_fu1_revenue, na.rm= TRUE ),
              median(SA$W_fu2_revenue, na.rm= TRUE ),
              median(SA$W_fu3_revenue, na.rm= TRUE ),
              median(SA$W_fu4_revenue, na.rm= TRUE )),
  Time= c("1","2","3","4","5"),
  ProfitsC= c(median(obs_control$W_bl_revenue, na.rm= TRUE ),
              median(obs_control$W_fu1_revenue, na.rm= TRUE ),
              median(obs_control$W_fu2_revenue, na.rm= TRUE ),
              median(obs_control$W_fu3_revenue, na.rm= TRUE ),
              median(obs_control$W_fu4_revenue, na.rm= TRUE )),
  ProfitsB= c(median(obs_bt$W_bl_revenue, na.rm= TRUE ),
              median(obs_bt$W_fu1_revenue, na.rm= TRUE ),
              median(obs_bt$W_fu2_revenue, na.rm= TRUE ),
              median(obs_bt$W_fu3_revenue, na.rm= TRUE ),
              median(obs_bt$W_fu4_revenue, na.rm= TRUE )),
  ProfitsPI= c(median(obs_pi$W_bl_revenue, na.rm= TRUE ),
               median(obs_pi$W_fu1_revenue, na.rm= TRUE ),
               median(obs_pi$W_fu2_revenue, na.rm= TRUE ),
               median(obs_pi$W_fu3_revenue, na.rm= TRUE ),
               median(obs_pi$W_fu4_revenue, na.rm= TRUE ))
)


time$Time <- factor(time$Time, levels = c(1,2,3,4,5),labels 
                    = c("BL","FU1","FU2", "FU3", "FU4"))
colors <- c("TB Training" = "darkred", "Kontrollgruppe" = "orange", 
            "PI Training" = "steelblue", "Insgesamt" = "black")

pdf(file="C:/Users/Fynn/Desktop/LaTex/Tabea/Time3.pdf", width=10,height=5)       ################## Hier ANPASSEN, sonst Fehlermeldung ###################################

ggplot(time, aes(x=Time, group=4)) +
  geom_line(aes(y = ProfitsB, color = "TB Training"),  stat="identity",
            linetype = 2,lwd = 1.025, alpha = 0.9) + 
  geom_point(aes(y = ProfitsB), color = "darkred", size=2 ) +
  
  geom_line(aes(y = ProfitsPI, color="PI Training"),  stat="identity",
            linetype = 2, lwd = 1.025, alpha = 0.9)+
  geom_point(aes(y = ProfitsPI), color = "steelblue", size=2 )+
  
  geom_line(aes(y = ProfitsC, color="Kontrollgruppe"),  stat="identity", 
            linetype = 2, lwd = 1.025, alpha = 0.9) +
  geom_point(aes(y = ProfitsC), color = "orange", size=2 )+
  
  geom_line(aes(y = ProfitsF, color="Insgesamt"),  stat="identity", 
            lwd = 1.3) + theme_bw() +
  geom_point(aes(y = ProfitsF), color = "black", size=2 )+
  
  labs(x = "Zeitpunkt",
       y = "Median-Umsatz (In CFA)",
       color = "Legende") +
  scale_color_manual(values = colors)+
  ggtitle("Median-Umsatz im Zeitverlauf") +
  
  theme(legend.position = "bottom", plot.title = element_text(hjust = 0.5)) +
  theme(text = element_text(size = 16)) + 
  scale_y_continuous(labels=function(x) format(x, big.mark = ","))

dev.off()

################################################################################
#### 3 Induktive Analyse #######################################################
################################################################################

### Induktives Testen der Hypothesen 

#Note: Im Folgenden verwenden wir die HC1 Standard Errors, auch "Stata" Errors
#gennant, da diese die größte Replizierbarkeit über verschiedene Programme hinaus
#besitzen. Näheres dazu in Fußnote 1, S. 12.                                              

## 3.1 Hypothese I 

# 3.1.1 Replikation

# Lineare Regression ohne Kontrollvariablen

OLS_Med_Profits_A = lm_robust(Med_W_profits ~ Group, data = SA, se_type = "stata")
tidy(OLS_Med_Profits_A , conf.int = TRUE)

OLS <- lm(Med_W_profits ~ Group, data = SA)
tidy(OLS)

OLS_Med_Revenue_A = lm_robust(Med_W_revenue ~ Group, data = SA, se_type = "stata")
tidy(OLS_Med_Revenue_A, conf.int = TRUE)

summary(OLS_Med_Profits_A )
summary(OLS_Med_Revenue_A)

# Lineare Regression mit Kontrollvariablen                                        # Sales und Profits nicht als KV, Multikoll.
                                                                                  
# KV für allgemeine Merkmale der Unternehmer*innen

OLS_Med_Profits_B = lm_robust(Med_W_profits ~ Group + Risk + Female, data = SA,
                 se_type = "stata")
tidy(OLS_Med_Profits_B , conf.int = TRUE)

OLS_Med_Revenue_B = lm_robust(Med_W_revenue ~ Group + Risk + Female, data = SA,
                 se_type = "stata")
tidy(OLS_Med_Revenue_B, conf.int = TRUE)

# KV für Eigenschaften der Unternehmer*innen

OLS_Med_Profits_C  = lm_robust(Med_W_profits ~ Group + Risk + Female + Age_E + 
                                 Edu + PersIn + PassEnt +  GenAtt, data = SA, 
                               se_type = "stata")
tidy(OLS_Med_Profits_C , conf.int = TRUE)

OLS_Med_Revenue_C= lm_robust(Med_W_revenue ~ Group + Risk + Female + Age_E + Edu + 
                               PersIn + PassEnt +  GenAtt, data = SA, 
                             se_type = "stata")

tidy(OLS_Med_Revenue_C, conf.int = TRUE)

# KV für Eigenschaften der Unternehmen

OLS_Med_Profits_D  = lm_robust(Med_W_profits ~ Group + Risk + Female + Sector +
                                 Age_E + Edu + Age_F + PersIn + PassEnt +  
                                 GenAtt + BusPra + Mark + Rec + Oper + Inform +
                                Innov + AccFin + Netw, data = SA,
                                se_type = "stata")


tidy(OLS_Med_Profits_D , conf.int = TRUE)

OLS_Med_Revenue_D = lm_robust(Med_W_revenue ~ Group + Risk + Female + Sector + 
                   Age_E + Edu + Age_F + PersIn + PassEnt +  GenAtt + BusPra +
                   Mark + Rec + Oper + Inform + Innov + AccFin + Netw, data = SA,
                 se_type = "stata")
tidy(OLS_Med_Revenue_D, conf.int = TRUE)

summary(OLS_Med_Profits_B)
summary(OLS_Med_Revenue_B)
summary(OLS_Med_Profits_C)
summary(OLS_Med_Revenue_C)
summary(OLS_Med_Profits_D)
summary(OLS_Med_Revenue_D)

##3.1.2 Abwandlung

OLS_Profits_Diff = lm_robust(W_profits_Diff ~ Group + Risk + Female + Sector +  
                               Age_E + Edu + Age_F + PersIn + PassEnt +  GenAtt + 
                               BusPra + Mark + Rec+ Oper + Inform + Innov + 
                               AccFin + Netw, data = SA,
                 se_type = "stata")

tidy(OLS_Profits_Diff, conf.int = TRUE)

OLS_Revenues_Diff = lm_robust(W_revenue_Diff ~ Group + Risk + Female + Sector + 
                                Age_E + Edu + Age_F + PersIn + PassEnt +  
                                GenAtt + BusPra + Mark + Rec + Oper + Inform + 
                                Innov + AccFin + Netw, data = SA,
                 se_type = "stata")

tidy(OLS_Revenues_Diff, conf.int = TRUE)

summary(OLS_Profits_Diff)
summary(OLS_Revenues_Diff)


#3.1.3 Robustheitschecks                                                                

# OLS Regression

OLS_1 = lm_robust(successful_W_profits ~ Group, data = SA, se_type = "stata")
tidy(OLS_1, conf.int = TRUE)


OLS_1_Controls_A= lm_robust(successful_W_profits ~ Group + as.factor(Risk) +
                            as.factor(Female) + Age_E + Edu + PersIn + PassEnt 
                              , data = SA, se_type = "stata")
tidy(OLS_1_Controls_A, conf.int = TRUE)


OLS_1_Controls_B= lm_robust(successful_W_profits ~ Group + as.factor(Risk) +
                              as.factor(Female) + + Age_E + Edu + PersIn + 
                              PassEnt +  GenAtt, data = SA, se_type = "stata")
tidy(OLS_1_Controls_B, conf.int = TRUE)

OLS_1_Controls_C= lm_robust(successful_W_profits ~ Group + as.factor(Risk) +
                              as.factor(Female) + Age_E + Edu + PersIn + 
                              PassEnt +  GenAtt + BusPra + Mark + Rec + Oper +
                              Inform + Innov + AccFin + GenAtt + Netw + Sector, 
                            data = SA, se_type = "stata")
tidy(OLS_1_Controls_C, conf.int = TRUE)

summary(OLS_1_Controls_A)
summary(OLS_1_Controls_B)
summary(OLS_1_Controls_C)

# Logit

Logit_1 = glm(successful_W_profits ~ Group, family = binomial, data = SA)
summary(Logit_1)

margins_1 = margins(Logit_1)
tidy (margins_1, conf.int = TRUE)

Logit_2 = glm(successful_W_profits ~ Group + as.factor(Risk) +
                              as.factor(Female) + Age_E + Edu + PersIn + 
                              PassEnt +  GenAtt + BusPra + Mark + Rec + Oper +
                              Inform + Innov + AccFin + GenAtt + Netw + Sector, 
                            family = binomial, data = SA)

pR2(Logit_1)
pR2(Logit_2)
margins_2 = margins(Logit_2)
tidy (margins_2, conf.int = TRUE)
summary(margins_2) 

#Note: Leichte Unterschiede zwischen Logit und OLS, keine Anzeichen auf Probleme
#bzgl. der Axiome von Kolmogorv

#Winsorized vs. non Winsorized
summary(OLS_Med_Profits_A )
OLS_Med_Profits_A_TEST = lm_robust(Med_profits ~ Group, data = SA, se_type = "stata")
summary(OLS_Med_Profits_A_TEST)

summary(cbind(SA$Med_profits,SA$Med_W_profits))

#Winsorized > Non Winsorized, aufgrund Annahme schwacher Exogenität
#Ergebnisse unterstützen diese Entscheidung

## 3.2 Hypothese II

# 3.2.2 Moderationseffekt in PI Training
# Controls: Gender Age 


#Version A: PROFITS
obs_pi_control$Risky <- ifelse(obs_pi_control$Risk>4,1,0)                       
obs_pi_control$Risky.c <- scale(obs_pi_control$Risky, scale= FALSE) 
obs_pi_control$pi.c <- scale(obs_pi_control$pi_D, scale= FALSE) 
obs_pi_control$Risky_x_PI.c <- obs_pi_control$Risky.c * obs_pi_control$pi.c

Moderator1A <- lm( obs_pi_control$successful_W_profits ~  obs_pi_control$Risky.c + 
                     obs_pi_control$pi.c + obs_pi_control$Female + 
                     obs_pi_control$Age_E)          
summary(Moderator1A)     

Moderator1B <- lm(obs_pi_control$successful_W_profits ~ obs_pi_control$Risky.c +
                    obs_pi_control$pi.c + obs_pi_control$Risky_x_PI.c +
                    obs_pi_control$Female + obs_pi_control$Age_E)
summary(Moderator1B)

describe(cbind(obs_pi_control$pi.c, obs_pi_control$Risky.c))                      #Bereits hier Keine Signifikaten Ergebnisse

# Simple Slope Analyse
obs_pi_control$Risky.c_h <- obs_pi_control$Risky.c - (0.5)                                  
obs_pi_control$Risky.c_l <- obs_pi_control$Risky.c + (0.5)  
obs_pi_control$Risky_x_PI.c_h <- obs_pi_control$Risky.c_h * obs_pi_control$pi.c
obs_pi_control$Risky_x_PI.c_l <- obs_pi_control$Risky.c_l * obs_pi_control$pi.c

Moderator1C <- lm(obs_pi_control$successful_W_profits ~ obs_pi_control$Risky.c +
                 obs_pi_control$pi.c + obs_pi_control$Risky_x_PI.c_h +
                 obs_pi_control$Female + obs_pi_control$Age_E)
summary(Moderator1C)


Moderator1D <- lm(obs_pi_control$successful_W_profits ~ obs_pi_control$Risky.c +
                    obs_pi_control$pi.c + obs_pi_control$Risky_x_PI.c_l +
                    obs_pi_control$Female + obs_pi_control$Age_E)
summary(Moderator1D)


#Version B: REVENUE

Moderator2A <- lm( obs_pi_control$successful_W_revenue ~ obs_pi_control$Risky.c + 
                     obs_pi_control$pi.c + obs_pi_control$Female + 
                     obs_pi_control$Age_E)          
summary(Moderator2A)     

Moderator2B <- lm(obs_pi_control$successful_W_revenue ~ obs_pi_control$Risky.c +
                    obs_pi_control$pi.c + obs_pi_control$Risky_x_PI.c +
                    obs_pi_control$Female + obs_pi_control$Age_E)
summary(Moderator2B)

describe(cbind(obs_pi_control$pi.c, obs_pi_control$Risky.c))                      

# Simple Slope Analyse

Moderator2C <- lm(obs_pi_control$successful_W_revenue ~ obs_pi_control$Risky.c +
                    obs_pi_control$pi.c + obs_pi_control$Risky_x_PI.c_h +
                    obs_pi_control$Female + obs_pi_control$Age_E)
summary(Moderator2C)


Moderator2D <- lm(obs_pi_control$successful_W_revenue ~ obs_pi_control$Risky.c +
                    obs_pi_control$pi.c + obs_pi_control$Risky_x_PI.c_l +
                    obs_pi_control$Female + obs_pi_control$Age_E)
summary(Moderator2D)

# 3.2.2 Moderationseffekt in Business Training
# Controls: Gender Age 

#Version A: PROFITS
obs_bt_control$Risky <- ifelse(obs_bt_control$Risk>4,1,0)                       
obs_bt_control$Risky.c <- scale(obs_bt_control$Risky, scale= FALSE) 
obs_bt_control$bt.c <- scale(obs_bt_control$bt_D, scale= FALSE) 
obs_bt_control$Risky_x_bt.c <- obs_bt_control$Risky.c * obs_bt_control$bt.c

Moderator3A <- lm( obs_bt_control$successful_W_profits ~  obs_bt_control$Risky.c + 
                     obs_bt_control$bt.c + obs_bt_control$Female + 
                     obs_bt_control$Age_E)          
summary(Moderator3A)     

Moderator3B <- lm(obs_bt_control$successful_W_profits ~ obs_bt_control$Risky.c +
                    obs_bt_control$bt.c + obs_bt_control$Risky_x_bt.c +
                    obs_bt_control$Female + obs_bt_control$Age_E)
summary(Moderator3B)

describe(cbind(obs_bt_control$bt.c, obs_bt_control$Risky.c))                      #Bereits hier Keine Signifikaten Ergebnisse

# Simple Slope Analyse
obs_bt_control$Risky.c_h <- obs_bt_control$Risky.c - (0.5)                                  
obs_bt_control$Risky.c_l <- obs_bt_control$Risky.c + (0.5)  
obs_bt_control$Risky_x_bt.c_h <- obs_bt_control$Risky.c_h * obs_bt_control$bt.c
obs_bt_control$Risky_x_bt.c_l <- obs_bt_control$Risky.c_l * obs_bt_control$bt.c

Moderator3C <- lm(obs_bt_control$successful_W_profits ~ obs_bt_control$Risky.c +
                    obs_bt_control$bt.c + obs_bt_control$Risky_x_bt.c_h +
                    obs_bt_control$Female + obs_bt_control$Age_E)
summary(Moderator3C)


Moderator3D <- lm(obs_bt_control$successful_W_profits ~ obs_bt_control$Risky.c +
                    obs_bt_control$bt.c + obs_bt_control$Risky_x_bt.c_l +
                    obs_bt_control$Female + obs_bt_control$Age_E)
summary(Moderator3D)


#Version B: REVENUE

Moderator4A <- lm( obs_bt_control$successful_W_revenue ~  obs_bt_control$Risky.c + 
                     obs_bt_control$bt.c + obs_bt_control$Female + 
                     obs_bt_control$Age_E)
summary(Moderator4A)     

Moderator4B <- lm(obs_bt_control$successful_W_revenue ~ obs_bt_control$Risky.c +
                    obs_bt_control$bt.c + obs_bt_control$Risky_x_bt.c +
                    obs_bt_control$Female + obs_bt_control$Age_E)
summary(Moderator4B)

describe(cbind(obs_bt_control$bt.c, obs_bt_control$Risky.c))                      #Bereits hier Keine Signifikaten Ergebnisse

# Simple Slope Analyse

Moderator4C <- lm(obs_bt_control$successful_W_revenue ~ obs_bt_control$Risky.c +
                    obs_bt_control$bt.c + obs_bt_control$Risky_x_bt.c_h +
                    obs_bt_control$Female + obs_bt_control$Age_E)
summary(Moderator4C)


Moderator4D <- lm(obs_bt_control$successful_W_revenue ~ obs_bt_control$Risky.c +
                    obs_bt_control$bt.c + obs_bt_control$Risky_x_bt.c_l +
                    obs_bt_control$Female + obs_bt_control$Age_E)
summary(Moderator4D)



################################################################################
#### 3 Daten Export ############################################################
################################################################################


#3.1 Ergebnisse

#3.1.1 Hypothese I

# Da lmrobust und stargazer sich nicht "vertragen" müssen die Ergebnisse manuell
# exportiert/erstellt werden.

output <- lm(Med_W_profits ~ Group, data = SA)

output2 <- lm(Med_W_profits ~ Group + Risk + Female, data = SA)

output3 <- lm(Med_W_profits ~ Group + Risk + Female + Age_E + Edu + PersIn
              + PassEnt +  GenAtt, data = SA)

output4 <- lm(Med_W_profits ~ Group + Risk + Female + Sector + Age_E + Edu 
              + Age_F + PersIn + PassEnt +  GenAtt + BusPra + Mark + Rec
              + Oper + Inform + Innov + AccFin + Netw, data = SA)

# Adjust standard errors
cov1         <- vcovHC(output, type = "HC1")
cov2         <- vcovHC(output2, type = "HC1")
cov3         <- vcovHC(output3, type = "HC1")
cov4         <- vcovHC(output4, type = "HC1")
robust_se    <- sqrt(diag(cov1))
robust_se2   <- sqrt(diag(cov2))
robust_se3    <- sqrt(diag(cov3))
robust_se4    <- sqrt(diag(cov4))
# Adjust F statistic 
wald_results1 <- waldtest(output, vcov = cov1)  
wald_results2<- waldtest(output2, vcov = cov2)
wald_results3<- waldtest(output3, vcov = cov3)
wald_results4<- waldtest(output4, vcov = cov4)

stargazer(output, output2, output3, output4,
          se        = list(robust_se,robust_se2,robust_se3,robust_se4),
          omit.stat = "f",
          add.lines = list(c("F Statistik ", "3.688**", "6.739***", 
                             "5.099***", "6.793***")))
# Revenue

output <- lm(Med_W_revenue ~ Group, data = SA)

output2 <- lm(Med_W_revenue ~ Group + Risk + Female, data = SA)

output3 <- lm(Med_W_revenue ~ Group + Risk + Female + Age_E + Edu + PersIn
              + PassEnt +  GenAtt, data = SA)

output4 <- lm(Med_W_revenue~ Group + Risk + Female + Sector + Age_E + Edu 
              + Age_F + PersIn + PassEnt +  GenAtt + BusPra + Mark + Rec
              + Oper + Inform + Innov + AccFin + Netw, data = SA)

#Adjust standard errors
cov1         <- vcovHC(output, type = "HC1")
cov2         <- vcovHC(output2, type = "HC1")
cov3         <- vcovHC(output3, type = "HC1")
cov4         <- vcovHC(output4, type = "HC1")
robust_se    <- sqrt(diag(cov1))
robust_se2   <- sqrt(diag(cov2))
robust_se3    <- sqrt(diag(cov3))
robust_se4    <- sqrt(diag(cov4))

#Adjust F statistic 
wald_results1 <- waldtest(output, vcov = cov1)  
wald_results2<- waldtest(output2, vcov = cov2)
wald_results3<- waldtest(output3, vcov = cov3)
wald_results4<- waldtest(output4, vcov = cov4)

stargazer(output, output2, output3, output4,
          se        = list(robust_se,robust_se2,robust_se3,robust_se4),
          omit.stat = "f",
          add.lines = list(c("F Statistik ", "0.441", "2.699***", 
                             "2.699***", "6.768***"))
          )

# Diff

output <- lm(W_profits_Diff ~ Group + Risk + Female + Sector + Age_E + Edu 
             + Age_F + PersIn + PassEnt +  GenAtt + BusPra + Mark + Rec
             + Oper + Inform + Innov + AccFin + Netw, data = SA)

output2 <- lm(W_revenue_Diff ~ Group + Risk + Female + Sector + Age_E + Edu 
             + Age_F + PersIn + PassEnt +  GenAtt + BusPra + Mark + Rec
             + Oper + Inform + Innov + AccFin + Netw, data = SA)



#Adjust standard errors
cov1         <- vcovHC(output, type = "HC1")
cov2         <- vcovHC(output2, type = "HC1")
robust_se    <- sqrt(diag(cov1))
robust_se2   <- sqrt(diag(cov2))

#Adjust F statistic 
wald_results1 <- waldtest(output, vcov = cov1)  
wald_results2<- waldtest(output2, vcov = cov2)


stargazer(output, output2,
          se        = list(robust_se,robust_se2),
          omit.stat = "f",
          add.lines = list(c("F Statistik ", "1.246", "1.259"))
          )

# Robustheitschecks
 output <- lm (successful_W_profits ~ Group, 
              data = SA)
 
 output2 <- lm (successful_W_profits ~ Group + as.factor(Risk) +
                 as.factor(Female) + Age_E + Edu + PersIn + 
                 PassEnt +  GenAtt + BusPra + Mark + Rec + Oper +
                 Inform + Innov + AccFin + GenAtt + Netw + Sector, 
               data = SA)
 
#Adjust standard errors
 cov1         <- vcovHC(output, type = "HC1")
 robust_se    <- sqrt(diag(cov1))
 cov2         <- vcovHC(output2, type = "HC1")
 robust_se    <- sqrt(diag(cov1))
 
 #Adjust F statistic 
 wald_results1 <- waldtest(output, vcov = cov1) 
 wald_results2 <- waldtest(output2, vcov = cov2) 
 
 
 stargazer(output, output2, output3,
           se        = list(robust_se),
           omit.stat = "f",
           add.lines = list(c("F Statistik ", "2.669*", "1.504" ))
            )
 
 
 stargazer(Logit_2)
 
#3.1.2 Hypothese II


stargazer(Moderator1A,Moderator1B,Moderator1C,Moderator1D, 
          title="Moderationseffekt von Risiko auf die Gewinne
          (PI Training)", font.size="footnotesize", align=TRUE)


stargazer(Moderator2A,Moderator2B,Moderator2C,Moderator2D, 
          title="Moderationseffekt von Risiko auf die Umsätze 
          (PI Training)", font.size="footnotesize", align=TRUE)

stargazer(Moderator3A,Moderator3B,Moderator3C,Moderator3D, 
          title="Moderationseffekt von Risiko auf die Gewinne 
          (Business Training)", font.size="footnotesize", align=TRUE)

stargazer(Moderator4A,Moderator4B,Moderator4C,Moderator4D, 
          title="Moderationseffekt von Risiko auf die Umsätze 
          (Business Trainings)", font.size="footnotesize", align=TRUE)






# 3.2 Datensatz für Tabea

saveRDS(SA, file = "Gruppe1_Datensatz.rds")
