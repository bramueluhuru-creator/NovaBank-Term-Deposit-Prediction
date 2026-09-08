# ==============================
# Data cleaning
# NovaBank Capstone Project
# ==============================

# Load the cleaned dataset
bank <- read.csv("data/cleaned/bank_clean.csv")

# Convert categorical variables back to factors
bank$job <- as.factor(bank$job)
bank$marital <- as.factor(bank$marital)
bank$education <- as.factor(bank$education)
bank$default <- as.factor(bank$default)
bank$housing <- as.factor(bank$housing)
bank$loan <- as.factor(bank$loan)
bank$contact <- as.factor(bank$contact)
bank$month <- as.factor(bank$month)
bank$poutcome <- as.factor(bank$poutcome)
bank$y <- as.factor(bank$y)

# Function to count outliers using the IQR method
count_outliers <- function(x) {
  Q1 <- quantile(x, 0.25)
  Q3 <- quantile(x, 0.75)
  IQR_value <- IQR(x)
  
  lower_bound <- Q1 - 1.5 * IQR_value
  upper_bound <- Q3 + 1.5 * IQR_value
  
  sum(x < lower_bound | x > upper_bound)
}

# Count outliers for all numeric variables
outlier_counts <- sapply(bank[sapply(bank, is.numeric)], count_outliers)

# Display the results
outlier_counts
str(bank)