# ==============================================================================
# Channel: CRUNCHECONOMETRIX
# TOPIC: Canonical DiD
# PART 4: Sensitivity Checks and Diagnostics
# Presenter: Dr. Ngozi ADELEYE (aka CrunchQueen)
# ==============================================================================

library(modelsummary)
library(flextable)
library(rio)
library(lmtest)

# 1. Recalculate your exact IQR bounds from Part 2 to target outliers in dfte
iqr_val     <- IQR(estimation_data$dfte, na.rm = TRUE)
q3          <- quantile(estimation_data$dfte, 0.75, na.rm = TRUE)
q1          <- quantile(estimation_data$dfte, 0.25, na.rm = TRUE)
upper_bound <- q3 + (1.5 * iqr_val)
lower_bound <- q1 - (1.5 * iqr_val)

# 2. Create your clean, trimmed dataset by dropping the 30 anomalous units
trimmed_data <- subset(estimation_data, dfte >= lower_bound & dfte <= upper_bound)

# 3. Re-estimate all 4 models on the clean, trimmed sample (321 observations)
m41_pooled_naive_trim    <- lm(fte2 ~ state, data = trimmed_data)
m42_pooled_controls_trim <- lm(fte2 ~ state + chain_factor, data = trimmed_data)
m43_did_naive_trim       <- lm(dfte ~ state, data = trimmed_data)
m44_did_controls_trim    <- lm(dfte ~ state + chain_factor, data = trimmed_data)

# 4. Package all 4 trimmed specifications inside a structured list container
trimmed_models_list <- list(
  "(1) Naive Pooled [Trim]" = m41_pooled_naive_trim,
  "(2) Pooled + Ctrl [Trim]" = m42_pooled_controls_trim,
  "(3) Canonical DiD [Trim]" = m43_did_naive_trim,
  "(4) DiD + Controls [Trim]" = m44_did_controls_trim
)

# 5. Export directly to Word with exact formatting, 3 decimals, and stars
msummary(
  trimmed_models_list,
  stars = TRUE,
  fmt = 3,
  output = "flextable"
) |> 
  save_as_docx(path = "Part4_Trimmed_Models_Regression_Table.docx")

cat("\n>>> Outlier sweep complete! Trimmed sample size (N =", nrow(trimmed_data), ") verified.\n")
cat(">>> Table saved inside your directory as 'Part4_Trimmed_Models_Regression_Table.docx'.\n")

# ==============================================================================
# MASTER SCRIPT FOR TRIMMED HETEROSKEDASTICITY AUDIT
# ==============================================================================
# Re-establish your exact trimmed data boundaries to ensure fresh memory tracking
iqr_val      <- IQR(minwage_excel$dfte[minwage_excel$sample == 1], na.rm = TRUE)
q3           <- quantile(minwage_excel$dfte[minwage_excel$sample == 1], 0.75, na.rm = TRUE)
q1           <- quantile(minwage_excel$dfte[minwage_excel$sample == 1], 0.25, na.rm = TRUE)
upper_bound  <- q3 + (1.5 * iqr_val)
lower_bound  <- q1 - (1.5 * iqr_val)
trimmed_data <- subset(minwage_excel, sample == 1 & dfte >= lower_bound & dfte <= upper_bound)
trimmed_data$chain_factor <- factor(trimmed_data$chain, labels = c("Burger King", "KFC", "Roy Rogers", "Wendy's"))

# Estimate all 4 Trimmed Specifications fresh in memory
m41_pooled_naive_trim    <- lm(fte2 ~ state, data = trimmed_data)
m42_pooled_controls_trim <- lm(fte2 ~ state + chain_factor, data = trimmed_data)
m43_did_naive_trim       <- lm(dfte ~ state, data = trimmed_data)
m44_did_controls_trim    <- lm(dfte ~ state + chain_factor, data = trimmed_data)

# Execute and print the Breusch-Pagan test results sequentially for each trimmed model
cat("\n--- MODEL 4.1: TRIMMED NAIVE POOLED OLS VARIANCE AUDIT ---\n")
bptest(m41_pooled_naive_trim)

cat("\n--- MODEL 4.2: TRIMMED POOLED WITH CONTROLS VARIANCE AUDIT ---\n")
bptest(m42_pooled_controls_trim)

cat("\n--- MODEL 4.3: TRIMMED CANONICAL DID VARIANCE AUDIT ---\n")
bptest(m43_did_naive_trim)

cat("\n--- MODEL 4.4: TRIMMED DID WITH CONTROLS VARIANCE AUDIT ---\n")
bptest(m44_did_controls_trim)
