# Blood Pressure Monitoring System - README2

## Overview
This SQL-based blood pressure monitoring system is designed to track patient vital signs before and after surgery, with advanced risk assessment capabilities for identifying patients at risk of major heart attacks.

## Database Structure

### Main Tables

#### 1. BloodPressureRecords
**Primary table containing all patient blood pressure data**
- **Purpose**: Stores comprehensive patient vital signs and demographics
- **Key Features**:
  - Patient identification and demographics
  - Blood pressure readings (Systolic/Diastolic)
  - Heart rate monitoring
  - Surgery timeline tracking (days before/after)
  - Moving average calculations for trend analysis

**Key Columns**:
- `PatientID`, `PatientName`, `Age`, `Gender`
- `Systolic`, `Diastolic`, `HeartRate`
- `RecordDate`, `DaysFromSurgery`, `DayDescription`
- `AvgSystolic_Moving`, `AvgDiastolic_Moving`

#### 2. AlarmingRate
**Identifies unusual blood pressure patterns**
- **Purpose**: Filters and flags abnormal blood pressure readings
- **Criteria**: 
  - Systolic ≥ 140 OR Diastolic ≥ 90 (High)
  - Systolic ≤ 90 OR Diastolic ≤ 60 (Low)

#### 3. HeartRateAlerts
**Monitors extreme heart rate conditions**
- **Purpose**: Identifies dangerously high or low heart rates
- **Thresholds**:
  - Extremely Low: ≤ 40 bpm
  - Extremely High: ≥ 130 bpm

#### 4. majorHeartAttackRisk
**Advanced risk assessment for heart attack prevention**
- **Purpose**: Identifies patients at high risk of major heart attacks
- **Risk Criteria**:
  - Age ≥ 45 (increased risk factor)
  - High Blood Pressure (Systolic ≥ 140 OR Diastolic ≥ 90)
  - High Heart Rate (≥ 100 bpm)

## Risk Assessment System

### Risk Levels
1. **CRITICAL**
   - Systolic ≥ 160 mmHg
   - Diastolic ≥ 100 mmHg
   - Heart Rate ≥ 120 bpm

2. **HIGH**
   - Systolic ≥ 140 mmHg
   - Diastolic ≥ 90 mmHg
   - Heart Rate ≥ 100 bpm

3. **MODERATE**
   - Other combinations meeting basic criteria

### Risk Factors Analysis
The system automatically categorizes risk factors:
- `High BP + High HR + Age >= 45`
- `High Systolic + High HR + Age >= 45`
- `High Diastolic + High HR + Age >= 45`
- `High BP + Age >= 45`
- `High HR + Age >= 45`

## Key Features

### 1. Moving Average Calculations
- Calculates 3-day moving averages for blood pressure trends
- Helps identify gradual changes in patient condition
- Provides context for individual readings

### 2. Surgery Timeline Tracking
- Tracks patient condition relative to surgery date
- Identifies risk patterns before and after procedures
- Enables preventive intervention strategies

### 3. Comprehensive Risk Analysis
- Multi-factor risk assessment
- Detailed explanations for each risk classification
- Normal range comparisons for clinical context

### 4. Patient-Specific Reporting
- Individual patient risk profiles
- Timeline-based risk occurrence tracking
- Detailed critical condition explanations

## Usage Instructions

### Running the System
1. Execute the complete SQL script (`SQLFile1.sql`)
2. The system will automatically:
   - Create all necessary tables
   - Populate with sample data
   - Calculate moving averages
   - Generate risk assessments

### Key Queries

#### View All Blood Pressure Records
```sql
SELECT * FROM dbo.BloodPressureRecords
ORDER BY PatientID, RecordDate;
```

#### View High-Risk Patients
```sql
SELECT * FROM dbo.majorHeartAttackRisk
WHERE RiskLevel = 'CRITICAL'
ORDER BY PatientID, RecordDate;
```

#### Summary Statistics
```sql
SELECT RiskLevel, COUNT(*) AS PatientCount
FROM dbo.majorHeartAttackRisk
GROUP BY RiskLevel;
```

## Clinical Applications

### 1. Pre-Surgery Assessment
- Identify patients requiring special monitoring
- Adjust surgical protocols based on risk levels
- Plan post-operative care requirements

### 2. Post-Surgery Monitoring
- Track recovery progress
- Identify complications early
- Guide medication adjustments

### 3. Risk Management
- Proactive intervention for high-risk patients
- Resource allocation for critical care
- Quality improvement initiatives

## Data Quality Features

### 1. Automatic Data Validation
- Checks for logical blood pressure ranges
- Validates heart rate parameters
- Ensures age-appropriate risk assessments

### 2. Comprehensive Error Handling
- Graceful table recreation
- Data integrity preservation
- Consistent naming conventions

### 3. Audit Trail
- Complete patient history tracking
- Timeline-based analysis capabilities
- Risk factor documentation

## Technical Specifications

### Database Requirements
- SQL Server compatible
- Supports DATE data types
- Window functions for moving averages

### Performance Considerations
- Indexed primary keys for fast retrieval
- Efficient moving average calculations
- Optimized risk assessment queries

### Scalability
- Modular table design
- Extensible risk criteria
- Configurable thresholds

## Maintenance and Updates

### Adding New Risk Factors
1. Modify the risk assessment logic in Section 16
2. Update risk factor descriptions
3. Adjust summary statistics queries

### Modifying Thresholds
1. Update criteria in INSERT statements
2. Adjust risk level classifications
3. Update documentation

### Data Backup
- Regular backups of all tables
- Preserve moving average calculations
- Maintain risk assessment history

## Support and Documentation

### File Structure
- `SQLFile1.sql`: Main system implementation
- `README2.md`: This documentation file

### Contact Information
For technical support or questions about the blood pressure monitoring system, refer to the system administrator or database team.

---

**Version**: 2.0  
**Last Updated**: 2025  
**System**: Blood Pressure Monitoring and Risk Assessment  
**Database**: SurgeryDB
