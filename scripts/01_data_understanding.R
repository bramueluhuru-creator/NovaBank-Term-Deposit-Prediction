# ==============================
# Data understanding
# NovaBank Capstone Project
# ==============================
# Load required packages
library(readr)
library(dplyr)

# Load the dataset
bank <- read_delim("data/raw/bank-full.csv", delim = ";")

# View the first six rows
head(bank)

# View the structure
str(bank)

# Display dataset dimensions
dim(bank)

# Display variable names
names(bank)

# Generate summary statistics
summary(bank)