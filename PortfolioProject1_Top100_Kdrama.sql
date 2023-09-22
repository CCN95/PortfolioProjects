SELECT *
FROM PortfolioProject1..top100_kdrama
ORDER BY 1,2



-- AVERAGE SCORES OF THE TOP 100 KDRAMA
	
SELECT AVG(Score) AS AverageScore
FROM PortfolioProject1..top100_kdrama



-- TOP 10 KDRAMA
/* Kdramas which scored more than the average. The average score from the previous query is 8.7 */

SELECT Top 10 *
FROM PortfolioProject1..top100_kdrama
WHERE Score > 8.7
ORDER BY Score DESC



-- ABOVE AVERAGE KDRAMAS WITH EPISODES LOWER THAN 10
	
SELECT 
	Title, 
	Score, 
	Episodes
FROM PortfolioProject1..top100_kdrama
WHERE Score > 8.7 
	AND Episodes <= 10
ORDER BY Score DESC, 
	Episodes DESC



-- TOP 10 KDRAMAS BASED ON WATCHERS
	
SELECT Top 10 *
FROM PortfolioProject1..top100_kdrama
WHERE Watchers > 100000
ORDER BY Watchers DESC



-- PERCENTAGE OF WATCHERS PER KDRAMA
	
SELECT 
	title, 
	episodes, 
	watchers,
	ROUND(watchers/ (SELECT SUM(watchers) FROM PortfolioProject1..top100_kdrama) * 100, 2) AS watcher_percentage
FROM PortfolioProject1..top100_kdrama
ORDER BY watchers DESC



-- KDRAMAS THAT HAVE "FEW", "MANY", OR "NORMAL" NUMBER OF EPISODES
/* Kdramas normally have 16 episodes. */
	
SELECT 
	Title, 
	Episodes, 
		CASE
			WHEN episodes <= 13 THEN 'Few'
			WHEN episodes BETWEEN 14 AND 16 THEN 'Normal'
			ELSE 'Many'
		END AS CategoryOfEpisodes
FROM PortfolioProject1..top100_kdrama
ORDER BY CategoryOfEpisodes



-- ACTION KDRAMA WITH 10 EPISODES OR LOWER
	
SELECT
	kdrama.Title, 
	kdrama.Episodes, 
	kdrama.Watchers, 
	kgenre.Genre
FROM PortfolioProject1..top100_kdrama AS kdrama
JOIN PortfolioProject1..top100_kdrama_genre AS kgenre
	ON kdrama.ID = kgenre.ID
WHERE kdrama.Episodes <= 10 
	AND genre LIKE '%action%'




-- USING CTE

-- TOTAL PERCENTAGE OF WATCHERS BASED ON GENRE
	
WITH
	WatcherPercentage (
		title, 
		episodes, 
		watchers, 
		watcher_percentage, 
		genre)
AS 
(
SELECT 
	kdrama.Title, 
	kdrama.Episodes, 
	kdrama.Watchers, 
	ROUND(kdrama.Watchers/ (SELECT SUM(kdrama.Watchers) 
	FROM PortfolioProject1..top100_kdrama kdrama
	JOIN PortfolioProject1..top100_kdrama_genre kgenre
		ON kdrama.ID = kgenre.ID) * 100, 2) AS watcher_percentage,
		TRIM(split.VALUE) AS trim_genre
FROM PortfolioProject1..top100_kdrama kdrama
JOIN PortfolioProject1..top100_kdrama_genre kgenre
	ON kdrama.ID = kgenre.ID
CROSS APPLY STRING_SPLIT(kgenre.Genre, ',') AS split
)
SELECT 
	genre, 
	SUM(watcher_percentage) AS TotalWatcherPercentage
FROM WatcherPercentage
GROUP BY genre
order by 2 desc
