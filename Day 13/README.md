# Day 13: Model Comparison & Feature Engineering

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** Hyperparameter Tuning, Class Weighting, and Distributed ML  
<img width="700" height="1350" alt="13" src="https://github.com/user-attachments/assets/c3a82f87-7ef1-4ea5-9770-6d09b7348ee9" />


![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)
---

## Theory: Engineering Reliable ML Systems

In Day 12, I diagnosed a critical failure: my models had **98% Accuracy** but **0% Recall**. They were "lazy" and missed every single buyer because of massive class imbalance (~98% of users don't buy).

Today, I moved beyond basic scripts to implement a robust **Evaluation Strategy** and **Scalable Architecture**.

### 1. The Metric Trade-Off (Accuracy vs. Recall)

One of the hardest theoretical lessons in ML is choosing the right metric.

* **Accuracy:** . In imbalanced data, this is misleading because the model achieves 98% by simply predicting "No Purchase" for everyone.
* **Recall (Sensitivity):**. This measures "How many of the actual buyers did we find?"
* **The Decision:** I chose to optimize for **Recall** because failing to detect a buyer (Missed Revenue) is more costly than annoying a non-buyer (False Alarm).

### 2. Scaling Architecture: Scikit-Learn vs. Spark ML

A key part of Day 13 was moving from Single-Node to Distributed computing.

* **Scikit-Learn:** Used for the *fast iteration* loop (finding the best parameters on a sample).
* **Spark ML:** Used to reimplement the winning strategy in a **distributed pipeline** that can handle 100M+ rows on the cluster.
---

## Deep Dive: The Mechanics Under the Hood

### 1. The Mathematics of "Class Weights"

How did adding `class_weight='balanced'` magically fix the model? It didn't change the algorithm; it changed the **Loss Function**.

* **Standard Logistic Regression:** Treats every error equally. Missing a "Buyer" (Class 1) costs the same penalty as missing a "Window Shopper" (Class 0). Since Class 0 is 98% of the data, the model minimizes total error by ignoring Class 1.
* **Balanced Weighting:** It assigns a higher penalty to mistakes on the minority class.

  $$Weight_{class} = \frac{Total Samples}{2 \times Samples_{class}}$$
  
  * **Class 0 Weight:**  (Low penalty)
  * **Class 1 Weight:**  (High penalty)
  * **Result:** The model is effectively told, *"One mistake on a Buyer is worth 50 mistakes on a Non-Buyer."* This forces the optimization algorithm (Gradient Descent) to bend the decision boundary to capture the buyers.

### 2. Architecture: Why Spark ML Pipelines?

Moving from Scikit-Learn to Spark ML isn't just a syntax change; it's a fundamental architectural shift.

* **Scikit-Learn (Eager Execution):**
  * Loads all data into **RAM** on a single machine (The Driver).
  * If data > RAM, the kernel crashes.
  * Computation happens sequentially on the CPU.

* **Spark ML (Lazy & Distributed):**
  * **Lazy Evaluation:** When I ran `pipeline.fit()`, Spark didn't compute immediately. It built a **DAG (Directed Acyclic Graph)** of the transformation steps.
  * **Distributed Processing:** The data is sharded across multiple "Worker Nodes" (Executors). The Master Node (Driver) sends instructions to the workers to compute gradients on their local chunks of data and aggregate the results.
  * **Scalability:** This allows training on Petabytes of data by simply adding more nodes to the cluster, without changing a single line of code.

### 3. Interpreting Log-Odds (The Feature Importance)

Why did `price_log` have a negative coefficient?

* Logistic Regression doesn't predict "Yes/No" directly; it predicts the **Log-Odds** of the event.
    $$\ln(\frac{p}{1-p}) = \beta_0 + \beta_1(Price) + \beta_2(Weekend)$$
  
* **Negative Coefficient ($\beta_1 < 0$):** A unit increase in Price *decreases* the log-odds of a purchase.
* **Positive Coefficient ($\beta_2 > 0$):** Being a weekend *increases* the log-odds.
* **Magnitude:** The larger the absolute value of the coefficient, the stronger the influence that feature has on the final probability.

---
## The Experiments: Finding "The Cure"

I designed a **Challenger Experiment** to test three strategies against the baseline.

| Model  | Strategy | Hypothesis | Result (Recall) | Verdict |
| ----  | ---- | ---- | ---- | ---- |
| **1. LogReg_Unbalanced** | Baseline | Standard parameters. | **0.00%** | **FAILED** (Same as Day 12) |
| **2. LogReg_Balanced** | **The Fix** | `class_weight='balanced'` | **53.64%** | **WINNER ** |
| **3. RandomForest** | The Upgrade | Complex Ensemble + Balanced | **5.15%** | **Underperformed** |

---
### Key Insight

The **Balanced Logistic Regression** was the clear winner.

* It sacrificed **Accuracy** (dropping from 98% → 55%) to gain **Recall** (0% → 53%).
* **Business Value:** A model that flags >50% of potential sales is infinitely more valuable than a model that ignores 100% of sales to maintain high "vanity accuracy."

---

## 📸 Visual Evidence

**1. The "Trade-Off" (MLflow Comparison Table)**
*Proof that Model 2 (Balanced) is the only one that actually works. Note the massive jump in Recall.*  

<img width="1183" height="277" alt="Screenshot 2026-01-21 at 19 22 18" src="https://github.com/user-attachments/assets/e41e567f-1b0b-4f17-a112-c7fab71e3844" />

**2. Visualizing the Models (Parallel Coordinates)**
*A visual representation of the trade-off. As we move from "Unbalanced" to "Balanced," the Accuracy line drops, which was necessary to capture the buyers.*  

<img width="1185" height="455" alt="Screenshot 2026-01-21 at 19 22 04" src="https://github.com/user-attachments/assets/491bcb59-6dce-471a-b8cf-0889b3eaeca5" />

**3. Feature Drivers (Coefficients)**
*Visualizing what drives a purchase. `price_log` is the strongest negative driver, while `is_weekend` positively impacts buying behavior.*  

<img width="762" height="393" alt="download" src="https://github.com/user-attachments/assets/bd98dbe3-4ac0-4bd7-bc5b-89907411fe04" />

**4. Scaling Up (Spark ML Pipeline)**
*Successful execution of the distributed pipeline, generating probability predictions on the Spark cluster.*  

<img width="711" height="180" alt="Screenshot 2026-01-21 at 19 21 25" src="https://github.com/user-attachments/assets/a48e0c38-1cc0-499f-b411-34f923922515" />

---

## Tech Stack

* **Scikit-Learn:** For rapid prototyping and hyperparameter tuning.
* **PySpark ML:** For building scalable, distributed machine learning pipelines.
* **MLflow:** For tracking experiments and comparing "Challenger" vs. "Baseline" models.
* **Matplotlib/Seaborn:** For visualizing Feature Coefficients.

## ✅ Tasks Completed

* [x] **Model Comparison:** Automated training of 3 distinct models to solve the Class Imbalance problem.
* [x] **Metric Analysis:** Identified that **Recall** is the superior metric for this business case, not Accuracy.
* [x] **Feature Importance:** Visualized Logistic Regression coefficients to explain model decisions.
* [x] **Spark ML Implementation:** Built and ran a distributed ML pipeline to prepare for production scale.

---

## 📂 Repository Structure

* **`DAY 13 – Model Comparison and Feature Engineering.ipynb`**: The notebook containing the training loop, the "Fix" for class imbalance, and the Spark ML pipeline code.
