## Surgery Blood Pressure Analysis (T-SQL)

### Overview
This repository contains a T-SQL script that seeds a sample dataset of perioperative blood-pressure measurements, computes 3-point moving averages (1 day before, day of, 1 day after) per patient, and flags unusual values into a separate table for review.

### Features
- **Data seeding**: Populates `dbo.BloodPressureRecords` with sample rows across days before/after surgery
- **Window analytics**: Computes moving averages per patient using window functions
- **Alert extraction**: Creates `dbo.AlarmingRate` with rows where moving averages breach thresholds
- **Easy inspection**: Selects from both tables to review results

### Tech stack
- **Microsoft SQL Server (T-SQL)**
  - Uses `GO` batch separators and window frames (`ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING`)
  - Compatible with SQL Server 2012+ and Azure SQL Database

### Repository structure
- `SQLFile1.sql` — main script to create tables, insert data, compute moving averages, and extract alarming rows

### Prerequisites
- SQL Server instance (on-prem, Docker, or Azure SQL Database)
- SSMS or Azure Data Studio for execution

### Getting started
1. Connect to your SQL Server/Azure SQL instance using SSMS or Azure Data Studio.
2. Create (or choose) a database named `SurgeryDB`:
```sql
CREATE DATABASE SurgeryDB;
Open and execute SQLFile1.sql. It will:
Use the SurgeryDB database
Drop/recreate dbo.BloodPressureRecords
Insert sample records
Compute moving averages via a CTE and window functions
Drop/recreate dbo.AlarmingRate
Insert only rows with unusual averages into dbo.AlarmingRate
Select from both tables for review
Data model
dbo.BloodPressureRecords

Keys/metadata: RecordID (IDENTITY, PK), PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription
Vitals: Systolic, Diastolic, HeartRate
Demographics/notes: Age, Gender, Medication, Allergic
Computed: AvgSystolic_Moving, AvgDiastolic_Moving
dbo.AlarmingRate

Same columns; populated only when moving averages breach thresholds
Core logic
Moving averages per patient:
AVG(CAST(Systolic AS DECIMAL(5,2))) OVER (
  PARTITION BY PatientID
  ORDER BY RecordDate
  ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
:)
Thresholds for flagging into dbo.AlarmingRate:
AvgSystolic_Moving >= 140 or <= 90
AvgDiastolic_Moving >= 90 or <= 60
Customize
Change thresholds: Edit the WHERE clause before inserting into dbo.AlarmingRate.
Adjust window size: Modify the ROWS BETWEEN ... AND ... frame.
Add more data: Append INSERT rows to dbo.BloodPressureRecords.
Target a different DB: Change the USE SurgeryDB; line or remove it and run in your desired context.
Example queries after running
SELECT * FROM dbo.BloodPressureRecords ORDER BY PatientID, RecordDate;
SELECT * FROM dbo.AlarmingRate ORDER BY PatientID, RecordDate;
Notes
The dataset is synthetic and intended for demonstrating window functions and simple thresholds.

```1:165:/workspace/README_FULL.md
## Surgery Blood Pressure Analysis — Full Reference

### Overview
This project demonstrates perioperative blood-pressure analytics in Microsoft SQL Server. The script creates a dataset of measurements around surgery dates, computes 3-point moving averages per patient using window functions, and extracts rows with unusual average values into a dedicated review table.

### Quick start
1. Connect to SQL Server (SSMS or Azure Data Studio).
2. Ensure a database named `SurgeryDB` exists, or create it:
```sql
CREATE DATABASE SurgeryDB;
Run the script below (or execute SQLFile1.sql). It will build tables, seed sample data, compute moving averages, and surface outliers.
Tables
dbo.BloodPressureRecords: Raw vitals plus computed moving averages
dbo.AlarmingRate: Subset of rows breaching thresholds
Moving average logic
3-point window per patient: previous day, current day, next day
SQL window frame: ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
Default thresholds
Systolic average flagged if >= 140 or <= 90
Diastolic average flagged if >= 90 or <= 60
Customize
Change thresholds in the WHERE clause before inserting into dbo.AlarmingRate.
Adjust the window frame to widen/narrow the moving average period.
Append additional INSERT rows to enrich sample data.
Full SQL script
-- ===========================================
-- Blood Pressure Records - Moving Average 1 Day Before/After Surgery
-- ===========================================

USE SurgeryDB;
GO

-- 1. Drop BloodPressureRecords if exists
IF OBJECT_ID('dbo.BloodPressureRecords', 'U') IS NOT NULL
    DROP TABLE dbo.BloodPressureRecords;
GO

-- 2. Create BloodPressureRecords table
CREATE TABLE dbo.BloodPressureRecords (
    RecordID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    PatientName NVARCHAR(30) NULL,
    RecordDate DATE NOT NULL,
    DaysFromSurgery INT NULL,
    DayDescription NVARCHAR(30) NULL,
    Systolic INT NULL,
    Diastolic INT NULL,
    HeartRate INT NULL,
    Age INT NULL,
    Gender NVARCHAR(10) NULL,
    Medication NVARCHAR(30) NULL,
    Allergic NVARCHAR(30) NULL,
    AvgSystolic_Moving DECIMAL(5,2) NULL,
    AvgDiastolic_Moving DECIMAL(5,2) NULL
);
GO

-- 3. Insert sample records
INSERT INTO dbo.BloodPressureRecords
(PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription, Systolic, Diastolic, HeartRate, Age, Gender, Medication, Allergic)
VALUES
(1, 'Patient_1', '2025-08-18', -2, '2 days before surgery', 135, 87, 73, 45, 'Male', NULL, NULL),
(1, 'Patient_1', '2025-08-19', -1, '1 day before surgery', 138, 88, 75, 45, 'Male', NULL, NULL),
(1, 'Patient_1', '2025-08-20', 0, 'Surgery Day', 140, 90, 80, 45, 'Male', NULL, NULL),
(1, 'Patient_1', '2025-08-21', 1, '1 day after surgery', 142, 91, 82, 45, 'Male', NULL, NULL),
(2, 'Patient_2', '2025-08-17', -3, '3 days before surgery', 129, 83, 72, 50, 'Female', 'Aspirin', 'Peanuts'),
(2, 'Patient_2', '2025-08-18', -2, '2 days before surgery', 131, 84, 73, 50, 'Female', 'Aspirin', 'Peanuts'),
(2, 'Patient_2', '2025-08-19', -1, '1 day before surgery', 133, 85, 74, 50, 'Female', 'Aspirin', 'Peanuts'),
(2, 'Patient_2', '2025-08-20', 0, 'Surgery Day', 135, 88, 78, 50, 'Female', 'Aspirin', 'Peanuts'),
(2, 'Patient_2', '2025-08-21', 1, '1 day after surgery', 136, 89, 79, 50, 'Female', 'Aspirin', 'Peanuts'),
(2, 'Patient_2', '2025-08-22', 2, '2 days after surgery', 138, 90, 80, 50, 'Female', 'Aspirin', 'Peanuts'),
(3, 'Patient_3', '2025-08-19', -1, '1 day before surgery', 124, 84, 74, 60, 'Male', NULL, NULL),
(3, 'Patient_3', '2025-08-20', 0, 'Surgery Day', 125, 85, 75, 60, 'Male', NULL, NULL),
(3, 'Patient_3', '2025-08-21', 1, '1 day after surgery', 127, 86, 77, 60, 'Male', NULL, NULL),
(3, 'Patient_3', '2025-08-22', 2, '2 days after surgery', 128, 87, 78, 60, 'Male', NULL, NULL),
(3, 'Patient_3', '2025-08-23', 3, '3 days after surgery', 130, 88, 79, 60, 'Male', NULL, NULL),
(4, 'Patient_4', '2025-08-16', -4, '4 days before surgery', 132, 86, 76, 55, 'Female', NULL, NULL),
(4, 'Patient_4', '2025-08-17', -3, '3 days before surgery', 135, 87, 77, 55, 'Female', NULL, NULL),
(4, 'Patient_4', '2025-08-18', -2, '2 days before surgery', 138, 88, 78, 55, 'Female', NULL, NULL),
(4, 'Patient_4', '2025-08-19', -1, '1 day before surgery', 140, 90, 80, 55, 'Female', NULL, NULL),
(4, 'Patient_4', '2025-08-20', 0, 'Surgery Day', 145, 95, 85, 55, 'Female', NULL, NULL),
(4, 'Patient_4', '2025-08-21', 1, '1 day after surgery', 150, 98, 88, 55, 'Female', NULL, NULL),
(4, 'Patient_4', '2025-08-22', 2, '2 days after surgery', 155, 100, 90, 55, 'Female', NULL, NULL),
(4, 'Patient_4', '2025-08-23', 3, '3 days after surgery', 160, 102, 92, 55, 'Female', NULL, NULL),
(4, 'Patient_4', '2025-08-24', 4, '4 days after surgery', 162, 105, 94, 55, 'Female', NULL, NULL);
GO

-- 4. Calculate moving averages (1 day before & 1 day after) with decimals
WITH CTE_Moving AS (
    SELECT 
        RecordID,
        AVG(CAST(Systolic AS DECIMAL(5,2))) OVER (
            PARTITION BY PatientID 
            ORDER BY RecordDate
            ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
        ) AS AvgSystolic_Moving,
        AVG(CAST(Diastolic AS DECIMAL(5,2))) OVER (
            PARTITION BY PatientID 
            ORDER BY RecordDate
            ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
        ) AS AvgDiastolic_Moving
    FROM dbo.BloodPressureRecords
)
UPDATE dbo.BloodPressureRecords
SET AvgSystolic_Moving = CTE_Moving.AvgSystolic_Moving,
    AvgDiastolic_Moving = CTE_Moving.AvgDiastolic_Moving
FROM dbo.BloodPressureRecords
JOIN CTE_Moving ON dbo.BloodPressureRecords.RecordID = CTE_Moving.RecordID;
GO

-- 5. View full BloodPressureRecords table
SELECT *
FROM dbo.BloodPressureRecords
ORDER BY PatientID, RecordDate;
GO

-- 6. Drop AlarmingRate if exists
IF OBJECT_ID('dbo.AlarmingRate', 'U') IS NOT NULL
    DROP TABLE dbo.AlarmingRate;
GO

-- 7. Create AlarmingRate table
CREATE TABLE dbo.AlarmingRate (
    RecordID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    PatientName NVARCHAR(30) NULL,
    RecordDate DATE NOT NULL,
    DaysFromSurgery INT NULL,
    DayDescription NVARCHAR(30) NULL,
    Systolic INT NULL,
    Diastolic INT NULL,
    HeartRate INT NULL,
    Age INT NULL,
    Gender NVARCHAR(10) NULL,
    Medication NVARCHAR(30) NULL,
    Allergic NVARCHAR(30) NULL,
    AvgSystolic_Moving DECIMAL(5,2) NULL,
    AvgDiastolic_Moving DECIMAL(5,2) NULL
);
GO

-- 8. Insert only unusual BP records
INSERT INTO dbo.AlarmingRate
(PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription, Systolic, Diastolic, HeartRate, Age, Gender, Medication, Allergic, AvgSystolic_Moving, AvgDiastolic_Moving)
SELECT PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription, Systolic, Diastolic, HeartRate, Age, Gender, Medication, Allergic, AvgSystolic_Moving, AvgDiastolic_Moving
FROM dbo.BloodPressureRecords
WHERE AvgSystolic_Moving >= 140
   OR AvgDiastolic_Moving >= 90
   OR AvgSystolic_Moving <= 90
   OR AvgDiastolic_Moving <= 60;
GO

-- 9. View AlarmingRate table
SELECT *
FROM dbo.AlarmingRate
ORDER BY PatientID, RecordDate;
GO
