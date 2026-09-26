-- =====================================================================
-- File: 01_Enterprise_DB_Setup.sql
-- Author: Vaibhav
-- Objective: Provision NexusTech_ERP database, schemas, and generate bulk test data
-- =====================================================================

USE master;
GO

-- 1. Provision the Database safely
IF DB_ID('NexusTech_ERP') IS NOT NULL
BEGIN
    ALTER DATABASE NexusTech_ERP SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NexusTech_ERP;
END
GO

CREATE DATABASE NexusTech_ERP;
GO

ALTER DATABASE NexusTech_ERP SET RECOVERY SIMPLE; -- Minimize log growth during bulk inserts
GO

USE NexusTech_ERP;
GO

-- 2. Define Schemas
CREATE SCHEMA HR;
GO
CREATE SCHEMA Sales;
GO

-- 3. Create Tables (Intentionally excluding non-clustered indexes for baseline testing)
CREATE TABLE HR.Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    LocationCode CHAR(3) NOT NULL
);
GO

CREATE TABLE HR.Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentID INT FOREIGN KEY REFERENCES HR.Departments(DepartmentID),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    HireDate DATE,
    IsActive BIT DEFAULT 1
);
GO

CREATE TABLE Sales.Transactions (
    TransactionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT FOREIGN KEY REFERENCES HR.Employees(EmployeeID),
    TransactionDate DATETIME,
    Amount DECIMAL(18,2),
    TransactionType VARCHAR(20),
    Status VARCHAR(20)
);
GO

-- 4. Seed Data - Departments
INSERT INTO HR.Departments (DepartmentName, LocationCode)
VALUES 
('Enterprise Sales', 'MUM'), ('IT Infrastructure', 'PUN'), ('Human Resources', 'MUM'), 
('Corporate Finance', 'DEL'), ('Global Marketing', 'BLR'), ('Client Support', 'HYD');
GO

SELECT * FROM HR.Departments;

-- 5. Insert data 20 Employees
INSERT INTO HR.Employees (DepartmentID, FirstName, LastName, HireDate)
VALUES 
(1, 'Rahul', 'Sharma', '2022-01-15'), (2, 'Priya', 'Patel', '2021-03-22'),
(3, 'Amit', 'Deshmukh', '2019-11-05'), (4, 'Sneha', 'Kulkarni', '2023-08-10'),
(5, 'Rohan', 'Joshi', '2020-02-18'), (6, 'Anjali', 'Rao', '2018-07-30'),
(1, 'Vikram', 'Singh', '2021-09-14'), (2, 'Kavita', 'Nair', '2022-11-25'),
(3, 'Siddharth', 'Menon', '2020-05-12'), (4, 'Neha', 'Gupta', '2019-01-20'),
(5, 'Aditya', 'Verma', '2023-04-03'), (6, 'Pooja', 'Iyer', '2021-08-17'),
(1, 'Manish', 'Tiwari', '2017-12-05'), (2, 'Divya', 'Reddy', '2020-10-09'),
(3, 'Karan', 'Malhotra', '2022-06-21'), (4, 'Swati', 'Chavan', '2019-03-11'),
(5, 'Gaurav', 'Bhatia', '2023-02-28'), (6, 'Shruti', 'Pandey', '2021-12-15'),
(1, 'Ravi', 'Kumar', '2018-09-02'), (2, 'Meera', 'Jadhav', '2022-05-19');
GO

-- 6. Seed Data - 50 Transactions

INSERT INTO Sales.Transactions (EmployeeID, TransactionDate, Amount, TransactionType, Status)
VALUES 
(3, '2025-06-15 09:30:00', 1500.00, 'Purchase', 'Completed'),
(8, '2025-07-21 14:45:00', 320.50, 'Purchase', 'Completed'),
(14, '2025-08-05 11:15:00', 890.00, 'Purchase', 'Pending'),
(2, '2025-09-10 16:20:00', 4500.75, 'Purchase', 'Completed'),
(19, '2025-09-15 10:05:00', 120.00, 'Refund', 'Completed'),
(7, '2025-10-02 13:50:00', 2750.25, 'Purchase', 'Completed'),
(1, '2025-10-18 09:10:00', 600.00, 'Purchase', 'Completed'),
(11, '2025-11-04 15:30:00', 1800.50, 'Purchase', 'Pending'),
(16, '2025-11-20 12:40:00', 950.00, 'Purchase', 'Completed'),
(5, '2025-12-05 14:15:00', 2100.00, 'Purchase', 'Completed'),
(9, '2025-12-12 10:25:00', 340.75, 'Refund', 'Completed'),
(13, '2026-01-08 11:50:00', 5300.00, 'Purchase', 'Completed'),
(20, '2026-01-15 16:05:00', 780.25, 'Purchase', 'Completed'),
(4, '2026-02-02 09:45:00', 1450.00, 'Purchase', 'Pending'),
(18, '2026-02-14 13:20:00', 250.00, 'Refund', 'Completed'),
(6, '2026-03-01 10:30:00', 3100.50, 'Purchase', 'Completed'),
(15, '2026-03-10 15:10:00', 670.00, 'Purchase', 'Completed'),
(10, '2026-03-22 11:40:00', 4200.75, 'Purchase', 'Pending'),
(17, '2026-04-05 14:55:00', 890.50, 'Purchase', 'Completed'),
(3, '2026-04-18 09:20:00', 1150.00, 'Refund', 'Completed'),
(12, '2026-05-02 16:35:00', 2900.25, 'Purchase', 'Completed'),
(8, '2026-05-15 12:15:00', 540.00, 'Purchase', 'Completed'),
(1, '2026-06-08 10:05:00', 3700.50, 'Purchase', 'Pending'),
(19, '2026-06-20 14:40:00', 620.75, 'Purchase', 'Completed'),
(14, '2026-07-05 11:25:00', 1850.00, 'Purchase', 'Completed'),
(7, '2026-07-18 15:50:00', 410.00, 'Refund', 'Completed'),
(2, '2026-08-02 09:35:00', 5200.25, 'Purchase', 'Completed'),
(16, '2026-08-15 13:10:00', 930.50, 'Purchase', 'Pending'),
(11, '2026-09-01 10:45:00', 2600.00, 'Purchase', 'Completed'),
(5, '2026-09-10 14:20:00', 175.75, 'Refund', 'Completed');
GO

