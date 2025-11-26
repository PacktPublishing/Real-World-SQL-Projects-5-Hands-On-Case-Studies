
--Q1 Identify matches played between two specific teams (e.g., India and South Africa) in 2024 and their results.

SELECT * 
FROM T20I
WHERE ((Team1 = 'South Africa' AND Team2 = 'India') OR (Team2 = 'South Africa' AND Team1 = 'India'))
AND YEAR(MatchDate) = 2024


--Q2 Find the team with the highest number of wins in 2024 and the total matches it won.

SELECT TOP 1 Winner, COUNT(*) AS 'Number of Wins'
FROM T20I
WHERE YEAR(MatchDate) = 2024
GROUP BY Winner
ORDER BY 'Number of Wins' DESC





--Q3 Rank the teams based on the total number of wins in 2024.

SELECT Winner, COUNT(*) AS 'Number of Wins',
	DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS Rank_Assigned
FROM T20I
WHERE YEAR(MatchDate) = 2024 AND Winner NOT IN('tied', 'no result')
GROUP BY Winner




--Q4 Which team had the highest average winning margin (in runs), and what was the average margin?

SELECT TOP 1 Winner, AVG(CAST(SUBSTRING(Margin, 1, CHARINDEX(' ', Margin) - 1) AS INT)) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%runs'
GROUP BY Winner
ORDER BY Avg_Margin DESC

--Q4.1 Which team had the highest average winning margin (in wickets), and what was the average margin?

SELECT TOP 1 Winner, AVG(CAST(SUBSTRING(Margin, 1, CHARINDEX(' ', Margin) - 1) AS INT)) AS Avg_Margin
FROM T20I
WHERE Margin LIKE '%wickets'
GROUP BY Winner
ORDER BY Avg_Margin DESC



--Q5 List all matches where the winning margin was greater than the average margin across all matches.

WITH CTE_AvgMargin AS(
	SELECT AVG(CAST(SUBSTRING(Margin, 1, CHARINDEX(' ', Margin) - 1) AS INT)) AS Avg_OverAllMargin
	FROM T20I
	WHERE Margin LIKE '%runs'
)
SELECT T.Team1, T.Team2, T.Winner, T.Margin
FROM T20I T
LEFT JOIN CTE_AvgMargin A ON 1 = 1
WHERE T.Margin LIKE '%runs'
AND CAST(SUBSTRING(Margin, 1, CHARINDEX(' ', Margin) - 1) AS INT) > A.Avg_OverAllMargin


--Q6 Find the team with the most wins when chasing a target (wins by wickets)
SELECT * 
FROM T20I

SELECT Winner, WinWhileChasing
FROM (
		SELECT Winner, COUNT(*) AS WinWhileChasing,
			RANK() OVER( ORDER BY COUNT(*) DESC) AS rk
		FROM T20I
		WHERE Margin LIKE '%wickets'
		AND Winner NOT IN ('tied', 'no result')
		GROUP BY Winner
) t
WHERE rk = 1


--Q7 Head-to-head record between two selected teams (e.g., England vs Australia).

DECLARE @TeamA VARCHAR(25) = 'India';
DECLARE @TeamB VARCHAR(25) = 'South Africa';

SELECT Winner, Count(*) AS Matches
FROM T20I
WHERE (Team1 = @TeamA AND Team2= @TeamB) OR (Team1 = @TeamB AND Team2= @TeamA)
GROUP BY Winner




--Q8 Identify the month in 2024 with the highest number of T20I matches played.

SELECT *
FROM T20I

SELECT YEAR(MatchDate) AS YearPlayed,
	   --Month(MatchDate) AS MonthNumber,
	   DATENAME(MONTH, MatchDate) AS MonthName,
	   COUNT(*) AS MatchesPlayed
FROM T20I
WHERE YEAR(MatchDate) = 2024
GROUP BY YEAR(MatchDate), Month(MatchDate), DATENAME(MONTH, MatchDate)
ORDER BY MatchesPlayed DESC




--Q9 For each team, find how many matches they played in 2024 and their win percentage.

SELECT *
FROM T20I

WITH CTE_MatchesPlayed AS (
	SELECT Team, COUNT(*) AS MatchesPlayed
	FROM (
			SELECT Team1 AS Team
			FROM T20I
			WHERE YEAR(MatchDate) = 2024
			UNION ALL
			SELECT Team2 AS Team
			FROM T20I
			WHERE YEAR(MatchDate) = 2024
		 ) t
	GROUP BY Team
	),
CTE_Wins AS (
	SELECT Winner AS Team, COUNT(*) AS Wins
	FROM  T20I
	WHERE YEAR(MatchDate) = 2024 AND Winner NOT IN ('tied', 'no result')
	GROUP BY Winner
)
SELECT 
		m.Team, m.MatchesPlayed, ISNULL(w.Wins, 0) AS Wins,
		CAST(ISNULL(w.Wins, 0) * 100.0/m.MatchesPlayed AS DECIMAL(5,2)) AS WinPercentage
From CTE_MatchesPlayed m
LEFT JOIN CTE_Wins w
ON m.Team = w.Team
ORDER BY WinPercentage DESC


--Q10 Identify the most successful team at each ground (team with most wins per ground).

SELECT *
FROM T20I

WITH CTE_WinsPerGround AS (
	SELECT Ground, Winner, Wins, RANK() OVER (PARTITION BY Ground ORDER BY Wins DESC) AS rn
	FROM (
			SELECT Ground, Winner, COUNT(*) AS Wins
			FROM T20I 
			WHERE Winner NOT IN ('tied','no result')
			GROUP BY Ground, Winner
		 ) t
)
SELECT Ground, Winner AS MostSuccessful, Wins
FROM CTE_WinsPerGround
WHERE rn = 1
ORDER BY Ground