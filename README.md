
This document contains the SQL script used to create sample blood pressure datasets around surgery dates, compute moving averages, and derive alert tables (BP and another one for HR). You can run it in SQL Server Management Studio (SSMS) or any SQL Server-compatible environment.

Notes:
The script starts with USE SurgeryDB;. Ensure the SurgeryDB database exists or change it to your target database.
The script drops tables if they exist and recreates them.
The tables have been updated; please check for high/low heart rate alerts.
Review before running in production environments.



## Full SQL

```sql
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

-- 10. Drop HeartRateAlerts if exists
IF OBJECT_ID('dbo.HeartRateAlerts', 'U') IS NOT NULL
  DROP TABLE dbo.HeartRateAlerts;
GO

-- 11. Create HeartRateAlerts table
CREATE TABLE dbo.HeartRateAlerts (
  RecordID INT IDENTITY(1, 1) PRIMARY KEY,
  PatientID INT NOT NULL,
  PatientName NVARCHAR(30) NULL,
  RecordDate DATE NOT NULL,
  DaysFromSurgery INT NULL,
  DayDescription NVARCHAR(30) NULL,
  HeartRate INT NOT NULL,
  HeartRateIndicator NVARCHAR(20) NOT NULL
);
GO

-- 12. Insert extremely high/low heart rate records
-- Assumed thresholds: <= 40 bpm (extremely low), >= 130 btar czf readmes.tgz -C /workspace README.md README_FULL.md
pm (extremely high)
INSERT INTO dbo.HeartRateAlerts
  (PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription, HeartRate, HeartRateIndicator)
SELECT
  PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription, HeartRate,
  CASE
    WHEN HeartRate <= 40 THEN 'Extremely Low'
    WHEN HeartRate >= 130 THEN 'Extremely High'
  END AS HeartRateIndicator
FROM dbo.BloodPressureRecords
WHERE HeartRate <= 40 OR HeartRate >= 130;
GO

-- 13. View HeartRateAlerts table
SELECT *
FROM dbo.HeartRateAlerts
ORDER BY PatientID, RecordDate;
GO
```

