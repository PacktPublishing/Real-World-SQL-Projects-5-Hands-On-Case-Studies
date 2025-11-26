--Q1 Find the busiest airport by the number of flights take off


SELECT TOP 1 a.Name, COUNT(*) AS TotalFlights
FROM Flights f
JOIN Airports a 
ON f.Origin = a.AirportID
GROUP BY a.Name
ORDER BY TotalFlights DESC


--Q2 Total number of tickets sold per airline

SELECT a.Name AS Airline,
	   COUNT(*) AS Ticketsold
FROM Tickets t
INNER JOIN Flights f ON t.FlightID = f.FlightID
INNER JOIN Airlines a ON f.AirlineID = a.AirlineID
GROUP BY a.Name



--Q3 List all flights operated by ‘IndiGo’ with airport names (origin and destination)


SELECT F.FlightID,
	   ap.Name AS OriginAirport,
	   ap1.Name AS DestinationAirport
FROM Flights f
INNER JOIN Airlines a ON f.AirlineID = a.AirlineID
INNER JOIN Airports ap ON f.Origin = ap.AirportID
INNER JOIN Airports ap1 ON f.Destination = ap1.AirportID
WHERE a.Name = 'Indigo'


--Q4 For each airport, show the top airline by number of flights departing from there

WITH CTE_flightRank AS (
SELECT *, 
		RANK() OVER (PARTITION BY Origin ORDER BY FlightCount DESC) as rn
FROM (
		SELECT f.Origin, f.AirlineID, COUNT(*) AS FlightCount
		FROM Flights f
		GROUP BY f.Origin, f.AirlineID
	) t
)

SELECT A.Name AS AirportName, AL.Name AS AirlineName, r.FlightCount
FROM CTE_flightRank r
JOIN Airports A ON r.Origin = A.AirportID
JOIN Airlines AL ON r.AirlineID = AL.AirlineID
WHERE rn = 1

--Q5 For each flight, show time taken in hours and categorize it as Short (<2h), Medium (2–5h), or Long (>5h)

SELECT 
	FlightID,
	DepartureTime,
	ArrivalTime,
	DATEDIFF(MINUTE, DepartureTime, ArrivalTime) / 60 AS DurationHours,
	CASE
		WHEN DATEDIFF(MINUTE, DepartureTime, ArrivalTime) < 120 THEN 'Short'
		WHEN DATEDIFF(MINUTE, DepartureTime, ArrivalTime) <= 300 THEN 'Medium'
		ELSE 'Long'
	END AS FlightCategory
FROM Flights


--Q6 Show each passenger's first and last flight dates and number of flights

WITH CTE_FlightsNo AS (
	SELECT PassengerID, 
			MIN(F.DepartureTime) AS FirstFlight,
			MAX(F.DepartureTime) AS LastFlight,
			COUNT(*) AS TotalFlights
	FROM Tickets T
	JOIN Flights F ON T.FlightID = F.FlightID
	GROUP BY PassengerID
)
SELECT 
	P.Name,
	cte.FirstFlight,
	cte.LastFlight,
	cte.TotalFlights
FROM CTE_FlightsNo cte
JOIN Passengers p ON cte.PassengerID = p.PassengerID




--Q7 Find flights with the highest price ticket sold for each route (origin -> destination)
WITH CTE_routetickets AS (
	SELECT 
		f.FlightID,
		f.Origin,
		f.Destination,
		t.TicketID,
		t.Price,
		RANK() OVER (PARTITION BY f.Origin, f.Destination ORDER BY t.Price DESC) AS rnk
	FROM Tickets t
	JOIN Flights f ON t.FlightID = f.FlightID
)
SELECT A1.Name AS Origin, 
		A2.Name AS Destination,
		rt.Price,
		rt.TicketID
FROM CTE_routetickets rt
JOIN Airports A1 ON rt.Origin = A1.AirportID
JOIN Airports A2 ON rt.Destination = A2.AirportID
WHERE rnk = 1













--Q8 Find the highest spending passenger in each Frequent Flyer Status group

WITH cte_spending AS (
SELECT *,
	RANK() OVER (PARTITION BY FrequentFlyerStatus ORDER BY TotalSpent DESC) AS rn
	FROM (
		SELECT p.PassengerID, p.Name, p.FrequentFlyerStatus, SUM(t.Price) AS TotalSpent
		FROM Passengers p
		JOIN Tickets t 
		ON p.PassengerID = t.PassengerID
		GROUP BY p.PassengerID, p.Name, p.FrequentFlyerStatus
	) t
) 
SELECT Name, FrequentFlyerStatus, TotalSpent
FROM cte_spending
WHERE rn = 1

