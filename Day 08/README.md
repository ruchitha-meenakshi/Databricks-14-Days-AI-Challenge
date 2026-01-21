# Day 8: Unity Catalog Governance 🏛️

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** Data Governance, Security, and SQL Namespaces
<img width="600" height="1350" alt="8" src="https://github.com/user-attachments/assets/c67d1843-948b-453b-9e83-3f0cb67c26b2" />


![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)

---

## Theory: Unity Catalog Governance

Data Engineering isn't just about moving data; it's about making data **discoverable**, **secure**, and **trusted**. Day 8 focuses on **Unity Catalog**, the centralized governance layer for the Lakehouse.

### 1. The 3-Level Namespace

In legacy systems, we often dealt with messy file paths (`/mnt/data/sales/...`) or simple "Database.Table" structures. Unity Catalog introduces a standardized 3-level hierarchy:

* **Catalog (`ecommerce`):** The top-level container. This typically represents a Business Unit (e.g., `Finance`, `HR`) or an Environment (e.g., `Dev`, `Prod`).
* **Schema (`silver`):** Also known as a Database. It logically groups tables based on purpose or quality (e.g., `bronze` for raw, `gold` for KPIs).
* **Table (`cleaned_traffic`):** The actual data asset.

**Benefit:** This structure allows us to reference data using clean, universal SQL paths:
`SELECT * FROM ecommerce.silver.cleaned_traffic`

### 2. Managed vs. External Tables

Unity Catalog supports two main types of tables:

* **Managed Tables:**
* **"Databricks manages everything."**
* The data files are stored in the root storage of the catalog.
* **Behavior:** If you run `DROP TABLE`, the table definition AND the underlying data files are deleted.
* **Use Case:** Intermediate tables (Bronze/Silver) where you don't need to access files manually.


* **External Tables:**
* **"You manage the files."**
* The table points to a specific path in your cloud storage (S3/ADLS).
* **Behavior:** If you run `DROP TABLE`, only the table definition is removed. The actual Parquet/Delta files remain safe in storage.
* **Use Case:** Data that needs to be accessed by other tools or preserved strictly.


### 3. Access Control (GRANT/REVOKE)

Security in Unity Catalog is handled via standard SQL permissions, not IAM roles or file keys.

* **Principle of Least Privilege:** We grant users exactly the access they need, and nothing more.
* **Example Model:**
* **Data Engineers:** Need `ALL PRIVILEGES` on `silver` to clean and transform data.
* **Data Analysts:** Need `SELECT` (Read-only) on `gold` to build dashboards.
* **Business Users:** Might only see a **View** (e.g., `top_products`) that hides sensitive columns like `user_session_id`.


```sql
GRANT SELECT ON TABLE gold.kpis TO `analysts`;
REVOKE DROP ON SCHEMA gold FROM `interns`;

```

### 4. Data Lineage

One of the most powerful features of Unity Catalog is **Automated Lineage**.

* **What it is:** UC automatically tracks how data flows between tables. It knows that `gold.kpis` was created by reading from `silver.cleaned_traffic`.

**Why it matters:**
* **Impact Analysis:** "If I change the column name in `silver`, who will it break?" (Lineage shows `gold` depends on it).
* **Traceability:** "Why is this revenue number wrong in the dashboard?" (Lineage lets you trace it back to the raw `bronze` source).
---

## Tasks Completed
- [x] **Created Hierarchy:** Built the `ecommerce` catalog and `bronze`/`silver`/`gold` schemas.
- [x] **Registered Tables:** Mapped my existing Delta Lake files to SQL tables.
- [x] **Permissions:** Configured `GRANT SELECT` to control access.
- [x] **Views:** Created a business-friendly view for high-performing products.

---
### 📂 Repository Structure

* **`DAY 8 – Unity Catalog Governance.ipynb`**: A single, modular notebook containing the logic for Bronze, Silver, and Gold layers, controlled by `dbutils.widgets`.
