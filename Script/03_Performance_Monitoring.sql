-- =====================================================================
-- File: 03_Performance_Monitoring.sql
-- Author: Vaibhav
-- Objective: Monitor KPIs via DMVs, identify missing indexes, and apply optimizations
-- =====================================================================

USE NexusTech_ERP;
GO

-- =====================================================================
-- PHASE 1: DIAGNOSTICS & MONITORING
-- =====================================================================

-- Metric 1: Server Wait Statistics (Identify CPU vs. I/O bottlenecks)
SELECT TOP 10
    wait_type,
    wait_time_ms / 1000.0 AS WaitTime_Seconds,
    waiting_tasks_count,
    (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceWaitTime_Seconds
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
    'DIRTY_PAGE_POLL', 'LAZYWRITER_SLEEP', 'LOGMGR_QUEUE', 'SLEEP_TASK', 
    'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'BROKER_TASK_STOP'
)
ORDER BY wait_time_ms DESC;
GO

-- Metric 2: High CPU Queries from the Plan Cache
SELECT TOP 5
    qs.execution_count,
    qs.total_worker_time / 1000 AS Total_CPU_Time_ms,
    (qs.total_worker_time / qs.execution_count) / 1000 AS Avg_CPU_Time_ms,
    SUBSTRING(qt.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(qt.text) ELSE qs.statement_end_offset END 
        - qs.statement_start_offset)/2) + 1) AS Problematic_Query,
    qp.query_plan AS Execution_Plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_worker_time DESC;
GO

-- Metric 3: Missing Index Recommendations
SELECT TOP 5
    ROUND(migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans), 2) AS Optimization_Impact_Score,
    'CREATE INDEX IX_' + OBJECT_NAME(mid.object_id) + ' ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '') + 
    CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + 
    ISNULL(mid.inequality_columns, '') + ')' + 
    ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS Recommended_DDL
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY Optimization_Impact_Score DESC;
GO

-- =====================================================================
-- PHASE 2: OPTIMIZATION DEPLOYMENT
-- =====================================================================
PRINT 'Deploying Schema Optimizations...';

-- Optimization 1: Covering Index for the Revenue Reporting Procedure
CREATE NONCLUSTERED INDEX IX_Transactions_Status_Date 
ON Sales.Transactions (Status, TransactionDate)
INCLUDE (EmployeeID, Amount);
GO

-- Optimization 2: Targeted Index for HR Lookups
CREATE NONCLUSTERED INDEX IX_Employees_LastName 
ON HR.Employees (LastName)
INCLUDE (FirstName, HireDate);
GO

-- Flush the procedure cache to force SQL Server to utilize the new indexes
DBCC FREEPROCCACHE;
GO

-- =====================================================================
-- PHASE 3: POST-OPTIMIZATION VALIDATION
-- =====================================================================
-- Execute manually with 'Include Actual Execution Plan' (Ctrl+M) enabled
-- Confirm the transition from 'Clustered Index Scan' to 'Index Seek'
EXEC Sales.usp_GetRevenueByEmployee @StartDate = '2024-01-01', @EndDate = '2026-12-31';
GO

