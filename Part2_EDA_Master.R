# ==============================================================================
# # Channel: CRUNCHECONOMETRIX
# # TOPIC: Canonical DiD
# # PART 2: Exploratory Data Analysis (EDA)
# # Presenter: Dr. Ngozi ADELEYE (aka CrunchQueen)
# ==============================================================================

# 1. Isolate active model variables and filter to the valid sample
eda_data <- subset(minwage_excel, sample == 1)[, c("dfte", "state", "chain")]

# Convert group indicators to fully-labelled factors for professional presentation
eda_data$state_factor <- factor(eda_data$state, labels = c("Pennsylvania (Control)", "New Jersey (Treatment)"))
eda_data$chain_factor <- factor(eda_data$chain, labels = c("Burger King", "KFC", "Roy Rogers", "Wendy's"))

# 2. Continuous Metric Breakdown (dfte)
summary(eda_data$dfte)

# Install the graphics library
library(ggplot2)

# 1. Tabulated Summary Statistics
# Calculate descriptive summaries for dfte, grouped by state
aggregate(dfte ~ state_factor, data = eda_data, FUN = function(x) c(Mean = mean(x), SD = sd(x), Median = median(x)))

# 2. Correlation Analysis
# 1. Ensure structural compliance packages are ready
if(!require(sjPlot)) install.packages("sjPlot")
library(sjPlot)

# 2. Extract active model variables for analysis
cor_vars <- subset(minwage_excel, sample == 1)[, c("dfte", "state", "chain")]

# 3. Export table straight to Word with academic formatting
tab_corr(
  cor_vars,
  na.deletion = "pairwise",
  corr.method = "pearson",
  digits = 3,
  p.numeric = FALSE,
  file = "EDA_Correlation_Matrix.doc"
)

# 3. Histogram of dfte
hist_eda <- ggplot(eda_data, aes(x = dfte)) +
  geom_histogram(binwidth = 2, fill = "#00B6C1", color = "#5A5B5D", alpha = 0.85) +
  labs(title = "Distribution Check: Employment Change (dfte)", y = "Restaurant Count", x = "Change in FTE") +
  theme_minimal()

# Display the chart in your viewer panel
print(hist_eda)

# 4. Grouped Sample Distribution Bar Chart
bar_eda <- ggplot(eda_data, aes(x = chain_factor, fill = state_factor)) +
  geom_bar(position = "dodge", alpha = 0.9) +
  scale_fill_manual(values = c("Pennsylvania (Control)" = "#5A5B5D", "New Jersey (Treatment)" = "#00B6C1")) +
  labs(title = "Categorical Sample Grid: Brand Frequencies", y = "Store Counts", x = "") +
  theme_minimal() + theme(legend.position = "bottom")

# Display the chart in your viewer panel
print(bar_eda)

# 5. Outlier and Diagnostic Bivariate Scatterplot with Boxplots
scatter_eda <- ggplot(eda_data, aes(x = state_factor, y = dfte, color = state_factor)) +
  geom_boxplot(width = 0.4, color = "#5A5B5D", outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.5, size = 2) +
  scale_color_manual(values = c("Pennsylvania (Control)" = "#5A5B5D", "New Jersey (Treatment)" = "#FD8C43")) +
  labs(title = "Outlier Detection: Group Variance Profile", y = "Change in FTE (dfte)", x = "") +
  theme_minimal() + theme(legend.position = "none")

# Display the charts in your viewer panel
print(scatter_eda)

# 6. Cross-tabulating Franchise by State Alignment (Categorical Frequencies Matrix)
table(eda_data$chain_factor, eda_data$state_factor)

# 7. Checking for Outliers
# Calculate the numerical boundaries for outliers in dfte
iqr_val <- IQR(eda_data$dfte, na.rm = TRUE)
q3 <- quantile(eda_data$dfte, 0.75, na.rm = TRUE)
q1 <- quantile(eda_data$dfte, 0.25, na.rm = TRUE)
upper_bound <- q3 + (1.5 * iqr_val)
lower_bound <- q1 - (1.5 * iqr_val)

# Identify which restaurant observations sit outside these boundaries
outlying_stores <- subset(eda_data, dfte > upper_bound | dfte < lower_bound)
nrow(outlying_stores)

# 4. Tabular Exports & Interpretation Guides
# Table A: Categorical Brand Balance
library(flextable)
brand_counts <- as.data.frame(table(eda_data$chain_factor, eda_data$state_factor))
brand_wide <- reshape(brand_counts, idvar = "Var1", timevar = "Var2", direction = "wide")
colnames(brand_wide) <- c("Franchise Brand", "Pennsylvania (Control)", "New Jersey (Treatment)")
flextable(brand_wide) |> theme_vanilla() |> save_as_docx(path = "EDA_Brand_Frequency_Table.docx")

# Table B: Grouped Summary Statistics (ΔY By State)
library(modelsummary)
datasummary(dfte ~ state_factor * (Mean + SD + Median), data = eda_data, output = "flextable") |>
  save_as_docx(path = "EDA_Grouped_Summaries.docx")

# Table C: The Outlier Summary Table
outlier_manifest <- subset(minwage_excel, sample == 1 & (dfte > upper_bound | dfte < lower_bound))[, c("sheet", "state", "chain", "dfte")]
outlier_manifest$state <- factor(outlier_manifest$state, labels = c("PA", "NJ"))
flextable(outlier_manifest) |> theme_vanilla() |> save_as_docx(path = "EDA_Outlier_Manifest_List.docx")
