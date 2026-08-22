* ==============================================================================
* Topic: CANONICAL DIFFERENCE-IN-DIFFERENCES (DID) ANALYSIS
* Part 4: Sensitivity Analysis & Diagnostics (with Trimmed Dataset)
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
* STEP 2: CALCULATE THE 1.5x IQR BOUNDS NATIVELY IN STATA
* ------------------------------------------------------------------------------
quietly summarize dfte, detail
scalar q1 = r(p25)
scalar q3 = r(p75)
scalar iqr_val = q3 - q1

scalar lower_fence = q1 - (1.5 * iqr_val)
scalar upper_fence = q3 + (1.5 * iqr_val)

* ------------------------------------------------------------------------------
* STEP 3: OUTLIER SWEEP (TRIMMING THE DATA DOWN TO 321 STORES)
* ------------------------------------------------------------------------------
keep if dfte >= lower_fence & dfte <= upper_fence

* Verify your trimmed observation count matches your R script perfectly (321)
count

* ------------------------------------------------------------------------------
* STEP 4: ESTIMATE AND EXPORT ALL 4 RE-RUN MODELS SIDE-BY-SIDE
* ------------------------------------------------------------------------------
asdoc reg fte2 state, replace title(Trimmed Sample Sensitivity Report) cwide save(Part4_Stata_Trimmed_Regressions.doc) text((1) Naive Pooled [Trim])
asdoc reg fte2 state i.chain, append cwide save(Part4_Stata_Trimmed_Regressions.doc) text((2) Pooled + Ctrl [Trim])
asdoc reg dfte state, append cwide save(Part4_Stata_Trimmed_Regressions.doc) text((3) Canonical DiD [Trim])
asdoc reg dfte state i.chain, append cwide save(Part4_Stata_Trimmed_Regressions.doc) text((4) DiD + Controls [Trim])

* ------------------------------------------------------------------------------
* STEP 5: HETEROSKEDASTICITY AUDITS ON RESTRICTED SAMPLES
* ------------------------------------------------------------------------------
quietly reg fte2 state
hettest

quietly reg fte2 state i.chain
hettest

quietly reg dfte state
hettest

quietly reg dfte state i.chain
hettest
