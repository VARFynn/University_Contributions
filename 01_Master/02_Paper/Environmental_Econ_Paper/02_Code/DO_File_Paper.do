*******************************
*** Env. Econ				***
*** Name: Fynn Lohre		***
*** Matr. Nr.: 202300181	***
*******************************

/*

Title: Bad Air Day: The Influence of Air Pollution on Quarterbacks' Performance 
- Evidence from the NFL

Submission Date: 15/12/2023

Examiner: Prof. Timo Hener

Content:

1 Pre 
2 Preparation of NFL Data 
3 Preparation of Pollution Data
4 Merge and, hence, Creation of Final Data Set
5 Descriptive Statistics
6 Regressions 
7 Robustness Checks 

*/

* -----------------------------------------------------------------------------*	
* 1 Pre *

version 17.0																	// Might be necessary to change minor syntaxes if version < 16, e.g. subinstr was changed by stata corp.
clear all
set more off
set rmsg on
set linesize 255

**** Only this line has to be adjusted ****
global folder "C:\Users\Fynn\Documents\GitHub\University_Contributions\01_Master\02_Paper\Environmental_Econ_Paper"


cd "$folder\02_Code"
global data "$folder\01_Data" 
global figures "$folder\05_Figures"
global tables "$folder\04_Tables"
import excel "$data\Football_Data_FULL.xlsx", ///
sheet("Raw_Data_Scraped_and_Formulars") firstrow

capture log close
log using LOG_File_Paper.log, replace

* -----------------------------------------------------------------------------*	
* 2 Preparation of NFL Data *

* 2.1 Exclusion if Pathway Games
*QBs of Home-Team
drop if (Date == mdy(10, 31, 2010) & inlist(Team, "San Francisco")) ///
       | (Date == mdy(09, 07, 2010) & inlist(Team, "Chicago")) ///
       | (Date == mdy(10, 23, 2011) & inlist(Team, "Chicago")) ///
       | (Date == mdy(10, 30, 2011) & inlist(Team, "Buffalo")) ///
       | (Date == mdy(10, 28, 2012) & inlist(Team, "New England")) ///
       | (Date == mdy(12, 16, 2012) & inlist(Team, "Seattle")) ///
       | (Date == mdy(09, 29, 2013) & inlist(Team, "Minnesota")) ///
       | (Date == mdy(10, 27, 2013) & inlist(Team, "San Francisco")) ///
       | (Date == mdy(12, 01, 2013) & inlist(Team, "Atlanta")) ///
       | (Date == mdy(09, 28, 2014) & inlist(Team, "Miami")) ///
       | (Date == mdy(10, 26, 2014) & inlist(Team, "Detroit")) ///
       | (Date == mdy(11, 09, 2014) & inlist(Team, "Dallas")) ///
       | (Date == mdy(10, 04, 2015) & inlist(Team, "New York")) ///
       | (Date == mdy(10, 25, 2015) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(11, 01, 2015) & inlist(Team, "Kansas")) ///
       | (Date == mdy(10, 02, 2016) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(10, 23, 2016) & inlist(Team, "New York")) ///
       | (Date == mdy(10, 30, 2016) & inlist(Team, "Washington")) ///
       | (Date == mdy(11, 21, 2016) & inlist(Team, "Oakland")) ///
       | (Date == mdy(09, 24, 2017) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(10, 01, 2017) & inlist(Team, "New Orleans")) ///
       | (Date == mdy(10, 22, 2017) & inlist(Team, "Los Angeles")) ///
       | (Date == mdy(10, 29, 2017) & inlist(Team, "Minnesota")) ///
       | (Date == mdy(11, 19, 2017) & inlist(Team, "New England")) ///
       | (Date == mdy(10, 14, 2018) & inlist(Team, "Seattle")) ///
       | (Date == mdy(10, 21, 2018) & inlist(Team, "Los Angeles")) ///
       | (Date == mdy(10, 28, 2018) & inlist(Team, "Philadelphia")) ///
       | (Date == mdy(11, 19, 2018) & inlist(Team, "Los Angeles")) ///
       | (Date == mdy(08, 13, 2019) & inlist(Team, "Oakland")) ///
       | (Date == mdy(10, 06, 2019) & inlist(Team, "Oakland")) ///
       | (Date == mdy(10, 13, 2019) & inlist(Team, "Carolina")) ///
       | (Date == mdy(10, 27, 2019) & inlist(Team, "Cincinnati")) ///
       | (Date == mdy(11, 03, 2019) & inlist(Team, "Houston")) ///
       | (Date == mdy(11, 18, 2019) & inlist(Team, "Kansas")) ///
       | (Date == mdy(10, 10, 2021) & inlist(Team, "Atlanta")) ///
       | (Date == mdy(10, 17, 2021) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(10, 02, 2022) & inlist(Team, "Minnesota")) ///
       | (Date == mdy(10, 09, 2022) & inlist(Team, "New York")) ///
       | (Date == mdy(10, 30, 2022) & inlist(Team, "Denver")) ///
       | (Date == mdy(11, 13, 2022) & inlist(Team, "Tampa Bay")) ///
       | (Date == mdy(11, 21, 2022) & inlist(Team, "San Francisco")) ///
       | (Date == mdy(10, 01, 2023) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(10, 08, 2023) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(10, 15, 2023) & inlist(Team, "Baltimore"))


*QBs of Away-Team
drop if (Date == mdy(10, 31, 2010) & inlist(Team, "Denver")) ///
       | (Date == mdy(09, 07, 2010) & inlist(Team, "Buffalo")) ///
       | (Date == mdy(10, 23, 2011) & inlist(Team, "Tampa Bay")) ///
       | (Date == mdy(10, 30, 2011) & inlist(Team, "Washington")) ///
       | (Date == mdy(10, 28, 2012) & inlist(Team, "St. Louis")) ///
       | (Date == mdy(12, 16, 2012) & inlist(Team, "Buffalo")) ///
       | (Date == mdy(09, 29, 2013) & inlist(Team, "Pittsburgh")) ///
       | (Date == mdy(10, 27, 2013) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(12, 01, 2013) & inlist(Team, "Buffalo")) ///
       | (Date == mdy(09, 28, 2014) & inlist(Team, "Oakland")) ///
       | (Date == mdy(10, 26, 2014) & inlist(Team, "Atlanta")) ///
       | (Date == mdy(11, 09, 2014) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(10, 04, 2015) & inlist(Team, "Miami")) ///
       | (Date == mdy(10, 25, 2015) & inlist(Team, "Buffalo")) ///
       | (Date == mdy(11, 01, 2015) & inlist(Team, "Detroit")) ///
       | (Date == mdy(10, 02, 2016) & inlist(Team, "Indianapolis")) ///
       | (Date == mdy(10, 23, 2016) & inlist(Team, "Los Angeles")) ///
       | (Date == mdy(10, 30, 2016) & inlist(Team, "Cincinnati")) ///
       | (Date == mdy(11, 21, 2016) & inlist(Team, "Houston")) ///
       | (Date == mdy(09, 24, 2017) & inlist(Team, "Baltimore")) ///
       | (Date == mdy(10, 01, 2017) & inlist(Team, "Miami")) ///
       | (Date == mdy(10, 22, 2017) & inlist(Team, "Arizona")) ///
       | (Date == mdy(10, 29, 2017) & inlist(Team, "Cleveland")) ///
       | (Date == mdy(11, 19, 2017) & inlist(Team, "Oakland")) ///
       | (Date == mdy(10, 14, 2018) & inlist(Team, "Oakland")) ///
       | (Date == mdy(10, 21, 2018) & inlist(Team, "Tennessee")) ///
       | (Date == mdy(10, 28, 2018) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(11, 19, 2018) & inlist(Team, "Kansas")) ///
       | (Date == mdy(08, 13, 2019) & inlist(Team, "Green Bay")) ///
       | (Date == mdy(10, 06, 2019) & inlist(Team, "Chicago")) ///
       | (Date == mdy(10, 13, 2019) & inlist(Team, "Tampa Bay")) ///
       | (Date == mdy(10, 27, 2019) & inlist(Team, "Los Angeles")) ///
       | (Date == mdy(11, 03, 2019) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(11, 18, 2019) & inlist(Team, "Los Angeles (Chargers)")) ///
       | (Date == mdy(10, 10, 2021) & inlist(Team, "New York (Jets)")) ///
       | (Date == mdy(10, 17, 2021) & inlist(Team, "Miami")) ///
       | (Date == mdy(10, 02, 2022) & inlist(Team, "New Orleans")) ///
       | (Date == mdy(10, 09, 2022) & inlist(Team, "Green Bay")) ///
       | (Date == mdy(10, 30, 2022) & inlist(Team, "Jacksonville")) ///
       | (Date == mdy(11, 13, 2022) & inlist(Team, "Seattle")) ///
       | (Date == mdy(11, 21, 2022) & inlist(Team, "Arizona")) ///
       | (Date == mdy(10, 01, 2023) & inlist(Team, "Atlanta")) ///
       | (Date == mdy(10, 08, 2023) & inlist(Team, "Buffalo")) ///
       | (Date == mdy(10, 15, 2023) & inlist(Team, "Tennessee"))

*2.2 Stadion
* Attach Stadion to Place - which is right now only in Team Location
gen Stadion = ""
replace Stadion = "State Farm Stadium" if inlist(Place, "Arizona")
replace Stadion = "Mercedes-Benz Stadium" if inlist(Place, "Atlanta")
replace Stadion = "M&T Bank Stadium" if inlist(Place, "Baltimore")
replace Stadion = "Highmark Stadium" if inlist(Place, "Buffalo")
replace Stadion = "Bank of America Stadium" if inlist(Place, "Carolina")
replace Stadion = "Soldier Field" if inlist(Place, "Chicago")
replace Stadion = "Paul Brown Stadium" if inlist(Place, "Cincinatti")
replace Stadion = "FirstEnergy Stadium" if inlist(Place, "Cleveland")
replace Stadion = "AT&T Stadium" if inlist(Place, "Dallas")
replace Stadion = "Empower Field at Mile High" if inlist(Place, "Denver")
replace Stadion = "Ford Field" if inlist(Place, "Detroit")
replace Stadion = "Lambeau Field" if inlist(Place, "Green Bay")
replace Stadion = "NRG Stadium" if inlist(Place, "Houston")
replace Stadion = "Lucas Oil Stadium" if inlist(Place, "Indianapolis")
replace Stadion = "TIAA Bank Field" if inlist(Place, "Jacksonville")
replace Stadion = "Arrowhead Stadium" if inlist(Place, "Kansas")
replace Stadion = "Allegiant Stadium" if inlist(Place, "Las Vegas")
replace Stadion = "SoFi Stadium" if inlist(Place, "Los Angeles (Chargers)") ///
| inlist(Place, "Los Angeles (Rams)")
replace Stadion = "Hard Rock Stadium" if inlist(Place, "Miami")
replace Stadion = "U.S. Bank Stadium" if inlist(Place, "Minnesota")
replace Stadion = "Gillette Stadium" if inlist(Place, "New England")
replace Stadion = "Caesars Superdome" if inlist(Place, "New Orleans")
replace Stadion = "MetLife Stadium" if inlist(Place, "New York (Giants)") ///
| inlist(Place, "New York (Jets)")
replace Stadion = "Lincoln Financial Field" if inlist(Place, "Philadelphia")
replace Stadion = "Heinz Field" if inlist(Place, "Pittsburgh")
replace Stadion = "Levi's Stadium" if inlist(Place, "San Francisco")
replace Stadion = "Lumen Field" if inlist(Place, "Seattle")
replace Stadion = "Raymond James Stadium" if inlist(Place, "Tampa Bay")
replace Stadion = "Nissan Stadium" if inlist(Place, "Tennesse")
replace Stadion = "FedExField" if inlist(Place, "Washington")
replace Stadion = "Edward Jones Dome" if inlist(Place, "St. Louis")
replace Stadion = "Qualcomm Stadium" if inlist(Place, "San Diego")
replace Stadion = "O.co Coliseum" if inlist(Place, "Oakland")

* Switch to the actual place of the Stadion
gen Place_2 = ""
replace Place_2 = "Glendale, Arizona" if Stadion == "State Farm Stadium"
replace Place_2 = "Atlanta, Georgia" if Stadion == "Mercedes-Benz Stadium"
replace Place_2 = "Baltimore, Maryland" if Stadion == "M&T Bank Stadium"
replace Place_2 = "Orchard Park, New York" if Stadion == "Highmark Stadium"
replace Place_2 = "Charlotte, North Carolina" ///
if Stadion == "Bank of America Stadium"
replace Place_2 = "Chicago, Illinois" if Stadion == "Soldier Field"
replace Place_2 = "Cincinnati, Ohio" if Stadion == "Paul Brown Stadium"
replace Place_2 = "Cleveland, Ohio" if Stadion == "FirstEnergy Stadium"
replace Place_2 = "Arlington, Texas" if Stadion == "AT&T Stadium"
replace Place_2 = "Denver, Colorado" if Stadion == "Empower Field at Mile High"
replace Place_2 = "Detroit, Michigan" if Stadion == "Ford Field"
replace Place_2 = "Green Bay, Wisconsin" if Stadion == "Lambeau Field"
replace Place_2 = "Houston, Texas" if Stadion == "NRG Stadium"
replace Place_2 = "Indianapolis, Indiana" if Stadion == "Lucas Oil Stadium"
replace Place_2 = "Jacksonville, Florida" if Stadion == "TIAA Bank Field"
replace Place_2 = "Kansas City, Missouri" if Stadion == "Arrowhead Stadium"
replace Place_2 = "Paradise, Nevada" if Stadion == "Allegiant Stadium"
replace Place_2 = "Inglewood, California" if Stadion == "SoFi Stadium"
replace Place_2 = "Miami Gardens, Florida" if Stadion == "Hard Rock Stadium"
replace Place_2 = "Minneapolis, Minnesota" if Stadion == "U.S. Bank Stadium"
replace Place_2 = "Foxborough, Massachusetts" if Stadion == "Gillette Stadium"
replace Place_2 = "New Orleans, Louisiana" if Stadion == "Caesars Superdome"
replace Place_2 = "East Rutherford, New Jersey" if Stadion == "MetLife Stadium"
replace Place_2 = "Philadelphia, Pennsylvania" if Stadion == "Lincoln Financial Field"
replace Place_2 = "Pittsburgh, Pennsylvania" if Stadion == "Heinz Field"
replace Place_2 = "Santa Clara, California" if Stadion == "Levi's Stadium"
replace Place_2 = "Seattle, Washington" if Stadion == "Lumen Field"
replace Place_2 = "Tampa, Florida" if Stadion == "Raymond James Stadium"
replace Place_2 = "Nashville, Tennessee" if Stadion == "Nissan Stadium"
replace Place_2 = "Landover, Maryland" if Stadion == "FedExField"
replace Place_2 = "St Louis, Missouri" if Stadion == "Edward Jones Dome"
replace Place_2 = "San Diego, California" if Stadion == "Qualcomm Stadium"
replace Place_2 = "Oakland, California" if Stadion == "O.co Coliseum"

gen exclude = 1																	// needed later for problematic data cases
replace exclude = 0 if Place_2 == "Seattle, Washington"
replace exclude = 0 if Place_2 == "Green Bay, Wisconsin"
replace exclude = 0 if Place_2 == "Foxborough, Massachusetts"

drop Place
rename Place_2 Place

** Insert Info on Rooftype
gen Stadiontype = ""

replace Stadiontype = "Retractable" if Stadion == "AT&T Stadium" ///
									| Stadion == "Hard Rock Stadium" ///
									| Stadion == "Lucas Oil Stadium" ///
									| Stadion == "Lumen Field" ///
									| Stadion == "Mercedes-Benz Stadium" ///
									| Stadion == "SoFi Stadium" ///
									| Stadion == "State Farm Stadium" ///	
									| Stadion == "NRG Stadium" 

replace Stadiontype = "Fixed" if Stadion == "Allegiant Stadium" ///
							| Stadion == "Bank of America Stadium" ///
							| Stadion == "Caesars Superdome" ///
							| Stadion == "Edward Jones Dome" ///
							| Stadion == "Ford Field" ///
							| Stadion == "MetLife Stadium" ///
							| Stadion == "Raymond James Stadium" 

replace Stadiontype = "Open" if Stadion == "Arrowhead Stadium" ///
							| Stadion == "Empower Field at Mile High"  ///
							| Stadion == "FedExField" ///
							| Stadion == "FirstEnergy Stadium" ///
							| Stadion == "Gillette Stadium" ///
							| Stadion == "Heinz Field" ///
							| Stadion == "Highmark Stadium" ///
							| Stadion == "Lambeau Field" ///
							| Stadion == "Levi's Stadium" ///
							| Stadion == "Lincoln Financial Field" ///
							| Stadion == "M&T Bank Stadium" ///
							| Stadion == "Nissan Stadium" ///
							| Stadion == "Paul Brown Stadium" ///
							| Stadion == "Soldier Field" ///
							| Stadion == "TIAA Bank Field" ///
							| Stadion == "U.S. Bank Stadium" ///
							| Stadion == "Qualcomm Stadium" ///
							| Stadion == "O.co Coliseum"

* 2.3 Prepartion for Merge -> Creation of Matching Var with Filenames
split Place, parse(",") gen(Place_Merge)										// split in two vars with , as seperator
gen Place_Merge = subinstr(Place_Merge1, " ", "", .)							// drop blankets -> San Francisco => SanFrancisco
drop Place_Merge1 Place_Merge2				


format Date %td 				
gen DateStr = string(Date)
gen Place_Date_Merge = Place_Merge + "_" + DateStr								// create unifier based on place + date to merge m:1 
drop Place_Merge DateStr

save "$data\Full.dta", replace

* -----------------------------------------------------------------------------*			
* 3 Preparation of Pollution Data *

* 3.1 PM10 Data Preperation
local string_list "Atlanta Arlington Atlanta Baltimore Charlotte Chicago Cincinnati Cleveland Denver Detroit EastRutherford Foxborough Glendale GreenBay Houston Indianapolis Inglewood Jacksonville KansasCity Landover MiamiGardens Minneapolis Nashville NewOrleans Oakland OrchardPark Paradise Philadelphia Pittsburgh SanDiego SantaClara Seattle StLouis Tampa" 

foreach str in `string_list' {	
	import delimited "$data\PM10\PM10_`str'.csv", clear
	drop sitename siteid source mainpollutant									// drop unnecessary
	rename pm10aqivalue pm10													
	gen Date = date(date, "MDY")
	format Date %td 
	drop date
	tset Date																	
	tsfill																		// fill TS with missing dates
	count if missing(pm10)
	ipolate pm10 Date, gen(pm10_ipol)											// linear interpolation of missings (kind of debatable; did it one time with ARIMA; no change)
	drop pm10 
	gen pm10 = round(pm10_ipol, 1)												// round to integers (not needed, also debatable, just a harmonization to AQI Index - also only an integer)
	drop pm10_ipol
	generate Name = "`str'"
	gen DateStr = string(Date)
	gen Place_Date_Merge = Name + "_" + DateStr									// create unifier based on place + date to merge m:1 
	drop Name DateStr Date
	save "$data\PM10\PM10_`str'.dta", replace
}

* 3.2 AQI Data Preparation

foreach str in `string_list' {	
	import delimited "$data\AQI\AQI_`str'.csv", clear
	drop sitename siteid source mainpollutant									// drop unnecessary
	rename aqivalue aqi													
	gen Date = date(date, "MDY")
	format Date %td 
	drop date
	tset Date																	
	tsfill																		// fill TS with missing dates - for AQI nearly no missings
	count if missing(aqi)
	ipolate aqi Date, gen(aqi_ipol)											
	drop aqi 
	gen aqi = round(aqi_ipol, 1)												// round to integers (not needed, also debatable, just a harmonization to AQI Index - also only an integer)
	drop aqi_ipol
	generate Name = "`str'"
	gen DateStr = string(Date)
	gen Place_Date_Merge = Name + "_" + DateStr									// create unifier based on place + date to merge m:1 
	drop Name DateStr Date
	save "$data\AQI\AQI_`str'.dta", replace
}




* 3.3 Weather Data Preparation
local string_list "Atlanta Arlington Atlanta Baltimore Charlotte Chicago Cincinnati Cleveland Denver Detroit EastRutherford Foxborough Glendale GreenBay Houston Indianapolis Inglewood Jacksonville KansasCity Landover MiamiGardens Minneapolis Nashville NewOrleans Oakland OrchardPark Paradise Philadelphia Pittsburgh SanDiego SantaClara Seattle StLouis Tampa" 

foreach str in `string_list' {
	import delimited "$data\Weather\Weather_`str'.csv", clear
	rename pptinches PPT
	rename tmeandegreesf Degree
	gen Date = date(date, "YMD")
	format Date %td 
	drop date
	tset Date
	generate Name = "`str'"
	gen DateStr = string(Date)
	gen Place_Date_Merge = Name + "_" + DateStr
	drop Name DateStr Date
	save "$data\Weather\Weather_`str'.dta", replace
}


* -----------------------------------------------------------------------------*	
* 4 Merge and, hence, Creation of Final Data Set *
* 4.1 PM10 

use "$data\Full.dta", clear
gen PM10 =. 

local string_list "Atlanta Arlington Atlanta Baltimore Charlotte Chicago Cincinnati Cleveland Denver Detroit EastRutherford Foxborough Glendale GreenBay Houston Indianapolis Inglewood Jacksonville KansasCity Landover MiamiGardens Minneapolis Nashville NewOrleans Oakland OrchardPark Paradise Philadelphia Pittsburgh SanDiego SantaClara Seattle StLouis Tampa" 

foreach str in `string_list' {
	merge m:1 Place_Date_Merge using "$data\PM10\PM10_`str'" 
	replace PM10 = pm10 if !missing(pm10)
	drop if _merge == 2
	drop _merge pm10
}

* 4.2 AQI
gen AQI =. 

local string_list "Atlanta Arlington Atlanta Baltimore Charlotte Chicago Cincinnati Cleveland Denver Detroit EastRutherford Foxborough Glendale GreenBay Houston Indianapolis Inglewood Jacksonville KansasCity Landover MiamiGardens Minneapolis Nashville NewOrleans Oakland OrchardPark Paradise Philadelphia Pittsburgh SanDiego SantaClara Seattle StLouis Tampa" 

foreach str in `string_list' {
	merge m:1 Place_Date_Merge using "$data\AQI\AQI_`str'" 
	replace AQI = aqi if !missing(aqi)
	drop if _merge == 2
	drop _merge aqi
}


* 4.3 Weather Data
gen Percipitation = .
gen Temperature = . 

local string_list "Atlanta Arlington Atlanta Baltimore Charlotte Chicago Cincinnati Cleveland Denver Detroit EastRutherford Foxborough Glendale GreenBay Houston Indianapolis Inglewood Jacksonville KansasCity Landover MiamiGardens Minneapolis Nashville NewOrleans Oakland OrchardPark Paradise Philadelphia Pittsburgh SanDiego SantaClara Seattle StLouis Tampa" 

foreach str in `string_list' {
	merge m:1 Place_Date_Merge using "$data\Weather\Weather_`str'" 
	replace Percipitation = PPT if !missing(PPT)
	replace Temperature = Degree if !missing(Degree)
	drop if _merge == 2
	drop _merge PPT Degree
}


* 4.4 final changes

gen Season = year(Date) - cond(month(Date) < 3, 1, 0)
drop if Season == 2023
drop Place_Date_Merge

encode Player, generate(Player_N)
encode Team, generate (Team_N)
encode Opponent, generate (Opponent_N)
encode Stadiontype, generate (Stadiontype_N)

replace PM10 = AQI if PM10 > AQI												// capturing overly estimated values
gen Diff = PM10 - AQI

save "$data\Full.dta", replace
* blocker 																		// to stop running the code here 

* 5 Descriptive Statistics *
*graph box PM10, by(, title(`"PM10 Concentration per Location"')) by(Place, iscale(*0.8))
*graph box Percipitation, by(, title(`"Precipitation per Location"')) by(Place, iscale(*0.8))
*graph box Temperature, by(, title(`"Temperature per Location"')) by(Place, iscale(*0.8))
*graph box Diff, by(, title(`"Difference PM10 and AQI per Location"')) by(Place, iscale(*0.8))
* Disabled for perfomance reasons 

sum Rating Attempts Completion Completion_Percentage Yds INTs INT_Percentage ///
Passing_Sucess_Rate PM10 Percipitation Temperature

bysort Stadiontype: sum Rating Attempts Completion Completion_Percentage Yds ///
INTs INT_Percentage Passing_Sucess_Rate Away PM10 Percipitation Temperature

* 6 Regressions *
*Pre Tests
reg INTs c.PM10#i.Stadiontype_N i.Season i.Player_N i.Opponent_N##Season,vce(robust)

reg INTs c.PM10#i.Stadiontype_N i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

reg INTs c.PM10#i.Stadiontype_N Temperature Percipitation i.Player_N ///
i.Team_N##Season i.Opponent_N##Season,vce(robust)

reg INTs c.PM10#i.Stadiontype_N Attempts Temperature Percipitation i.Player_N ///
i.Team_N##Season i.Opponent_N##Season,vce(robust)

reg Attempts c.PM10#i.Stadiontype_N Temperature Percipitation i.Player_N  ///
i.Team_N##Season i.Opponent_N##Season,vce(robust)

reg INT_Percentage c.PM10#i.Stadiontype_N Temperature Percipitation i.Player_N ///
i.Team_N##Season i.Opponent_N##Season,vce(robust)

reg Rating c.PM10#i.Stadiontype_N Temperature Percipitation i.Player_N ///
 i.Team_N##Season i.Opponent_N##Season,vce(robust)

reg Rating c.PM10#i.Stadiontype_N Attempts Temperature Percipitation ///
i.Player_N i.Team_N##Season i.Opponent_N##Season,vce(robust)

reg TDs c.PM10#i.Stadiontype_N Temperature Percipitation i.Player_N ///
i.Team_N##Season i.Opponent_N##Season,vce(robust)

reg Passing_Sucess_Rate c.PM10#i.Stadiontype_N Temperature Percipitation ///
i.Player_N i.Team_N##Season i.Opponent_N##Season,vce(robust)

reg YA c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

reg Completion_Percentage c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C1
reg Attempts c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C2
reg Yds c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C3
reg INTs c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C4 Success Rate 
reg Passing_Sucess_Rate c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)


*C5
reg INT_Percentage c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C6
reg Rating c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C7 neg, non sg. not yet displayed
reg TDs c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)




* 7 Robustness Checks *
* 7.1 Without 3 Problematic Matching Cases

*C1 still sign
reg Attempts c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season if exclude == 1, vce(robust)

*C2
reg Yds c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season if exclude == 1 ,vce(robust)

*C3
reg INTs c.PM10#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season if exclude == 1, vce(robust)

* 7.2 With AQI General instead of PM10 

*C1 non sg. 
reg Attempts c.AQI#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C2 non sg.
reg Yds c.AQI#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C3 for Fixed highly sq. findings. Could be, that there is some not captured 
reg INTs c.AQI#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C4 Success Rate 
reg Passing_Sucess_Rate c.AQI#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C5
reg INT_Percentage c.AQI#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)

*C6
reg Rating c.AQI#i.Stadiontype_N i.Stadiontype_N#c.Temperature ///
Away i.Stadiontype_N#c.Percipitation i.Player_N i.Team_N##Season ///
i.Opponent_N##Season,vce(robust)



* 7.3 Reproducing Results Equvialent to Jeremy Foreman  

* I will skip this part - they did for yearly data for the home county
* of some QBs a FE Regression neglecting too many aspects 

*However, they used the following code: 
*xtset playerid year
*xtreg intpct l.intpct nflexp gs yearcnt cum_medianaqi, robust
*xtreg qbr l.qbr nflexp gs yearcnt cum_medianaqi, robust
*sum intpct qbr yearcnt nflexp gs cum_medianaqi if e(sample)
*pwcorr intpct qbr yearcnt nflexp gs cum_medianaqi if e(sample), sig


* Just by adding a team fixed effect, every observed effect vanishes....
* However, Many Thanks to @Jeremy for provide the relevant code. 