Select *
From PortfolioProject2..CovidDeaths
where continent is not null
order by 3,4



Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject2..CovidDeaths
where continent is not null
order by 1,2



-- Total Cases vs Total Deaths
-- Shows the likelihood of dying due to Covid if you are living in the Philippines
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
where location = 'Philippines'
and continent is not null
order by 1,2



-- Total Cases vs Population
-- Shows the percentage of population in the Philippines who contracted Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject2..CovidDeaths
where location = 'Philippines'
and continent is not null
order by 1,2



-- What are the countries that have the highest infection rate compared to population?
Select location, population, max(total_cases) as HighestInfectionCount, 
max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject2..CovidDeaths
group by location, population
order by PercentPopulationInfected desc



-- What countries have the highest death count per population?
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject2..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



-- Death count per continent
Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject2..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc




-- GLOBAL NUMBERS



-- Death Percentage across the world
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths) / NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
where continent is not null
group by date
order by 1,2



-- World's Total Death Percentage 
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths) / NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject2..CovidDeaths
where continent is not null
order by 1,2




-- Total Population vs. Total Vaccinations
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations as bigint)) 
	OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths cd
Join PortfolioProject2..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3




-- Using CTE



-- Percentage of RollingPeopleVaccinated over Population in the Philippines
With PopvsVac (Continent, Location, Date, Population, New_Vaccinatins, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations as bigint)) 
	OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths cd
Join PortfolioProject2..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
where Location = 'Philippines'



-- Maximum number of vaccinated around the world
With PopvsVac (Continent, Location, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.population, cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations as bigint)) 
	OVER (Partition by cd.location order by cd.location) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths cd
Join PortfolioProject2..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
select Continent, Location, max(RollingPeopleVaccinated) as Max_Vaccinated
from PopvsVac
group by Continent, Location
order by 3 desc



-- TEMP TABLE 

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations as bigint)) 
	OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths cd
Join PortfolioProject2..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
where Location = 'Philippines'



-- Creating View to store data for later visualizations 

Drop view if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cast(cv.new_vaccinations as bigint)) 
	OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths cd
Join PortfolioProject2..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

select *
from PercentPopulationVaccinated