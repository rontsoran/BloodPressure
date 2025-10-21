-- ===========================================
-- Blood Pressure Records and Heart Risk Assessment
-- ===========================================
-- NOTE: Before running this script, create a database with your desired name.
-- In this example, the database is named 'Database1'.
-- You can create it using:
--     CREATE DATABASE Database1;
--     GO
-- ===========================================

USE Database1;
GO

-- ===========================================
-- 1. BloodPressureRecords Table
-- ===========================================

-- Drop BloodPressureRecords table if it exists
IF OBJECT_ID('dbo.BloodPressureRecords', 'U') IS NOT NULL
    DROP TABLE dbo.BloodPressureRecords;
GO

-- Create BloodPressureRecords table
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

-- Insert sample patient records
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

-- ===========================================
-- 2. Calculate 1-Day Moving Averages
-- ===========================================
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

-- View updated BloodPressureRecords table
SELECT *
FROM dbo.BloodPressureRecords
ORDER BY PatientID, RecordDate;
GO

-- ===========================================
-- 3. AlarmingRate Table (Abnormal BP)
-- ===========================================

IF OBJECT_ID('dbo.AlarmingRate', 'U') IS NOT NULL
    DROP TABLE dbo.AlarmingRate;
GO

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

-- Insert only unusual BP records
INSERT INTO dbo.AlarmingRate
    (PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription, Systolic, Diastolic, HeartRate, Age, Gender, Medication, Allergic, AvgSystolic_Moving, AvgDiastolic_Moving)
SELECT 
    PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription, Systolic, Diastolic, HeartRate, Age, Gender, Medication, Allergic, AvgSystolic_Moving, AvgDiastolic_Moving
FROM dbo.BloodPressureRecords
WHERE AvgSystolic_Moving >= 140
   OR AvgDiastolic_Moving >= 90
   OR AvgSystolic_Moving <= 90
   OR AvgDiastolic_Moving <= 60;
GO

-- View AlarmingRate table
SELECT *
FROM dbo.AlarmingRate
ORDER BY PatientID, RecordDate;
GO

-- ===========================================
-- 4. HeartRateAlerts Table (Extreme HR)
-- ===========================================

IF OBJECT_ID('dbo.HeartRateAlerts', 'U') IS NOT NULL
    DROP TABLE dbo.HeartRateAlerts;
GO

CREATE TABLE dbo.HeartRateAlerts (
    RecordID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    PatientName NVARCHAR(30) NULL,
    RecordDate DATE NOT NULL,
    DaysFromSurgery INT NULL,
    DayDescription NVARCHAR(30) NULL,
    HeartRate INT NOT NULL,
    HeartRateIndicator NVARCHAR(20) NOT NULL
);
GO

-- Insert extremely high or low heart rate records
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

-- View HeartRateAlerts table
SELECT *
FROM dbo.HeartRateAlerts
ORDER BY PatientID, RecordDate;
GO

-- ===========================================
-- 5. MajorHeartAttackRisk Table
-- ===========================================

IF OBJECT_ID('dbo.majorHeartAttackRisk', 'U') IS NOT NULL
    DROP TABLE dbo.majorHeartAttackRisk;
GO

CREATE TABLE dbo.majorHeartAttackRisk (
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
    RiskFactors NVARCHAR(200) NULL,
    RiskLevel NVARCHAR(20) NULL,
    CriticalReason NVARCHAR(300) NULL,
    AvgSystolic_Moving DECIMAL(5,2) NULL,
    AvgDiastolic_Moving DECIMAL(5,2) NULL
);
GO

-- Insert high-risk patients
INSERT INTO dbo.majorHeartAttackRisk
    (PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription, Systolic, Diastolic, HeartRate, Age, Gender, Medication, Allergic, RiskFactors, RiskLevel, CriticalReason, AvgSystolic_Moving, AvgDiastolic_Moving)
SELECT 
    PatientID, PatientName, RecordDate, DaysFromSurgery, DayDescription, Systolic, Diastolic, HeartRate, Age, Gender, Medication, Allergic,
    CASE 
        WHEN Systolic >= 140 AND Diastolic >= 90 AND HeartRate >= 100 AND Age >= 45 THEN 'High BP + High HR + Age >= 45'
        WHEN Systolic >= 140 AND HeartRate >= 100 AND Age >= 45 THEN 'High Systolic + High HR + Age >= 45'
        WHEN Diastolic >= 90 AND HeartRate >= 100 AND Age >= 45 THEN 'High Diastolic + High HR + Age >= 45'
        WHEN Systolic >= 140 AND Diastolic >= 90 AND Age >= 45 THEN 'High BP + Age >= 45'
        WHEN HeartRate >= 100 AND Age >= 45 THEN 'High HR + Age >= 45'
        ELSE 'Multiple Risk Factors'
    END AS RiskFactors,
    CASE 
        WHEN Systolic >= 160 OR Diastolic >= 100 OR HeartRate >= 120 THEN 'CRITICAL'
        WHEN Systolic >= 140 OR Diastolic >= 90 OR HeartRate >= 100 THEN 'HIGH'
        ELSE 'MODERATE'
    END AS RiskLevel,
    CASE 
        WHEN Systolic >= 160 THEN CONCAT('CRITICAL: Systolic BP ', Systolic, ' mmHg (Normal: <120, High: 140-159, Critical: >=160)')
        WHEN Diastolic >= 100 THEN CONCAT('CRITICAL: Diastolic BP ', Diastolic, ' mmHg (Normal: <80, High: 90-99, Critical: >=100)')
        WHEN HeartRate >= 120 THEN CONCAT('CRITICAL: Heart Rate ', HeartRate, ' bpm (Normal: 60-100, High: 100-119, Critical: >=120)')
        WHEN Systolic >= 140 THEN CONCAT('HIGH: Systolic BP ', Systolic, ' mmHg (Normal: <120, High: >=140)')
        WHEN Diastolic >= 90 THEN CONCAT('HIGH: Diastolic BP ', Diastolic, ' mmHg (Normal: <80, High: >=90)')
        WHEN HeartRate >= 100 THEN CONCAT('HIGH: Heart Rate ', HeartRate, ' bpm (Normal: 60-100, High: >=100)')
        ELSE CONCAT('MODERATE: Age ', Age, ' (Risk factor: >=45)')
    END AS CriticalReason,
    AvgSystolic_Moving,
    AvgDiastolic_Moving
FROM dbo.BloodPressureRecords
WHERE (Systolic >= 140 OR Diastolic >= 90 OR HeartRate >= 100)
  AND Age >= 45;
GO

-- View Major Heart Attack Risk table
SELECT *
FROM dbo.majorHeartAttackRisk
ORDER BY PatientID, RecordDate;
GO

-- Summary statistics by RiskLevel
SELECT 
    RiskLevel,
    COUNT(*) AS PatientCount,
    AVG(CAST(Age AS DECIMAL(5,2))) AS AvgAge,
    AVG(CAST(Systolic AS DECIMAL(5,2))) AS AvgSystolic,
    AVG(CAST(Diastolic AS DECIMAL(5,2))) AS AvgDiastolic,
    AVG(CAST(HeartRate AS DECIMAL(5,2))) AS AvgHeartRate
FROM dbo.majorHeartAttackRisk
GROUP BY RiskLevel
ORDER BY 
    CASE RiskLevel 
        WHEN 'CRITICAL' THEN 1 
        WHEN 'HIGH' THEN 2 
        WHEN 'MODERATE' THEN 3 
    END;
GO

-- Detailed critical patients breakdown
SELECT 
    'High risk' AS Analysis,
    PatientID,
    PatientName,
    Age,
    DaysFromSurgery,
    DayDescription,
    CONCAT(Systolic, '/', Diastolic) AS BloodPressure,
    HeartRate,
    CriticalReason
FROM dbo.majorHeartAttackRisk
WHERE RiskLevel = 'CRITICAL'
ORDER BY PatientID, RecordDate;
GO
