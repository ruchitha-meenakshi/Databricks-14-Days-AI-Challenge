# Day 14: AI-Powered Analytics: Genie & Mosaic AI

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** Generative AI (Mosaic AI), Natural Language to SQL (Genie), and MLOps Governance  
<img width="700" height="1350" alt="14" src="https://github.com/user-attachments/assets/19682177-4f78-4610-8b96-4c0df055de82" />


![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)
---

## The Mission: AI & Production

For Day 14, the goal was to move beyond traditional ML into **Generative AI** and **Production Operations (MLOps)**.
I needed to simulate a full AI lifecycle:

1. **GenAI:** Analyze unstructured text (reviews) using Large Language Models (LLMs).
2. **Genie:** Translate natural language business questions into SQL.
3. **MLOps:** Deploy the best model from Day 13 to the Unity Catalog.

---
## Theoretical Foundations

### 1. Databricks Genie:
Genie is not just a "text-to-SQL" chatbot. It is a governed, knowledge-aware natural language interface for data.  

* Unlike generic LLMs (like ChatGPT) that hallucinate SQL, Genie is aware of the specific **Schema** and **Unity Catalog** metadata. It understands table relationships, column types, and specific business logic defined in the data warehouse.
* **Role in Project:** It democratizes data access, allowing non-technical stakeholders to ask questions like "What is the revenue trend?" without needing to learn SQL.

### 2. Mosaic AI
Mosaic AI is the unified tooling layer on Databricks for the entire Generative AI lifecycle.  

* It simplifies the complex process of building GenAI apps. Instead of managing raw GPU infrastructure, Mosaic AI provides managed services for:
    * **Model Serving:** Hosting LLMs (like Llama 3 or DBRX) as API endpoints.
    * **Vector Search:** Enabling RAG (Retrieval Augmented Generation) architectures.

* **Evaluation:** Automatically testing if an AI model's answers are accurate and safe.
* **Role in Project:** I used the principles of Mosaic AI (specifically Transfer Learning) to apply a pre-trained Transformer model to analyzing customer sentiment.

### 3. AI-Assisted Analysis (Unstructured $\to$ Structured)
Traditional Data Analytics is limited to structured tables (numbers, dates, categories).

* **The Gap:** 80% of enterprise data is **unstructured** (emails, PDF reports, free-text reviews).
* **The Solution:** Generative AI Integration acts as a "bridge." It reads unstructured text (e.g., "This product broke in two days") and converts it into structured data points (e.g., Sentiment: Negative, Reason: Quality Issue). This unlocks a deeper layer of analytics that SQL alone cannot reach.

---
## Part 1: The Data Crisis (Mistake & Fix)

**The Plan:** Query the existing `ecommerce.silver.gold_products` table to analyze customer reviews.  
**The Reality:** The table didn't exist, and the dataset contained **zero** text reviews.  

<img width="700" height="100" alt="The Data Crisis" src="https://github.com/user-attachments/assets/35096a2e-0a57-4e34-8d7b-4c9456e68e99" />

* **The Error:** `[TABLE_OR_VIEW_NOT_FOUND] The table or view 'gold_products' cannot be found.`
* **The Fix:** I acted as a Data Engineer and generated **Synthetic Data**. I created a DataFrame `customer_reviews_gold` containing realistic `review_text`, `category`, and `price` data to enable the downstream AI tasks.

```python
# Synthetic Data Creation
data = {
    "review_text": ["This product is amazing!", "Terrible, waste of money."],
    "category": ["Electronics", "Electronics"],
    "price": [500.0, 200.0]
}
# Saved as temp view for SQL querying

```
---

## Part 2: Mosaic AI Simulation (Sentiment Analysis)

I simulated a **Mosaic AI** workflow by applying a pre-trained Transformer model to the synthetic reviews.

### 1. Transfer Learning

Instead of training a model from scratch (which requires labeled data and weeks of time), I used **Transfer Learning** with the `transformers` library.

* **Model:** DistilBERT (Fine-tuned for Sentiment).
* **Task:** Read English text and output `POSITIVE` or `NEGATIVE`.

<img width="700" height="389" alt="Transfer Learning" src="https://github.com/user-attachments/assets/eae4a09c-3736-452d-95d8-ac28bbbb4d19" />


### 2. The "Unseen Data" Test

To prove the model wasn't just memorizing my synthetic data, I tested it on brand new sentences it had never seen.

* *Input:* "The delivery was super fast, but the product feels cheap."
* *AI Verdict:* **NEGATIVE** (Confidence: 99.9%)
* *Insight:* The AI understood the nuance that "cheap product" outweighs "fast delivery."

<img width="499" height="198" alt="Unseen data test" src="https://github.com/user-attachments/assets/a1c6c64e-55d8-4c0c-814a-b77fe52e74bf" />

---

## Part 3: The "Genie" (Natural Language to SQL)

Databricks Genie allows users to ask questions in plain English. I simulated this by manually translating business prompts into optimized Spark SQL.

| Prompt | SQL Strategy | Result |
| --- | --- | --- |
| *"Show me total revenue by category"* | `GROUP BY category` on synthetic data. | **Electronics** is the top earner ($900) vs Home ($170) |
| *"Which products have the highest conversion rate?"* | Proxied using **Sales Count**: `COUNT(*) ... GROUP BY product_id`. | Products **101** & **102** are best-sellers (2 sales each). |
| *"What's the trend of daily purchases over time?"* | Switched to Day 13 data (`gold_features`) and aggregated by `hour`. | Purchases ramp up at **6 AM** and peak around **9-10 AM**. |
| *"Find customers who viewed but never purchased"* | Querying the negative class: `WHERE is_purchased = 0`. | Identified **10.7 Million** non-buying user sessions.|
| *"Find customers who are unhappy (Negative Sentiment)"*| Filtering the AI Model's output: `WHERE sentiment = 'NEGATIVE'`.| Instantly flagged **3 negative reviews** for support to address.|

`Query-1: Show me total revenue by category`  
<img width="314" height="115" alt="Query_1" src="https://github.com/user-attachments/assets/de7e3286-41d6-4190-b8ea-04f2e0a4a1d3" />  

`Query-2: Which products have the highest conversion rate?`  
<img width="292" height="137" alt="Query_2" src="https://github.com/user-attachments/assets/d61ac9f5-a954-412c-859f-9cf95f9e2cf7" />  

`Query-3: What's the trend of daily purchases over time?`  
<img width="465" height="373" alt="Query_3" src="https://github.com/user-attachments/assets/898814e1-ff8f-4bd7-8f2f-980bbdddb2db" />  

`Query-4: Find customers who viewed but never purchased`  
<img width="286" height="112" alt="Query_4" src="https://github.com/user-attachments/assets/ba152b6d-d7a6-408e-b0a6-546f750a7671" />  

`Query-5: Find customers who are unhappy (Negative Sentiment)`  
<img width="849" height="160" alt="Query_5" src="https://github.com/user-attachments/assets/c95febfa-64ea-48a6-a27a-83e63eb510d6" />

---

## Part 4: The MLOps Hurdle (Mistake & Fix)

The final task was to register my winning model (Balanced Logistic Regression) from Day 13.

**The Mistake:**
I tried to register the Day 13 run ID directly.

* **Error:** `MlflowException: Model passed for registration did not contain any signature metadata.`
<img width="954" height="144" alt="MLOps Error" src="https://github.com/user-attachments/assets/0b472a55-2834-45a5-b95f-2f0e47d677e2" />

* **The Lesson:** Databricks Unity Catalog acts as a gatekeeper. It refuses to register "Mystery Models." You **must** define a **Signature** (Input/Output Schema) so downstream systems know how to use the model safely.

**The Fix:**
I wrote a patch script:

1. **Load** the model from Day 13.
2. **Infer Signature** using a temporary input dataframe (`price_log`, `hour`, `is_weekend`).
3. **Re-log** the model *with* the signature.
4. **Register** the new version.

```python
# The Fix Code
signature = infer_signature(temp_data, prediction)
mlflow.sklearn.log_model(..., signature=signature)
mlflow.register_model(..., "Final_Purchase_Predictor_v1")

```

---

## Part 5: Final Stage

After applying the fix, the model was successfully promoted to the Model Registry.

* **Model Name:** `Final_Purchase_Predictor_v1`
* **Version:** 1
* **Status:** Registered in Unity Catalog

<img width="619" height="410" alt="MLOps" src="https://github.com/user-attachments/assets/fe1cdd5d-8c80-4aaf-b559-ea1d5453f91c" />

---

## Tech Stack

* **Hugging Face Transformers:** For accessing pre-trained LLMs (DistilBERT) to simulate Mosaic AI.
* **PySpark SQL:** For executing the "Genie" queries and analyzing the synthetic dataset.
* **MLflow Model Registry:** For governing the model lifecycle and versioning.
* **Unity Catalog:** The centralized governance layer where the final model is stored.
* **Python & Pandas:** For generating the synthetic "Customer Reviews" dataset.
---

## ✅ Tasks Completed

* [x] **Data Engineering (Fix):** Solved the "missing data" crisis by generating a synthetic `customer_reviews_gold` dataset with text and metadata.
* [x] **Mosaic AI Simulation:** Built an NLP pipeline using **Transfer Learning** to perform Sentiment Analysis on unstructured text.
* [x] **Genie Simulation:** Executed 5 distinct "Natural Language to SQL" queries, translating business questions into optimized Spark SQL.
* [x] **Production Deployment:** Diagnosed and fixed the **"Missing Signature"** error in Unity Catalog by inferring the schema and re-logging the model.
* [x] **Grand Finale:** Successfully registered `Final_Purchase_Predictor_v1` as a production-ready asset.

---

## 📂 Repository Structure

* **`DAY 14 – AI-Powered Analytics_ Genie & Mosaic AI.ipynb`**: The final notebook containing the GenAI Sentiment pipeline, the 5 Genie SQL queries, and the Model Registry "Patch" code.
