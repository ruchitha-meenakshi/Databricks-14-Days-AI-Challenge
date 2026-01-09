# Day 1: Platform Setup, Lakehouse Architecture & Data Optimization  
**Challenge:** Databricks 14-Day AI Challenge  
**Tools:** PySpark, Databricks Community Edition, Kaggle API  
**Dataset:** [E-Commerce Behavior Data (Oct/Nov 2019)](https://www.kaggle.com/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store)
![Day1](https://github.com/user-attachments/assets/f1b1d419-fa27-41df-90b9-6c2b50f8d74a)

---

## 🧠 Theory: Understanding the Ecosystem
During Day 1, I focused on understanding *why* modern data stacks look the way they do compared to traditional methods.

### 1. Why Databricks vs. Pandas?
*Pandas is excellent for small, single-machine analysis but hits a memory wall with large datasets. Databricks leverages Apache Spark to distribute computation across multiple machines, allowing you to process terabytes of data as easily as kilobytes.*

* **The Scalability Limit:** In my local environment (Pandas), loading a 9GB+ CSV dataset (like the one used here) crashes the RAM because Pandas operates on a "Single Node."
* **The Distributed Solution:** Databricks uses **Apache Spark** to distribute the data across multiple nodes (computers) in a cluster. This allows processing millions of rows in seconds.

### 2. What is the "Lakehouse" Architecture?
*The Lakehouse Architecture combines the low-cost, flexible storage of Data Lakes with the reliability and speed of Data Warehouses. This unified system supports all data workloads, from raw unstructured files for AI to clean, structured tables for SQL analytics.*

* **Data Lake (The "Raw" Layer):** I stored the raw, messy CSV files in Databricks Volumes. This is cheap and flexible.
* **Data Warehouse (The "Processed" Layer):** I transformed these CSVs into **Parquet** tables. This provided strict schema enforcement and high-performance querying, similar to a warehouse.

### 3. Databricks Workspace Structure
*The Workspace is a collaborative web interface where data teams create Notebooks, manage Compute clusters, and organize Data. It unifies the tools for engineering, SQL analysis, and Machine Learning into a single environment so teams stop working in silos.*

* **Compute:** The processing power (clusters) that runs the code.
* **Notebooks:** The interactive interface where I wrote PySpark code.
* **Volumes/Data Explorer:** The file system where I managed my raw and processed datasets.

### 4. Industry Use Cases
*Leading global companies choose Databricks to solve complex data problems that require massive scale and real-time speed. Whether it's streaming movies or optimizing oil rigs, the platform handles the heavy lifting for mission-critical AI.*

* **Netflix:** Uses this architecture for personalization algorithms, streaming petabytes of log data to recommend movies.
* **Shell:** Optimizes supply chain inventory by analyzing sensor data from thousands of machines.
* **Comcast:** Processes voice commands from remote controls in real-time using distributed Spark clusters.
---

## 🛠️ Project: E-Commerce Data Pipeline

**Objective:** Ingest 100M+ user events, clean the data, and optimize storage for analysis.

### Step 1: Environment & Ingestion
I set up the **Databricks Community Edition** and configured the Kaggle API to pull data directly into the cloud environment, bypassing my local machine entirely.

* **Infrastructure Created:**
    * `Schema`: `workspace.ecommerce`
    * `Volume`: `workspace.ecommerce.ecommerce_data`

```python
# Creating the storage layer
spark.sql("""CREATE SCHEMA IF NOT EXISTS workspace.ecommerce""")
spark.sql("""CREATE VOLUME IF NOT EXISTS workspace.ecommerce.ecommerce_data""")
```

### Step 2: The "InferSchema" Trap (Lessons Learned)
Initially, I loaded the data using inferSchema=True.

* **Observation:** Spark had to read the huge CSV file twice (once to guess types, once to load data). This is computationally expensive.

* **The Fix:** Moving forward, explicit schema definition is required for production pipelines to prevent "price" columns from accidentally becoming strings.

### Step 3: Storage Optimization (CSV → Parquet)
Reading raw CSVs for every analysis is inefficient. I built a pipeline to convert the raw October & November data into Parquet format.

**Why Parquet?**

* **Columnar Storage:** Compresses data significantly (saves storage costs).

* **Schema Preservation:** Unlike CSV, Parquet remembers that event_time is a Timestamp and price is a Double.

* **Speed:** Reading the processed Parquet file was 10x faster than the raw CSV.

```python
# Saving data to the "Processed" layer for fast access later
base_path = "/Volumes/workspace/ecommerce/ecommerce_data/processed_data"

combined_df.write \
    .mode("overwrite") \
    .parquet(f"{base_path}/combined_all")
```
<img width="840" height="384" alt="Screenshot 2026-01-09 at 16 38 38" src="https://github.com/user-attachments/assets/effd949d-6d4b-4a0c-b99b-b3df2c140759" />
[Reference: Day 0 Notebook]

### Step 4: Verification & Analysis
In Day 1 Notebook, I demonstrated how to load this optimized data. Note that no schema definition was needed—Spark read the metadata directly from the Parquet file.

```python
# Loading 42 Million rows instantly
oct_events = spark.read.parquet(f"{base_path}/oct_2019")
print(f"✅ Loaded October Data: {oct_events.count():,} rows")
```
[Output: 42,448,764 rows loaded]

## Practice Exercises
I also completed the challenge basics: creating and filtering DataFrames manually.

```python
# Filter expensive products
data = [("iPhone", 999), ("Samsung", 799), ("MacBook", 1299)]
df = spark.createDataFrame(data, ["product", "price"])
df.filter(df.price > 1000).show()
```
<img width="583" height="474" alt="Screenshot 2026-01-09 at 16 39 00" src="https://github.com/user-attachments/assets/33dbe646-39f8-4f1b-bc7a-b0bab66360dc" />

## 📂 Repository Structure

* **`Day 0 - Setup & Data Loading (Prerequisites).ipynb`**
  The Data Engineering pipeline: Ingests raw CSV data from Kaggle, creates the Schema/Volume, cleans the data, and saves optimized Parquet files.

* **`Day 1 (09.01.26)– Platform Setup & First Steps.ipynb`**
  The Analyst workflow: Loads the pre-processed Parquet data directly for analysis and performs basic DataFrame operations.

