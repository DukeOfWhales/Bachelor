//Generate Dataset
import excel "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\War Intensity Full Data Set.xlsx", sheet("MEPV2012n") firstrow case(lower) clear

replace country="Timor-Leste" if country=="East Timor"

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


//Merge with Extra War Data
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Extra War Data.dta"

drop if country=="(North) Sudan"

drop _merge

//Generate variabels
gen dcivwar=0
replace dcivwar=1 if civwar>0
gen dintwar=0
replace dintwar=1 if intwar>0
gen dethwar=0
replace dethwar=1 if ethwar>0

count if dintwar==1

label variable dintwar "Interstate Warfare"
label variable dcivwar "Civil Warfare"
label variable dethwar "Ethnic Warfare"

//Merge with Sanctions Dataset
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Sanction Dataset.dta"

replace arms=0 if arms==.
replace military=0 if military==.
replace trade=0 if trade==.
replace financial=0 if financial==.
replace travel=0 if travel==.
replace other=0 if other==.
replace sender_mult=0 if sender_mult==.
replace target_mult=0 if target_mult==.

drop if _merge==2

drop _merge

gen sanction=0 
replace sanction=1 if arms==1 | military==1 | trade==1 | financial==1 | travel==1 | sender_mult==1


label variable arms "arms sanction"
label variable trade "trade sanction"
label variable military "military assistance sanction"
label variable financial "financial sanction"
label variable travel "travel sanction"
label variable other "other sanctions"
label variable target_mult "sanction targets multiple"
label variable sender_mult "sanction has multiple senders"
label variable sanction "US sanction"

//Merge with GDP growth
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP Growth.dta"

//keep if _merge==3 //Keeps the data with an overlap

drop _merge

drop if GDPgrowth==.

label variable GDPgrowth "GDP Growth"

//Merge with GDP pr. capita constant US
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP per capita constant US.dta"

//keep if _merge==3

drop _merge 

gen lGDPpr2015=log(GDPpr2015)

label variable lGDPpr2015 "Log GDP per capita"

//Merge with GDP Ret til constant 2015 US dollars
//merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP.dta"
//keep if _merge==3
//drop _merge

//Merge with Investments
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Investment.dta" 

//keep if _merge==3

drop _merge


//Merge with Economic Freedom
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\EconFreedom.dta"

//keep if _merge==3 //Keeps the data with an overlap

drop _merge

rename economicfreedomsummaryindex EconFreedom

label variable EconFreedom "Economic Freedom"

//Merge with Trade Openness
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Trade Openness.dta"

//keep if _merge==3 //Keeps the data with an overlap

drop _merge

gen Trade=TradeOpenness*GDPpr2015/100
gen lTrade=log(Trade)

label variable lTrade "Log Trade per capita"

//Merge with Government Spending
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Government Spending as Percantage of BNP.dta" 

//keep if _merge==3

drop _merge

generate Gov=Government*GDPpr2015/100
generate lGov=log(Gov)

label variable lGov "Log Government Exp"

//Merge with education levels
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Years of Schooling.dta"

//keep if _merge==3

drop _merge

label variable schooling "Years of Schooling"

//Merge with Lifespan
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Lifespan.dta"

//keep if _merge==3

drop _merge

gen lLifespan=log(Lifespan)

label variable lLifespan "Log Lifespan"

//Merge with Regime Type
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Regimetype.dta"

//keep if _merge==3

drop _merge

label variable Regimetype "Regime Type"


//drop variables
//drop intwar //vil du have tilbage senere. Bruges til at vise intensiteter i datasættet.
drop civwar
drop ethwar
//drop nborder
//drop totint
drop totciv
drop totalac
drop nint
drop nciv
drop nac 
//drop region
//drop nregion
//drop regint
drop regciv
drop regac
drop nrint
drop nrciv
drop nrac

drop rank
drop quartile
drop TradeOpennes

drop if dintwar==.
drop if GDPgrowth==.

//Prepare for Regression
egen country_id=group(country) //Desprings variables

xtset country_id year //Tells Stata what is x and t variables

//Label variables
//label variable MeanConflictNeighboor
//label variable MeanConflictRegion
//label variable MeanWarNeighboor "Mean War Neighbour"
//label variable GovData "Spending data available"

//Run regression Part 1 Control Variables With The Most Observations
qui xtreg GDPgrowth dintwar i.year, fe vce(robust)
eststo r1
esttab r1 using example1.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Only the War Variables\label{tab:1}) replace 

esttab r1, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Only the War Variable\label{tab:1}) replace 

qui xtreg GDPgrowth dintwar dcivwar dethwar i.year, fe vce(robust)
eststo r2
qui xtreg GDPgrowth dintwar lGDPpr2015 i.year, fe vce(robust)
eststo r3
qui xtreg GDPgrowth dintwar lGDPpr2015 sanction i.year, fe vce(robust)
eststo r4
qui xtreg GDPgrowth dintwar lGDPpr2015 lLifespan i.year, fe vce(robust)
eststo r5
qui xtreg GDPgrowth dintwar dcivwar dethwar lGDPpr2015 sanction lLifespan i.year, fe vce(robust)
eststo r6
esttab r2 r3 r4 r5 r6 using GDP.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Control Variables With The Most Observations\label{tab:4}) replace 

esttab r2 r3 r4 r5 r6, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Only the War Variable\label{tab:1}) replace 

qui xtreg GDPgrowth dintwar arms military trade financial travel other sender_mult target_mult i.year, fe vce(robust) 
eststo a1
esttab a1 using sanctions.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(The effect of individual sanctions\label{tab:sanction}) replace 

//Regression part 2 Trade, Investment and Schooling Variables

qui xtreg GDPgrowth dintwar i.year if lTrade!=., fe vce(robust)
eststo r21
qui xtreg GDPgrowth dintwar lTrade i.year, fe vce(robust)
eststo r22
qui xtreg GDPgrowth dintwar Investment i.year, fe vce(robust)
eststo r23
qui xtreg GDPgrowth dintwar schooling i.year if schooling!=., fe vce(robust)
eststo r24
qui xtreg GDPgrowth dintwar lGDPpr2015 lTrade Investment schooling lLifespan i.year, fe vce(robust)
eststo r25
esttab r21 r22 r23 r24 r25 using Trade1.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Trade, Investment and Schooling Variables\label{tab:5}) replace 

//Regression part 3 Government Expenditure and Economic Freedom
qui xtreg GDPgrowth dintwar i.year if lGov!=., fe vce(robust)
eststo r31
qui xtreg GDPgrowth dintwar lGov i.year, fe vce(robust)
eststo r32
qui xtreg GDPgrowth dintwar i.year if EconFreedom!=., fe vce(robust)
eststo r33
qui xtreg GDPgrowth dintwar EconFreedom i.year, fe vce(robust)
eststo r34
qui xtreg GDPgrowth dintwar lTrade Investment schooling lGDPpr2015 lLifespan lGov EconFreedom i.year, fe vce(robust)
eststo r35
esttab r31 r32 r33 r34 r35, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Government Expenditure and Economic Freedom\label{tab:6}) replace 

//Apendix
qui xtreg GDPgrowth dintwar lGDPpr2015 lLifespan i.year if lGov!=., fe vce(robust)
eststo r36
esttab r36 using GovApendix.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Government Expenditure Data\label{tab:GovApendix}) replace 

qui xtreg GDPgrowth dintwar i.year if lGov!=., fe vce(robust)
eststo r31
qui xtreg GDPgrowth dintwar lGov i.year, fe vce(robust)
eststo r32
qui xtreg GDPgrowth dintwar lGov lGDPpr2015 lLifespan i.year, fe vce(robust)
eststo r33
qui xtreg GDPgrowth dintwar i.year if EconFreedom!=., fe vce(robust)
eststo r34
qui xtreg GDPgrowth dintwar L.EconFreedom i.year, fe vce(robust)
eststo r35
qui xtreg GDPgrowth dintwar lTrade Investment schooling lGDPpr2015 lLifespan lGov L.EconFreedom i.year, fe vce(robust)
eststo r36
esttab r31 r32 r33 r34 r35 r36, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Government Expenditure and Economic Freedom\label{tab:6}) replace 

//Part 5 - Spice



//Part 4 - Undlad data
drop if country=="Iran, Islamic Rep."
drop if country=="Iraq"
drop if country=="United States"
drop if country=="Afghanistan"
drop if region==5
drop if region==25
drop if region==50
drop if region==53
drop if region==56

//Drop Africa
drop if region==1 | region==2 | region==3 | region==4 | region==12 | region==14 | region==23 | region==25 | region==41

keep if region==25
keep if region==50
 if region==53
drop if region==56

qui xtreg GDPgrowth dintwar lGDPpr2015 i.year, fe vce(robust)
eststo r15
qui xtreg GDPgrowth dintwar lGDPpr2015 i.year if lTrade!=., fe vce(robust)
eststo r11
qui xtreg GDPgrowth dintwar lGDPpr2015 i.year if Investment!=., fe vce(robust)
eststo r12
qui xtreg GDPgrowth dintwar lGDPpr2015 i.year if lGov!=., fe vce(robust)
eststo r13
qui xtreg GDPgrowth dintwar lGDPpr2015 i.year if EconFreedom!=., fe vce(robust)
eststo r14
esttab r15 r11 r12 r13, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Removing all nations with area in Africa\label{tab:AfricaApendix}) replace 

qui xtreg GDPgrowth dintwar Investment i.year, fe vce(robust)

qui xtreg GDPgrowth dintwar schooling i.year, fe vce(robust)

qui xtreg GDPgrowth dintwar lGov i.year, fe vce(robust)

qui xtreg GDPgrowth dintwar EconFreedom i.year, fe vce(robust)


//Regression Part Selection Effects. Endogeneuity.
//Selection Effects desription
sum GDPgrowth GDPpr2015 sanction Lifespan Trade Investment schooling Gov EconFreedom if dintwar==1

//Selection Effects Regression
qui xtreg dintwar GDPgrowth i.year, fe vce(robust)
eststo Final1
qui xtreg dintwar GDPgrowth lGDPpr2015 i.year, fe vce(robust)
eststo Final111
qui xtreg dintwar EconFreedom i.year, fe vce(robust)
eststo Final2
qui xtreg dintwar lTrade i.year, fe vce(robust)
eststo Final3
qui xtreg dintwar schooling i.year, fe vce(robust)
eststo Final4
qui xtreg dintwar Investment i.year, fe vce(robust)
eststo Final5
qui xtreg dintwar lGDPpr2015 i.year, fe vce(robust)
eststo Final6
qui xtreg dintwar lGov i.year, fe vce(robust)
eststo Final7
qui xtreg dintwar lLifespan i.year, fe vce(robust)
eststo Final8
qui xtreg dintwar dcivwar i.year, fe vce(robust)
eststo Final10
qui xtreg dintwar dethwar i.year, fe vce(robust)
eststo Final11
qui xtreg dintwar GDPgrowth dcivwar dethwar lGDPpr2015 Investment lTrade EconFreedom schooling lGov lLifespan i.year, fe vce(robust)
eststo Final9
qui xtreg dintwar L.GDPgrowth i.year, fe vce(robust)
eststo Final12
qui xtreg dintwar L.lGDPpr2015 i.year, fe vce(robust)
eststo Final13

esttab Final1 Final6 Final111 using Selection.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Selection Effects\label{tab:8}) replace 

esttab Final10 Final11 Final8 Final3 Final5 Final4 Final7 using SelectionApendix.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Selection Effects\label{tab:8}) replace

Final10 Final11 Final12 Final8 Final3 Final5 Final4 Final7 Final2

//Regional Effects
generate SumWarNeighbour=totint-

generate MeanWarNeighbour=totint/nborder if nborder!=0
replace MeanWarNeighbour=totint if nborder==0

generate MeanWarRegion=regint/nregion if nregion!=0
replace MeanWarRegion=regint if nregion==0

qui xtreg GDPgrowth MeanWarNeighbour i.year if dintwar==0, fe vce(robust)
eststo r1
qui xtreg GDPgrowth MeanWarNeighbour lGDPpr2015 lTrade Investment lLifespan i.year if dintwar==0, fe vce(robust)
eststo r2
qui xtreg GDPgrowth MeanWarRegion i.year if dintwar==0, fe vce(robust)
eststo r3
qui xtreg GDPgrowth MeanWarRegion lGDPpr2015 lTrade Investment lLifespan i.year if dintwar==0, fe vce(robust)
eststo r4
esttab r1 r2 r3 r4 using NeighbourhoodApendix.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(War in the Neighboorhood\label{tab:WarApendix}) replace

//Descriptive Statics
//Correlations
corr dintwar GDPgrowth lGDPpr2015 lTrade EconFreedom schooling lGov Lifespan year

corr  GDPgrowth dintwar lGDPpr2015 sanction
corr  GDPgrowth dintwar lGDPpr2015 lLifespan
corr  GDPgrowth dintwar lGDPpr2015 lTrade
corr  GDPgrowth dintwar lGDPpr2015 Investment
corr  GDPgrowth dintwar lGDPpr2015 lGov
corr GDPgrowth dintwar lGDPpr2015 schooling
corr GDPgrowth dintwar lGDPpr2015 EconFreedom

//Means
mean  GDPgrowth dintwar GDPpr2015 year sanction
mean  GDPgrowth dintwar GDPpr2015 year Lifespan
mean  GDPgrowth dintwar GDPpr2015 year Trade
mean  GDPgrowth dintwar GDPpr2015 year Investment
mean GDPgrowth dintwar GDPpr2015 year schooling
mean  GDPgrowth dintwar GDPpr2015 year Gov
mean GDPgrowth dintwar GDPpr2015 year EconFreedom

//Wars
tab region dintwar

xtdescribe

//Regression Part - Varying forms of y and x
label variable intwar "Level of Intwar"

qui xtreg GDPgrowth i.intwar lGDPpr2015 i.year, fe vce(robust)
eststo Final1
qui xtreg GDPgrowth intwar lGDPpr2015 i.year, fe vce(robust)
eststo Final2
qui xtreg lGDPpr2015 dintwar L.lGDPpr2015 i.year, fe vce(robust)
eststo Final3
qui xtreg lGDPpr2015 i.intwar L.lGDPpr2015 i.year, fe vce(robust)
eststo Final4
qui xtreg lGDPpr2015 intwar L.lGDPpr2015 i.year, fe vce(robust)
eststo Final5
esttab Final3 Final5 Final2 Final4 Final1 using Varyingyandx.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Varying GDP growth measure and War measure\label{tab:9}) replace

/*

//Find gennemsnittet for nabolandende
generate MeanConflictNeighboor=0
replace MeanConflictNeighboor=totalac/nborder if nborder !=0

//Gennemsnit for Regionen
generate MeanConflictRegion=0
replace MeanConflictRegion=regac/nregion if nregion !=0

generate MeanWarNeighboor=0
replace MeanWarNeighboor=totint/nborder if nborder!=0

generate MeanWarRegion=0
replace MeanWarNeighboor=regint/nregion if nregion!=0

bysort year: egen medianGDPpr=median(GDPpr)

gen rich=0 
replace rich=1 if GDPpr>medianGDPpr

gen lGDPpr=log(GDPpr)

xtset country_id year //Tells Stata what is x and t variables


//Merge with Consumption Data
//merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\Consumption.dta"

//keep if _merge==3

//drop _merge

//gen lCon=log(Consumption)

//gen Condata=0
//replace Condata=1 if Consumption!=.

gen GovData=0
replace GovData=1 if Government!=.

gen WarGovInteraction=GovData*dintwar

qui xtreg GDPgrowth dintwar i.year, fe vce(robust)
eststo NoGov
qui xtreg GDPgrowth dintwar GovData WarGovInteraction i.year, fe vce(robust)
eststo Gov2
qui xtreg GDPgrowth dintwar GovData WarGovInteraction lGDPpr dcivwar dethwar i.year, fe vce(robust)
eststo Gov3

esttab NoGov Gov2 Gov3 using WarGovInteraction.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression Table \label{tab:6}) replace 

esttab Gov2 Gov3, drop(19* 20*) r2 p n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression table\label{tab2}) replace 

qui xtreg GDPgrowth dintwar i.year, fe vce(robust)
eststo Gov00

qui xtreg GDPgrowth dintwar dethwar dcivwar lGDPpr i.year, fe vce(robust)
eststo Gov0

qui xtreg GDPgrowth dintwar dethwar dcivwar lGDPpr lGov i.year, fe vce(robust)
eststo Gov1

esttab Gov00 Gov0 Gov1, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression table\label{tab2}) replace 

esttab Gov00 Gov0 Gov1 using Gov.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Government Expenditure Data\label{tab:4}) replace 

mean GDP GDPpr dintwar dcivwar dethwar MeanWarNeighboor if GovData==0
mean GDP GDPpr dintwar dcivwar dethwar MeanWarNeighboor if GovData==1

//drop _merge

xtset country_id year //Tells Stata what is x and t variables

//Scout dataset
drop if travel==0
collapse (mean) avg_gdp_growth=GDPgrowth, by(country)
sort avg_gdp_growth

drop if country=="Iraq"
drop if country=="Bosnia and Herzegovina"
drop if country=="Libya"
drop if country=="Myanmar"

gen WarlGDPprInteraction=lGDPpr*dintwar
gen WarlGDPInteraction=lGDP*dintwar


//Samlet effect
qui xtreg GDPgrowth dintwar i.year, fe vce(robust)
eststo d1

//other wars
qui xtreg GDPgrowth dintwar dcivwar dethwar i.year, fe vce(robust)
eststo d21

//Robustness checks
//GDP
qui xtreg GDPgrowth dintwar dcivwar dethwar lGDPpr i.year, fe vce(robust)
eststo d22

qui xtreg GDPgrowth dintwar dcivwar dethwar lGDPpr WarlGDPprInteraction i.year, fe vce(robust)
eststo d23

qui xtreg GDPgrowth dintwar dcivwar dethwar lGDP i.year, fe vce(robust)
eststo d231

qui xtreg GDPgrowth MeanWarNeighboor lGDPpr i.year, fe vce(robust)
eststo d24



esttab d21 d22 d23 d231 d232, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression table\label{tab:2}) replace

esttab d21 d22 using GDP.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression table\label{tab:2}) replace

//esttab d1 using example1.tex, drop(19* 20*) r2 p n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression table\label{tab1})

esttab d1 using example1.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Interstate warfares effect on GDP growth \label{tab:1}) replace

count if GovData==0 | Condata==0

drop if GovData==0
drop if Condata==0

//esttab d2 d3 d41 d43 using GDP.tex, drop(19* 20*) r2 p n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression table\label{tab2}) replace

//Neighboorhood conflicts
qui xtreg GDPgrowth dintwar GDPpr MeanConflictNeighboor i.year, fe vce(robust)
eststo d3

qui xtreg GDPgrowth dintwar GDPpr dcivwar dethwar MeanConflictNeighboor i.year, fe vce(robust)
eststo d41

qui xtreg GDPgrowth dintwar GDPpr dcivwar dethwar MeanWarNeighboor i.year, fe vce(robust)
eststo d42

qui xtreg GDPgrowth dintwar GDPpr dcivwar dethwar MeanConflictRegion i.year, fe vce(robust)
eststo d43

esttab d41 d42 d43, drop(19* 20*) r2 p n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression table\label{tab2})

//Sanctions
qui xtreg GDPgrowth dintwar lGDPpr dcivwar dethwar arms military trade financial travel other sender_mult i.year, fe vce(robust)
eststo d5


esttab d5 using apendixsanctions.tex, drop(19* 20*) r2 se n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression table\label{tab:3}) replace

//esttab d5 using sanctions.tex, drop(19* 20*) r2 p n label scalars(N_g) stats(N N_g r2, labels(`"Observations"' `"Number of countries"' `"R-squared"')) title(Regression table\label{tab2}) replace


//Different y variables
xtreg lGDPpr GDPpr dintwar L.dintwar LL.dintwar LLL.dintwar i.year, fe
eststo d6


//Andre slags x variable
qui xtreg GDPgrowth MeanWarNeighboor i.year, fe
eststo a1
qui xtreg GDPgrowth MeanWarNeighboor dintwar i.year, fe
eststo a2
qui xtreg GDPgrowth MeanConflictNeighboor dintwar i.year, fe
eststo a3
qui xtreg GDPgrowth MeanConflictRegion dintwar i.year, fe
eststo a4
qui xtreg GDPgrowth totint dintwar i.year, fe
eststo a5
esttab a1 a2 a3 a4 a5, drop(19* 20*) r2 p n

//Import tryouts
merge 1:1 country year using "C:\Users\Tobyd\OneDrive - Aarhus universitet\Uni-livet\6. Semester\Bachelor\Data\GDP per capita constant US.dta"

keep if _merge==3

gen lGDPpr2015=log(GDPpr2015)

xtreg GDPgrowth dintwar i.year, fe
eststo d9

xtreg lGDPpr dintwar i.year, fe
eststo d10

xtreg lGDPpr2015 dintwar i.year, fe
eststo d11

xtreg GDPgrowth dintwar L.dintwar LL.dintwar i.year, fe
eststo d6

xtreg lGDPpr dintwar L.dintwar LL.dintwar i.year, fe
eststo d7

xtreg lGDPpr2015 dintwar L.dintwar LL.dintwar i.year, fe
eststo d8
esttab d9 d10 d11 d6 d7 d8, drop(19* 20*) r2 p n

//Når vi drop if country=="Bosnia and Herzegovina" så er rich ikke significant længere, other bliver significant

/*
qui xtreg GDPgrowth i.intwar i.year, fe
eststo d1
qui xtreg GDPgrowth i.intwar rich i.year, fe
eststo d2
qui xtreg GDPgrowth i.intwar rich MeanConflictNeighboor i.year, fe
eststo d3
qui xtreg GDPgrowth i.intwar rich MeanConflictNeighboor dethwar i.year, fe
eststo d4
qui xtreg GDPgrowth i.intwar rich MeanConflictNeighboor dcivwar dethwar i.year, fe
eststo d5
qui xtreg GDPgrowth i.intwar rich MeanConflictNeighboor dcivwar dethwar arms military trade financial travel other target_mult sender_mult i.year, fe
eststo d6
esttab d1 d2 d3 d4 d5 d6, drop(19* 20*) r2 p n

//The coefficient from travel==1 comes from Libya having a GDP growth of 97% in 2012 and Bosnia having a GDP growth of 81% in 1996 and Iraq having a GDP growth of 49% in 2004 abd 39,6% in 1998
*/