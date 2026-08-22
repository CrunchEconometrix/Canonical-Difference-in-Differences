
* ==============================================================================
* Topic: CANONICAL DIFFERENCE-IN-DIFFERENCES (DID) ANALYSIS
* Part 3: Main Regression Analysis & Diagnostics 
* Channel: CrunchEconometrix
* Presenter: Dr. Ngozi ADELEYE (aka CrunchQueen)
* ==============================================================================

**Date: August 2026

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
//sample obs drops from 410 to 351

* Describe structure and check variable names in visual command window
describe
list dfte state chain in 1/5

* Ensure required automated exporting packages are installed natively
capture ssc install asdoc

* Define explicit categorical factor labels
label define statelab 0 "Pennsylvania (Control)" 1 "New Jersey (Treatment)"
label values state statelab

* Establish factor labels for your categorical control variable
label define chainlab 1 "Burger King" 2 "KFC" 3 "Roy Rogers" 4 "Wendy's"
label values chain chainlab

* ------------------------------------------------------------------------------
* STEP 2: REGRESSION WORKFLOW & RESULTS EXPORTING
* ------------------------------------------------------------------------------
* Model 3.1: Naive Pooled OLS
asdoc reg fte2 state, replace title(Full Sample Empirical Regressions) cwide save(Part3_Stata_Regressions.doc) text((1) Naive Pooled)

* Model 3.2: Naive Pooled with Franchise Brand Controls
asdoc reg fte2 state i.chain, append cwide save(Part3_Stata_Regressions.doc) text((2) Pooled with Controls)

* Model 3.3: Canonical DiD with STATE only (Using pre-calculated dfte)
asdoc reg dfte state, append cwide save(Part3_Stata_Regressions.doc) text((3) Canonical DiD)

* Model 3.4: Canonical DiD with Franchise Brand Controls
asdoc reg dfte state i.chain, append cwide save(Part3_Stata_Regressions.doc) text((4) DiD with Controls)

* ------------------------------------------------------------------------------
* STEP 3: EXECUTE HETEROSKEDASTICITY AUDITS VIA BREUSCH-PAGAN
* ------------------------------------------------------------------------------
display "--- BP TEST: MODEL 3.1 (NAIVE POOLED OLS) ---"
quietly reg fte2 state
hettest

display "--- BP TEST: MODEL 3.2 (POOLED WITH CONTROLS) ---"
quietly reg fte2 state i.chain
hettest

display "--- BP TEST: MODEL 3.3 (CANONICAL DID) ---"
quietly reg dfte state
hettest

display "--- BP TEST: MODEL 3.4 (DID WITH CONTROLS) ---"
quietly reg dfte state i.chain
hettest
