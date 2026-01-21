# Day 3: PySpark Transformations Deep Dive 

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** Advanced Joins, Window Functions, and User-Defined Functions (UDFs)  
![3](https://github.com/user-attachments/assets/acb6ddc6-0dd9-4bfe-a175-b15413726aa5)


![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-Completed-green?style=for-the-badge)
---

## Theory: Moving Beyond "Just Coding"

Today I learned that handling Big Data isn't just about writing code; it's about managing resources efficiently. Here is the breakdown:

### 1. PySpark vs. Pandas
* **Pandas (The Solo Chef):** Imagine one chef trying to cook for a wedding. If the order is too big (too much data), the kitchen crashes. This is Pandas—it works great for small tasks but runs out of memory on big ones.
* **Spark (The Kitchen Brigade):** Spark is like a team of 100 chefs. It splits the work up. If the job is huge, it just adds more chefs (computers).
  * **The "Lazy" Secret:** Spark is smart. It doesn't start cooking immediately. It reads the whole recipe (code) first to find shortcuts (optimizations) before it even turns on the stove.


### 2. The Art of Joins (Inner, Left, Right, Full)
In distributed computing, joining is the most expensive operation because of **Shuffling.**
  * **The Shuffle Problem**: Imagine you have two massive piles of playing cards (Table A and Table B) in two different rooms. To match the "King of Hearts" from both piles, you have to physically move cards between rooms. In Spark, this means sending data over the network between different servers. This is slow and clogs the network.

**The Join Types Explained**:
* **Inner Join:** The "Strict" Filter. It keeps only rows where keys exist in both tables. If a product ID in the `Sales` table doesn't exist in the `Products` table, that sale record is deleted from the result.
* **Left Join:** The "Sales Preservation" Filter. It keeps all rows from the Left (Sales) table. If a product description is missing in the Right (Products) table, Spark doesn't delete the sale—it just fills the description column with `null.` This is standard for enriching Fact tables.
* **Right Join:** The "Audit" Filter. It keeps all rows from the Right table. 
* **Full Outer Join:** The "Hoarder" Filter. It keeps everything. If a sale has no product info, it keeps it. If a product has no sales, it keeps it.

#### The Speed Hack: Broadcast Join
Usually, joining big data requires moving massive files across the network (slow).
* **The Trick:** I had one huge table (46M sales) and one tiny table (Departments).
* **The Solution:** Instead of moving the huge table, I gave a **copy** of the tiny Department list to every single computer.
* **Result:** The computers could finish the work instantly without talking to each other.

### 3. Window Functions 
Standard aggregations (GroupBy) are destructive—they collapse rows.
* `GroupBy:` "User A spent $500 total." (You lose the individual transaction details).
* `Window:` "User A bought a shirt for $50, then shoes for $100 (Total so far: $150)..."
**How it works:** A Window Function creates a "frame" around the current row to look at other rows.
  1. `PartitionBy:` Defines the group (e.g., "Look only at this user's history").
  2. `OrderBy:` Defines the timeline (e.g., "Sort transactions from Jan 1st to Dec 31st").
  3. `RowsBetween:` Defines the scope (e.g., "Look at all rows from the beginning of time up to the current row").
This allows us to calculate **Running Totals, Moving Averages, and Rankings** without losing the granularity of the raw data.

### 4. User-Defined Functions (Custom Tools)
Spark has a rich library of native functions (col, sum, avg, split). But sometimes, business logic is too complex for SQL (e.g., proprietary scoring models, complex text parsing).
  * **The Trade-off:** Native Spark functions run inside the JVM (Java Virtual Machine) and are highly optimized. When you write a Python UDF, Spark has to:
    1. Serialize the data (convert it to a format Python understands).
    2. Send it to a Python process.
    3. Run your Python code line-by-line.
    4. Send the result back to the JVM.
  * **The "Vectorized" Solution:** Modern Spark uses **Pandas UDFs** (built on Apache Arrow). Instead of processing row-by-row, it sends a whole "batch" (vector) of data to Python at once. It is much faster, but still slower than native Spark code. 
    **Rule of Thumb: Always check if a native function exists before writing a UDF.**
---

## 🛠️ Hands-On: The Engineering Pipeline

### 1: Data Enrichment (Broadcast Join)
I enriched the raw sales data with a "Department" lookup table by extracting the main category from `category_code`.
* **Tech:** `split(col("category_code"), r"\.")[0]` to handle the regex parsing safely.
<img width="793" height="443" alt="Screenshot 2026-01-11 at 15 25 05" src="https://github.com/user-attachments/assets/d1a5ccfa-60f8-4b36-a028-6e2ca0304dfd" />

### 2: User Behavioral Analysis (Window Functions)
I calculated the **lifetime value** of a customer at the exact moment of each purchase.
* **Logic:** `sum("price").over(Window.partitionBy("user_id").orderBy("event_time"))`
<img width="750" height="604" alt="Screenshot 2026-01-11 at 15 26 45" src="https://github.com/user-attachments/assets/cb102d54-27ac-4279-8c24-0640c08b2ee5" />

### 3: Conversion Funnel Analysis
I created a derived feature to measure brand performance: **View-to-Purchase Conversion Rate**.
* **Transformation:** Pivoted the data (Rows=Brand, Columns=Events) to calculate `(Purchase / View) * 100`.
<img width="643" height="564" alt="Screenshot 2026-01-11 at 15 27 46" src="https://github.com/user-attachments/assets/fa1577a3-a0d6-46d3-b727-332b47e178db" />
---

## ✅ Tasks Completed
- [x] Loaded optimized Parquet data (`spark.read.parquet`).
- [x] Performed **Broadcast Joins** (Left, Inner, Right, Full).
- [x] Calculated **Running Totals** using Window partitioning.
- [x] Created **Derived Features** (Conversion Rate) via Pivoting.
- [x] Implemented a **UDF** to categorize price ranges.

---
## 📂 Repository Structure

* **`Day 3 - PySpark Transformations Deep Dive.ipynb `**
    The Advanced Data Engineering notebook: Demonstrates Broadcast Joins for optimization, implements Window Functions for running totals (user behavioral analysis), and creates complex derived features like conversion rates using Pivoting and UDFs.
