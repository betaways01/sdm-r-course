# Exercise

## **Exercise: Building and Interpreting a MaxEnt Model**

In this exercise, you will build a **MaxEnt model** to predict the distribution of a species using occurrence data and environmental predictors provided by the `dismo` package.

---

### **Objectives**
1. Load and explore occurrence data and environmental predictors.
2. Fit a MaxEnt model to predict the species distribution.
3. Generate and visualize a habitat suitability map.
4. Evaluate the model using AUC and interpret the results.

---

### **Step 1: Load Required Libraries**
Load the necessary libraries for building and visualizing the MaxEnt model.
```r
# Load required libraries
library(dismo)  # For MaxEnt modeling
library(raster) # For spatial raster data
library(maps)   # For base map visualization
```

---

### **Step 2: Load Occurrence Data**
The `dismo` package includes occurrence data for **Bradypus variegatus** (a species of sloth). Your task is to:
- Load the data.
- Extract latitude and longitude columns.
- Visualize the occurrence points on a world map.
```r
# Load occurrence data
occurrence_file <- system.file("ex", "bradypus.csv", package = "dismo")
occurrences <- read.csv(occurrence_file)

# Keep only longitude and latitude columns
occurrences <- occurrences[, 2:3]
colnames(occurrences) <- c("lon", "lat")

# Visualize occurrences on a map
map("world", col = "gray90", fill = TRUE, bg = "lightblue", lwd = 0.5)
points(occurrences, col = "red", pch = 20, cex = 0.8)
```

---

### **Step 3: Load Environmental Predictors**
Environmental predictors (e.g., temperature, precipitation) are provided as raster layers in the `dismo` package. Your task is to:
- Load and stack the predictors.
- Visualize one layer to understand the data.

```r
# Load and stack environmental predictors
path <- system.file("ex", package = "dismo")
predictor_files <- list.files(path, pattern = "grd$", full.names = TRUE)
predictors <- stack(predictor_files)

# Visualize one predictor layer
plot(predictors[[1]], main = "Environmental Predictor: Layer 1")
```

---

### **Step 4: Fit a MaxEnt Model**
Use the **`maxent`** function to build a MaxEnt model using the occurrence data and environmental predictors.

```r
# Fit the MaxEnt model
maxent_model <- maxent(predictors, occurrences)

# View model summary
print(maxent_model)
```

---

### **Step 5: Generate a Habitat Suitability Map**
Use the fitted model to predict habitat suitability across the study area and visualize the output.

```r
# Predict habitat suitability
suitability_map <- predict(maxent_model, predictors)

# Visualize the suitability map
plot(suitability_map, main = "MaxEnt Habitat Suitability Map")
map("world", add = TRUE, col = "gray", lwd = 0.5)
```

---

### **Step 6: Evaluate the Model**
Evaluate the model’s performance using **AUC**.

1. Extract suitability values at occurrence points.
2. Generate random background points and extract their suitability values.
3. Combine the predictions and calculate the **AUC**.

```r
# Extract predictions for presence and background points
presence_values <- extract(suitability_map, occurrences)
background_points <- randomPoints(predictors, 500)  # Generate 500 background points
background_values <- extract(suitability_map, background_points)

# Combine predictions
labels <- c(rep(1, length(presence_values)), rep(0, length(background_values)))
predictions <- c(presence_values, background_values)

# Evaluate using AUC
library(pROC)
roc_curve <- roc(labels, predictions)
plot(roc_curve, main = "ROC Curve for MaxEnt Model")
auc_value <- auc(roc_curve)
print(paste("AUC:", auc_value))
```

---

## **Questions**
1. What do the high-suitability areas on the map represent? How do they align with your knowledge of Bradypus variegatus habitat?
2. What does the AUC value tell you about the model’s performance?
3. What steps could you take to improve this model (e.g., addressing sampling bias or selecting different predictors)?

---

## **Challenge (Optional)**
- Modify the background point selection to focus on areas near occurrence points (e.g., using a buffer).
- Try using a subset of predictors and compare the results.
- Use cross-validation to assess model performance.

--- 

Happy modeling! 🚀
