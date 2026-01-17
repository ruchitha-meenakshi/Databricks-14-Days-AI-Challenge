# Day 9: SQL Analytics & Visualization

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** BI, Reporting, and Visualizing Insights
<img width="700" height="1350" alt="9" src="https://github.com/user-attachments/assets/e8060224-e6ce-4d3a-a4db-db5e2e5a9822" />


![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)
---

## Theory: The Lakehouse Analytics Layer

Today, I switched personas from **Data Engineer** to **Data Analyst**.
In a traditional setup, I would have to move data from the "Lake" to a separate "Data Warehouse" to run SQL. In the **Lakehouse** architecture, I simply spun up a **SQL Warehouse** compute engine and queried the same Delta tables (`silver.cleaned_traffic`) directly.

### The Traditional Problem ("The Two-Tier Architecture")
In a traditional data stack, analyzing this data would have required a complex, multi-step process:
1.  **Data Lake:** Raw files land here (cheap storage, but hard to query).
2.  **ETL Pipeline:** Engineers write code to move data out of the Lake.
3.  **Data Warehouse:** Data is loaded into a separate, expensive system (like Redshift or Snowflake) just to run SQL queries.
4.  **BI Tool:** Dashboards connect to the Warehouse.

*The Result:* Data is duplicated, stale (waiting for nightly loads), and expensive to store twice.

### The Lakehouse Solution
In this project, I skipped the "Data Warehouse" step entirely.
* **Unified Storage:** My data lives in **Delta Lake** tables (`silver.cleaned_traffic`). This provides the structure and ACID reliability of a warehouse but keeps the low cost of cloud storage (S3/ADLS).
* **Separated Compute:** I spun up a **Serverless SQL Warehouse**—a specialized compute engine optimized for high-concurrency SQL queries. It sits *on top* of the Delta tables.

### Why this works
1.  **Zero-Copy:** The dashboard reads the exact same files the Data Engineer wrote. No export, no copy commands.
2.  **Freshness:** As soon as the engineering notebook finishes (or streams), the dashboard is up-to-date.
3.  **Performance:** Databricks uses the **Photon Engine** (a vectorized query engine) under the hood, making SQL queries on the Lake just as fast as traditional warehouses.

---

### The Workflow
1.  **Data Prep (Engineer):** I used a Spark notebook to ingest and merge **Combined Data (Oct & Nov)** into the Silver layer, handling schema enforcement and deduplication.
2.  **Analysis (Analyst):** I switched to the SQL Editor and used standard ANSI SQL to write complex analytical queries (Window functions, funnel analysis) directly against the Silver tables.
3.  **Visualization (Reporter):** I built a live **Lakeview Dashboard** to visualize trends. The dashboard shares the same Unity Catalog governance model as the raw data, ensuring security policies follow the data.
---

## Key SQL Techniques Used

### 1. Smoothing Volatility (Window Functions)
I used `ROWS BETWEEN 6 PRECEDING...` to create a **7-Day Moving Average** for revenue, smoothing out daily spikes to see the true trend.

### 2. Funnel Analysis
I calculated the conversion rates from `View` → `Cart` → `Purchase` per category to identify high-performing products.

### 3. Customer Segmentation (RFM)
I grouped users into **VIP**, **Loyal**, and **Regular** tiers based on their lifetime purchase counts to understand our user base.

---

## Dashboard Output
*The final dashboard tracking Revenue, Funnels, and Customer Tiers.*
<img width="1012" height="686" alt="Screenshot 2026-01-17 at 14 40 28" src="https://github.com/user-attachments/assets/18cba280-e97c-48e2-a9ee-fa222c5f5e6b" />

---
## 🚀 Key Learnings
* **Zero-Copy Analytics:** I didn't need to export data to Tableau or PowerBI. The dashboard sits directly on top of the Delta Tables.
* **Unified Governance:** The same Unity Catalog permissions that protect the raw files also protect the dashboard results.
---
## ✅ Tasks Completed
- [x] **SQL Warehouse Setup:** Configured a Serverless SQL Warehouse to act as the compute engine for analytics.
- [x] **Advanced SQL Querying:**
    - Developed **Moving Average** logic using Window Functions (`ROWS BETWEEN...`) to smooth revenue trends.
    - Built a **Conversion Funnel** query to track user journeys from View → Cart → Purchase.
    - Created a **Customer Segmentation** model (RFM-style) to classify users into VIP and Regular tiers.
- [x] **Dashboard Creation:** Built a multi-chart Lakeview Dashboard combining Line, Bar, and Pie charts.
- [x] **Interactivity & Governance:**
    - Added a global **Date Range Filter** for dynamic reporting.
    - Configured **Data Permissions** to ensure the dashboard shares the secure access model of the underlying Unity Catalog tables.
---
### 📂 Repository Structure
* **`Day 9 - SQL Analytics & Dashboards.ipynb`**: The engineering notebook used to ingest and merge the combined Oct/Nov dataset for this specific analysis.
* **`Day 9 - analytics_queries.sql`**: A consolidated SQL file containing the three analytical queries (Revenue Trends, Funnel Analysis, Customer Tiers) used to power the visualizations.
