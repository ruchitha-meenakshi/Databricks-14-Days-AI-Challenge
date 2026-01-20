# Day 12: MLflow Basics
## Experiment Tracking & The "Accuracy Paradox" 

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** MLflow, Experiment Tracking, and Model Evaluation  
<img width="700" height="1350" alt="12" src="https://github.com/user-attachments/assets/ef65a1da-7c46-49c8-aa1c-86f583659b3b" />


![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)

---

## Theory: The "Lab Journal" for AI
Training a model is easy. Remembering exactly which parameters you used two weeks ago is hard.

In traditional Data Science, we often run ad-hoc scripts, see a result, change a variable, and overwrite the code. This leads to a loss of knowledge. Today, I moved beyond "scripted" ML to using a robust MLOps Platform (MLflow). I treated MLflow as my "Lab Journal" - a permanent, searchable history of every experiment I ran.

I utilized the four core components of the MLflow Ecosystem to manage this lifecycle:

### 1. MLflow Tracking (The "Journal")

This is the component I used most heavily today. It allows data scientists to log every detail of a model training run so it can be reproduced later.

* **Parameters:** The "Ingredients" (e.g., `model_type="DecisionTree"`, `max_depth=5`).
* **Metrics:** The "Results" (e.g., `accuracy=0.9821`).
* **Artifacts:** The "Evidence" (e.g., The Confusion Matrix image I generated to diagnose the Class Imbalance).

### 2. MLflow Models (The "Shipping Container")

Instead of just saving a raw "pickle" file, MLflow packages the model in a standard format (`MLmodel`).

* **Why it matters:** This standard format means I can train a model in Scikit-Learn today, and deploy it to a REST API, Docker container, or Spark batch job tomorrow without changing the code.

### 3. MLflow Registry (The "Traffic Controller")

*Note: While I focused on tracking today, the Registry is the next logical step.*
The Registry is a centralized repository to manage the **lifecycle** of the model. It handles versioning (v1, v2) and stage transitions (e.g., moving a model from `Staging` -> `Production`).

### 4. The MLflow UI (The "Dashboard")

The UI is where the logging becomes actionable.

* **Comparison:** I used the **Parallel Coordinates Plot** to visually compare how changing features (Price vs. All) impacted accuracy.
* **Visibility:** It provided a single pane of glass to see that, despite different algorithms, all models were "flatlining" at the same accuracy, forcing me to investigate the data distribution.

---

### The Experiments

I tested three different approaches to predict user purchases (`is_purchased`), iteratively adding complexity.

| Run Name | Model Type | Features Used | Hypothesis | Result |
| --- | --- | --- | --- | --- |
| **Run_1_Price_Only** | Logistic Regression | `price_log` | Price is the main driver. | **98.21% Accuracy** |
| **Run_2_All_Features** | Logistic Regression | `price_log`, `hour`, `is_weekend` | Time context improves prediction. | **98.21% Accuracy** |
| **Run_3_Decision_Tree** | Decision Tree | All Features | Non-linear rules work better. | **98.21% Accuracy** |

---

## Analysis: The "Accuracy Trap"

At first glance, achieving **98% Accuracy** on the first try seems like a massive success. However, MLflow helped me diagnose a critical failure hidden behind that high score.

### 1. The Diagnosis

I logged a **Confusion Matrix** as an image artifact in MLflow to visualize *where* the model was making mistakes.

* **True Negatives:** `19,642` (Correctly ignored non-buyers)
* **True Positives:** `0` (Failed to identify a single buyer)
* **False Negatives:** `357` (Missed every actual sale)

### 2. The Conclusion

The model is "lazy." Due to the massive **Class Imbalance** (~98% of users don't buy), the model learned that the safest strategy is to simply predict **"No Purchase" (0)** for everyone.

* **The Paradox:** The model is statistically accurate (98%) but practically useless (0 sales predicted).
* **The Lesson:** Without logging the visual **Confusion Matrix artifact**, I might have celebrated a "successful" model. Now I know I need to apply **Oversampling (SMOTE)** or **Class Weights** in the next iteration.

---

## 📸 Visual Evidence

**1. The Experiment Log (MLflow UI)**  
*Comparison of 3 runs showing that despite adding features and changing models, the accuracy remained identical (98.21%).*

<img width="700" height="330" alt="Screenshot 2026-01-20 at 13 01 47" src="https://github.com/user-attachments/assets/e2c7882d-575f-4799-b757-8afcfbdc3210" />



**2. The "Flatline" (Parallel Coordinates Plot)**  
*Visualizing the hyperparameters. Notice how the line on the far right (accuracy) is completely flat, regardless of the model type.*  

<img width="700" height="646" alt="Screenshot 2026-01-20 at 12 35 59" src="https://github.com/user-attachments/assets/1934d7ac-dd43-4161-915b-497ce6fb1554" />



**3. The "Smoking Gun" (Confusion Matrix Artifact)**  
*Logged as an image artifact. This reveals the truth: The model achieved high accuracy by predicting **Zero** True Positives (Sales).*  

<img width="400" height="400" alt="confusion_matrix" src="https://github.com/user-attachments/assets/508b85b7-458e-42f2-b50a-a00a02f4c120" />

---

## Tech Stack

* **MLflow:** For tracking Parameters, Metrics, and Artifacts (Images).
* **Scikit-Learn:** Logistic Regression & Decision Trees.
* **Matplotlib/Seaborn:** Generated custom evaluation plots logged directly to the cloud.
---
## ✅ Tasks Completed

* [x] **Data Loading:** Converted `gold_features` from Unity Catalog to Pandas for training.
* [x] **Experiment Tracking:** Logged 3 distinct runs comparing Algorithms and Features using `mlflow.start_run()`.
* [x] **Artifact Logging:** Generated and saved a **Confusion Matrix** image to the MLflow run.
* [x] **Model Comparison:** Used the MLflow UI to compare runs side-by-side.
* [x] **Metric Diagnosis:** Identified the "Null Accuracy" problem where high accuracy masked poor performance on the target class.

---
## 📂 Repository Structure

* **`DAY 12 – MLflow Basics.ipynb`**: The notebook containing the training logic for Logistic Regression and Decision Tree models, including MLflow logging commands and the final "Accuracy Paradox" diagnosis.
