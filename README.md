# -Week-4-Task-Database-Performance-Monitoring-and-Reporting
# SQL Server Performance Monitoring & Query Optimization

## 📌 Project Overview
This project demonstrates an end-to-end enterprise database performance audit and optimization workflow. It simulates a heavy transactional workload against a standardized ERP database (`NexusTech_ERP`) to deliberately generate CPU and I/O bottlenecks. Using SQL Server's native Dynamic Management Views (DMVs) and Execution Plan analysis, structural inefficiencies are identified and resolved through targeted non-clustered covering indexes.

## 🛠️ Technology Stack
* **RDBMS:** Microsoft SQL Server 2022 Developer Edition
* **Environment:** SQL Server Management Studio (SSMS)
* **Techniques:** Dynamic Management Views (DMVs), Execution Plan Analysis, Workload Simulation, Query Tuning, SARGability Optimization

## 🗂️ Repository Structure
| File/Folder | Description |
| :--- | :--- |
| `01_Enterprise_DB_Setup.sql` | Provisions the database, schemas (`HR`, `Sales`), and generates 10,000+ realistic seed records. |
| `02_Workload_Simulation.sql` | Compiles application stored procedures and executes T-SQL loops to pollute the plan cache and simulate heavy server load. |
| `03_Performance_Monitoring.sql` | Extracts diagnostic data via DMVs (`sys.dm_exec_query_stats`, `sys.dm_db_missing_index_details`) and deploys structural index optimizations. |
| `Performance_Optimization_Report.docx` | Comprehensive documentation of the audit methodology, identified bottlenecks, and executed resolutions. |
| `Screenshots/` | Visual evidence of Activity Monitor metrics and Execution Plan comparisons (Before/After). |

## 🚀 Methodology & Implementation Steps

### 1. Database Provisioning & Baseline
Created a normalized schema featuring `HR.Employees` and `Sales.Transactions`. Critical financial tables were intentionally left without non-clustered indexes to establish a baseline for identifying structural deficiencies during load testing.

### 2. Workload Simulation
Encapsulated complex aggregation queries and wildcard string searches into stored procedures. Iteratively executed these procedures to force the SQL Server storage engine to perform inefficient Clustered Index Scans and generate measurable CPU wait statistics.

### 3. Diagnostics & Bottleneck Identification
Queried DMVs to extract real-time internal server state data:
* **`sys.dm_os_wait_stats`:** Monitored `PAGEIOLATCH_SH` (disk reading pressure) and `CXPACKET` (thread parallelism contention).
* **`sys.dm_exec_query_stats`:** Isolated the specific stored procedures consuming the highest total worker time (CPU latency).
* **Execution Plans:** Identified high-cost `Clustered Index Scan` operations consuming >90% of query execution cost.

### 4. Optimization & Resolution
Deployed Non-Clustered Covering Indexes tailored to the exact specifications requested by the query optimizer. 
* *Example Deployment:* `CREATE NONCLUSTERED INDEX IX_Transactions_Status_Date ON Sales.Transactions (Status, TransactionDate) INCLUDE (EmployeeID, Amount);`

## 📊 Performance Results (Before vs. After)

**Before Optimization:**
* Heavy memory pressure due to the engine reading the entire table into memory for filtering.
* Execution plans confirmed a highly inefficient **Clustered Index Scan**.
* *Insert screenshot here once pushed:*
  <br> `![Pre Optimization](Screenshots/02_Pre_Optimization_Scan.png)`

**After Optimization:**
* Drastic reduction in logical reads; the index satisfied the `WHERE` clause directly while supplying the `SELECT` columns via the leaf level (`INCLUDE` clause).
* Execution plans confirmed a highly efficient **Index Seek**.
* *Insert screenshot here once pushed:*
  <br> `![Post Optimization](Screenshots/04_Post_Optimization_Seek.png)`

## ⚙️ How to Run This Project
1. Open SQL Server Management Studio (SSMS) and connect to your local SQL Server instance.
2. Open and execute `01_Enterprise_DB_Setup.sql` to build the database and seed the data.
3. Open `02_Workload_Simulation.sql` and execute the script to compile the procedures and simulate the server load.
4. Open `03_Performance_Monitoring.sql` and execute the DMV SELECT queries (Phase 1) to view the diagnostic results in the grid.
5. Highlight and execute the `CREATE INDEX` statements in Phase 2, then run Phase 3 with **Include Actual Execution Plan** (`Ctrl + M`) enabled to verify the performance gains.

---
**Author:** Vaibhav
