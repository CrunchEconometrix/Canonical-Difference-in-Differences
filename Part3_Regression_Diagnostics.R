# ==============================================================================
# # Channel: CRUNCHECONOMETRIX
# # TOPIC: Canonical DiD
# # PART 3: Regression and Diagnostics
# # Presenter: Dr. Ngozi ADELEYE (aka CrunchQueen)
# ==============================================================================

# 1. Load your core compliance engines
library(rio)
library(modelsummary)
library(flextable)
library(lmtest)

# Step 2: Reload your Excel file back into R's memory from your directory
minwage_excel <- import("minwage_saved.xlsx") 

# Step 3: Filter your sample to the active estimation observations 
estimation_data <- subset(minwage_excel, sample == 1) 

# Step 4: Turn 'chain' into a proper categorical variable for brand controls 
estimation_data$chain_factor <- factor(estimation_data$chain, 
                                       labels = c("Burger King", "KFC", "Roy Rogers", "Wendy's"))

# ------------------------------------------------------------------------------
# REGRESSION PIPELINE: ESTIMATING MODELS (1) TO (4)
# ------------------------------------------------------------------------------
# Model 3.1: Naive Pooled OLS with STATE only
m31_pooled_naive <- lm(fte2 ~ state, data = estimation_data)

# Model 3.2: Naive Pooled OLS with STATE and CHAIN controls
m32_pooled_controls <- lm(fte2 ~ state + chain_factor, data = estimation_data)

# Model 3.3: Canonical DiD with STATE only (Using pre-calculated difference dFTE)
m33_did_naive <- lm(dfte ~ state, data = estimation_data)

# Model 3.4: Canonical DiD with STATE and CHAIN controls
m34_did_controls <- lm(dfte ~ state + chain_factor, data = estimation_data)

# ------------------------------------------------------------------------------
# EXPORTING PIPELINE: AUTOMATING SIDE-BY-SIDE WORD TABLES
# ------------------------------------------------------------------------------
# Place all 4 models inside a structured named list for the table headers
part3_models <- list(
  "(1) Naive Pooled"          = m31_pooled_naive,
  "(2) Pooled with Controls"  = m32_pooled_controls,
  "(3) Canonical DiD"         = m33_did_naive,
  "(4) DiD with Controls"     = m34_did_controls
)

# Compile and export natively to Word using the flextable pipe engine
msummary(
  part3_models,
  stars = TRUE,      # Automatically maps academic significance stars
  fmt = 3,           # Tightly locks rounding to 3 decimal places
  output = "flextable"
) |> 
  save_as_docx(path = "Part3_Empirical_Regressions_Table.docx")

cat("\n>>> Part 3 Models Estimated Successfully! File saved in your directory. <<<\n")

# ==============================================================================
# SELF-CONTAINED MASTER SCRIPT FOR ITEM: MULTI-MODEL HETEROSKEDASTICITY AUDIT
# ==============================================================================
# Execute and print the Breusch-Pagan test results sequentially for each model
cat("\n--- MODEL 3.1: NAIVE POOLED OLS HETEROSKEDASTICITY AUDIT ---\n")
bptest(m31_pooled_naive)

cat("\n--- MODEL 3.2: POOLED WITH CONTROLS HETEROSKEDASTICITY AUDIT ---\n")
bptest(m32_pooled_controls)

cat("\n--- MODEL 3.3: CANONICAL DID HETEROSKEDASTICITY AUDIT ---\n")
bptest(m33_did_naive)

cat("\n--- MODEL 3.4: DID WITH CONTROLS HETEROSKEDASTICITY AUDIT ---\n")
bptest(m34_did_controls)
