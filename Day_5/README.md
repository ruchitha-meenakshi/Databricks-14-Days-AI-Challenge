# Day 4: Delta Lake Advanced
**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** Time Travel, Optimization (Z-Order), and Maintenance (Vacuum)  
<img width="1080" height="1350" alt="5 (1)" src="https://github.com/user-attachments/assets/84669809-f9c2-4d14-9842-f848f2e312fe" />



![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)
---
## Deep Dive: Advanced Delta Lake Internals

### 1. Time Travel (MVCC & The Transaction Log)

**The Core Concept: Multi-Version Concurrency Control (MVCC)**
Standard data lakes (like raw Parquet on S3) are "eventually consistent." If you overwrite a file while someone is reading it, the reader might crash. Delta Lake uses MVCC to solve this.

* **Snapshot Isolation:** Every time you read a Delta table, you are reading a specific "snapshot" of the table state. This snapshot is immutable. Even if a writer is adding new data *during* your read, your view of the data does not change.
* **The `_delta_log`:** This is the brain of Time Travel. It contains a sequence of JSON files (e.g., `000001.json`, `000002.json`).
* **Add/Remove Actions:** The log doesn't just say "row added." It says "File A was added" or "File B was logically removed."
* **Reconstructing State:** To "Time Travel" to version 5, Spark reads the log up to `000005.json` and ignores all subsequent entries. It reconstructs the file list exactly as it existed at that moment.

> **Theory Note:** To prevent the log from becoming too slow to read, Delta creates "Checkpoint" files (Parquet format) every 10 commits. These checkpoints summarize the state of the table, so Spark doesn't have to replay the entire history from zero.
<img width="947" height="499" alt="Screenshot 2026-01-13 at 16 00 14" src="https://github.com/user-attachments/assets/a6f69b0f-2e48-4613-8bfe-2ac907b5d716" />

### 2. MERGE (The Upsert Algorithm)

**The Challenge:**
In immutable storage (like HDFS or S3), you cannot modify a single row in a file. You must rewrite the entire file.

**The Algorithm (Two-Pass Approach):**
When you run a `MERGE` command, Delta Lake performs a sophisticated join operation:

1. **Scan & Join:** It scans the **Source** (incoming data) and performs an `INNER JOIN` with the **Target** (existing table) to identify which files contain records that need to be updated.
2. **Rewrite (Copy-on-Write):** It does **not** touch files that don't need changes. For the files that *do* contain matches:
* It reads the old file.
* It updates/inserts the rows in memory.
* It writes out a **brand new** Parquet file containing the updated data.
* It marks the old file as "tombstoned" (logically deleted) in the transaction log.

> **Why this matters:** This minimizes I/O. If you have 1TB of data but new changes only touch 1GB partition, Delta only rewrites that specific partition/file, not the whole table.
<img width="708" height="339" alt="Screenshot 2026-01-13 at 15 59 10" src="https://github.com/user-attachments/assets/f37eaa8b-47ee-4bf0-9bf3-0559de82897e" />


### 3. OPTIMIZE (Bin-Packing)

**The Physics of Storage:**
Opening a file over a network (S3/Azure Blob) has high latency (overhead). Reading 1,000 files of 1KB takes significantly longer than reading 1 file of 1MB, even though the data size is the same.

**Bin-Packing Algorithm:**
`OPTIMIZE` is not just concatenating files. It uses a **Bin-Packing** strategy.

* It looks at the current files in a partition.
* It groups small files together until they reach a target size (default is usually around 1GB).
* It is idempotent: If you run it twice, the second run does nothing if the files are already optimized.

### 4. Z-ORDER (Space-Filling Curves)

**The Problem with Standard Sort:**
If you sort by Column A (Year) and then Column B (Department), your data is clustered perfectly by Year. But inside a Year, Department is scattered. If you query `WHERE Department = 'Sales'`, the database usually has to scan every Year.

**The Z-Curve Solution (Morton Code):**
Z-Ordering maps multi-dimensional data into one dimension while preserving "locality."

* **Interleaving Bits:** Imagine two columns: X (binary `10`) and Y (binary `01`). A Z-order calculation interleaves their bits to create a new value `1001`.
* **Result:** Data points that are close to each other in multi-dimensional space (e.g., similar Brand AND similar Price) are stored physically close to each other on the disk.

**Data Skipping:**
Parquet files have a footer that stores the `MIN` and `MAX` values for columns in that file. Because Z-Ordering clusters similar data, the `MIN/MAX` ranges become very tight (non-overlapping).

* *Without Z-Order:* File 1 range: [A-Z]. File 2 range: [A-Z]. (Spark must scan both).
* *With Z-Order:* File 1 range: [A-M]. File 2 range: [N-Z]. (If searching for 'Samsung', Spark skips File 1 entirely).
<img width="585" height="243" alt="Screenshot 2026-01-13 at 16 00 30" src="https://github.com/user-attachments/assets/f25a56b1-6a96-4ed9-ba8a-cbe356967b10" />

### 5. VACUUM (Log vs. Physical Deletion)

**Logical Deletion:**
When you `DELETE` or `UPDATE` data in Delta, the old parquet files remain on disk. The transaction log simply marks them as `remove` entries. They are invisible to current readers but exist for Time Travel.

**The Safety Limit:**
`VACUUM` physically deletes these "tombstoned" files.

* **Retention Period:** By default, Delta prevents you from vacuuming files newer than 7 days.
* **Why?** If a long-running job is reading a snapshot from 1 hour ago, and you VACUUM the files that job is reading, the job will fail with a `FileNotFoundException`. The 7-day buffer ensures active jobs and short-term time travel remain safe.
<img width="526" height="160" alt="Screenshot 2026-01-13 at 16 00 55" src="https://github.com/user-attachments/assets/f4ae5fcd-58a7-4318-80a7-ed0193dbb230" />

---

## ✅ Tasks Completed
- [x] Recovered historical data using Time Travel (Version History & Timestamp).
- [x] Implemented Incremental Upserts (MERGE) to handle late-arriving updates.
- [x] Accelerated query performance using OPTIMIZE and Z-ORDER (Data Skipping).
- [x] Managed storage retention and costs with VACUUM (Garbage Collection).

---

## 📂 Repository Structure

* **`Day 5 - PySpark Transformations Deep Dive.ipynb `**
    The Maintenance & Optimization notebook: detailed implementation of Time Travel for data recovery, Incremental MERGE for CDC, and performance tuning using Z-Order and Vacuum for efficient storage management.
