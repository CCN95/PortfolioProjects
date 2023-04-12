select *
from PortfolioProject1..top100_kdrama
order by 1,2



-- Average Scores of the Top 100 Kdrama
select AVG(Score) as AverageScore
from PortfolioProject1..top100_kdrama



-- Top 10 Kdrama which scored more than the average
-- If average score is 8.7
select Top 10 *
from PortfolioProject1..top100_kdrama
where Score > 8.7
order by Score desc



-- Above average Kdramas with Episodes lower than 10 
select Title, Score, Episodes
from PortfolioProject1..top100_kdrama
where Score > 8.7 and Episodes <= 10
order by Score desc, Episodes desc



-- Top 10 Kdramas with high number of watchers
select Top 10 *
from PortfolioProject1..top100_kdrama
where Watchers > 100000
order by Watchers desc



-- Percentage of watchers per kdrama
select title, episodes, watchers,
	round(watchers/ (select sum(watchers) from PortfolioProject1..top100_kdrama) * 100, 2) as watcher_percentage
from PortfolioProject1..top100_kdrama
order by watchers desc



-- Kdramas that have "Few", "Many" or "Normal" number of episodes
select Title, Episodes, 
	case
		when episodes <= 13 then 'Few'
		when episodes between 14 and 16 then 'Normal'
		else 'Many'
	end as CategoryOfEpisodes
from PortfolioProject1..top100_kdrama
order by CategoryOfEpisodes



-- Action Kdrama with 10 episodes or lower
select kd.Title, kd.Episodes, kd.Watchers, kg.Genre
from PortfolioProject1..top100_kdrama kd
join PortfolioProject1..top100_kdrama_genre kg
	on kd.ID = kg.ID
where kd.Episodes <= 10 
	and genre like '%action%'




-- Using CTE

-- Looking into the total percentage of watchers per genre
With WatcherPercentage (title, episodes, watchers, watcher_percentage, genre)
as 
(
select kd.Title, kd.Episodes, kd.Watchers, 
	round(kd.Watchers/ (select sum(kd.Watchers) 
	from PortfolioProject1..top100_kdrama kd
	join PortfolioProject1..top100_kdrama_genre kg
		on kd.ID = kg.ID) * 100, 2) as watcher_percentage,
	trim(split.value) as trim_genre
from PortfolioProject1..top100_kdrama kd
join PortfolioProject1..top100_kdrama_genre kg
	on kd.ID = kg.ID
cross apply string_split(kg.Genre, ',') as split
)
select genre, sum(watcher_percentage) TotalWatcherPercentage
from WatcherPercentage
group by genre
order by 2 desc
