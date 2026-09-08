# ==============================
# Predictive Modeling
# NovaBank Capstone Project
# ==============================

# Load required packages
library(caret)                                               # Machine learning utilities
library(readr)                                               # Read CSV files
library(dplyr)                                               # Data manipulation
library(rpart)                                               # Decision tree algorithm
library(rpart.plot)                                          # Plot decision trees
library(randomForest)                                        # Random Forest algorithm

# Set seed for reproducibility
set.seed(123)                                                # Ensure results can be reproduced

# ---------------------------------------
# Load Processed Dataset
# ---------------------------------------

bank_model <- read.csv("data/processed/bank_model.csv")      # Load the processed dataset

# ---------------------------------------
# Convert Categorical Variables to Factors
# ---------------------------------------

bank_model$job <- as.factor(bank_model$job)                  # Convert job to a factor
bank_model$marital <- as.factor(bank_model$marital)          # Convert marital status to a factor
bank_model$education <- as.factor(bank_model$education)      # Convert education to a factor
bank_model$default <- as.factor(bank_model$default)          # Convert default status to a factor
bank_model$housing <- as.factor(bank_model$housing)          # Convert housing loan status to a factor
bank_model$loan <- as.factor(bank_model$loan)                # Convert personal loan status to a factor
bank_model$contact <- as.factor(bank_model$contact)          # Convert contact type to a factor
bank_model$month <- as.factor(bank_model$month)              # Convert month to a factor
bank_model$poutcome <- as.factor(bank_model$poutcome)        # Convert previous campaign outcome to a factor
bank_model$y <- as.factor(bank_model$y)                      # Convert target variable to a factor

# ---------------------------------------
# Split Dataset
# ---------------------------------------

# Create training dataset (60%)
train_index <- createDataPartition(                          # Create indices for the training set
  bank_model$y,
  p = 0.60,
  list = FALSE
)

train_data <- bank_model[train_index, ]                      # Training dataset
remaining_data <- bank_model[-train_index, ]                 # Remaining observations

# Split remaining data into validation and testing sets
validation_index <- createDataPartition(                     # Create indices for the validation set
  remaining_data$y,
  p = 0.50,
  list = FALSE
)

validation_data <- remaining_data[validation_index, ]        # Validation dataset
test_data <- remaining_data[-validation_index, ]             # Testing dataset

# ---------------------------------------
# Verify Dataset Splits
# ---------------------------------------

dim(train_data)                                              # Display training dataset dimensions
dim(validation_data)                                         # Display validation dataset dimensions
dim(test_data)                                               # Display testing dataset dimensions

prop.table(table(train_data$y))                              # Display class distribution in the training set
prop.table(table(validation_data$y))                         # Display class distribution in the validation set
prop.table(table(test_data$y))                               # Display class distribution in the testing set

# ---------------------------------------
# Build Logistic Regression Model
# ---------------------------------------

logistic_model <- glm(                                       # Train a logistic regression model
  y ~ .,                                                     # Use all available predictor variables
  data = train_data,                                         # Use the training dataset
  family = binomial(link = "logit")                          # Specify binary logistic regression
)

summary(logistic_model)                                      # Display model summary

# ---------------------------------------
# Build and Prune Decision Tree
# ---------------------------------------

# Grow a large decision tree
decision_tree <- rpart(
  y ~ .,                                                     # Use all predictor variables
  data = train_data,                                         # Training dataset
  method = "class",                                          # Classification tree
  control = rpart.control(
    cp = 0.0005,                                             # Grow a large tree
    minsplit = 20,                                           # Minimum observations before splitting
    minbucket = 10,                                          # Minimum observations in terminal nodes
    maxdepth = 30                                             # Allow deep trees
  )
)

# Display the complexity parameter table
printcp(decision_tree)

# Plot the cross-validation error
plotcp(decision_tree)

# -------------------------------------------------
# Automatically prune to approximately 12 terminal nodes
# -------------------------------------------------

cp_table <- decision_tree$cptable                            # Extract CP table

target_splits <- 11                                          # 11 splits ≈ 12 terminal nodes

closest_row <- which.min(abs(cp_table[, "nsplit"] - target_splits))

selected_cp <- cp_table[closest_row, "CP"]                   # Select corresponding CP value

cat("Selected CP:", selected_cp, "\n")

# Prune the tree
pruned_tree <- prune(
  decision_tree,
  cp = selected_cp
)

# Display the pruned tree
rpart.plot(
  pruned_tree,
  type = 2,
  extra = 104,
  fallen.leaves = TRUE,
  cex = 0.8,
  tweak = 1.2
)

# Save the tree
png(
  "outputs/pruned_decision_tree.png",
  width = 2600,
  height = 1800,
  res = 300
)

rpart.plot(
  pruned_tree,
  type = 2,
  extra = 104,
  fallen.leaves = TRUE,
  cex = 0.8,
  tweak = 1.2
)

dev.off()

# Display the final tree summary
print(pruned_tree)

# ---------------------------------------
# Build Random Forest Model
# ---------------------------------------

set.seed(123)                                                # Ensure reproducibility

random_forest <- randomForest(                               # Train a Random Forest model
  y ~ .,                                                     # Use all available predictor variables
  data = train_data,                                         # Use the training dataset
  ntree = 500,                                               # Grow 500 trees
  mtry = floor(sqrt(ncol(train_data) - 1)),                  # Select predictors randomly at each split
  importance = TRUE                                          # Calculate variable importance
)

print(random_forest)                                         # Display model summary

varImpPlot(random_forest)                                    # Display variable importance plot

# Save the Variable Importance Plot
png("outputs/random_forest_variable_importance.png",
    width = 2000,
    height = 1200,
    res = 300)

varImpPlot(random_forest)

dev.off()

# ---------------------------------------
# Generate Predictions on Validation Set
# ---------------------------------------

# Logistic Regression Predictions
logistic_prob <- predict(                                    # Predict probabilities
  logistic_model,
  newdata = validation_data,
  type = "response"
)

logistic_pred <- ifelse(                                     # Convert probabilities into class labels
  logistic_prob >= 0.50,
  "yes",
  "no"
)

logistic_pred <- factor(                                     # Convert predictions to factors
  logistic_pred,
  levels = c("no", "yes")
)

# Decision Tree Predictions
tree_pred <- predict(                                        # Predict classes
  decision_tree,
  newdata = validation_data,
  type = "class"
)

# Random Forest Predictions
forest_pred <- predict(                                      # Predict classes
  random_forest,
  newdata = validation_data,
  type = "class"
)

# ---------------------------------------
# Confusion Matrices
# ---------------------------------------

logistic_cm <- confusionMatrix(                              # Evaluate Logistic Regression
  data = logistic_pred,
  reference = validation_data$y,
  positive = "yes"
)

tree_cm <- confusionMatrix(                                  # Evaluate Decision Tree
  data = tree_pred,
  reference = validation_data$y,
  positive = "yes"
)

forest_cm <- confusionMatrix(                                # Evaluate Random Forest
  data = forest_pred,
  reference = validation_data$y,
  positive = "yes"
)

# Display Results
logistic_cm                                                  # Logistic Regression performance

tree_cm                                                      # Decision Tree performance

forest_cm                                                    # Random Forest performance


# ---------------------------------------
# Evaluate Random Forest on the Test Set
# ---------------------------------------

# Predict customer classes using the Random Forest model
test_pred <- predict(                                        # Generate predictions
  random_forest,                                              # Use the trained Random Forest model
  newdata = test_data,                                        # Predict on the unseen test dataset
  type = "class"                                              # Return predicted class labels
)

# Create the confusion matrix
test_cm <- confusionMatrix(                                   # Compare predictions with actual outcomes
  data = test_pred,                                           # Predicted customer classes
  reference = test_data$y,                                    # Actual customer classes
  positive = "yes"                                             # Treat "yes" as the positive class
)

# Display the model performance
test_cm                                                       # Show the confusion matrix and evaluation metrics

