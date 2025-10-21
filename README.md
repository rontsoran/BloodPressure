# Blood Pressure Monitoring & Heart Risk Assessment System
Version 2.0 – Last Updated: 2025  
Database: SurgeryDB

---

## Overview
This SQL-based system monitors patient vital signs before and after surgery.  
It performs real-time tracking of blood pressure and heart rate, calculates moving averages, and evaluates multi-factor heart attack risk levels.  
The system is designed for clinicians, data analysts, and researchers focused on preventive cardiac care.

---

## Database Structure

### 1. BloodPressureRecords
Main table containing all patient records and demographics.

**Purpose:**  
Stores comprehensive patient vital signs and surgery timeline information.

**Key Features:**
- Patient identification and demographics  
- Blood pressure readings (Systolic, Diastolic)  
- Heart rate monitoring  
- Surgery timeline tracking (`DaysFromSurgery`, `DayDescription`)  
- 3-day moving average calculations (`AvgSystolic_Moving`, `AvgDiastolic_Moving`)

**Key Columns:**  
`PatientID`, `PatientName`, `Age`, `Gender`, `Systolic`, `Diastolic`, `HeartRate`,  
`RecordDate`, `DaysFromSurgery`, `DayDescription`, `AvgSystolic_Moving`, `AvgDiastolic_Moving`

---

### 2. AlarmingRate
Identifies unusual blood pressure patterns.

**Purpose:**  
Flags patients with abnormal readings that require further analysis.

**Criteria:**
- Systolic ≥ 140 or Diastolic ≥ 90 → High  
- Systolic ≤ 90 or Diastolic ≤ 60 → Low  

---

### 3. HeartRateAlerts
Detects extreme heart rate conditions.

**Purpose:**  
Identifies cases of dangerously high or low heart rates.

**Thresholds:**
- Extremely Low: ≤ 40 bpm  
- Extremely High: ≥ 130 bpm  

---

### 4. majorHeartAttackRisk
Performs advanced risk assessment for early prevention of major heart attacks.

**Purpose:**  
Integrates multiple health factors to determine overall patient risk level.

**Risk Criteria:**
- Age ≥ 45 (increased age factor)  
- High Blood Pressure (Systolic ≥ 140 or Diastolic ≥ 90)  
- High Heart Rate (≥ 100 bpm)  

---

## Risk Assessment System

### Risk Levels
**CRITICAL**  
- Systolic ≥ 160 mmHg  
- Diastolic ≥ 100 mmHg  
- Heart Rate ≥ 120 bpm  

**HIGH**  
- Systolic ≥ 140 mmHg  
- Diastolic ≥ 90 mmHg  
- Heart Rate ≥ 100 bpm  

**MODERATE**  
- Any combination meeting at least one of the above criteria  

---

## Key Features

1. **Moving Average Calculations**  
   - 3-day moving averages for blood pressure and heart rate  
   - Trend detection and early risk identification  

2. **Surgery Timeline Tracking**  
   - Tracks readings relative to surgery date  
   - Enables pre- and post-surgery comparison  

3. **Comprehensive Risk Analysis**  
   - Multi-factor risk scoring  
   - Clinically relevant threshold comparisons  

4. **Patient-Specific Reporting**  
   - Individualized risk summaries  
   - Timeline-based risk visualization  

---

## Usage Instructions

### Running the System
1. Execute the main SQL script:  
   ```sql
   SQLFile1.sql
