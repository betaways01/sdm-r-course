# Maxent Bias Correction

---

### **1. Introduction to Bias in MaxEnt Models**

---

#### **What is Bias?**

Bias in MaxEnt models refers to **errors or distortions** that arise during data collection or modeling, leading to **inaccurate predictions** about species distributions. Bias can occur due to several reasons, such as **uneven sampling efforts** or environmental conditions that are not uniformly represented.

---

#### **Impact of Bias**

Bias can significantly affect your model's predictions:

- **Over-representation of specific areas**: If most species occurrence points are from easily accessible areas (e.g., near roads), the model may predict those areas as highly suitable even when they are not.
- **Under-representation of important habitats**: Regions that are rarely sampled may be overlooked, even if they are critical for the species.
- **Incorrect response curves**: The relationships between species and environmental variables may not reflect their true ecological preferences.

---

#### **Why Is Bias Correction Important?**

Correcting bias is essential for **reliable and meaningful predictions**. Without addressing bias:

- The model may overfit to areas with more data, reducing its ability to generalize to other regions.
- Conservation efforts could be misdirected, focusing on areas that are not genuinely suitable for the species.

---

### **Callout Blocks to Clarify Key Points**

::: {.rmdnote}
**Key Insight**: Bias can distort suitability maps, making areas with more occurrence points seem more favorable for the species.
:::

::: {.rmdtip}
**Pro Tip**: Always examine your occurrence data for patterns that suggest bias, such as clustering near roads or urban centers.
:::

---

#### **Real-Life Example**

Imagine you're modeling the habitat of a bird species using occurrence data. Most sightings are reported near cities because they are easier to access. Without correcting for this sampling bias, your model might predict that urban areas are more suitable for the species, even if the bird prefers forests.

---

#### **Simple Visualization**

To demonstrate the impact of bias, you can create a **scatter plot** of occurrence points overlaid on environmental predictors (e.g., temperature or elevation). This plot can highlight clustering in specific areas, indicating sampling bias.

```r
# Example Visualization in R
library(ggplot2)
data(maps)  # Built-in map data
ggplot() +
  borders("world", colour = "gray85", fill = "gray80") +
  geom_point(data = occurrence_data, aes(x = lon, y = lat), color = "red", size = 1.5) +
  theme_minimal() +
  ggtitle("Distribution of Occurrence Points") +
  labs(x = "Longitude", y = "Latitude")
```

This simple plot helps visualize if occurrence points are evenly distributed or biased toward specific regions.

---

#### **Summary**

Bias in MaxEnt models is a common challenge but can be addressed effectively with proper techniques. Recognizing and correcting sampling and spatial biases ensures that your models produce reliable predictions and support informed conservation decisions.

---

### **2. Types of Bias**

---

#### **1. Sampling Bias**

Sampling bias occurs when species occurrence data is collected unevenly across the study area. This can happen due to practical constraints, such as accessibility or survey effort.

**Causes**:
- Easier access to some areas (e.g., near roads, urban centers).
- Survey focus on specific regions or habitats.

**Examples**:
- Most occurrence points for a species are clustered near cities or along well-traveled paths.
- Remote areas with potentially suitable habitats are underrepresented.

::: {.rmdnote}
**Key Insight**: Sampling bias makes it seem like the species is more abundant in accessible areas, even if it prefers remote habitats.
:::

**Visualization Example**:
You can visualize sampling bias by plotting occurrence points over a map and identifying clusters.

```r
library(ggplot2)
ggplot() +
  borders("world", colour = "gray85", fill = "gray80") +
  geom_point(data = occurrence_data, aes(x = lon, y = lat), color = "blue", size = 1.2) +
  theme_minimal() +
  ggtitle("Sampling Bias in Occurrence Data") +
  labs(x = "Longitude", y = "Latitude")
```

---

#### **2. Spatial Bias**

Spatial bias happens when specific environmental conditions are over- or under-represented in the occurrence data.

**Causes**:
- The species is primarily recorded in habitats that are easier to identify.
- Some environmental conditions are not sampled thoroughly.

**Examples**:
- Over-representation of lowland areas while mountain habitats are overlooked.
- Sampling effort focused on one biome (e.g., forests), ignoring other potential habitats (e.g., grasslands).

::: {.rmdcaution}
**Watch Out**: Spatial bias can lead to misleading response curves, where the model falsely associates the species with specific conditions.
:::

**How to Detect Spatial Bias**:
- Overlay occurrence points on environmental variables (e.g., elevation, precipitation) to check for uneven representation.

---

#### **3. Data Bias**

Data bias results from errors or inconsistencies in the occurrence or environmental datasets.

**Causes**:
- Misidentified species in occurrence records.
- Environmental predictors with low resolution or missing values.
- Temporal mismatch between occurrence and environmental data.

**Examples**:
- Occurrence data collected decades ago may not reflect current distributions.
- Predictors like temperature and precipitation may have gaps or inconsistencies.

::: {.rmdtip}
**Pro Tip**: Check for errors in both occurrence and environmental data before modeling. Use functions like `CoordinateCleaner` in R to remove problematic records.
:::

**Tools to Address Data Bias**:
- Use **GBIF** or similar platforms to clean occurrence data.
- Validate environmental layers by inspecting resolution, extent, and coordinate systems.

```r
# Example of checking predictor quality in R
library(raster)
plot(predictor_layer, main = "Inspecting Environmental Data Quality")
```

---

#### **Summary**

| **Type of Bias**     | **Cause**                              | **Impact**                                     | **Example**                                         |
|-----------------------|----------------------------------------|-----------------------------------------------|---------------------------------------------------|
| **Sampling Bias**     | Uneven survey effort, accessibility    | Over-representation of easily accessed areas   | Occurrence points clustered near roads            |
| **Spatial Bias**      | Non-uniform environmental conditions   | Skewed species-environment relationships       | More data from lowland areas than mountainous regions |
| **Data Bias**         | Errors in occurrence/environmental data| Misleading predictions or unsuitable habitats  | Misidentified species or outdated environmental data |

Recognizing these biases early allows for effective correction methods, ensuring your models provide accurate and ecologically meaningful predictions.

---
### **3. Methods for Bias Correction**

---

#### **1. Spatial Thinning**

**Definition**: Spatial thinning is the process of reducing occurrence points to ensure a more uniform spatial distribution, minimizing over-representation of certain areas.

**How it works**:
- Removes closely clustered occurrence points within a specified distance threshold.
- Ensures occurrences are more evenly spaced.

**Tools**:
- **`spThin`**: For thinning occurrence data spatially.
- **`CoordinateCleaner`**: For removing duplicate or erroneous coordinates.

**Code Example**:
```r
library(spThin)

# Thin occurrence data to a minimum distance of 10 km
thinned_data <- thin(loc.data = occurrence_data,
                     lat.col = "lat", lon.col = "lon",
                     spec.col = "species", thin.par = 10,
                     reps = 1, verbose = TRUE)

# View the thinned dataset
head(thinned_data)
```

---

#### **2. Target-Group Background Sampling**

**Definition**: Selects background points based on species with similar sampling biases to ensure realistic comparisons.

**How it works**:
- Identifies areas where similar species were sampled and selects background points within those regions.
- Improves the ecological relevance of background points.

**Implementation in MaxEnt**:
- Use a set of occurrence records from ecologically similar species to define the sampling area for background points.

**Code Example**:
```r
library(dismo)

# Generate target-group background points
bg_points <- randomPoints(predictors, n = 500, ext = target_extent)

# Visualize background points
plot(predictors[[1]], main = "Target-Group Background Points")
points(bg_points, col = "blue", pch = 20)
```

---

#### **3. Bias Files**

**Definition**: Raster layers that weight the likelihood of background points, based on known sampling intensity or bias patterns.

**How it works**:
- Kernel density estimation is used to create a bias layer.
- The bias file is included in MaxEnt modeling to guide background selection.

**Steps to Create a Bias File**:
1. Generate a kernel density raster using occurrence data.
2. Normalize the raster values to a scale of 0–1.
3. Use the bias raster as input in MaxEnt.

**Code Example**:
```r
library(raster)
library(adehabitatHR)

# Create a kernel density estimate
coords <- occurrence_data[, c("lon", "lat")]
bias_layer <- kernelUD(coords, h = "href", grid = 100)

# Convert to raster and normalize
bias_raster <- raster(bias_layer)
bias_raster <- bias_raster / max(values(bias_raster), na.rm = TRUE)

# Visualize the bias file
plot(bias_raster, main = "Bias File")
```

---

#### **4. Environmental Filters**

**Definition**: Reducing the extent of environmental predictors to focus on areas that are biologically relevant to the species.

**How it works**:
- Crops predictor layers to specific geographic extents or regions of interest.
- Avoids including irrelevant or outlier areas in modeling.

**Code Example**:
```r
library(raster)

# Crop environmental layers to a specific extent
extent_filter <- extent(-100, -50, -30, 20)  # Define the geographic region
filtered_predictors <- crop(predictors, extent_filter)

# Visualize filtered layers
plot(filtered_predictors[[1]], main = "Filtered Environmental Layer")
```

---

### **4. Practical Application: Bias Correction in R**

#### **Step 1: Spatial Thinning**
1. Load the occurrence data.
2. Use the **`spThin`** package to thin data spatially.

#### **Step 2: Generate a Bias File**
1. Create a kernel density raster using occurrence points.
2. Normalize the raster to scale it from 0–1.
3. Use this raster as a bias file in MaxEnt.

#### **Step 3: Apply Target-Group Background Sampling**
1. Generate background points constrained by regions with similar species occurrence.
2. Incorporate the background points into the MaxEnt model.

#### **Step 4: Filter Environmental Predictors**
1. Define a geographic extent based on the species’ range or study area.
2. Crop environmental layers to the defined extent.

---

#### **Code Workflow Example**:
```r
# Step 1: Spatial Thinning
thinned_data <- thin(loc.data = occurrence_data, lat.col = "lat", lon.col = "lon",
                     spec.col = "species", thin.par = 10)

# Step 2: Create Bias File
coords <- occurrence_data[, c("lon", "lat")]
bias_layer <- kernelUD(coords, h = "href", grid = 100)
bias_raster <- raster(bias_layer) / max(values(bias_layer), na.rm = TRUE)

# Step 3: Generate Target-Group Background Points
bg_points <- randomPoints(predictors, n = 500, ext = extent(-80, -60, -40, 10))

# Step 4: Filter Predictors
filtered_predictors <- crop(predictors, extent(-80, -60, -40, 10))
```

---
### **5. Evaluating Bias-Corrected Models**  

---

After applying bias correction techniques, it is essential to evaluate how the model has improved and whether the changes align with ecological expectations.

---

#### **1. Comparison of Metrics**  

Metrics allow us to assess whether bias correction has led to **better model performance**. The key metrics to compare **before and after bias correction** include:

| **Metric**        | **Purpose**                                           | **Interpretation**                                |
|-------------------|------------------------------------------------------|--------------------------------------------------|
| **AUC (Area Under Curve)** | Measures the ability to distinguish presence from background. | Higher values (0.7–1.0) indicate better discrimination. |
| **TSS (True Skill Statistic)** | Balances sensitivity (true positives) and specificity (true negatives). | Values closer to 1 indicate better performance. |
| **Response Curves** | Show how environmental variables influence predictions. | Smoother, ecologically meaningful curves indicate a good model. |

##### **Code Example: Compare AUC Before and After Bias Correction**
```r
library(pROC)

# Evaluate the model BEFORE bias correction
auc_before <- auc(roc(labels_before, predictions_before))

# Evaluate the model AFTER bias correction
auc_after <- auc(roc(labels_after, predictions_after))

# Print the AUC scores for comparison
print(paste("AUC Before Correction:", auc_before))
print(paste("AUC After Correction:", auc_after))
```

::: {.rmdtip}
**What to Look For?**
- If AUC and TSS increase after bias correction, the model has improved.
- If response curves are biologically meaningful, the correction was effective.
:::

---

#### **2. Visual Inspection**  

Suitability maps allow for a **side-by-side comparison** to identify changes in predicted distributions.

##### **Code Example: Compare Suitability Maps Before and After Bias Correction**
```r
# Plot suitability maps before and after correction
par(mfrow = c(1,2))  # Arrange plots side-by-side

plot(suitability_map_before, main = "Before Bias Correction")
plot(suitability_map_after, main = "After Bias Correction")
```

::: {.rmdcaution}
**Common Observations:**
- If the bias-corrected map **removes artificial clustering**, the correction was successful.
- If high-suitability areas shift **toward biologically realistic regions**, the model has improved.
:::

---

#### **3. Ecological Plausibility**  

A final check is to **compare the model’s predictions with known habitat preferences** of the species.

**Questions to Ask:**
- Does the model predict suitable habitats where the species is known to occur?
- Has it removed artificial hotspots caused by sampling bias?
- Are predictions ecologically reasonable (e.g., not placing a freshwater species in deserts)?

---

### **6. Common Pitfalls in Bias Correction**  

While bias correction improves models, mistakes can lead to **worse predictions**. Below are some common pitfalls and how to avoid them.

---

#### **1. Over-Thinning Leading to Loss of Valuable Data**  
- **Problem**: If thinning reduces occurrence points too much, important information is lost.
- **Solution**: Use an appropriate threshold (e.g., **10 km** rather than extreme distances like 50 km).

##### **Code Example: Adjust Thinning Distance**
```r
thinned_data <- thin(occurrence_data, lat.col = "lat", lon.col = "lon",
                     spec.col = "species", thin.par = 10)  # Use a reasonable 10 km threshold
```

---

#### **2. Inappropriate Use of Bias Layers**  
- **Problem**: A poorly constructed bias layer may over-correct and **remove real ecological signals**.
- **Solution**: Ensure bias layers **reflect actual sampling effort**, not just presence density.

##### **Code Example: Normalize Bias Raster Properly**
```r
bias_raster <- bias_raster / max(values(bias_raster), na.rm = TRUE)  # Normalize to 0-1 scale
```

---

#### **3. Neglecting Ecological Relevance During Correction**  
- **Problem**: Removing bias without considering **species ecology** can lead to misleading results.
- **Solution**: Always compare corrected predictions with **known habitat preferences**.

::: {.rmdtip}
**Best Practice:** Use literature and expert knowledge to verify if bias-corrected predictions make **biological sense**.
:::

---

### **7. Summary and Best Practices**  

Bias correction is a crucial step in ensuring **accurate and ecologically valid species distribution models**.

---

#### **Key Takeaways for Bias Correction**  

| **Step**             | **Best Practice**                                  |
|----------------------|---------------------------------------------------|
| **Check for Bias**   | Plot occurrence points over environmental layers. |
| **Apply Thinning**   | Use **moderate** distances (e.g., 10 km).         |
| **Use Bias Layers**  | Generate kernel density maps of sampling effort.  |
| **Evaluate Models**  | Compare AUC, TSS, and response curves.            |
| **Visual Inspection** | Ensure corrected maps align with habitat preferences. |

---

#### **Checklist for Implementing Bias Correction in MaxEnt**  

✅ **Check for clustering in occurrence points.**  
✅ **Apply spatial thinning to remove over-represented areas.**  
✅ **Generate a bias file to weight background selection.**  
✅ **Compare suitability maps before and after correction.**  
✅ **Ensure ecological validity of corrected predictions.**  

By following these best practices, you can ensure **your MaxEnt model provides realistic, unbiased predictions** that contribute meaningfully to ecological research and conservation. 🚀
--- 
