-- =====================================================================
-- File: 02_Workload_Simulation.sql
-- Author: Vaibhav
-- Objective: Compile application stored procedures and simulate heavy server load
-- =====================================================================

USE NexusTech_ERP;
GO

-- 1. Compile Procedure 1: Heavy Aggregation (Missing Index on Status/Date)
CREATE OR ALTER PROCEDURE Sales.usp_GetRevenueByEmployee
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    -- Forces a Clustered Index Scan because the WHERE clause columns aren't indexed
    SELECT 
        e.FirstName, 
        e.LastName, 
        COUNT(t.TransactionID) AS TotalTransactions,
        SUM(t.Amount) AS TotalRevenue
    FROM Sales.Transactions t
    INNER JOIN HR.Employees e ON t.EmployeeID = e.EmployeeID
    WHERE t.Status = 'Completed' 
      AND t.TransactionDate BETWEEN @StartDate AND @EndDate
    GROUP BY e.FirstName, e.LastName
    ORDER BY TotalRevenue DESC;
END;
GO

-- 2. Compile Procedure 2: Poorly Written Query (Implicit Conversion/Wildcards)
CREATE OR ALTER PROCEDURE HR.usp_SearchEmployees
    @SearchTerm VARCHAR(50)
AS
BEGIN
    -- Leading wildcards (%) prevent index seeks (SARGability issue)
    SELECT EmployeeID, FirstName, LastName, HireDate
    FROM HR.Employees
    WHERE LastName LIKE '%' + @SearchTerm + '%';
END;
GO

-- 3. Execute the Workload Simulator
PRINT 'Initiating Load Simulation... (Please wait 10-20 seconds)';
SET NOCOUNT ON;
DECLARE @RunCount INT = 1;

-- Run a loop to pollute the plan cache and generate actionable wait statistics
DECLARE @RunCount INT = 1;

WHILE @RunCount <= 50
BEGIN
    EXEC Sales.usp_GetRevenueByEmployee 
        @StartDate = '2024-01-01', 
        @EndDate = '2026-12-31';

    EXEC HR.usp_SearchEmployees @SearchTerm = '88';
    
    SET @RunCount = @RunCount + 1;
END;

PRINT 'Load Simulation Complete. Ready for monitoring.';
GO

