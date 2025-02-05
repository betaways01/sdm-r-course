# GBM Variable Selection

---

## **1. Introduction to Variable Selection in GBM**  

---

### **Why Variable Selection Matters in GBM for SDM**  

Gradient Boosting Machines (**GBM**) are powerful for **Species Distribution Modeling (SDM)**, but they can become **computationally expensive** and **prone to overfitting** when too many predictors are included. Selecting the most important environmental variables improves:  

✅ **Model Accuracy** – Reduces noise from irrelevant predictors.  
✅ **Model Simplicity** – Fewer variables make the model easier to interpret.  
✅ **Faster Computation** – Training and predictions become more efficient.  
✅ **Better Generalization** – The model performs well on unseen data.  

---

### **Challenges of Using Too Many Predictors**  

While GBM can handle many variables, **not all predictors contribute equally** to the model. Using too many predictors leads to:  

⚠️ **Overfitting** – The model memorizes noise instead of learning general patterns.  
⚠️ **Longer Training Time** – More variables mean more computations, slowing down model fitting.  
⚠️ **Difficult Interpretation** – It becomes harder to explain why the model makes certain predictions.  
⚠️ **Collinearity Issues** – Highly correlated variables can distort the model’s ability to learn independent relationships.  

::: {.rmdnote}
**Example of a Poorly Selected Model**  
Imagine modeling the distribution of a bird species with **20 climate variables**. If **10 of them are highly correlated**, the model might give **redundant or misleading predictions**, overcomplicating interpretation.
:::

---

### **Goal: Selecting the Most Relevant Environmental Variables**  

The aim of **variable selection** in GBM is to:  

🔹 **Identify which predictors strongly influence species distribution**.  
🔹 **Remove weak or redundant variables** that add noise.  
🔹 **Ensure the selected variables align with ecological understanding**.  

---

### **What’s Next?**  

In the next section, we will explore different **methods for selecting the best variables** for GBM models. These include:  

📌 **Feature Importance Scores** – Identify which variables matter most.  
📌 **Recursive Feature Elimination (RFE)** – Iteratively remove the weakest variables.  
📌 **Correlation Analysis** – Avoid redundancy by removing correlated predictors.  
📌 **Cross-Validation-Based Selection** – Keep only variables that improve test set performance.  

🚀 **Let’s dive into the different selection methods!**  

---
## **2. Methods for Variable Selection in GBM**  

---

Selecting the right predictors is essential for **efficient and accurate** species distribution modeling (**SDM**) using **Gradient Boosting Machines (GBM)**. Below are five key methods used to identify and retain the most relevant environmental variables.

---

### **1. Feature Importance Scores**  

GBM automatically assigns an **importance score** to each variable based on how often it is used to split the data across decision trees. 

🔹 **High-importance variables** contribute significantly to model accuracy.  
🔹 **Low-importance variables** can be removed to simplify the model without reducing performance.  

**How to use it?**  
- Train an initial **GBM model** using all predictors.  
- Extract **feature importance rankings** and remove the weakest variables.  

::: {.rmdtip}
**When to Use This?**  
Use feature importance as the **first step** before applying other variable selection methods.
:::

---

### **2. Recursive Feature Elimination (RFE)**  

Recursive Feature Elimination (**RFE**) is an iterative approach where the **least important** variables are removed **one by one**, and the model is retrained each time.  

🔹 Helps identify the **optimal number of variables**.  
🔹 Ensures **weak predictors do not dilute model accuracy**.  

**How to use it?**  
- Start with all predictors and rank their importance.  
- Remove the **least important variable** and retrain the GBM model.  
- Repeat until performance no longer improves.

::: {.rmdcaution}
**Downside:**  
RFE is computationally expensive because the model is retrained multiple times.
:::

---

### **3. Correlation Analysis**  

Many environmental variables (e.g., **temperature, precipitation**) are **highly correlated**, which can distort GBM’s ability to learn independent patterns.  

🔹 **Goal**: Identify and remove redundant variables.  
🔹 **Solution**: Use a **correlation matrix** and **Variance Inflation Factor (VIF)** to detect collinearity.  

**How to use it?**  
- Compute **correlation coefficients** between predictors.  
- If two variables are **highly correlated** (r > 0.7), remove one.  

::: {.rmdnote}
**Example:**  
If **Bio1 (Annual Mean Temperature)** and **Bio5 (Maximum Temperature of the Warmest Month)** are highly correlated, keep only one.
:::

---

### **4. AIC/BIC Model Comparison**  

Model selection using **Akaike Information Criterion (AIC)** or **Bayesian Information Criterion (BIC)** helps determine the best predictor set based on **model complexity vs. accuracy**.

🔹 **AIC** favors models with **fewer predictors** while maintaining accuracy.  
🔹 **BIC** penalizes models with **too many variables**, ensuring simplicity.  

**How to use it?**  
- Fit GBM models with different sets of variables.  
- Compute AIC/BIC scores for each model.  
- Select the model with the **lowest AIC/BIC score**.

::: {.rmdtip}
**Best Practice:**  
Use AIC/BIC **alongside feature importance and correlation analysis** for optimal variable selection.
:::

---

### **5. Cross-Validation-Based Selection**  

Cross-validation ensures that variable selection improves **real-world predictive performance**, not just training accuracy.  

🔹 **Goal**: Keep only predictors that improve **test set performance**.  
🔹 **Method**: Use **AUC (Area Under Curve) and Accuracy** on a **validation dataset**.  

**How to use it?**  
- Train a **GBM model with all variables**.  
- Remove a predictor and **check if AUC/accuracy decreases**.  
- Keep only the variables that **consistently improve test set predictions**.

::: {.rmdcaution}
**Warning:**  
Cross-validation can be **computationally expensive** but ensures the final model is robust.
:::

---

### **Summary of Variable Selection Methods**

| **Method**                      | **When to Use**                             | **Pros**                                      | **Cons**                                      |
|----------------------------------|--------------------------------------------|----------------------------------------------|----------------------------------------------|
| **Feature Importance Scores**    | First step for identifying key variables.  | Quick and easy.                              | May not remove all redundant variables.      |
| **Recursive Feature Elimination (RFE)** | When you want the best subset of features. | Finds optimal variable set.                  | Computationally expensive.                   |
| **Correlation Analysis**         | To remove redundant variables.             | Improves model stability.                     | Doesn’t detect weakly correlated but irrelevant features. |
| **AIC/BIC Model Comparison**     | When balancing accuracy and simplicity.    | Ensures model is not overly complex.         | May remove useful predictors if over-penalized. |
| **Cross-Validation Selection**   | To optimize test set performance.          | Ensures best real-world predictions.         | Computationally expensive.                   |

---

### **What’s Next?**  

Now that we understand **methods for variable selection**, we will move to the **coding demonstration**, applying these techniques in R to improve a **GBM-based species distribution model**. 🚀
---
## **3. Coding Demonstration: Variable Selection in GBM**  

This coding exercise will guide you through the process of **selecting the most important variables** for a **GBM-based Species Distribution Model (SDM)** in R. We will use built-in datasets and packages to ensure the workflow is reproducible.  

---

### **Step 1: Load an SDM Dataset with Multiple Environmental Variables**  

We will use the `bioclim` dataset from the `dismo` package, which contains species **presence-absence data** along with environmental predictors.

#### **Load Necessary Libraries**
```r
# Load required packages
library(gbm)          # Gradient Boosting Machine
library(dismo)        # SDM-related datasets
library(caret)        # Data partitioning and evaluation
library(corrplot)     # Correlation visualization
library(randomForest) # Feature importance comparison
```

#### **Load and Inspect the Dataset**
```r
# Load example SDM dataset
data <- dismo::bioclim

# Convert species presence to a factor (classification task)
data$presence <- as.factor(data$presence)

# View dataset structure
str(data)
```

---

### **Step 2: Train an Initial GBM Model with All Predictors**  

Before selecting variables, let’s train a **baseline GBM model** with all environmental predictors.

#### **Split Data into Training and Testing Sets**
```r
# Set seed for reproducibility
set.seed(123)

# Create training (70%) and testing (30%) sets
trainIndex <- createDataPartition(data$presence, p = 0.7, list = FALSE)
train_data <- data[trainIndex, ]
test_data  <- data[-trainIndex, ]
```

#### **Train the Full GBM Model**
```r
# Train an initial GBM model
gbm_full <- gbm(presence ~ ., 
                data = train_data,
                distribution = "bernoulli",  # Classification task
                n.trees = 500,  
                shrinkage = 0.01,  
                interaction.depth = 3,  
                cv.folds = 5)  # Cross-validation to prevent overfitting

# View feature importance
summary(gbm_full)
```

✅ **What to Look For?**  
- Higher scores indicate variables that contribute the most to predictions.  
- Low-importance variables should be considered for removal.  

---

### **Step 3: Compute Feature Importance Scores and Remove Low-Importance Variables**  

GBM provides **relative influence scores** for each predictor. We will remove variables that contribute little to model accuracy.

#### **Plot Feature Importance**
```r
# Visualize feature importance
barplot(summary(gbm_full)$rel.inf, names.arg = summary(gbm_full)$var, las = 2, col = "steelblue",
        main = "Feature Importance in GBM", cex.names = 0.8)
```

#### **Remove Low-Importance Variables**
```r
# Define a cutoff threshold for importance (e.g., remove variables < 2%)
important_vars <- summary(gbm_full)$var[summary(gbm_full)$rel.inf > 2]

# Retain only important variables
train_data_reduced <- train_data[, c("presence", important_vars)]
test_data_reduced  <- test_data[, c("presence", important_vars)]
```

✅ **What to Look For?**  
- The feature importance plot highlights which variables significantly impact the model.  
- Removing low-importance variables improves efficiency **without reducing accuracy**.  

---

### **Step 4: Perform Correlation Analysis to Eliminate Redundant Variables**  

Environmental predictors are often **highly correlated**, which can introduce redundancy.

#### **Compute a Correlation Matrix**
```r
# Compute correlation matrix
cor_matrix <- cor(train_data_reduced[, -1])  # Remove target variable
corrplot(cor_matrix, method = "color", type = "upper", tl.cex = 0.8, title = "Correlation Matrix")
```

#### **Remove Highly Correlated Variables (r > 0.7)**
```r
# Identify correlated pairs
high_cor <- findCorrelation(cor_matrix, cutoff = 0.7, names = TRUE)

# Remove correlated predictors
train_data_final <- train_data_reduced[, !(colnames(train_data_reduced) %in% high_cor)]
test_data_final  <- test_data_reduced[, !(colnames(test_data_reduced) %in% high_cor)]
```

✅ **Why Does This Matter?**  
- Removing highly correlated variables prevents **redundant information** in the model.  
- The **GBM model generalizes better** by relying on independent predictors.  

---

### **Step 5: Retrain GBM with Reduced Features and Compare Accuracy/AUC**  

#### **Train the Reduced GBM Model**
```r
# Train a GBM model with selected variables
gbm_reduced <- gbm(presence ~ ., 
                    data = train_data_final,
                    distribution = "bernoulli",
                    n.trees = 500,  
                    shrinkage = 0.01,  
                    interaction.depth = 3,  
                    cv.folds = 5)

# View feature importance of reduced model
summary(gbm_reduced)
```

#### **Evaluate Model Performance (AUC and Accuracy)**
```r
library(pROC)

# Predict on test set
full_pred <- predict(gbm_full, test_data, n.trees = 500, type = "response")
reduced_pred <- predict(gbm_reduced, test_data_final, n.trees = 500, type = "response")

# Compute AUC for full model
full_auc <- auc(roc(test_data$presence, full_pred))

# Compute AUC for reduced model
reduced_auc <- auc(roc(test_data_final$presence, reduced_pred))

# Print AUC Scores
print(paste("Full GBM AUC:", full_auc))
print(paste("Reduced GBM AUC:", reduced_auc))
```

#### **Compare Accuracy**
```r
# Convert predictions to binary classes
full_pred_class <- ifelse(full_pred > 0.5, "1", "0")
reduced_pred_class <- ifelse(reduced_pred > 0.5, "1", "0")

# Compute accuracy
full_acc <- sum(full_pred_class == test_data$presence) / nrow(test_data)
reduced_acc <- sum(reduced_pred_class == test_data_final$presence) / nrow(test_data_final)

print(paste("Full Model Accuracy:", full_acc))
print(paste("Reduced Model Accuracy:", reduced_acc))
```

✅ **Expected Outcome**:  
- The **reduced model should have similar AUC and accuracy** to the full model but with fewer predictors.  
- **Computation time is reduced**, making the model more efficient.  

---

### **Key Observations**
- **Feature importance analysis helps remove weak variables.**  
- **Correlation filtering prevents redundancy.**  
- **The reduced model performs as well as the full model but is more efficient.**  

---

### **Summary of GBM Variable Selection Process**  

| **Step**                      | **Purpose**                                       | **Outcome** |
|--------------------------------|---------------------------------------------------|-------------|
| **Train Full Model**           | Baseline model with all variables.               | Initial AUC and accuracy. |
| **Feature Importance Filtering** | Remove low-impact variables.                     | Simplifies model without losing accuracy. |
| **Correlation Analysis**        | Remove highly correlated predictors.             | Improves model interpretability. |
| **Train Reduced Model**        | Use only important, independent variables.       | Faster and more efficient predictions. |
| **Compare Accuracy & AUC**     | Ensure reduced model performs as well as full.   | Similar accuracy but improved efficiency. |


---
## **4. Model Evaluation After Variable Selection**  

After selecting the most relevant variables for **GBM-based Species Distribution Modeling (SDM)**, we must **evaluate the impact** of variable selection on model performance, ecological relevance, and computational efficiency.

---

### **1. Compare Model Performance Before and After Variable Selection**  

We compare the **full model (with all variables)** and the **reduced model (with selected variables)** using **AUC (Area Under Curve) and accuracy**.

#### **Code Example: AUC and Accuracy Comparison**
```r
library(pROC)

# Compute AUC for Full Model
full_pred <- predict(gbm_full, test_data, n.trees = 500, type = "response")
full_auc <- auc(roc(test_data$presence, full_pred))

# Compute AUC for Reduced Model
reduced_pred <- predict(gbm_reduced, test_data_final, n.trees = 500, type = "response")
reduced_auc <- auc(roc(test_data_final$presence, reduced_pred))

# Print AUC Scores
print(paste("Full Model AUC:", full_auc))
print(paste("Reduced Model AUC:", reduced_auc))
```

✅ **Expected Result**:  
- If the **AUC remains similar**, the **reduced model is just as effective** while being more efficient.  
- If the **AUC decreases significantly**, important predictors may have been removed.

---

### **2. Visualizing Response Curves**  

Response curves **show how environmental variables influence species suitability**. Ensuring that response curves remain **biologically meaningful** after variable selection is crucial.

#### **Code Example: Response Curve Visualization**
```r
# Plot response curves for the full model
par(mfrow = c(1,2))
plot.gbm(gbm_full, i.var = "bio1", main = "Full Model: Bio1")
plot.gbm(gbm_reduced, i.var = "bio1", main = "Reduced Model: Bio1")
```

✅ **What to Look For?**  
- **Similar response curves** between the full and reduced models indicate that key environmental drivers are preserved.  
- If response curves change drastically, an **important predictor may have been removed**.

---

### **3. Assessing Computational Efficiency Gains**  

A key advantage of **variable selection** is reducing computational time. We compare training times before and after variable selection.

#### **Code Example: Compute Training Time**
```r
# Measure time for full model
start_time <- Sys.time()
gbm_full <- gbm(presence ~ ., data = train_data, distribution = "bernoulli", n.trees = 500)
end_time <- Sys.time()
full_time <- end_time - start_time

# Measure time for reduced model
start_time <- Sys.time()
gbm_reduced <- gbm(presence ~ ., data = train_data_final, distribution = "bernoulli", n.trees = 500)
end_time <- Sys.time()
reduced_time <- end_time - start_time

# Print time comparison
print(paste("Full Model Training Time:", full_time))
print(paste("Reduced Model Training Time:", reduced_time))
```

✅ **Expected Result**:  
- **The reduced model should train faster**, improving efficiency **without losing predictive power**.  
- In large datasets, **this speed improvement can be significant**.

---

## **5. Best Practices & Common Pitfalls**  

### **1. Avoid Over-Removing Important Variables**  
- **Pitfall**: Removing **slightly less important variables** may still affect model performance.  
- **Solution**: Gradually remove variables and **compare AUC/accuracy** at each step.  

### **2. Ensure Biological/Ecological Relevance**  
- **Pitfall**: Some variables may be statistically weak but ecologically essential.  
- **Solution**: **Consult ecological knowledge** before eliminating predictors.  

::: {.rmdtip}
**Example**:  
Even if **elevation (Bio6)** has low importance, it might still be **critical for mountain species**.
:::

### **3. Balance Model Simplicity with Accuracy**  
- **Pitfall**: Keeping **too many predictors** makes the model complex and slow.  
- **Solution**: Use **AIC, BIC, or cross-validation** to find the best trade-off between **accuracy and simplicity**.  

✅ **Key Takeaway**: The goal is to **maintain high predictive power** while **removing unnecessary complexity**.

---

## **6. Summary & Key Takeaways**  

### **1. Why Variable Selection Matters**  
- Reducing redundant variables **improves model accuracy and interpretability**.  
- Removing unnecessary predictors **speeds up training and prediction times**.  

### **2. Recommended Workflow for GBM Variable Selection**  

| **Step**                   | **Purpose**                                     | **Method** |
|----------------------------|-------------------------------------------------|------------|
| **Train Full Model**       | Establish a baseline performance.              | Train GBM with all variables. |
| **Compute Feature Importance** | Identify key predictors.                  | Use GBM’s built-in importance ranking. |
| **Remove Low-Importance Variables** | Simplify the model.                 | Drop predictors with very low scores. |
| **Perform Correlation Analysis** | Eliminate redundant variables.          | Remove highly correlated predictors (r > 0.7). |
| **Retrain GBM**            | Improve computational efficiency.              | Use only selected variables. |
| **Evaluate Performance**   | Ensure no loss in predictive power.            | Compare AUC, accuracy, and response curves. |

### **3. Iterative Refinement for SDM Models**  
- **Reassess after each removal step** to avoid losing important predictors.  
- **Validate response curves** to ensure ecological interpretability.  
- **Adjust hyperparameters** to optimize performance after feature reduction.  

✅ **Final Takeaway**:  
By selecting the right variables, **GBM models remain accurate, efficient, and ecologically meaningful**, making them powerful tools for **Species Distribution Modeling (SDM)**. 🚀
