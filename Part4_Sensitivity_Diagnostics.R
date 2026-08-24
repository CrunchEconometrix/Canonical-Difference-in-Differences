# ==============================================================================
# Channel: CRUNCHECONOMETRIX
# TOPIC: Canonical DiD
# PART 4: Sensitivity Checks, Diagnostics, and Robust Error Correction
# Presenter: Dr. Ngozi ADELEYE (aka CrunchQueen)
# ==============================================================================

library(readxl)
library(modelsummary)
library(flextable)
library(lmtest)
library(sandwich)

# 1. Load data from your explicit folder destination path
minwage_excel <- read_excel("C:/Users/ngozi/Desktop/CrunchEconometrix/CrunchEconometrix Video Tutorials (New)/2026 Prospective Topics for Videos/Topic 1_Canonical DiD Files/Canonical DiD_Datasets/minwage_excel.xlsx")

# 2. Restrict data to the active estimation sample (351 units)
estimation_data <- subset(minwage_excel, sample == 1) 

# 3. Turn brand codes into proper categorical factors
estimation_data$chain_factor <- factor(estimation_data$chain, 
                                       labels = c("Burger King", "KFC", "Roy Rogers", "Wendy's"))

# ------------------------------------------------------------------------------
# THE 1.5x IQR OUTLIER DELETION MACHINE (SECURED)
# ------------------------------------------------------------------------------
# Calculate the absolute 25th and 75th percentiles of employment changes
iqr_val     <- IQR(estimation_data$dfte, na.rm = TRUE)
q3          <- quantile(estimation_data$dfte, 0.75, na.rm = TRUE)
q1          <- quantile(estimation_data$dfte, 0.25, na.rm = TRUE)

# Establish John Tukey's mathematical upper and lower fences
upper_bound <- q3 + (1.5 * iqr_val)
lower_bound <- q1 - (1.5 * iqr_val)

# Physically purge the 30 volatile anomaly stores to leave exactly 321 observations
trimmed_data <- subset(estimation_data, dfte >= lower_bound & dfte <= upper_bound)

# ------------------------------------------------------------------------------
# REGRESSION PIPELINE ON RESTRICTED DATA (321 STORES)
# ------------------------------------------------------------------------------
m41_pooled_naive_trim    <- lm(fte2 ~ state, data = trimmed_data)
m42_pooled_controls_trim <- lm(fte2 ~ state + chain_factor, data = trimmed_data)
m43_did_naive_trim       <- lm(dfte ~ state, data = trimmed_data)
m44_did_controls_trim    <- lm(dfte ~ state + chain_factor, data = trimmed_data)

# Package all 4 trimmed specifications inside a structured list container
trimmed_models_list <- list(
  "(1) Naive Pooled [Trim]"   = m41_pooled_naive_trim,
  "(2) Pooled + Ctrl [Trim]"  = m42_pooled_controls_trim,
  "(3) Canonical DiD [Trim]"  = m43_did_naive_trim,
  "(4) DiD + Controls [Trim]" = m44_did_controls_trim
)

# ------------------------------------------------------------------------------
# EXPORT PIPELINE: AUTOMATING ROBUST WORD TABLES FOR TRIMMED DATA
# ------------------------------------------------------------------------------
msummary(
  trimmed_models_list,
  vcov = "HC1",      # Keeps standard error reporting robust and fully synced with Stata!
  stars = TRUE,
  fmt = 3,
  output = "flextable"
) |> 
  save_as_docx(path = "Part4_Robust_Trimmed_Models_Table.docx")

# ------------------------------------------------------------------------------
# LIVE SCREEN PREVIEWS & FINAL HOMOSKEDASTICITY SENSITIVITY CHECK
# ------------------------------------------------------------------------------
# Live Screen Preview: Displays your full vs. trimmed robust matrix right on your screen panel
cat("\n--- LIVE PREVIEW: PART 4 ROBUST TRIMMED REGRESSION MATRIX ---\n")
msummary(trimmed_models_list, vcov = "HC1", stars = TRUE, fmt = 3)

# Execute and print the Breusch-Pagan test results sequentially
cat("\n--- BP TEST: MODEL 4.1 (TRIMMED NAIVE POOLED OLS) ---\n")
bptest(m41_pooled_naive_trim)

cat("\n--- BP TEST: MODEL 4.2 (TRIMMED POOLED WITH CONTROLS) ---\n")
bptest(m42_pooled_controls_trim)

cat("\n--- BP TEST: MODEL 4.3 (TRIMMED CANONICAL DID) ---\n")
bptest(m43_did_naive_trim)

cat("\n--- BP TEST: MODEL 4.4 (TRIMMED DID WITH CONTROLS) ---\n")
bptest(m44_did_controls_trim)

