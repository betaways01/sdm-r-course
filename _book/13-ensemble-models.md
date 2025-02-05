# Ensemble Models
---

## **1. Introduction to Ensemble Models**  

---

### **What Are Ensemble Models?**  

Ensemble models combine predictions from multiple models to **increase accuracy, stability, and generalization**. Instead of relying on a single model, ensembles aggregate results from different models to produce a more **robust** prediction.  

Ensemble methods are particularly useful in **Species Distribution Modeling (SDM)** because different algorithms may capture different aspects of species-environment relationships.  

---

### **Why Use Ensemble Approaches in SDM?**  

📌 **Single models may be biased** – Different SDM algorithms have strengths and weaknesses.  
📌 **Combining models improves reliability** – Ensembles reduce overfitting and increase prediction stability.  
📌 **More realistic ecological interpretations** – Reducing uncertainty in predictions makes results more reliable for conservation planning.  

✅ **Example**: If a species’ distribution is predicted differently by **MaxEnt (presence-only) and Random Forest (presence-absence)**, an ensemble model can **blend** both predictions for a better outcome.  

---

### **Advantages Over Single-Model Predictions**  

| **Advantage**      | **Explanation** |
|--------------------|----------------|
| **Increased Accuracy** | Aggregating models reduces individual errors. |
| **Better Generalization** | Prevents overfitting to training data. |
| **Reduced Uncertainty** | Multiple models provide more stable predictions. |
| **Improved Ecological Interpretability** | More robust predictions across different environmental gradients. |

✅ **Takeaway**: Ensemble models are widely used in **machine learning and ecology** to improve species distribution predictions.  

---

## **2. Types of Ensemble Methods**  

There are four common **ensemble modeling techniques** used in SDM.  

---

### **1. Bagging (Bootstrap Aggregating)**  

Bagging creates multiple versions of the same model by training them on **different random subsets of the data** and then averaging their predictions.  

📌 **Example**: **Random Forest** is a bagging method that builds multiple decision trees and averages their outputs.  

✅ **Reduces variance** and prevents overfitting.  
✅ Works well for **presence-absence models**.  

---

### **2. Boosting**  

Boosting builds models **sequentially**, where each new model **learns from the errors of the previous models** to improve performance.  

📌 **Example**: **Gradient Boosting Machine (GBM)** sequentially refines weak learners into a strong model.  

✅ Improves **accuracy** by learning from mistakes.  
✅ Works well with **complex, nonlinear relationships**.  

---

### **3. Stacking (Model Stacking)**  

Stacking is a **meta-learning approach** that combines predictions from multiple models and **trains another model to learn which predictions to trust more**.  

📌 **Example**: Combining **MaxEnt, Random Forest, and GBM** into a final predictive model.  

✅ Learns the **best combination of models** for optimal predictions.  
✅ Reduces **individual model biases**.  

---

### **4. Weighted Ensemble Models**  

Instead of treating all models equally, **weighted ensembles** assign different weights to different models based on **performance metrics** (e.g., AUC, TSS).  

📌 **Example**: If **MaxEnt** performs best for presence-only data, it gets a **higher weight** than CART or GBM in the final ensemble.  

✅ Balances **strengths and weaknesses** of different models.  
✅ Can be **customized** based on model reliability.  

---

### **Summary: Choosing the Right Ensemble Method**  

| **Ensemble Method** | **Best For** | **Key Benefit** |
|--------------------|------------|--------------|
| **Bagging (RF)** | Presence-Absence Data | Reduces overfitting |
| **Boosting (GBM)** | Complex SDM Patterns | Increases accuracy |
| **Stacking** | Combining Multiple SDM Models | Improves predictive power |
| **Weighted Ensembles** | Balancing Model Contributions | Reduces bias |


---

## **3. Implementing Ensemble Models in R**  

In this section, we will **train multiple Species Distribution Models (SDMs)** using **CART, Random Forest (RF), Gradient Boosting Machine (GBM), and MaxEnt**, then **combine their predictions into an ensemble model** for improved accuracy and robustness.

---

### **Step 1: Load Necessary Libraries**  
```r
# Load required libraries
library(dismo)        # For species distribution modeling
library(rpart)        # CART (Decision Tree)
library(randomForest) # Random Forest
library(gbm)         # Gradient Boosting Machine
library(caret)       # Model training and evaluation
library(ENMeval)     # MaxEnt modeling
library(terra)       # Handling raster data
```

---

### **Step 2: Load and Prepare Data**  

We will use **presence-absence data** from `dismo::bioclim` and **environmental predictors**.

```r
# Load species data
data <- dismo::bioclim

# Convert presence to a factor (classification task)
data$presence <- as.factor(data$presence)

# Split into Training and Testing Sets (70% Training, 30% Testing)
set.seed(123)
trainIndex <- createDataPartition(data$presence, p = 0.7, list = FALSE)
train_data <- data[trainIndex, ]
test_data  <- data[-trainIndex, ]
```

---

### **Step 3: Train Individual SDM Models**  

#### **1. CART Model (Decision Tree)**
```r
cart_model <- rpart(presence ~ ., data = train_data, method = "class")
cart_pred <- predict(cart_model, test_data, type = "prob")[,2]  # Probability of presence
```

---

#### **2. Random Forest Model**
```r
rf_model <- randomForest(presence ~ ., data = train_data, ntree = 500, importance = TRUE)
rf_pred <- predict(rf_model, test_data, type = "prob")[,2]  # Probability of presence
```

---

#### **3. Gradient Boosting Machine (GBM)**
```r
gbm_model <- gbm(presence ~ ., data = train_data, distribution = "bernoulli", 
                 n.trees = 500, shrinkage = 0.01, interaction.depth = 3)
gbm_pred <- predict(gbm_model, test_data, n.trees = 500, type = "response")
```

---

#### **4. MaxEnt Model (Presence-Only)**
```r
# Prepare data for MaxEnt
presence_points <- train_data[train_data$presence == 1, c("lon", "lat")]
background_points <- randomPoints(predictors, 500)  # Generate background points

# Train MaxEnt model
maxent_model <- maxent(predictors, presence_points)

# Predict probabilities
maxent_pred <- predict(maxent_model, test_data)
```

---

### **Step 4: Combine Predictions into an Ensemble Model**  

We will use a **simple mean ensemble** by averaging the probability predictions from all models.

```r
# Combine model predictions
ensemble_pred <- (cart_pred + rf_pred + gbm_pred + maxent_pred) / 4
```

Alternatively, **weighted ensembles** can be used by giving higher weights to models with better AUC scores.

```r
# Compute AUC scores for each model
library(pROC)
auc_cart <- auc(roc(test_data$presence, cart_pred))
auc_rf <- auc(roc(test_data$presence, rf_pred))
auc_gbm <- auc(roc(test_data$presence, gbm_pred))
auc_maxent <- auc(roc(test_data$presence, maxent_pred))

# Compute weighted ensemble based on AUC
total_auc <- auc_cart + auc_rf + auc_gbm + auc_maxent
weights <- c(auc_cart, auc_rf, auc_gbm, auc_maxent) / total_auc
ensemble_pred_weighted <- (weights[1] * cart_pred + 
                           weights[2] * rf_pred + 
                           weights[3] * gbm_pred + 
                           weights[4] * maxent_pred)
```

---

### **Step 5: Evaluate Ensemble Performance vs. Individual Models**  

#### **1. Compute AUC Scores**
```r
auc_ensemble <- auc(roc(test_data$presence, ensemble_pred))
auc_weighted_ensemble <- auc(roc(test_data$presence, ensemble_pred_weighted))

print(paste("CART AUC:", auc_cart))
print(paste("Random Forest AUC:", auc_rf))
print(paste("GBM AUC:", auc_gbm))
print(paste("MaxEnt AUC:", auc_maxent))
print(paste("Simple Ensemble AUC:", auc_ensemble))
print(paste("Weighted Ensemble AUC:", auc_weighted_ensemble))
```

#### **2. Compare Accuracy**
```r
# Convert probabilities to presence/absence using 0.5 threshold
ensemble_pred_class <- ifelse(ensemble_pred > 0.5, "1", "0")
weighted_ensemble_pred_class <- ifelse(ensemble_pred_weighted > 0.5, "1", "0")

# Compute accuracy for each model
accuracy_ensemble <- sum(ensemble_pred_class == test_data$presence) / nrow(test_data)
accuracy_weighted_ensemble <- sum(weighted_ensemble_pred_class == test_data$presence) / nrow(test_data)

print(paste("Ensemble Accuracy:", accuracy_ensemble))
print(paste("Weighted Ensemble Accuracy:", accuracy_weighted_ensemble))
```

✅ **Expected Results**:  
- The **ensemble models should outperform individual models**.  
- **Weighted ensembles** should perform **better than simple averaging** because they prioritize **better-performing models**.  

---

### **Summary: Ensemble Modeling in SDM**  

| **Model**    | **Strengths** | **Weaknesses** |
|-------------|-------------|--------------|
| **CART** | Simple & interpretable | Lower accuracy |
| **Random Forest (RF)** | Reduces overfitting | Computationally expensive |
| **GBM** | High predictive accuracy | Requires tuning |
| **MaxEnt** | Works with presence-only data | Can't model true absences |
| **Ensemble (Mean)** | Balances strengths of all models | May treat weaker models equally |
| **Weighted Ensemble** | Prioritizes stronger models | Requires AUC-based weighting |

✅ **Final Takeaway**:  
- **Simple averaging** of models is an **easy way to improve accuracy**.  
- **Weighted ensembles** provide **even better performance** by giving **higher importance to stronger models**.  

---
## **4. Benefits and Limitations of Ensemble Models**  

---

### **Benefits of Ensemble Models**  

Ensemble models provide significant improvements over single-model predictions, making them valuable for **Species Distribution Modeling (SDM)**.  

✅ **Improved Accuracy**  
- By combining multiple models, ensembles capture **different aspects of species-environment relationships**, leading to **better predictions**.  
- **Example**: If MaxEnt overpredicts species presence and RF underpredicts, the ensemble **balances** these biases.  

✅ **Reduced Overfitting**  
- Individual models (e.g., **CART**) may overfit to training data, but ensembles **smooth out inconsistencies**.  
- Methods like **bagging (RF)** and **boosting (GBM)** prevent models from learning noise.  

✅ **Better Generalization to New Data**  
- Combining models makes predictions **more stable** across different environmental conditions.  
- **Example**: If a single model performs poorly in certain regions, others in the ensemble compensate.  

✅ **More Robust Predictions for Conservation**  
- When SDMs are used for conservation planning, **reducing uncertainty is crucial**.  
- **Example**: In habitat suitability mapping, ensembles minimize the risk of **false negatives** (missing critical habitats).  

---

### **Limitations of Ensemble Models**  

⚠️ **Increased Computational Cost**  
- Training multiple models requires **more processing power and time**.  
- **Example**: Running **CART, RF, GBM, and MaxEnt together** takes longer than a single MaxEnt model.  

⚠️ **Model Complexity**  
- Understanding **why** an ensemble makes a prediction is harder than understanding a **single decision tree (CART)**.  
- **Solution**: Feature importance analysis can **help interpret which variables matter most**.  

⚠️ **Difficult Interpretation**  
- Some stakeholders (e.g., policymakers, conservation planners) prefer **simple, interpretable models**.  
- **Example**: A single **decision tree (CART)** is easy to explain, while a complex **GBM ensemble** is not.  

✅ **Takeaway**:  
Use ensembles **when accuracy is critical** but be mindful of **computational costs and interpretability challenges**.  

---

## **5. Summary & Best Practices**  

### **When to Use Ensemble Models in SDM**  

📌 When **multiple models provide different results**, and we need a **consensus prediction**.  
📌 When we want to **reduce uncertainty** in species distribution maps.  
📌 When working with **complex environmental datasets** where single models struggle.  
📌 When prioritizing **accuracy over interpretability** (e.g., conservation planning).  

---

### **Recommended Workflow for Building and Evaluating Ensembles**  

✅ **Step 1: Train Multiple Models**  
- Use **CART, RF, GBM, and MaxEnt** to generate individual predictions.  

✅ **Step 2: Select the Best Models**  
- Remove models that perform poorly (low **AUC, TSS, or Kappa** scores).  

✅ **Step 3: Combine Predictions Using an Ensemble Approach**  
- **Simple averaging** (mean of all models).  
- **Weighted averaging** (assign higher weight to better-performing models).  

✅ **Step 4: Evaluate Ensemble Performance**  
- Compare ensemble **AUC and accuracy** with individual models.  
- Use **response curves** to check ecological validity.  

✅ **Step 5: Visualize and Interpret Results**  
- Generate **ensemble suitability maps** and compare with individual model maps.  
- Ensure **predictions align with ecological expectations**.  

---

### **How to Select the Best Models for Ensemble Predictions?**  

| **Scenario** | **Best Approach** |
|-------------|-------------------|
| **High Interpretability Needed** | Use **CART + RF** (decision trees are easier to explain). |
| **Presence-Only Data** | Use **MaxEnt + GBM** (handles presence-background data well). |
| **Max Accuracy Required** | Use **Weighted Ensemble (GBM + RF)**. |
| **Computationally Limited** | Use **Random Forest (RF)** (avoids training multiple models). |

✅ **Final Takeaway**  
- Ensemble models provide **higher accuracy, reduced overfitting, and better generalization**.  
- However, they require **more computation** and can be **harder to interpret**.  
- Choose the **right ensemble approach** based on **your dataset and conservation goals**.  
