# Day 4: PySpark Transformations Deep Dive 

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** Advanced Joins, Window Functions, and User-Defined Functions (UDFs)  
<img width="1080" height="1350" alt="4" src="https://github.com/user-attachments/assets/f097c9b2-ca7f-409f-9c5f-091ec6deedd7" />




![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)
---

## Theory: The "Smart" Storage Layer

Today, I moved beyond saving simple files. I learned that in the real world, data pipelines break easily if you just dump files into a folder. **Delta Lake** is the solution to that chaos.

### 1. What is Delta Lake?

Think of **Parquet** as a "dumb" storage format (like a CSV, but binary). It stores data, but it doesn't know *what* is stored or *when* it changed.

**Delta Lake** is a storage **layer** that sits on top of Parquet files. It adds a "brain" to your storage called the **Transaction Log** (`_delta_log`).

* **The Brain (`_delta_log`):** This folder tracks every single operation (insert, update, delete) that happens to your table.
* **The Body (Parquet):** The actual data is still stored as Parquet files, but Delta manages *which* files are valid at any given time.

### 2. ACID Transactions (The Safety Net)

In Big Data, jobs often fail halfway through. Without ACID, a failed job leaves you with "half-written" corrupt data. Delta Lake guarantees **ACID** properties:

* **A - Atomicity (All or Nothing):** If a job tries to write 100 files and crashes after 99, Delta cancels the *entire* operation. No partial "zombie" data exists.
* **C - Consistency:** Everyone sees the same data at the same time. You won't read a file while it is being rewritten.
* **I - Isolation:** Multiple users can write to the table at the same time without corrupting each other's work.
* **D - Durability:** Once the system says "Success," the data is saved permanently, even if the power goes out.

> **Analogy:** ACID is like a Bank Transfer. If I send you money, money leaves my account and enters yours simultaneously. If the bank's system crashes halfway, the money doesn't vanish—the transaction is cancelled, and the money stays in my account.

### 3. Schema Enforcement (The Bouncer)
One of the biggest causes of "Data Swamps" is bad data quality—e.g., someone accidentally changing a column from `Integer` to `String`.

* **The "Schema on Read" Problem:** Standard Spark/Parquet lets you save *anything*. You only find out the data is broken days later when you try to read it and the code crashes.
* **The Delta Solution:** Delta checks the schema **on Write**. It acts like a nightclub bouncer. If the new data doesn't match the table's schema (e.g., wrong column name or data type), Delta **rejects the write** immediately and throws an error.

### 4. Delta Lake vs. Parquet (The Showdown)

| Feature | Parquet (File Format) | Delta Lake (Storage Layer) |
| --- | --- | --- |
| **Updates** | Impossible. You must rewrite the *entire* folder. | **MERGE** command allows modifying specific rows. |
| **History** | None. Once you overwrite, the old data is gone. | **Time Travel.** You can query previous versions (`VERSION AS OF`). |
| **Reliability** | Low. If a job fails, you get corrupt files. | **High (ACID).** Failed jobs leave no trace. |
| **Performance** | Slower over time (too many small files). | **Optimized.** Auto-compacts small files (OPTIMIZE command). |
| **Schema** | Accepts anything (dangerous). | **Enforcement.** Rejects bad data automatically. |

---
### Why this matters for Data Engineering

Before Delta Lake, Data Engineers spent 50% of their time fixing broken pipelines caused by corrupt files or bad schemas. With Delta, the storage layer handles these reliability issues, allowing us to focus on the actual logic.

---
## 🛠️ Hands-On: The Engineering Pipeline

### Task 1: Converting to Delta
I successfully converted our raw Parquet event logs into the Delta format, enabling the transaction log.
<img width="666" height="313" alt="Screenshot 2026-01-12 at 17 13 31" src="https://github.com/user-attachments/assets/6d267ab9-bf47-4153-b449-276032e354ad" />

### Task 2: Handling Unity Catalog Restrictions
* **Challenge:** Unity Catalog does not allow creating standard tables on top of Volume paths.
* **Solution:** I used **Path-Based Access** (`delta.``/path/to/files```) to query the Delta files directly via SQL without registering a formal table.
<img width="514" height="273" alt="Screenshot 2026-01-12 at 17 13 51" src="https://github.com/user-attachments/assets/9ebab1b3-5e95-4b99-84ff-d2c82763b98e" />

### Task 3: Testing Schema Enforcement
I deliberately tried to append data with wrong columns (`x`, `y`, `z`) to the production table.
* **Result:** Delta successfully **blocked** the write.
* **Error Caught:** `[DELTA_SCHEMA_MISMATCH] A schema mismatch detected when writing to the Delta table.`
<img width="928" height="502" alt="image" src="https://github.com/user-attachments/assets/c41992a5-09ef-4a4a-8826-bda9d942e828" />

### Task 4: The Upsert (MERGE)
In Parquet, handling duplicates requires rewriting the whole table. In Delta, I used the `MERGE` command to handle new incoming data:
1.  **Update:** If the user already exists, update their `price`.
2.  **Insert:** If the user is new, insert the row.
```python
# The Upsert Logic
deltaTable.alias("target").merge(
    updates_df.alias("source"),
    "target.user_id = source.user_id AND target.product_id = source.product_id"
).whenMatchedUpdate(set = {
    "price": "source.price"
}).whenNotMatchedInsertAll().execute()
```
<img width="773" height="352" alt="Screenshot 2026-01-12 at 17 15 30" src="https://github.com/user-attachments/assets/d48d7ca7-8a9a-406e-8873-cf3fcd4acef6" />

---
## ✅ Tasks Completed  
- [x] Converted files to Delta Format.
- [x] Created Tables (via PySpark and SQL)
- [x] Proven Schema Enforcement works.
- [x] Handled Duplicates/Upserts.

---
## 📂 Repository Structure

* **`Day 3 - Delta Lake Introduction.ipynb `**
    The Lakehouse Architecture notebook: Demonstrates the transition from static files to smart Delta Tables, validating data quality with Schema Enforcement, and implementing Upserts (MERGE) to handle duplicate records efficiently.
