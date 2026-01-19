# Day 11: Statistical Analysis & ML Prep

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** ML Preparation, Hypothesis Testing, and Feature Engineering  
<img width="700" height="1350" alt="11" src="https://github.com/user-attachments/assets/90b44e58-5cf9-490f-b2d9-baaebf131708" />


![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)
---

## Theory: From Raw Logs to Predictive Signals

Today's challenge highlighted a critical aspect of the Data Science Lifecycle: **The gap between "Data Storage" and "Model Readiness."**

### 1. The "Feature Engineering First" Paradox
In traditional workflows, Exploratory Data Analysis (EDA) often precedes Feature Engineering. However, dealing with **Time-Series Event Logs** requires a unique approach.
* **The Problem:** Raw timestamps (`event_time`) and string labels (`event_type`) have no mathematical magnitude. You cannot calculate a standard deviation on a timestamp.
* **The Solution:** I inverted the pipeline to perform **Feature Extraction** first. By converting raw logs into numerical signals (`hour`, `is_weekend`, `binary_target`), I unlocked the ability to perform statistical tests.

### 2. Handling "Power Law" Distributions (Log Transformation)
E-commerce pricing rarely follows a standard Bell Curve (Normal Distribution). Instead, it follows a **Power Law (Pareto Distribution)**—a massive number of cheap items and a "long tail" of very expensive ones.
* **The Risk:** Linear Machine Learning models (like the Logistic Regression we will use) assume data is normally distributed. Extreme outliers (e.g., a $2,500 laptop vs $5 soap) can distort the model's weights, causing it to over-prioritize price.
* **The Fix:** I applied a **Logarithmic Transformation** (`log(1+x)`).
    * *Before:* StdDev = `356.88` (High Variance/Noise)
    * *After:* StdDev = `1.19` (Stabilized Variance)
    * *Theory:* This induces **Homoscedasticity** (constant variance), making the feature "safe" for the model to learn from without bias.

### 3. Capturing Cyclic Human Behavior (Temporal Features)
Machine Learning models do not inherently understand the concept of a "Weekend." To a model, a timestamp is just a continuously increasing number.
* **Inductive Bias:** By explicitly creating the `is_weekend` and `hour` features, I am injecting "domain knowledge" into the dataset. I am forcing the model to consider that human behavior follows a **7-day cycle**.
* **Validation:** My hypothesis test confirmed this cycle exists: the **Conversion Rate** jumps from 1.42% (Weekdays) to 1.70% (Weekends), proving this feature contains a strong predictive signal.

### 4. Price Elasticity of Demand (Correlation Analysis)
Economic theory suggests **Price Elasticity** should be negative (as Price ⬆️, Demand ⬇️).
* **My Finding:** Pearson Correlation = `0.0098` (Near Zero).
* **Interpretation:** This indicates **Perfectly Inelastic Demand** for this dataset. The purchase decision is driven by *need* or *product type*, not by the price tag. This tells me that "Price" might actually be a weak predictor for the model compared to "Time."

---

## Key Findings & Interpretation

### 1. The "Weekend Shopper" Surprise (Hypothesis Test)
**My Initial Hypothesis:** I assumed that weekends would have *lower* conversion rates because people are out "window shopping" on mobile devices.

**The Data Proved Me Wrong:**
* **Weekend Conversion Rate:** `1.70%`
* **Weekday Conversion Rate:** `1.42%`
<img width="459" height="133" alt="Hypothesis" src="https://github.com/user-attachments/assets/61bb3f3c-efa2-48ef-9d6b-79df634bc2f3" />

**Insight:** Users are actually **~20% more likely to buy** on weekends.
* **ML Implication:** The `is_weekend` flag is a high-value positive signal. The model I train tomorrow should weight this feature heavily.

### 2. The "Price Insensitivity" Discovery (Correlation)
I validated the economic theory: *Does a higher price reduce the probability of a purchase?*

* **Correlation Coefficient:** `0.0098` (Near Zero)
<img width="539" height="93" alt="Correlation" src="https://github.com/user-attachments/assets/3fb8377b-7d54-44c1-9bc0-bc41856c8342" />

* **Insight:** Surprisingly, **Price is not a barrier to purchase** for this customer base. Users are statistically just as likely to buy an expensive item as a cheap one.

### 3. Normalizing Volatility (Feature Engineering)
* **Raw Data:** The price distribution was extremely volatile (StdDev: `356.88`), dominated by outliers.
* **Transformation:** I applied a Log transformation (`log(x+1)`), which compressed the variance (StdDev: `1.19`). This makes the feature "safe" for linear machine learning models.
<img width="382" height="175" alt="Feature engineering" src="https://github.com/user-attachments/assets/454fd778-82bb-4ec7-bc03-4c0594853527" />

---
### The Workflow

1. **Feature Engineering:** Transformed raw timestamps and skewed prices into learnable signals (`hour`, `is_weekend`, `price_log`).
2. **Target Encoding:** Converted categorical events (`purchase`) into a binary target (`1`/`0`) to prepare for classification.
3. **Statistical Validation:** Used Spark aggregations and correlation matrices to validate feature importance before model training.

**Next Step:** With the `gold_features` table saved, I am ready to train a Machine Learning model in **Day 12**.

---
## ✅ Tasks Completed

* [x] **Feature Engineering Pipeline:** Generated temporal signals (`hour`, `day_of_week`) and a cyclical `is_weekend` flag to capture user behavior patterns.
* [x] **Data Normalization:** Applied Log transformation (`log(x+1)`) to fix "Power Law" skew, successfully reducing price variance from **356 to 1.19**.
* [x] **Hypothesis Testing:** Disproved the "Window Shopper" theory by discovering that **Weekend Conversion (1.70%)** is actually higher than Weekday (1.42%).
* [x] **Correlation Analysis:** Identified near-zero price elasticity (`0.0098`), proving that price is not a significant barrier to purchase for this dataset.
* [x] **Gold Layer Generation:** Finalized and saved the `gold_features` table to Unity Catalog, enabling immediate ML training for the next stage.
---
## 📂 Repository Structure

* **`DAY 11 – Statistical Analysis & ML Prep.ipynb`**: The narrative notebook containing the feature engineering logic, statistical tests, and inline analysis of results.
