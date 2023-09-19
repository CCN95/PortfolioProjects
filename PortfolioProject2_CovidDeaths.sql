SELECT *
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4



SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- TOTAL CASES vs. TOTAL DEATHS
/* Shows the likelihood of dying due to Covid if you are living in the Philippines */

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE location = 'Philippines'
AND continent IS NOT NULL
ORDER BY 1,2



-- TOTAL CASES vs. POPULATION
/* Shows the percentage of population in the Philippines who contracted Covid */

SELECT 
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject2..CovidDeaths
WHERE location = 'Philippines'
AND continent IS NOT NULL
ORDER BY 1,2



-- HIGHEST INFECTION RATE
/* What are the countries that have the highest infection rate compared to population? */

SELECT 
	location, 
	population, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject2..CovidDeaths
GROUP BY 
	location, 
	population
ORDER BY PercentPopulationInfected DESC



-- HIGHEST DEATH COUNT
/* What countries have the highest death count per population? */

SELECT
	location, 
	MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- DEATH COUNT PER CONTINENT

SELECT
	continent, 
	SUM(total_deaths) AS TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC





-- GLOBAL NUMBERS

/* Death Percentage across the world */

SELECT 
	date, 
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths, 
	SUM(new_deaths) / NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2



/* World's Total Death Percentage */

SELECT
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths, 
	SUM(new_deaths) / NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2




/* Total Population vs. Total Vaccinations */

SELECT
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER 
		(PARTITION BY cd.location order by cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths cd
JOIN PortfolioProject2..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3




-- USING CTE

/* Percentage of RollingPeopleVaccinated over Population in the Philippines */

WITH 
	PopvsVac (
		Continent, 
		Location, 
		Date, 
		Population, 
		New_Vaccinatins, 
		RollingPeopleVaccinated)
AS
(
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER 
		(Partition by cd.location order by cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths cd
JOIN PortfolioProject2..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT 
	*, 
	(RollingPeopleVaccinated/Population)*100
FROM PopvsVac
WHERE Location = 'Philippines'



/* Maximum number of vaccinated around the world */

WITH
	PopvsVac (
		Continent, 
		Location, 
		Population, 
		New_Vaccinations, 
		RollingPeopleVaccinated)
AS
(
SELECT 
	cd.continent, 
	cd.location, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER 
		(Partition by cd.location order by cd.location) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths cd
JOIN PortfolioProject2..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT 
	Continent, 
	Location, 
	MAX(RollingPeopleVaccinated) AS Max_Vaccinated
FROM PopvsVac
GROUP BY Continent, Location
ORDER 3 desc



-- TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER 
		(Partition by cd.location order by cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths cd
JOIN PortfolioProject2..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL

SELECT 
	*, 
	(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
WHERE Location = 'Philippines'



-- STORED VIEW
/* Creating View to store data for later visualizations */

DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated 
AS
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS bigint)) OVER 
		(Partition by cd.location order by cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths cd
JOIN PortfolioProject2..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
