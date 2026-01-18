# Day 10: Performance Optimization

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** Query Tuning, Data Skipping, and Caching  
<img width="700" height="1350" alt="10" src="https://github.com/user-attachments/assets/34eb6acd-9f8e-4653-8a08-928766bafd0f" />


![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)
---

## Theory: The Art of "Data Skipping"

In Big Data, the fastest query is the one that reads the **least amount of data**. Today, I moved beyond simple SQL queries to optimize the **physical layout** of my Delta Lake tables (`silver.cleaned_traffic`).

### 1. Partitioning

**The Concept:** Partitioning breaks a massive table into smaller physical folders based on a high-cardinality column (e.g., `event_date`).

* **How it works:** If I run `SELECT * FROM events WHERE event_date = '2019-11-01'`, the engine looks at the directory structure and **only** opens the folder `event_date=2019-11-01`. It completely ignores months of other data.
* **Analogy:** Organizing a library by **Genre** (History, Sci-Fi, etc.) so you don't have to search the whole building.

### 2. Z-Ordering

**The Concept:** While partitioning handles folders, **Z-Ordering** (Multi-Dimensional Clustering) optimizes data *inside* those files.

* **How it works:** Delta Lake uses a **Space-Filling Curve (Z-Curve)** algorithm to physically co-locate related information. It sorts data so that records with similar `user_id` and `product_id` sit next to each other in the same file.
* **The Magic:** This allows Spark to skip specific *files* (or chunks of files) if the metadata (Min/Max statistics) shows the target data isn't there.

---

## Performance Analysis: The "Small Data" Paradox

I benchmarked the query execution before and after optimization using a specific User ID lookup (`user_id = 554517099`).

| Strategy | Execution Time | Outcome |
| --- | --- | --- |
| **Baseline (Raw Scan)** | `0.8745` seconds | - |
| **Partitioned + Z-Ordered** | `1.3732` seconds | **Slower (Overhead)** |
| **Disk Cache (Reads from local SSD Cache)** | `0.4593` seconds | **~18% Faster** |

### Why was the Optimized Table slower?

This counter-intuitive result demonstrates a key principle of Big Data Engineering: **The Small File Problem**.

1. **Dataset Size:** My dataset is relatively small (< 1GB).
2. **Over-Partitioning:** Partitioning by `event_date` created ~60 small physical folders (one per day).
3. **Metadata Overhead:** The time Spark spent opening/closing these multiple small files and checking Z-Order metadata exceeded the time it would have taken to simply "brute-force" scan the original single file.

**Conclusion:** Partitioning and Z-Ordering are mandatory for **Terabyte-scale** data where "Data Skipping" saves massive I/O. On small datasets, the metadata management cost outweighs the benefits.

### Caching Success (Serverless)

I also tested the **Databricks Disk Cache** on Serverless Compute.

* **First Run: Reads from Cloud Storage:** 0.55s (Fetched from Cloud Storage)
* **Second Run: Automatic Disk Cache:** 0.46s (Fetched from local SSD)
* **Result:** A consistent speedup for iterative queries because Databricks automatically cached the active data to the worker node's SSDs.

---

## Step-by-Step Implementation

### 1. Baseline Benchmark

I established a control metric by running a query on the un-optimized `silver.cleaned_traffic` table.

```python
# Result: Scanned the entire table to find 1 user.
count = spark.sql(f"SELECT * FROM cleaned_traffic WHERE user_id = {target_user}").count()

```

### 2. Applied Partitioning & Z-Ordering

I recreated the table with a physical layout optimized for Date and User lookups.

```sql
CREATE OR REPLACE TABLE optimized_traffic
USING DELTA
PARTITIONED BY (event_date)  -- Physical Folders
AS SELECT * FROM cleaned_traffic;

OPTIMIZE optimized_traffic
ZORDER BY (user_id, product_id); -- Logical Sorting
```

### 3. Serverless Caching

Since `CACHE TABLE` is not supported in Serverless, I relied on the automatic **Disk Cache**.

```python
# The first query warms the cache; the second query hits the SSDs.
df.filter(f"user_id = {target_user}").count()

```

---

## ✅ Tasks Completed

* [x] **Benchmarking:** Measured query latency before and after optimization.
* [x] **Table Partitioning:** Restructured the Silver table to partition by `event_date`.
* [x] **Z-Order Indexing:** Applied multi-dimensional clustering on `user_id` and `product_id`.
* [x] **Caching Analysis:** Validated the performance benefits of the Databricks Disk Cache on Serverless compute.

## 📂 Repository Structure

* **`DAY 10 – Performance Optimization.ipynb`**: The notebook containing benchmarks, OPTIMIZE commands, and Caching logic.
