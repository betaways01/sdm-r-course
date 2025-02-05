# Cart, RF, and GBM

---

## **1. Introduction to Tree-Based Models**  

### **Overview of Tree-Based Machine Learning Models in SDM**  

Tree-based models are widely used in **Species Distribution Modeling (SDM)** due to their ability to handle **complex, non-linear relationships** between species occurrences and environmental variables. These models split data into hierarchical structures, making predictions based on decision rules.  

The three most commonly used tree-based models in SDM are:  

1. **CART (Classification and Regression Trees)** – A simple decision tree model.  
2. **Random Forest (RF)** – An ensemble of multiple decision trees.  
3. **Gradient Boosting Machine (GBM)** – A boosting technique that builds trees sequentially.  

These models help answer key ecological questions like:  
- **Which environmental factors** are most important in determining a species' distribution?  
- **Where is the species likely to occur** given the environmental conditions?  
- **How do environmental changes impact species distributions?**  

---

### **When to Use CART, RF, and GBM?**  

Each model has **unique advantages and trade-offs**, making them useful in different scenarios:

| **Model**       | **When to Use** | **Best Use Cases** |
|----------------|----------------|--------------------|
| **CART** | When interpretability is the priority. | Identifying key environmental thresholds affecting species presence. |
| **Random Forest (RF)** | When accuracy and robustness are important. | Large datasets with complex species-environment relationships. |
| **Gradient Boosting Machine (GBM)** | When high predictive performance is needed. | Climate change projections and highly non-linear relationships. |

---

### **Strengths and Weaknesses of Each Model**  

| **Model**       | **Strengths** | **Weaknesses** |
|----------------|--------------|---------------|
| **CART** | Simple and interpretable. | Prone to overfitting. |
| **RF** | Handles large datasets well; reduces overfitting. | Less interpretable than CART. |
| **GBM** | High predictive accuracy; handles missing data well. | Computationally intensive and requires tuning. |

---

::: {.rmdtip}
**Pro Tip**: If you need a simple, explainable model, start with **CART**. If you need better accuracy, use **Random Forest**. For the best predictive power, go with **GBM**.
:::

---

### **Next Steps**  

In the following sections, we will explore **CART, RF, and GBM** in detail, covering:  
- **Theoretical foundations** (how they work).  
- **Coding demonstrations** (practical implementation in R using real datasets).  


---
## **2. Classification and Regression Trees (CART)**  

---

### **A. Theory Explanation**  

#### **What is CART?**  

CART (**Classification and Regression Trees**) is a simple yet powerful machine learning algorithm that makes predictions by **splitting the data into smaller subsets** based on decision rules. The model is structured like a tree:  

- **Nodes** represent decision points based on predictor variables.  
- **Branches** connect decision points to possible outcomes.  
- **Leaves** represent final predictions (species presence/absence or suitability scores).  

#### **How Does CART Work?**  

1. **Recursive Partitioning**:  
   - The algorithm selects a predictor variable and a **splitting threshold** (e.g., temperature > 15°C).  
   - It divides the data into two groups: one that meets the condition and one that doesn’t.  
   - The process repeats for each group until a stopping rule is met (e.g., minimum number of observations per node).  

2. **Prediction**:  
   - If modeling **presence/absence**, the tree assigns a class (0 or 1).  
   - If modeling **species suitability**, the tree assigns a probability or numerical score.  

---

#### **Advantages of CART**  

✅ **Simple and Interpretable** – Easy to understand and visualize.  
✅ **Handles Categorical and Continuous Data** – Works with both numerical and factor variables.  
✅ **Captures Nonlinear Relationships** – Unlike traditional regression, it can model complex relationships.  

---

#### **Limitations of CART**  

⚠️ **Prone to Overfitting** – Trees may grow too complex and fit noise in the data.  
⚠️ **Lower Accuracy Compared to RF & GBM** – Ensemble methods like **Random Forest** and **Gradient Boosting** often outperform single decision trees.  
⚠️ **Sensitive to Small Data Changes** – Slight variations in data can lead to a different tree structure.  

---

::: {.rmdnote}
**Key Takeaway**:  
CART is great for quick insights but can be **unstable and prone to overfitting**. Random Forest (RF) and Gradient Boosting (GBM) improve upon CART by combining multiple trees.
:::

---

### **B. Coding Demonstration: CART in R**  

Let’s fit a **CART model** using the `rpart` package and visualize the tree.

---

#### **Step 1: Load Libraries**
```r
# Load necessary libraries
library(rpart)      # CART model
library(rpart.plot) # Visualizing trees
library(dismo)      # SDM-related datasets
library(caret)      # Model evaluation
```

---

#### **Step 2: Load a Built-in Dataset**  

We will use the `bioclim` dataset from the `dismo` package, which contains species presence-absence data along with environmental predictors.  

```r
# Load example SDM dataset
data <- dismo::bioclim

# View structure of the dataset
str(data)

# Define presence/absence variable
data$presence <- as.factor(data$presence)  # Convert to factor for classification
```

---

#### **Step 3: Split Data into Training and Testing Sets**
```r
# Set seed for reproducibility
set.seed(123)

# Split data into training (70%) and testing (30%)
trainIndex <- createDataPartition(data$presence, p = 0.7, list = FALSE)
train_data <- data[trainIndex, ]
test_data  <- data[-trainIndex, ]
```

---

#### **Step 4: Fit a CART Model**
```r
# Train a CART model
cart_model <- rpart(presence ~ bio1 + bio12 + bio5 + bio6, 
                     data = train_data, 
                     method = "class",  # Classification task
                     control = rpart.control(minsplit = 10))

# Print tree summary
print(cart_model)
```

---

#### **Step 5: Visualize the Decision Tree**
```r
# Plot the decision tree
rpart.plot(cart_model, main = "CART Decision Tree for Species Presence")
```

---

#### **Step 6: Evaluate Model Performance**
```r
# Make predictions on test data
predictions <- predict(cart_model, test_data, type = "class")

# Generate confusion matrix
confusionMatrix(predictions, test_data$presence)
```

---

### **Key Observations**
- The decision tree **identifies key environmental thresholds** that influence species presence.
- The confusion matrix evaluates **accuracy, sensitivity, and specificity**.
- **Next Step**: Improve model accuracy by using **Random Forest (RF)** to reduce overfitting.

---

### **Summary**
✅ **CART is simple and interpretable** but can overfit the data.  
✅ **It helps identify key environmental factors affecting species presence.**  
✅ **For better accuracy, ensemble methods like RF and GBM are preferred.**  

---
## **3. Random Forest (RF)**  

---

### **A. Theory Explanation**  

#### **What is Random Forest?**  

Random Forest (**RF**) is an **ensemble learning** method that builds **multiple decision trees** and combines their predictions to improve accuracy. Unlike a single decision tree (**CART**), Random Forest:  

- **Reduces overfitting** by averaging multiple tree predictions.  
- **Randomly selects features** at each split, preventing any single predictor from dominating the model.  

Think of it as a **team of decision trees**, where each tree gives its own "vote," and the forest decides based on the majority vote.  

---

### **How Does Random Forest Work?**  

1. **Bootstrap Sampling**:  
   - The model randomly selects **subsets of the data** (with replacement) to train each tree.  
   
2. **Feature Randomization**:  
   - At each tree split, **only a random subset of predictors** is considered to prevent overfitting.  

3. **Voting for Final Prediction**:  
   - Each tree makes a prediction, and the **majority vote** determines the final output.  

---

### **Advantages of Random Forest**  

✅ **Higher accuracy than CART** – Reduces overfitting by averaging multiple trees.  
✅ **Handles large datasets well** – Works with many predictors and interactions.  
✅ **Captures complex relationships** – Suitable for non-linear species-environment relationships.  

---

### **Limitations of Random Forest**  

⚠️ **Computationally expensive** – Requires more processing power than a single decision tree.  
⚠️ **Less interpretable than CART** – Harder to visualize decision rules.  
⚠️ **Tuning is needed** – The number of trees and feature selection must be optimized.  

::: {.rmdnote}
**When to Use RF?**  
- When CART is overfitting and needs more generalization.  
- When working with large datasets with **many predictors**.  
- When interactions between variables are complex.  
:::

---

### **B. Coding Demonstration: Random Forest in R**  

Let’s build a **Random Forest model** using the `randomForest` package.  

---

#### **Step 1: Load Libraries**  
```r
# Load necessary libraries
library(randomForest)  # For building RF models
library(dismo)         # For SDM datasets
library(caret)         # For model evaluation
```

---

#### **Step 2: Load and Prepare Data**  
We will use the **bioclim** dataset from `dismo`, which contains species presence-absence data and environmental predictors.

```r
# Load example dataset
data <- dismo::bioclim

# Convert species presence into a factor (classification task)
data$presence <- as.factor(data$presence)

# View dataset structure
str(data)
```

---

#### **Step 3: Split Data into Training and Testing Sets**  
We split the data **70% for training** and **30% for testing**.

```r
# Set seed for reproducibility
set.seed(123)

# Create training and testing sets
trainIndex <- createDataPartition(data$presence, p = 0.7, list = FALSE)
train_data <- data[trainIndex, ]
test_data  <- data[-trainIndex, ]
```

---

#### **Step 4: Fit a Random Forest Model**  
Now, we train a **Random Forest model** to predict species presence.

```r
# Train a Random Forest model
rf_model <- randomForest(presence ~ bio1 + bio12 + bio5 + bio6, 
                         data = train_data, ntree = 500, 
                         importance = TRUE)

# View model summary
print(rf_model)
```

---

#### **Step 5: Evaluate Feature Importance**  
Random Forest provides **feature importance scores**, showing which environmental variables influence predictions the most.

```r
# Plot variable importance
varImpPlot(rf_model, main = "Variable Importance in Random Forest")
```

::: {.rmdtip}
**Interpretation**:  
- Higher values indicate stronger predictors.  
- **Temperature and precipitation** are often key factors in species distribution models.
:::

---

#### **Step 6: Compare RF Accuracy with CART**  

Now, we compare the accuracy of **CART vs. Random Forest**.

```r
# Predict species presence on test data
rf_predictions <- predict(rf_model, test_data)

# Compute confusion matrix
conf_matrix_rf <- confusionMatrix(rf_predictions, test_data$presence)

# Print accuracy
print(conf_matrix_rf$overall["Accuracy"])
```

If you also trained a **CART model**, compare the accuracy scores:

```r
print(conf_matrix_cart$overall["Accuracy"])  # Accuracy of CART
print(conf_matrix_rf$overall["Accuracy"])    # Accuracy of Random Forest
```

---

### **Key Observations**
- **RF should have higher accuracy** than CART.  
- **Important predictors** are ranked based on contribution to the model.  
- **More trees (ntree = 500)** generally improve model performance.  

---

### **Summary**
✅ **Random Forest is more accurate and robust than CART**.  
✅ **Feature importance helps explain which environmental factors matter**.  
✅ **Works well for SDM but is less interpretable than a single decision tree**.  

---
## **4. Gradient Boosting Machine (GBM)**  

---

### **A. Theory Explanation**  

#### **What is GBM?**  

Gradient Boosting Machine (**GBM**) is an **ensemble learning technique** that builds a series of decision trees **sequentially**. Unlike **Random Forest (RF)**, which builds trees independently, GBM focuses on **reducing errors iteratively** by learning from mistakes made by previous trees.  

#### **How GBM Works**  

1. **Starts with a weak model** (e.g., a small decision tree).  
2. **Builds new trees step by step**, each one improving the previous model by focusing on **hard-to-predict** cases.  
3. **Combines all trees** into a final model that reduces overall errors.  

GBM **optimizes predictions** by minimizing a loss function (e.g., classification error, mean squared error).  

---

### **Advantages of GBM**  

✅ **Higher predictive accuracy than CART and RF** – Learns from past mistakes and adjusts iteratively.  
✅ **Handles missing data well** – Can work with incomplete datasets without imputation.  
✅ **Works well with small datasets** – Unlike RF, it does not require large amounts of data.  

---

### **Limitations of GBM**  

⚠️ **Requires careful tuning** – Parameters like the **learning rate** and **number of trees** must be optimized.  
⚠️ **Computationally expensive** – Slower training compared to RF, especially with large datasets.  
⚠️ **Can overfit** – If too many trees are added without regularization, it may learn noise.  

::: {.rmdnote}
**When to Use GBM?**  
- When **higher accuracy** is needed than what RF or CART can provide.  
- When working with **small datasets** where RF might not perform well.  
- When you are okay with tuning model hyperparameters for better results.  
:::

---

### **B. Coding Demonstration: GBM in R**  

We will now train a **GBM model** using the `gbm` package and compare its accuracy with **CART and RF**.

---

#### **Step 1: Load Libraries**  
```r
# Load necessary libraries
library(gbm)          # For Gradient Boosting Machine
library(dismo)        # For SDM datasets
library(caret)        # For model evaluation
```

---

#### **Step 2: Load and Prepare Data**  

We use the `bioclim` dataset, which contains **species presence-absence data** and **environmental predictors**.

```r
# Load example dataset
data <- dismo::bioclim

# Convert species presence to a factor (classification task)
data$presence <- as.factor(data$presence)

# View dataset structure
str(data)
```

---

#### **Step 3: Split Data into Training and Testing Sets**  

```r
# Set seed for reproducibility
set.seed(123)

# Create training (70%) and testing (30%) sets
trainIndex <- createDataPartition(data$presence, p = 0.7, list = FALSE)
train_data <- data[trainIndex, ]
test_data  <- data[-trainIndex, ]
```

---

#### **Step 4: Train a GBM Model**  

GBM requires setting **hyperparameters**, including:  
- **Number of trees (`n.trees`)** – More trees improve performance but increase computation.  
- **Learning rate (`shrinkage`)** – Controls how much each tree contributes to the final prediction.  
- **Tree depth (`interaction.depth`)** – Controls complexity of individual trees.  

```r
# Train a GBM model
gbm_model <- gbm(presence ~ bio1 + bio12 + bio5 + bio6, 
                 data = train_data,
                 distribution = "bernoulli",  # For classification
                 n.trees = 500,  
                 shrinkage = 0.01,  
                 interaction.depth = 3,  
                 cv.folds = 5)  # Cross-validation to prevent overfitting

# Print model summary
summary(gbm_model)
```

---

#### **Step 5: Tune Hyperparameters for Optimal Performance**  

We can **optimize hyperparameters** using **cross-validation** to select the best combination of `n.trees` and `shrinkage`.

```r
# Tune the GBM model by selecting the best number of trees
best_trees <- gbm.perf(gbm_model, method = "cv")
print(paste("Optimal number of trees:", best_trees))
```

---

#### **Step 6: Compare GBM with RF and CART**  

We will **evaluate the accuracy of all models** and compare their performance.  

```r
# Make predictions on test data
gbm_predictions <- predict(gbm_model, test_data, n.trees = best_trees, type = "response")
gbm_predictions_class <- ifelse(gbm_predictions > 0.5, "1", "0")

# Generate confusion matrix for GBM
conf_matrix_gbm <- confusionMatrix(as.factor(gbm_predictions_class), test_data$presence)

# Print accuracy
print(conf_matrix_gbm$overall["Accuracy"])
```

---

#### **Final Model Comparison**  

Let’s compare **CART, RF, and GBM** by checking their accuracy scores.

```r
print(conf_matrix_cart$overall["Accuracy"])  # Accuracy of CART
print(conf_matrix_rf$overall["Accuracy"])    # Accuracy of Random Forest
print(conf_matrix_gbm$overall["Accuracy"])   # Accuracy of GBM
```

**Expected Outcome:**  
- **CART**: Lowest accuracy but easy to interpret.  
- **RF**: Better than CART, but not as optimized as GBM.  
- **GBM**: Highest accuracy after tuning hyperparameters.  

---

### **Key Observations**  
✅ **GBM is the most accurate** of the three models.  
✅ **It requires tuning**, but results improve with optimized settings.  
✅ **Random Forest is a good balance** between accuracy and computation.  
✅ **CART is useful when interpretability is more important than accuracy.**  

---

### **Summary**  

| **Model**       | **Strengths** | **Weaknesses** |
|----------------|--------------|---------------|
| **CART** | Simple and interpretable. | Overfits and has lower accuracy. |
| **RF** | More accurate and robust. | Computationally expensive. |
| **GBM** | Highest predictive power. | Slower and requires tuning. |

✅ **Use CART** when you need explainable decision rules.  
✅ **Use Random Forest** when you need high accuracy with minimal tuning.  
✅ **Use GBM** when you need **maximum predictive power** and can afford tuning.  

Next, we **compare all three models using real-world SDM applications! 🚀**

---
## **5. Model Comparison and Interpretation**  

---

### **How Do CART, RF, and GBM Compare?**  

Now that we’ve trained **Classification and Regression Trees (CART)**, **Random Forest (RF)**, and **Gradient Boosting Machine (GBM)**, it's time to evaluate their performance using **AUC (Area Under the Curve), accuracy, and feature importance**.  

Each model has its strengths and weaknesses, and we will determine the best one for different **Species Distribution Modeling (SDM)** scenarios.

---

### **Step 1: Evaluate Model Performance with AUC and Accuracy**  

#### **Calculate AUC for Each Model**  

AUC (**Area Under the Curve**) is a metric that tells us how well the model **distinguishes presence vs. absence points**. A higher AUC means better performance.

```r
library(pROC)

# Compute AUC for CART
cart_pred <- predict(cart_model, test_data, type = "prob")[,2]
cart_auc <- auc(roc(test_data$presence, cart_pred))

# Compute AUC for Random Forest
rf_pred <- predict(rf_model, test_data, type = "prob")[,2]
rf_auc <- auc(roc(test_data$presence, rf_pred))

# Compute AUC for GBM
gbm_pred <- predict(gbm_model, test_data, n.trees = best_trees, type = "response")
gbm_auc <- auc(roc(test_data$presence, gbm_pred))

# Print AUC Scores
print(paste("CART AUC:", cart_auc))
print(paste("Random Forest AUC:", rf_auc))
print(paste("GBM AUC:", gbm_auc))
```

✅ **Expected Results**:  
- **CART** → **Lowest AUC** (simpler model, more overfitting).  
- **RF** → **Better AUC** (reduces overfitting with multiple trees).  
- **GBM** → **Best AUC** (iterative learning improves accuracy).  

---

#### **Compare Accuracy Across Models**  

```r
# Print accuracy for CART, RF, and GBM
print(conf_matrix_cart$overall["Accuracy"])  # CART
print(conf_matrix_rf$overall["Accuracy"])    # Random Forest
print(conf_matrix_gbm$overall["Accuracy"])   # GBM
```

✅ **Expected Outcome**: GBM **should have the highest accuracy**, followed by **Random Forest**, with **CART having the lowest accuracy**.

---

### **Step 2: Compare Feature Importance**  

Feature importance helps us **understand which environmental variables are most influential** in predicting species presence.

```r
# Plot feature importance for Random Forest
varImpPlot(rf_model, main = "Feature Importance - Random Forest")

# Feature importance for GBM
summary(gbm_model)
```

✅ **What to Look For?**  
- If **temperature (bio1)** is highly important, it suggests the species' distribution is temperature-sensitive.  
- If **precipitation (bio12)** is important, it indicates a reliance on moisture.  
- **GBM and RF should rank similar variables highly**, but CART may have fewer features.  

---

### **Step 3: Visualizing Model Performance**  

To compare model outputs, we can **plot ROC curves** for all three models.

```r
# Plot ROC curves
plot(roc(test_data$presence, cart_pred), col = "red", main = "ROC Curve Comparison")
plot(roc(test_data$presence, rf_pred), col = "blue", add = TRUE)
plot(roc(test_data$presence, gbm_pred), col = "green", add = TRUE)
legend("bottomright", legend = c("CART", "Random Forest", "GBM"), col = c("red", "blue", "green"), lwd = 2)
```

✅ **Expected Observations**:  
- The **green line (GBM)** should have the highest curve (best performance).  
- The **blue line (RF)** should be better than **CART (red)**.  

---

### **Step 4: Selecting the Best Model for Different SDM Scenarios**  

| **Scenario**                        | **Best Model** | **Reason** |
|--------------------------------------|---------------|------------|
| **Quick, explainable rules**         | **CART**      | Simple, interpretable |
| **General purpose SDM**              | **RF**        | Good balance of accuracy & stability |
| **Highest predictive power needed**  | **GBM**       | Best accuracy but needs tuning |
| **Large datasets with many predictors** | **RF** or **GBM** | Handles many variables well |
| **Limited computation resources**    | **CART**      | Runs faster than RF/GBM |

✅ **Takeaway**:  
- Use **CART for interpretation**.  
- Use **Random Forest for accuracy with minimal tuning**.  
- Use **GBM for the best performance** (if computational resources allow).  

---

### **Final Thoughts**  

- **CART** is simple but prone to **overfitting** and lower accuracy.  
- **Random Forest** reduces overfitting, improves accuracy, and is a **great general-purpose SDM model**.  
- **GBM** provides **the best accuracy** but requires **more tuning** and computational power.  

---
