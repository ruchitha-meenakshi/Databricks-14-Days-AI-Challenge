# Day 2: Apache Spark Fundamentals 

**Challenge:** [Databricks 14-Day AI Challenge](https://www.linkedin.com/feed/hashtag/?keywords=databrickswithidc)  
**Topic:** Spark Architecture & DataFrame Transformations  

<img width="512" height="640" alt="image" src="https://github.com/user-attachments/assets/06efecc7-5f4f-4cfc-9049-6494f0d2cb58" />

![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![Codebasics](https://img.shields.io/badge/Codebasics-F7931E?style=for-the-badge)
![Indian Data Club](https://img.shields.io/badge/Indian_Data_Club-4CAF50?style=for-the-badge)  
![Status](https://img.shields.io/badge/Status-In_Progress-yellow?style=for-the-badge)
---

## 🧠 Theory: How Spark Works
Today I learned that Spark is **Lazy** (in a good way!).

### 1. Spark Architecture: 
Spark is a distributed computing engine. This means it doesn't run on one computer; it runs on a cluster of computers acting as one.

* **The Driver (The "Manager"):**
  * **Role:** This is the process running your main function (your notebook). It is the "Brain" of the operation.
  * **Responsibilities:** It converts your Python code into tasks, builds the execution plan (DAG), and schedules work for the Executors. It also collects the final results (e.g., when you run `.collect()` or `print`).
  * **Critical Note:** The Driver has limited memory. If you try to `.collect()` a 100GB dataset back to the Driver, it will crash (OOM Error).

* **The Executors (The "Workers"):**
  * **Role:** These are processes running on the worker nodes (the other computers in the cluster).
  * **Responsibilities:** They do the heavy lifting. They execute the tasks assigned by the Driver and store data in memory or on disk.
  * **Scale:** You can have 10 or 1,000 executors working in parallel.

* **DAG (Directed Acyclic Graph):**
  * **What is it?** It is the "Instruction Manual" or "Recipe" that the Driver creates.
  * **Directed:** It flows one way (Input -> Processing -> Output).
  * **Acyclic:** It doesn't loop back on itself (no infinite loops).
  * **Why it matters:** When you write code, Spark doesn't run it immediately. It draws this graph first. This allows the Catalyst Optimizer to rearrange the graph for maximum speed (e.g., "Let's filter the data before we join it to save time").

#### Analogy: Think of a restaurant.  
* **Driver:** The Head Chef (Planning the menu, shouting orders).
* **Executors:** The Line Cooks (Chopping, frying, plating in parallel).
* **DAG:** The Ticket/Order (The specific list of steps to cook the meal).
  <img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/183f929e-9136-4e4d-9949-7559d12b5ce6" />


### 2. DataFrames vs. RDDs  
This is the classic "Old Spark" vs. "Modern Spark" comparison.

* **RDD (Resilient Distributed Dataset):**
  * **What is it?** The low-level building block of Spark. It's essentially a distributed collection of Python objects.
  * **The Problem:** Spark treats RDDs as "black boxes." It doesn't know what's inside the objects (is it a string? an integer?). Because of this, it cannot optimize much.
  * **Performance:** In Python (PySpark), RDDs are **slow** because data has to be serialized (converted) between Python and the Java Virtual Machine (JVM) for every single row.

* **DataFrames:**
  * **What is it?** A distributed collection of data organized into named columns (like a SQL table or Excel sheet).
  * **The Superpower:** Spark understands the **Schema** (Column types).
  * **Performance:** Because Spark knows the structure, it uses the Tungsten execution engine to optimize memory and CPU.
  * **Key Takeaway:** In PySpark, DataFrames are almost as fast as Scala/Java code. RDDs are significantly slower. **Always use DataFrames.**

### 3. Lazy Evaluation: Doing Less to Do More  
This is the hardest concept for beginners coming from Pandas.

* **Eager Evaluation (Pandas):** You run ```df = read_csv(...)```, and the computer reads the file immediately. You run ```df_filtered = df[df['price'] > 10]```, and it filters immediately.

* **Lazy Evaluation (Spark):**
  * **Transformations (Lazy):** When you run ```df.filter(...)``` or ```df.select(...)```, Spark does nothing. It just records the step in the DAG. It says, "Okay, later I will need to filter."
  * **Actions (Eager):** Spark only starts working when you ask for a result (an Action). **Examples:** ```count(), show(), write(), collect().```

* **Why is this brilliant?** Imagine you load a 1TB file but only want the top 10 rows ```(df.limit(10).show()).```
  *  **If Eager:** It would load 1TB into memory, then take the top 10. (Slow/Crash).
  *  **If Lazy:** Spark looks at the plan and sees you only want 10 rows. It reads just enough of the file to find 10 rows and stops. (Instant).

### 4. Notebook Magic Commands  
In Databricks, we can mix languages within a single notebook using "Magic" commands (denoted by ```%```).  
* ```%python:``` The default for our notebook. Allows us to write PySpark code.
* ```%sql:``` Allows us to write standard SQL queries.
  * **Pro-tip:** We can create a temporary view of our dataframe (```df.createOrReplaceTempView("my_data")```) and then query it with ```%sql SELECT * FROM my_data.```
* ```%fs:``` Short for "File System". It allows us to interact with the Databricks file system (DBFS) and Volumes.
  * ```%fs ls /Volumes/...```: List files.
  * ```%fs head ...```: Preview a file.
  * **Note:** In the "Day 0" notebook, we used ```%sh``` (shell) to run ```ls -lh```. ```%fs``` is the Databricks-native version of that.
---
## Hands-On Practice: Analyzing E-Commerce Data

**Objective:** Perform standard ETL operations (Extract, Transform, Load) on a sample dataset to find top-performing brands.  
### Step 1: Sampling & Ingestion  
To simulate a development environment, I created a 1% sample from the main dataset and saved it as a separate CSV.  
* **Input:** `424,672` rows (Sampled from the 100M+ dataset).
<img width="932" height="432" alt="Screenshot 2026-01-10 at 11 23 26" src="https://github.com/user-attachments/assets/07ea66ff-9a2e-4e56-a870-b571a580cdff" />
*(Reading the sample CSV and previewing the schema)*  

### Step 2: Filtering (The "Samsung" Analysis)  
I used PySpark transformations to isolate specific user behaviors.  
* **Task:** Find all confirmed purchases for the brand "Samsung".
* **Code:** `df.filter((col("brand") == "samsung") & (col("event_type") == "purchase"))`
* **Result:** Found **1,745** specific purchase events.
<img width="929" height="239" alt="Screenshot 2026-01-10 at 11 23 36" src="https://github.com/user-attachments/assets/c678bec5-f281-49d3-a172-bf4538d4b171" />

### Step 3: Aggregation (Top Brands)  
I performed a `groupBy` and `orderBy` transformation to rank brands by total sales volume.  
**🏆 Top 5 Brands by Purchase Count:**  
1.  **Samsung** (1,745)
2.  **Apple** (1,424)
3.  **Xiaomi** (590)
4.  *(Null/Generic)* (558)
5.  **Huawei** (222)
<img width="365" height="201" alt="Screenshot 2026-01-10 at 11 30 38" src="https://github.com/user-attachments/assets/9ff8fa26-ffbf-454f-8721-c5bc7b3f0680" />

---
## 📂 Repository Structure

* **`Day 2 - Apache Spark Fundamentals.ipynb`**
  The Transformation & Analysis notebook: Demonstrates Spark architecture (Lazy Evaluation), performs ETL transformations (Select, Filter, GroupBy) on sample data, and generates brand performance reports.

