SELECT * FROM Customer
SELECT * FROM Products
SELECT * FROM Shipping
SELECT * FROM Sales
SELECT * FROM TargetSales

--Q1. List the top 10 customers by total sales amount. Show CustomerID, full name, and total sales.

SELECT TOP 10 c.ID, c.FirstName + ' ' + c.LastName AS CustomerName,
		SUM(s.Price) AS TotalSales
FROM Customer c 
JOIN Sales s
ON c.ID = s.CustomerID
GROUP BY c.ID, c.FirstName, c.LastName
ORDER BY TotalSales DESC




--Q2. Show total sales per month for the year 2023, ordered by month.

SELECT DATEFROMPARTS(YEAR(s.OrderDate), MONTH(s.OrderDate), 1) AS MonthStart,
	SUM(s.Price) AS TotalSales
FROM Sales s
WHERE YEAR(s.OrderDate) = 2023
GROUP BY DATEFROMPARTS(YEAR(s.OrderDate), MONTH(s.OrderDate), 1)
ORDER BY MonthStart





--Q3. Find out the products that have never been sold

SELECT * FROM Products
SELECT * FROM Sales

SELECT p.ProductID, p.ProductName, p.Category
FROM Products p
LEFT JOIN Sales s 
ON p.ProductID = s.ProductID
WHERE s.ProductID IS NULL


--Q4. Find how many new customers were acquired in 2022

SELECT * FROM Sales
SELECT COUNT(*) AS NewCustomersin2022
FROM(
	SELECT CustomerID, 
		MIN(OrderDate) AS FirstOrderDate
	FROM Sales
	GROUP BY CustomerID
	HAVING YEAR(MIN(OrderDate)) = '2022'
) t



--Q5. Calculate the profit margin (Profit / Sales) percentage for each category.

SELECT p.Category, 
	CAST(SUM(s.Profit)/ SUM(s.Price) * 100.0 AS decimal(10,2)) AS ProfitMarginPercent
FROM Sales s
JOIN Products p 
ON s.ProductID = p.ProductID
GROUP BY p.Category








--Q6. For each category, show date-wise sales and a running total of sales over time.

WITH cte_dailySales AS (
SELECT Category, s.OrderDate, SUM(s.Price) AS DailySales
FROM Sales s
JOIN Products p
ON s.ProductID = p.ProductID
GROUP BY Category, s.OrderDate
)
SELECT 
	Category, OrderDate, DailySales,
	SUM(DailySales) OVER (PARTITION BY Category ORDER BY OrderDate 
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RunningTotal
	FROM cte_dailySales



--Q7. Get the most recent order (by OrderDate) for every customer.

WITH cte_mostRecent AS (
	SELECT DISTINCT s.OrderID, s.CustomerID, s.OrderDate, 
		RANK() OVER (PARTITION BY CustomerID ORDER BY s.OrderDate DESC) AS rn
	FROM Sales s
)
SELECT OrderID, CustomerID, OrderDate
FROM cte_mostRecent
WHERE rn = 1
ORDER BY CustomerID

--Using group by

SELECT DISTINCT s.OrderID, s.CustomerID, s.OrderDate
	FROM Sales s
	JOIN (
			SELECT CustomerID, MAX(OrderDate) AS MostRecent
			FROM Sales
			GROUP BY CustomerID
	) t
	ON s.CustomerID = t.CustomerID
	AND s.OrderDate = t.MostRecent



--Q8. Classify customers based on their total sale. Show CustomerID, name, total sales: 
--Platinum – TotalSales ≥ 15,000
--Gold – 10,000 to < 15,000
--Silver – 5,000 to < 10,000
--Bronze – < 5,000

WITH cte_customerSales AS (
	SELECT c.ID AS CustomerID, 
		c.FirstName + ' ' + c.LastName AS CustomerName,
		SUM(s.Price) AS TotalSales
	FROM Sales s
	JOIN Customer c 
	ON s.CustomerID = c.ID
	GROUP BY c.ID, c.FirstName, c.LastName
)
SELECT CustomerID, CustomerName, TotalSales,
	CASE
		WHEN TotalSales >= 15000 THEN 'Platinum'
		WHEN TotalSales >= 10000 THEN 'Gold'
		WHEN TotalSales >= 5000 THEN 'Silver'
		ELSE 'Bronze'
	END AS CustomerSegment
FROM cte_customerSales
ORDER BY TotalSales DESC







--Q9. For each category, find the product with the highest total sales. If ties exist, show all tied products.

WITH cte_totalSales AS (
	SELECT Category, ProductName, TotalSales,
		RANK() OVER (PARTITION BY Category ORDER BY TotalSales DESC) AS rn
	FROM (
			SELECT p.Category, p.ProductName, SUM(s.Price) AS TotalSales
			FROM Sales s 
			JOIN Products p 
			ON s.ProductID = p.ProductID
			GROUP BY p.Category, p.ProductName
		) t
)
SELECT Category, ProductName, TotalSales
FROM cte_totalSales
WHERE rn = 1


--Q10. Actual vs Target sales by category & year

SELECT * FROM TargetSales
SELECT * FROM Sales

WITH cte_TargetSales AS (
	SELECT Category, REPLACE(Year, '_Sales', '') AS SalesYear, TargetSales
	FROM
		(
			SELECT Category, Year, TargetSales
			FROM TargetSales
			UNPIVOT (
				TargetSales FOR Year IN (
					[2020_Sales],
					[2021_Sales],
					[2022_Sales],
					[2023_Sales]
				)
			)u
		)t
),
ActualSalesTable AS (
	SELECT p.Category, YEAR(s.OrderDate) AS SalesYear, SUM(s.Price) as ActualSales
	FROM Sales s
	JOIN Products p
	ON s.ProductID = p.ProductID
	GROUP BY p.Category, YEAR(s.OrderDate) 
)	
Select 
 t.Category,
 t.SalesYear,
 t.TargetSales,
 a.ActualSales AS ActualSales
FROM cte_targetSales t
LEFT JOIN ActualSalesTable a
ON t.Category = a.Category
AND t.SalesYear = a.SalesYear