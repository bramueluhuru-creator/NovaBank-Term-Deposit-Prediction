# ==============================
# Exploratory data analysis
# NovaBank Capstone Project
# ==============================

# Load required packages
library(readr)
library(dplyr)
library(ggplot2)
library(corrplot)

# Load the cleaned dataset
bank <- read.csv("data/cleaned/bank_clean.csv")

# Convert categorical variables to factors
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

# Display the frequency of the target variable
table(bank$y)

# Display the percentage distribution
prop.table(table(bank$y)) * 100

#creates a bar chart for variable y
ggplot(bank, aes(x = y)) +
  geom_bar(fill = "steelblue") +
  labs(
    title = "Distribution of Customer Subscription",
    x = "Subscription",
    y = "Number of Customers"
  )

#saves the bar chart
ggsave(
  "outputs/figures/target_variable_distribution.png",
  width = 8,
  height = 5
)

# Create a summary table for the target variable
target_distribution <- data.frame(
  Count = table(bank$y),
  Percentage = round(prop.table(table(bank$y)) * 100, 2)
)

target_distribution

# Summary statistics for numeric variables
summary(bank[sapply(bank, is.numeric)])

# Plot histograms for numeric variables
numeric_vars <- names(bank)[sapply(bank, is.numeric)]

for (var in numeric_vars) {
  p <- ggplot(bank, aes_string(x = var)) +
    geom_histogram(bins = 30, fill = "steelblue", color = "black") +
    labs(
      title = paste("Distribution of", var),
      x = var,
      y = "Frequency"
    )
  
  print(p)
  
  ggsave(
    filename = paste0("outputs/figures/", var, "_histogram.png"),
    plot = p,
    width = 8,
    height = 5
  )
}

# Correlation matrix for numeric variables
numeric_data <- bank[sapply(bank, is.numeric)]

correlation_matrix <- cor(numeric_data)

round(correlation_matrix, 2)

# Create and save the correlation heatmap

png(
  "outputs/figures/correlation_heatmap.png",
  width = 1000,
  height = 900
)

par(mar = c(1, 1, 4, 1))  # Increase top margin for the title

corrplot(
  correlation_matrix,
  method = "color",
  type = "upper",
  order = "hclust",
  addCoef.col = "black",
  tl.col = "black",
  tl.srt = 45,
  number.cex = 0.7,
  title = "Correlation Heatmap of Numerical Variables",
  mar = c(0, 0, 2, 0)
)

mtext("Variables", side = 1, line = 0.5, cex = 1)
mtext("Variables", side = 2, line = 0.5, cex = 1)

dev.off()

# Plot subscription rate by categorical variables
categorical_vars <- c(
  "job", "marital", "education", "default",
  "housing", "loan", "contact", "month", "poutcome"
)

for (var in categorical_vars) {
  
  p <- ggplot(bank, aes_string(x = var, fill = "y")) +
    geom_bar(position = "fill") +
    scale_y_continuous(labels = scales::percent) +
    labs(
      title = paste("Subscription Rate by", tools::toTitleCase(var)),
      x = tools::toTitleCase(var),
      y = "Percentage",
      fill = "Subscription"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  print(p)
  
  ggsave(
    filename = paste0("outputs/figures/", var, "_subscription_rate.png"),
    plot = p,
    width = 8,
    height = 5
  )
}

# Compare numerical variables by subscription status
numeric_vars <- c(
  "age",
  "balance",
  "day",
  "duration",
  "campaign",
  "pdays",
  "previous"
)

for (var in numeric_vars) {
  
  p <- ggplot(bank, aes_string(x = "y", y = var, fill = "y")) +
    geom_boxplot() +
    labs(
      title = paste(tools::toTitleCase(var), "by Subscription Status"),
      x = "Subscription",
      y = tools::toTitleCase(var)
    ) +
    theme_minimal() +
    theme(legend.position = "none")
  
  print(p)
  
  ggsave(
    filename = paste0("outputs/figures/", var, "_boxplot.png"),
    plot = p,
    width = 8,
    height = 5
  )
}