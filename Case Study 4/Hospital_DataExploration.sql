--Q1. For each doctor, count how many distinct patients they have treated.

SELECT doc.DoctorID, 
	doc.FirstName + ' ' + doc.LastName AS DoctorName,
	COUNT(DISTINCT v.PatientID) AS DistinctPatients
FROM PatientVisits v
JOIN Dim_Doctor doc
ON v.DoctorID = doc.DoctorID
GROUP BY doc.DoctorID, doc.FirstName, doc.LastName
ORDER BY DistinctPatients DESC




--Q2. Show the revenue split by each payment method, along with total visits.

SELECT pm.PaymentMethod,
		COUNT(v.VisitID) AS TotalVisits,
		SUM(v.BillAmount) AS TotalRevenue
FROM PatientVisits v
JOIN Dim_PaymentMethod pm
ON v.PaymentMethodID = pm.PaymentMethodID
GROUP BY pm.PaymentMethod




--Q3. Categorize patients into age groups and calculate the average bill amount for each age band.(Assume age at time of visit based on VisitDate.)

WITH cte_PatientAge AS (
SELECT v.VisitID, v.BillAmount,
	CASE 
		WHEN DATEDIFF(YEAR, p.DOB, v.VisitDate) < 18 THEN '0-17'
		WHEN DATEDIFF(YEAR, p.DOB, v.VisitDate) BETWEEN 18 AND 35 THEN '18-35'
		WHEN DATEDIFF(YEAR, p.DOB, v.VisitDate) BETWEEN 36 AND 55 THEN '36-55'
		ELSE '56+'
	END AS AgeGroup
FROM DIM_Patient_Clean p
JOIN PatientVisits v
ON v.PatientID = p.PatientID
)
SELECT AgeGroup, 
	COUNT(*) AS TotalVisits,
	CAST(AVG(BillAmount) AS DECIMAL(18,2)) AvgBillAmount
FROM cte_PatientAge
GROUP BY AgeGroup
ORDER BY 
	 CASE AgeGroup
		WHEN '0-17' THEN 1
		WHEN '18-35' THEN 2
		WHEN '36-55' THEN 3
		WHEN '56+' THEN 4
	 END


--Q4. Find total revenue and number of visits for each department.

SELECT d.DepartmentName,
	COUNT(v.VisitID) AS TotalVisits,
	SUM(v.BillAmount) AS TotalRevenue
FROM PatientVisits v
JOIN DIM_Department_Clean d
ON v.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
ORDER BY TotalRevenue DESC





--Q5. Rank departments based on their total revenue within each department category.

SELECT DepartmentCategory, DepartmentName, TotalRevenue,
		RANK() OVER (PARTITION BY DepartmentCategory ORDER BY TotalRevenue DESC) AS RevenueRank
FROM (
		SELECT d.DepartmentCategory, d.DepartmentName,
			 SUM(v.BillAmount) AS TotalRevenue
		FROM PatientVisits v
		JOIN DIM_Department_Clean d
		ON v.DepartmentID = d.DepartmentID
		GROUP BY d.DepartmentCategory, d.DepartmentName
	) t


--Q6. For each department, find the average satisfaction score and average wait time.

SELECT d.DepartmentName,
		CAST(AVG(v.SatisfactionScore) AS DECIMAL(10,2)) AS AvgSatisfactionScore,
		CAST(AVG(v.WaitTimeMinutes) AS DECIMAL(10,2)) AS AvgWaitTime
FROM PatientVisits v
JOIN DIM_Department_Clean d
ON v.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
ORDER BY AvgSatisfactionScore DESC



--Q7. Compare the total number of hospital visits on weekdays vs weekends.

SELECT DayType, COUNT(*) AS TotalVisits
FROM 
(
	SELECT 
		CASE 
			WHEN DATENAME(Weekday, VisitDate) IN ('Saturday','Sunday')
				THEN 'Weekend'
			ELSE 'Weekday'
		END AS DayType
	FROM PatientVisits
) t
GROUP BY DayType







--Q8. For each month, calculate total visits and a running cumulative total of visits.

WITH cte_monthlyVisits AS (
	SELECT
		DATEFROMPARTS(YEAR(VisitDate), MONTH(VisitDate), 1) AS MonthStart,
		COUNT(*) AS TotalVisits
	FROM PatientVisits
	GROUP BY YEAR(VisitDate), MONTH(VisitDate)
	--ORDER BY MonthStart
)
SELECT MonthStart, TotalVisits,
	SUM(TotalVisits) OVER(ORDER BY MonthStart
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeVisits
FROM cte_monthlyVisits
ORDER BY MonthStart



--Q9. Find the doctors with the highest average satisfaction score (minimum 100 visits).

SELECT d.DoctorID, d.FirstName + ' ' + d.LastName AS DoctorName,
		COUNT(v.VisitID) AS TotalVisits,
		CAST(AVG(v.SatisfactionScore) AS DECIMAL(10,2)) AS AvgSatisfactionScore
FROM Dim_Doctor d
JOIN PatientVisits v
ON d.DoctorID = v.DoctorID
GROUP BY d.DoctorID, d.FirstName, d.LastName
HAVING COUNT(v.VisitID) > 100



--Q10. Identify the most commonly prescribed treatment for each diagnosis.

WITH cte_treatment AS (
	SELECT d.DiagnosisName, t.TreatmentName, COUNT(*) AS TreatmentCount,
		RANK() OVER(PARTITION BY d.DiagnosisName ORDER BY COUNT(*) DESC) AS rn
	FROM PatientVisits v
	JOIN Dim_Diagnosis d
	ON v.DiagnosisID = d.DiagnosisID
	JOIN Dim_Treatment t 
	ON t.TreatmentID = v.TreatmentID
	GROUP BY d.DiagnosisName, t.TreatmentName
)
SELECT DiagnosisName, TreatmentName, TreatmentCount
FROM cte_treatment
WHERE rn = 1