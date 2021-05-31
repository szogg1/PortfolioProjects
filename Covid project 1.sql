
-- Full data table CovidDeaths ordered by Country and Date

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--Full data table CovidVaccinations ordered by Country and Date

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Simplified CovidDeaths table with key information for further insight, ordered by Country and Date

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Cases Vs Deaths by Location
-- Shows the chances of dying from Covid in your country 
-- High death percentage at start of pandemic could be as a result of lack of testing (only the sick get tested - sick more likely to die) 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%kingdom%'
ORDER BY 1,2;

--Cases vs population
--How many people got covid in your country

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE location like '%kingdom%'
ORDER BY 1,2;


--Max covid infection by country ranked by highest infection rate

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%'
GROUP BY Location, population 
ORDER BY percent_population_infected DESC


-- Highest Covid deaths by country 

SELECT location, MAX(CAST(total_deaths as int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Highest Covid deaths by continent 

SELECT continent, MAX(CAST(total_deaths as int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

--New cases and deaths per day 

SELECT date, sum(new_cases) AS total_cases, sum(cast(new_deaths AS int)) AS total_deaths, sum(cast(new_deaths AS int))/sum(new_cases) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Total population vaccinated

SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- Rolling Vaccination Count

SELECT dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vac_count 
-- ,(rolling_vac_count/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- USE CTE
-- Allows both a Rolling Vaccination Count with a Rolling percentage vaccinated

WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_vac_count) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vac_count 
-- ,(rolling_vac_count/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
Select *, (rolling_vac_count/population)*100 AS rolling_percentage_vac
FROM popvsvac

-- TEMP TABLE
-- if the table needs to be run again with new select function remove table with following code (DROP TABLE IF exists #percentpopulationvaccinated)
--Allows both a Rolling Vaccination Count with a Rolling percentage vaccinated

CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar (255), 
location nvarchar (255),
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_vac_count numeric
)

INSERT INTO #percentpopulationvaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vac_count 
-- ,(rolling_vac_count/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

Select *, (rolling_vac_count/population)*100 AS rolling_percentage_vac
FROM #percentpopulationvaccinated

-- Creating view for tableau visualisation 

CREATE VIEW percentpopulationvaccinated1 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST (vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vac_count 
-- ,(rolling_vac_count/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
