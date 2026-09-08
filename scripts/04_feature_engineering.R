# ==============================
# Feature Engineering
# NovaBank Capstone Project
# ==============================

# Load required packages
library(readr)                                                # Read CSV files
library(dplyr)                                                # Data manipulation

# Load cleaned dataset
bank <- read.csv("data/cleaned/bank_clean.csv")               # Load the cleaned dataset

# ---------------------------------------
# Convert categorical variables to factors
# ---------------------------------------

bank$job <- as.factor(bank$job)                               # Convert job to a factor
bank$marital <- as.factor(bank$marital)                       # Convert marital status to a factor
bank$education <- as.factor(bank$education)                   # Convert education to a factor
bank$default <- as.factor(bank$default)                       # Convert default status to a factor
bank$housing <- as.factor(bank$housing)                       # Convert housing loan status to a factor
bank$loan <- as.factor(bank$loan)                             # Convert personal loan status to a factor
bank$contact <- as.factor(bank$contact)                       # Convert contact type to a factor
bank$month <- as.factor(bank$month)                           # Convert month to a factor
bank$poutcome <- as.factor(bank$poutcome)                     # Convert previous campaign outcome to a factor
bank$y <- as.factor(bank$y)                                   # Convert target variable to a factor

# ---------------------------------------
# Remove variables that cause data leakage
# ---------------------------------------

bank_model <- bank %>%                                        # Create the modeling dataset
  select(-duration)                                           # Remove call duration because it is unknown before the call

# ---------------------------------------
# Inspect the processed dataset
# ---------------------------------------

str(bank_model)                                               # Display the dataset structure

summary(bank_model)                                           # Display summary statistics

# ---------------------------------------
# Save processed dataset
# ---------------------------------------

write.csv(                                                    # Save the processed dataset
  bank_model,
  "data/processed/bank_model.csv",
  row.names = FALSE
)

cat("Feature-engineered dataset saved successfully!\n")       # Display a success message