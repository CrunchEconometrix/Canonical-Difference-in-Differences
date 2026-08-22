* ==============================================================================
* Topic: CANONICAL DIFFERENCE-IN-DIFFERENCES (DID) ANALYSIS
* Part 2: Exploratory Data Analysis
* Channel: CrunchEconometrix
* Presenter: Dr. Ngozi ADELEYE (aka CrunchQueen)
* ==============================================================================

clear all
macro drop _all
capture log close

* Ensure external export engine is loaded natively
capture ssc install asdoc

* ------------------------------------------------------------------------------
* STEP 1: DATA ACQUISITION & WORKSPACE LOCALIZATION
* ------------------------------------------------------------------------------

use "https://ditraglia.com/data/minwage.dta", clear

* Export full baseline copy as an Excel Spreadsheet to local folder
export excel using "minwage_excel.xlsx", firstrow(variables) replace

* Keep only the valid estimation sample (351 units)
keep if sample == 1

* Describe structure and check variable names in visual command window
describe
list dfte state chain in 1/5

* ------------------------------------------------------------------------------
* STEP 2: CATEGORICAL FACTOR LABELLING
* ------------------------------------------------------------------------------
label define statelab 0 "Pennsylvania (Control)" 1 "New Jersey (Treatment)"
label values state statelab

label define chainlab 1 "Burger King" 2 "KFC" 3 "Roy Rogers" 4 "Wendy's"
label values chain chainlab

* ------------------------------------------------------------------------------
* STEP 3: TABULAR EXPORTS VIA ASDOC
* ------------------------------------------------------------------------------
* 1. Tabular Cross-Tabulation Export (Table A)
asdoc tabulate chain state, replace title(Brand Frequency Cross-Tabulation) save(Stata_EDA_Tables.doc)

* 2. Grouped Descriptive Statistical Summaries (Table B)
asdoc summarize dfte, by(state) append save(Stata_EDA_Tables.doc)

* 3. Correlation Analysis (Table C)
asdoc correlate dfte state chain, append save(Stata_EDA_Tables.doc) title(EDA Variable Correlation Matrix)

* ------------------------------------------------------------------------------
* STEP 4: GRAPHICS WORKFLOW GENERATION
* ------------------------------------------------------------------------------
* Graphic A: Symmetrical Outcome Histogram
histogram dfte, width(2) frequency fcolor(cyan) lcolor(stone) ///
    title("Distribution Check: Employment Change (dfte)") xtitle("Change in FTE")
graph export "Stata_EDA_Histogram.png", as(png) replace

* Graphic B: Proportional Side-by-Side Bar Chart
graph bar, over(state) over(chain) asyvars b1title("Franchise Brands") ///
    title("Categorical Sample Grid: Brand Frequencies") ytitle("Store Counts")
graph export "Stata_EDA_Barchart.png", as(png) replace

* Graphic C: Outlier Grouped Boxplot Matrix
graph box dfte, over(state) title("Outlier Detection: Group Variance Profile") ///
    ytitle("Change in FTE (dfte)")
graph export "Stata_EDA_Boxplot.png", as(png) replace

