# Model Evaluation in SDM

---

## **1. Introduction to Model Evaluation**  

---

### **Why Model Evaluation is Important in SDM**  

Model evaluation is a **critical step** in **Species Distribution Modeling (SDM)** because it determines how well a model predicts the distribution of species in different environmental conditions. **Without proper evaluation, predictions may be misleading and lead to incorrect conservation decisions.**  

Model evaluation ensures that:  

✅ **The model is accurate** – Predictions match real-world observations.  
✅ **The model generalizes well** – Works on new/unseen data, not just the training set.  
✅ **Ecological validity is maintained** – Predictions align with biological knowledge.  

---

### **Key Objectives of Model Evaluation**  

1️⃣ **Assessing Accuracy** – How well does the model predict species presence/absence?  
2️⃣ **Avoiding Overfitting** – Does the model generalize to unseen data?  
3️⃣ **Ecological Relevance** – Are predictions biologically meaningful?  
4️⃣ **Comparing Multiple Models** – Which algorithm (CART, RF, GBM, MaxEnt) performs best for the dataset?  

---

### **Common Pitfalls in Model Evaluation**  

⚠️ **Overfitting**  
- The model memorizes training data instead of learning true species-environment relationships.  
- **Fix**: Use cross-validation and limit model complexity.  

⚠️ **Biased Datasets**  
- If presence records are clustered in sampled areas (e.g., near roads), the model may falsely predict that species prefer those areas.  
- **Fix**: Use **spatially explicit validation** and account for sampling bias.  

⚠️ **Improper Thresholding**  
- Using the wrong threshold for presence/absence conversion can **skew accuracy metrics**.  
- **Fix**: Experiment with different **thresholding methods** (e.g., maximum sensitivity-specificity, 10th percentile).  

::: {.rmdtip}
**Pro Tip:** Always check the **ecological plausibility** of the model. A high accuracy score does not mean the model makes biologically realistic predictions!
:::

---

## **2. Performance Metrics for Model Evaluation**  

---

### **1. Classification Metrics (For Presence/Absence Models)**  

When species data is **binary (presence = 1, absence = 0)**, we use classification metrics to measure how well the model differentiates between the two.

#### **Accuracy** – Overall correctness of predictions  
**Formula:**  
\[
Accuracy = \frac{TP + TN}{TP + TN + FP + FN}
\]
✅ **Good for balanced datasets** but **misleading for imbalanced data** (e.g., when species are rare).  

---

#### **Sensitivity (Recall)** – Ability to correctly predict species presence  
**Formula:**  
\[
Sensitivity = \frac{TP}{TP + FN}
\]
✅ **Important for conservation** because false negatives (FN) may ignore suitable habitats.  

---

#### **Specificity** – Ability to correctly predict absence  
**Formula:**  
\[
Specificity = \frac{TN}{TN + FP}
\]
✅ **Useful in understanding over-predictions** of species presence.  

---

#### **Kappa Statistic** – Agreement Beyond Random Chance  
Kappa adjusts accuracy to account for **random chance agreement**.  

**Formula:**  
\[
Kappa = \frac{Accuracy - Expected Accuracy}{1 - Expected Accuracy}
\]
✅ **More reliable than accuracy** for imbalanced datasets.  

---

### **2. Area Under the Curve (AUC-ROC & AUC-PR)**  

AUC is one of the most common evaluation metrics in **species distribution models**.

#### **ROC Curve (Receiver Operating Characteristic Curve)**  
- Plots **True Positive Rate (Sensitivity)** vs. **False Positive Rate (1 - Specificity)**  
- **Higher AUC = Better ability to distinguish presence from absence**.  

✅ **Works well for most classification tasks.**  

**Interpreting AUC Scores:**  

| **AUC Score** | **Model Performance** |
|--------------|----------------------|
| 0.5          | Random Guessing       |
| 0.7 - 0.8    | Fair                 |
| 0.8 - 0.9    | Good                 |
| 0.9 - 1.0    | Excellent            |

---

#### **Precision-Recall (PR) Curve – Best for Rare Species**  

When species are **rare**, AUC-ROC may be misleading. Instead, use the **Precision-Recall Curve**, which evaluates model performance when **absences outnumber presences**.

- **Precision** = How many predicted presences were actually correct?  
- **Recall** = Sensitivity (ability to detect all presences).  

✅ **Best when species presence is rare (e.g., endangered species).**  

---

### **3. True Skill Statistic (TSS)**  

TSS is an alternative to **AUC** that **does not depend on prevalence (species rarity)**.

**Formula:**  
\[
TSS = Sensitivity + Specificity - 1
\]

✅ **Good for ecological models where presence/absence is not evenly distributed.**  
✅ **Ranges from -1 (worse than random) to 1 (perfect prediction).**  

---

### **4. Root Mean Square Error (RMSE) for Continuous Models**  

When the **model outputs continuous suitability values (e.g., habitat suitability indices)**, RMSE measures how much **predictions deviate from actual presence/absence**.

**Formula:**  
\[
RMSE = \sqrt{\frac{\sum (Predicted - Observed)^2}{n}}
\]

✅ **Lower RMSE = Better fit.**  
✅ **Works well when comparing continuous predictions (e.g., suitability scores from MaxEnt).**  

---

## **Comparison of Model Evaluation Metrics**

| **Metric**      | **Best For**                     | **Weaknesses** |
|----------------|--------------------------------|---------------|
| **Accuracy**    | Balanced presence/absence datasets. | Misleading for imbalanced data. |
| **Sensitivity** | Conservation-focused predictions. | Can overestimate species presence. |
| **Specificity** | Preventing false positives. | Ignores presence misclassification. |
| **Kappa**       | Adjusting accuracy for chance. | Harder to interpret. |
| **AUC-ROC**     | General model evaluation. | Can be biased for rare species. |
| **AUC-PR**      | Rare species modeling. | Not commonly used in SDM. |
| **TSS**         | Presence-background models. | Less known outside ecology. |
| **RMSE**        | Continuous suitability models. | Doesn’t work for presence/absence. |

---

### **Next Steps**  

Now that we understand **model evaluation metrics**, the next section will explore **different validation techniques** (cross-validation, train-test split, and spatial validation) to ensure our models generalize well to new data. 🚀

---
## **3. Model Validation Approaches**  

---

Model validation ensures that our **Species Distribution Models (SDMs)** perform well on unseen data. Without proper validation, models may **overfit** or fail to **generalize** to real-world conditions.

---

### **1. Train-Test Split**  

**Why Use a Separate Test Set?**  
A model that fits training data well might **fail on new data**. The **train-test split** ensures that the model is evaluated on **independent data** to measure generalization.

✅ **Prevents overfitting**  
✅ **Ensures predictions are reliable**  
✅ **Used in all machine learning applications**  

#### **Code Example: Train-Test Split**
```r
# Load necessary package
library(caret)

# Split data: 70% Training, 30% Testing
set.seed(123)
trainIndex <- createDataPartition(data$presence, p = 0.7, list = FALSE)
train_data <- data[trainIndex, ]
test_data  <- data[-trainIndex, ]
```

---

### **2. Cross-Validation**  

Cross-validation is used when we **don’t want to lose data for training**. It divides the dataset into **multiple subsets** and trains the model several times to ensure stability.

---

#### **K-Fold Cross-Validation**  

- Splits data into **K folds** (e.g., **5-fold or 10-fold**).
- The model is trained on **K-1 folds** and tested on the remaining fold.
- The process repeats **K times**, and results are averaged.

✅ **More reliable than a single train-test split**  
✅ **Works well with small datasets**  

#### **Code Example: K-Fold Cross-Validation**
```r
# Perform 5-fold cross-validation
train_control <- trainControl(method = "cv", number = 5)
cv_model <- train(presence ~ ., data = train_data, method = "rf", trControl = train_control)
print(cv_model)
```

---

#### **Leave-One-Out Cross-Validation (LOOCV)**  

- Uses **one data point** as the test set and **all others** as training.
- Repeats this process for every data point.

✅ **Best for very small datasets**  
✅ **Ensures all data points contribute to validation**  
⚠️ **Computationally expensive for large datasets**  

#### **Code Example: LOOCV**
```r
# Perform Leave-One-Out Cross-Validation
train_control_loocv <- trainControl(method = "LOOCV")
loocv_model <- train(presence ~ ., data = train_data, method = "rf", trControl = train_control_loocv)
print(loocv_model)
```

---

### **3. Spatially Explicit Validation**  

Standard validation methods assume that data points are **independent**, but species occurrence points are often **spatially clustered**. **Spatially explicit validation** ensures that evaluation accounts for spatial autocorrelation.

✅ **Prevents overestimating model performance**  
✅ **Ensures the model works in unsampled areas**  

#### **Approach: Block Cross-Validation**  

- Divides the study area into **spatial blocks**.
- Uses some blocks for **training** and others for **testing**.

#### **Code Example: Spatial Cross-Validation**
```r
library(blockCV)

# Define spatial blocks
blocks <- spatialBlock(speciesData = data, theRange = 100000, k = 5)

# Perform cross-validation with spatial blocks
train_control_spatial <- trainControl(method = "cv", index = blocks$folds)
spatial_model <- train(presence ~ ., data = train_data, method = "rf", trControl = train_control_spatial)
print(spatial_model)
```

---

## **4. Visualizing Model Performance**  

Model evaluation is **easier to interpret** when results are visualized. Below are key ways to visualize model quality.

---

### **1. ROC and Precision-Recall Curves**  

#### **ROC Curve (Receiver Operating Characteristic Curve)**  
- **X-axis**: False Positive Rate  
- **Y-axis**: True Positive Rate  
- Higher **AUC** (closer to 1) indicates better performance.

#### **Code Example: Plot ROC Curve**
```r
library(pROC)

# Compute and plot ROC curve
roc_curve <- roc(test_data$presence, predict(model, test_data, type = "prob")[,2])
plot(roc_curve, main = "ROC Curve")
```

---

#### **Precision-Recall Curve**  

Best used for **imbalanced datasets** where absences outnumber presences.

#### **Code Example: Precision-Recall Curve**
```r
# Compute and plot Precision-Recall curve
pr_curve <- pr.curve(scores.class0 = predict(model, test_data, type = "prob")[,2],
                     weights.class0 = test_data$presence)
plot(pr_curve, main = "Precision-Recall Curve")
```

---

### **2. Suitability Maps and Threshold Selection**  

**Binary vs. Continuous Predictions**  
- **Continuous maps** show habitat suitability scores.  
- **Binary maps** classify suitable vs. unsuitable areas based on a threshold.  

#### **Thresholding Approaches**  
- **Maximize Sensitivity-Specificity**  
- **10th Percentile Presence Threshold** (for rare species).  

#### **Code Example: Suitability Map with Thresholding**
```r
library(raster)

# Predict suitability
suitability_map <- predict(model, raster_stack, type = "response")

# Convert to binary presence/absence using threshold
threshold <- 0.5
binary_map <- suitability_map > threshold

# Plot results
par(mfrow = c(1,2))
plot(suitability_map, main = "Continuous Suitability Map")
plot(binary_map, main = "Binary Presence/Absence Map")
```

---

### **3. Response Curves**  

Response curves show how **each environmental variable affects species predictions**.

✅ **Ensures ecological realism**  
✅ **Helps identify misleading predictors**  

#### **Code Example: Plot Response Curves**
```r
# Plot response curves for important variables
plot.gbm(model, i.var = "bio1", main = "Effect of Temperature (Bio1)")
plot.gbm(model, i.var = "bio12", main = "Effect of Precipitation (Bio12)")
```

✅ **What to Look For?**  
- Do the response curves **make ecological sense**?  
- Are important predictors showing meaningful **trends**?  

---

### **Summary: Key Model Validation & Visualization Techniques**

| **Method**                         | **Purpose**                                       | **Best For** |
|-------------------------------------|-------------------------------------------------|-------------|
| **Train-Test Split**                | Evaluates performance on unseen data. | General model validation. |
| **K-Fold Cross-Validation**         | Ensures stability across multiple splits. | Large datasets. |
| **LOOCV**                           | Uses every point for training/testing. | Small datasets. |
| **Spatial Cross-Validation**        | Prevents spatial overfitting. | SDMs with clustered data. |
| **ROC Curve**                       | Evaluates sensitivity-specificity trade-off. | Presence/absence models. |
| **Precision-Recall Curve**          | Measures performance for rare species. | Imbalanced datasets. |
| **Suitability Maps**                | Visualizes habitat suitability. | Presence-only models (e.g., MaxEnt). |
| **Response Curves**                 | Ensures predictor-response relationships make sense. | All SDMs. |

---

### **Next Steps**
Now that we have **validated the model and visualized results**, the next section will explore **comparing different SDM models (CART, RF, GBM, MaxEnt) to choose the best approach for a given dataset.** 🚀

---

## **5. Comparing Models: CART, RF, GBM, and MaxEnt**  

Selecting the best **Species Distribution Model (SDM)** depends on **data type**, **research goals**, and **computational resources**. Here, we compare **CART, Random Forest (RF), Gradient Boosting Machine (GBM), and MaxEnt** to determine when each is most useful.

---

### **1. Best Evaluation Metrics for Tree-Based vs. Presence-Background Models**  

Different model types require different evaluation metrics:  

| **Metric**      | **CART & RF (Classification)** | **GBM (Boosting)** | **MaxEnt (Presence-Only)** |
|----------------|------------------------------|-------------------|--------------------------|
| **Accuracy**   | ✅ Good for presence/absence | ✅ Works well | ❌ Not applicable |
| **AUC-ROC**    | ✅ Good for all classification models | ✅ Strong predictor | ✅ Best for MaxEnt |
| **Precision-Recall** | ✅ Works for imbalanced data | ✅ Works for boosting models | ✅ Works for presence-only data |
| **TSS**        | ✅ Useful in SDMs | ✅ More informative than accuracy | ✅ Common in presence-background models |
| **Response Curves** | ✅ Helps interpret variable impact | ✅ Useful for interpretation | ✅ Essential for ecological validation |

✅ **Takeaway**: **MaxEnt relies more on AUC and presence-background validation**, while tree-based methods use **accuracy and classification metrics**.  

---

### **2. When to Use Different SDM Models?**  

| **Model**    | **Best Used For** | **Advantages** | **Disadvantages** |
|-------------|------------------|---------------|------------------|
| **CART** | Simple rules-based classification. | Easy to interpret. | Prone to overfitting. |
| **Random Forest (RF)** | Presence-absence classification. | Handles nonlinear relationships, reduces overfitting. | Computationally expensive. |
| **GBM** | High-accuracy modeling. | Best predictive power. | Requires tuning, slow training. |
| **MaxEnt** | Presence-only data modeling. | Handles small datasets, works without absence data. | Cannot model true absence data. |

✅ **Takeaway**:  
- **Use CART when interpretability is key.**  
- **Use RF for balanced presence-absence classification.**  
- **Use GBM when maximum accuracy is needed.**  
- **Use MaxEnt when only presence data is available.**  

---

### **3. Performance Trade-Offs: Interpretability vs. Accuracy vs. Computational Cost**  

| **Factor**   | **CART** | **RF** | **GBM** | **MaxEnt** |
|-------------|---------|--------|--------|---------|
| **Interpretability** | ✅ Very High | ❌ Harder to interpret | ❌ Harder to interpret | ✅ Response curves help interpret results |
| **Accuracy** | ❌ Low | ✅ High | ✅ Very High | ✅ High for presence-only |
| **Computational Cost** | ✅ Fast | ❌ Medium-High | ❌ High | ✅ Efficient for presence-only |

✅ **Takeaway**:  
- **Use CART when interpretability is more important than accuracy.**  
- **Use RF/GBM when accuracy is the priority.**  
- **Use MaxEnt when working with presence-only data and computational efficiency is needed.**  

---

## **6. Common Pitfalls in Model Evaluation**  

Even when models perform well, **several pitfalls** can lead to misleading results.

### **1. Overfitting: When a Model is Too Complex and Fails to Generalize**  

⚠️ **Problem**: A model that fits training data perfectly but performs poorly on new data.  

🔹 **Solution**:  
- Use **cross-validation** to ensure generalization.  
- **Regularization** in GBM and MaxEnt prevents overfitting.  
- **Limit tree depth** in CART and RF.  

---

### **2. Ignoring Spatial Bias: Why Presence Points Should Be Spatially Independent**  

⚠️ **Problem**:  
- If presence records **cluster near roads or specific locations**, the model may falsely learn that species prefer those areas.  

🔹 **Solution**:  
- Use **spatial cross-validation** instead of random splits.  
- **Apply bias correction** in MaxEnt to adjust for sampling effort.  

---

### **3. Improper Thresholding: Setting Unrealistic Suitability Cutoffs**  

⚠️ **Problem**:  
- Converting **continuous suitability scores** into **binary presence-absence maps** using arbitrary thresholds.  

🔹 **Solution**:  
- Use **Maximize Sensitivity-Specificity Thresholding**.  
- Compare **multiple thresholding methods** to select the most meaningful.  

✅ **Takeaway**: Always validate threshold selection with ecological knowledge.  

---

## **7. Summary & Best Practices**  

### **Key Takeaways from Model Evaluation**  
- **Different models require different evaluation metrics** – RF/GBM rely on classification metrics, while MaxEnt uses presence-background validation.  
- **Choose models based on data availability** – Presence-absence models work well for classification, while MaxEnt is best for presence-only data.  
- **Avoid common pitfalls** – Overfitting, spatial bias, and improper thresholding can reduce model reliability.  

---

### **Recommended Workflow for Assessing SDM Performance**  

✅ **Step 1: Choose an SDM Model Based on Data Type**  
- Use **CART, RF, or GBM for presence-absence**.  
- Use **MaxEnt for presence-only data**.  

✅ **Step 2: Apply Proper Validation Techniques**  
- Use **Train-Test Splitting** or **Cross-Validation** for presence-absence models.  
- Use **Spatial Cross-Validation** when presence points are clustered.  

✅ **Step 3: Select the Right Performance Metrics**  
- **Accuracy, Sensitivity, Specificity, Kappa** for RF/GBM.  
- **AUC, TSS, PR-Curve** for MaxEnt.  

✅ **Step 4: Interpret Results Ecologically**  
- Ensure that **response curves make biological sense**.  
- Check that **species presence is predicted in ecologically relevant areas**.  

---

### **Iterative Improvements: How to Refine Models Based on Evaluation Results**  

🔄 **If AUC is low** → Try different feature selection methods.  
🔄 **If overfitting occurs** → Reduce model complexity (e.g., increase regularization in GBM, limit tree depth in RF).  
🔄 **If presence points are biased** → Use spatially explicit validation.  

✅ **Final Takeaway**:  
By following **best practices in model evaluation**, you ensure that **species distribution models are robust, accurate, and ecologically meaningful**. 🚀
