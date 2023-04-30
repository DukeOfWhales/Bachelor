//Generate Dataset
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\War Intensity Full Data Set.xlsx", sheet("MEPV2012n") firstrow case(lower) clear

drop scode
drop ccode
drop if ind==0
drop ind
drop intind 
drop intviol 
drop civviol 
drop ethviol
drop inttot
drop civtot
drop actotal 
drop ncivlist
drop nintlist
drop naclist

//Merge with Sanctions Dataset
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Sanction Dataset.dta"

replace arms=0 if arms==.
replace military=0 if military==.
replace trade=0 if trade==.
replace financial=0 if financial==.
replace travel=0 if travel==.
replace other=0 if other==.
replace sender_mult=0 if sender_mult==.

drop if _merge==2

drop _merge

//Merge with GDP growth
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP Growth.dta"

keep if _merge==3 //Keeps the data with an overlap

drop _merge

//Prepare for Regression
egen country_id=group(country) //Desprings variables

xtset country_id year //Tells Stata what is x and t variables

//Find gennemsnittet for nabolandende
generate MeanConflictNeighboor=0
replace MeanConflictNeighboor=totalac/nborder if nborder !=0

//Gennemsnit for Regionen
generate MeanConflictRegion=0
replace MeanConflictRegion=regac/nregion if nregion !=0

//GDPgrowth regression without Government
//xtreg GDPgrowth intwar ethwar civwar MeanConflictRegion arms military trade financial travel other sender_mult i.year, fe 

//Merge with Inflation Data
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Inflation Data.dta"

keep if _merge==3

drop _merge

//Merge with GDP
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP.dta"

keep if _merge==3

drop _merge

//Merge with Government Spending IMF
//merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Government data\Public Finances in Modern History"

//Merge with Government Spending
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Government Spending as Percantage of BNP.dta" 
//

keep if _merge==3

generate Gov=0
replace Gov=Government*GDP/100
generate lGov=log(Gov)

xtreg GDPgrowth lGov intwar L.intwar ethwar civwar MeanConflictNeighboor arms military financial travel other sender_mult i.year, fe

drop _merge

//Merge with Total Import
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Total Import.dta"

keep if _merge==3 //Keeps the data with an overlap

drop _merge

//Merge with Total Export
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Total Exports.dta"

keep if _merge==3

drop _merge

//Merge with Debt
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Debt.dta"

//Merge with Military Spending
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Military Spending.dta"

keep if _merge==3 //Keeps the data with an overlap


//totalac is the total amount of unrest in neighboring countries

tabulate intwar if Debt !=.
tabulate ethwar if Debt !=.
tabulate civwar if Debt !=.


//Preparing Datasets

//Import of goods and services
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Import of Goods and Services.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time TotImp

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Total Import.dta", replace


//Exports of goods and services


//Net Exports
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Net Exports by country.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time NetExp

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Net Exports.dta", replace

//GDP Growth
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP pr. Capita Growth 1.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time GDPgrowth

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP Growth.dta", replace

//GDP per capita constant US dollars
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP per capita constant US.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time GDPpr2015

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP per capita constant US.dta", replace

//Total debt
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Debt levels.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time Debt

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Debt.dta", replace

//Military Spending
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Military Spending.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time Military

generate lMil=log(Military)

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Military Spending.dta", replace

//Inflation Data
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Inflation Data.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time Inf

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Inflation Data.dta", replace

//GDP
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP pr. country.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time GDP

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP.dta", replace

//Trade Openness
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Trade Openness.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time TradeOpenness

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Trade Openness.dta", replace

//Upper secondary education
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Upper secondary School.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time Uppersecondaryschool

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Upper secondary School.dta", replace

//Private Consumption
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Private Consumption pr. capita.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time Consumption

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Consumption.dta", replace

//Gross Capital Formation
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Gross Capital Formation.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time Investment

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Investment.dta", replace

//Life Expectancy at Birth
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Life Expentancy at Birth.xls", sheet("Data") firstrow clear

reshape long time, i(country) j(year)

rename time Lifespan

save "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Lifespan.dta", replace

//Generate variables. Check to see if its systematic which countries lack observations.
sort country year
by country: egen mean_intwar=mean(intwar)
by country: egen mean_civwar=mean(civwar)
by country: egen mean_ethwar=mean(ethwar)

//Checking for wrong names

drop if _merge==3
drop if year<1961
drop if year >2012

//More commands that might be relevant later

collapse (mean) avg_gdp_growth= GDPgrowth, by(CountryCode)

collapse (mean) avg_gdp_growth= GDPgrowth, by(country)

gen hhhh=1
collapse hhh, by(CountryC)
