/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT
	*
FROM PortfolioProject.dbo.CovidDeaths cd 
ORDER BY 3,4 DESC

SELECT
	*
FROM PortfolioProject.dbo.CovidVaccinations cv 
ORDER BY 3,4 DESC


--Select Data that we are going to be using

SELECT 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM PortfolioProject.dbo.CovidDeaths cd 
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


SELECT 
	Location, 
	date, 
	total_cases,  
	total_deaths,
	CAST((total_deaths * 100.0 / total_cases) AS FLOAT) AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE Location LIKE '%states%'
ORDER BY Location, date


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid


SELECT 
	location, 
	date, 
	population,
	total_cases,
	CAST((population * 100.0 / total_cases) AS FLOAT) AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE location LIKE '%states%'
ORDER BY location, date


--Looking at Countries with Highest Infection Rate compared to Population


SELECT 
	location,  
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((CAST(total_cases AS FLOAT) / population) *100 ) AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths cd 
--WHERE location LIKE '%states%'
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population


SELECT 
	location,  
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE continent <> ''
GROUP BY location 
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


SELECT 
	location,  
	MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE continent = ''
GROUP BY location 
ORDER BY TotalDeathCount DESC


-- Global numbers


SELECT 
	CAST(date AS datetime) AS date, 
	SUM(new_cases) AS sumnewcases,  
	SUM(new_deaths) AS sumnewdeaths,
	SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths cd 
--WHERE Location LIKE '%states%'
WHERE continent <> ''
GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query


WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(

SELECT
	dea.continent, 
	dea.location, 
	CAST(dea.date AS datetime) AS date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS datetime)) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''
--ORDER BY 2,3
)
SELECT 
	*, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent varchar(50),
location varchar(50),
date datetime,
population numeric,
new_vaccinations varchar(50),
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent, 
	dea.location, 
	CAST(dea.date AS datetime) AS date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS datetime)) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent <> ''
--ORDER BY 2,3

SELECT 
	*, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
SELECT
	dea.continent, 
	dea.location, 
	CAST(dea.date AS datetime) AS date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS datetime)) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''
--ORDER BY 2,3

SELECT
	*
FROM PercentPopulationVaccinated
