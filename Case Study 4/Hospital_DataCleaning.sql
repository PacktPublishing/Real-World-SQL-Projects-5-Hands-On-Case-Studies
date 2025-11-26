SELECT * FROM Dim_Patient
SELECT * FROM Dim_Doctor
SELECT * FROM Dim_Department
SELECT * FROM Dim_Diagnosis
SELECT * FROM Dim_Treatment
SELECT * FROM Dim_PaymentMethod
SELECT * FROM PatientVisits_2020_2021
SELECT * FROM PatientVisits_2022_2023
SELECT * FROM PatientVisits_2024
SELECT * FROM PatientVisits_2025



-- Data Cleaning (Patient Table)
---- Remove patient rows where FirstName is missing
---- Standardize FirstName and LastName to proper case and create a new FullName column
---- Gender values should be either Male or Female
---- Split CityStateCountry into City, State, and Country columns

CREATE TABLE DIM_Patient_Clean (
	PatientID varchar(20) PRIMARY KEY,
	FullName varchar(120),
	Gender varchar(10),
	DOB date,
	City varchar(50),
	State varchar(50),
	Country varchar(50)
)

INSERT INTO DIM_Patient_Clean (
		PatientID, FullName, Gender, DOB, City, State, Country
	)
SELECT 
	p.PatientID,
	UPPER(LEFT(LTRIM(RTRIM(p.FirstName)),1)) +   LOWER(SUBSTRING(LTRIM(RTRIM(p.FirstName)), 2, LEN(LTRIM(RTRIM(p.FirstName))))) + ' '
	+
	UPPER(LEFT(LTRIM(RTRIM(p.LastName)),1)) +   LOWER(SUBSTRING(LTRIM(RTRIM(p.LastName)), 2, LEN(LTRIM(RTRIM(p.LastName)))))
	AS FullName,
	CASE 
		WHEN p.Gender = 'M' THEN 'Male'
		WHEN p.Gender = 'F' THEN 'Female'
		ELSE p.Gender
	END AS Gender,
	p.DOB,
	PARSENAME(REPLACE(p.CityStateCountry, ',' , '.'), 3) AS City,
	PARSENAME(REPLACE(p.CityStateCountry, ',' , '.'), 2) AS State,
	PARSENAME(REPLACE(p.CityStateCountry, ',' , '.'), 1) AS Country
	FROM Dim_Patient p
	WHERE p.FirstName IS NOT NULL


-- Data Cleaning (Department Table)
---- Remove departments where DepartmentCategory is missing
---- Drop HOD and DepartmentName columns
---- Use Specialization as DepartmentName column

CREATE TABLE DIM_Department_Clean (
	DepartmentID Varchar(20) Primary Key,
	DepartmentName Varchar(100),
	DepartmentCategory Varchar(100)
)

INSERT INTO DIM_Department_Clean (
	DepartmentID, DepartmentName, DepartmentCategory
)

SELECT d.DepartmentID, d.Specialization AS DepartmentName, d.DepartmentCategory
FROM DIM_Department d
WHERE d.DepartmentCategory IS NOT NULL



-- Data Cleaning (Patient Visits Table)
---- Merge all yearly visit tables (2020–2025) into one consolidated PatientVisits table

CREATE TABLE PatientVisits (
  VisitID         VARCHAR(20) PRIMARY KEY,
  PatientID       VARCHAR(20),
  DoctorID        VARCHAR(20),
  DepartmentID    VARCHAR(20),
  DiagnosisID     VARCHAR(20),
  TreatmentID     VARCHAR(20),
  PaymentMethodID VARCHAR(20),
  VisitDate       DATE,
  VisitTime       TIME,
  DischargeDate   DATE,
  BillAmount      DECIMAL(18,2),
  InsuranceAmount DECIMAL(18,2),
  SatisfactionScore INT,
  WaitTimeMinutes INT
  -- Optional: add FOREIGN KEYs here if you want to point to clean dimensions later
  FOREIGN KEY (PatientID)       REFERENCES Dim_Patient_Clean(PatientID),
  FOREIGN KEY (DoctorID)        REFERENCES Dim_Doctor(DoctorID),
  FOREIGN KEY (DepartmentID)    REFERENCES Dim_Department_Clean(DepartmentID),
  FOREIGN KEY (DiagnosisID)     REFERENCES Dim_Diagnosis(DiagnosisID),
  FOREIGN KEY (TreatmentID)     REFERENCES Dim_Treatment(TreatmentID),
  FOREIGN KEY (PaymentMethodID) REFERENCES Dim_PaymentMethod(PaymentMethodID)
);

INSERT INTO PatientVisits (
  VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
  PaymentMethodID, VisitDate, VisitTime, DischargeDate,
  BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes
)

SELECT
  VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
  PaymentMethodID, VisitDate, VisitTime, DischargeDate,
  BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes
FROM PatientVisits_2020_2021

UNION ALL

SELECT
  VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
  PaymentMethodID, VisitDate, VisitTime, DischargeDate,
  BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes
FROM PatientVisits_2022_2023

UNION ALL

SELECT
  VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
  PaymentMethodID, VisitDate, VisitTime, DischargeDate,
  BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes
FROM PatientVisits_2024

UNION ALL

SELECT
  VisitID, PatientID, DoctorID, DepartmentID, DiagnosisID, TreatmentID,
  PaymentMethodID, VisitDate, VisitTime, DischargeDate,
  BillAmount, InsuranceAmount, SatisfactionScore, WaitTimeMinutes
FROM PatientVisits_2025;

