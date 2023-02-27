
SELECT *
FROM ILearnSQL.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date
	
--SELECT *
--FROM ILearnSQL..CovidVaccinations
WHERE continent IS NOT NULL
--ORDER BY 3,4

-- A glimpse at the columns of interest

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ILearnSQL.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- To compare the total cases to total death in Canada
-- Shows the probability of death per covid case 

SELECT Date, Population, Total_cases, Total_deaths, (total_deaths/total_cases)*100 AS Percentage_death
FROM ILearnSQL.dbo.CovidDeaths
WHERE continent IS NOT NULL AND location = 'Canada'
ORDER BY 1

-- To view the total cases per population in each country
-- Shows percentage of the population with covid

SELECT Location, Population, total_cases, (total_cases/population)*100 AS Percentage_Covid_Cases
FROM ILearnSQL.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 4 DESC

-- To view a comparison of daily deaths to population in Countries 
--shows what percentage of the population was lost to covid

SELECT Location, Date, Population, Total_deaths, (total_deaths/population)*100 AS Percentage_death
FROM ILearnSQL.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- To view a comparison of daily deaths to population in Canada 
--shows what percentage of the population was lost to covid

SELECT date, population, total_deaths, (total_deaths/population)*100 AS percentage_death
FROM ILearnSQL.dbo.CovidDeaths
WHERE location = 'Canada' AND continent IS NOT NULL
ORDER BY 1,2



-- Exploring countries with higest infection rate compared to their population

SELECT Location, Population, MAX(total_cases) AS Max_Covid_cases, MAX((total_cases/population))*100 AS Percentage_Population_Infected
FROM ILearnSQL..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, Population
ORDER BY Percentage_Population_Infected DESC 

-- Exploring countries by death counts per population

SELECT Location, Population, MAX(CAST(total_deaths AS INT)) AS Max_death_count
FROM ILearnSQL..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Max_death_count DESC

-- Exploring Continents by death counts

SELECT Location, MAX(CAST(total_deaths AS INT)) AS Max_death_count
FROM ILearnSQL..CovidDeaths
WHERE continent IS  NULL
GROUP BY Location
ORDER BY Max_death_count DESC

SELECT Continent, MAX(CAST(total_deaths AS INT)) AS Max_death_count
FROM ILearnSQL..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Max_death_count DESC


-- GLOBAL NUMBERS

SELECT location, population, SUM(total_cases) As GrandTotalCases, SUM(CAST(total_deaths AS INT)) AS GrandTotalDeaths
FROM ILearnSQL..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population

WITH GlobalCases_Deaths AS(
SELECT location, population, SUM(cast(new_cases as int)) As GrandTotalCases, SUM(CAST(new_deaths AS INT)) AS GrandTotalDeaths
FROM ILearnSQL..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
)
SELECT location, (GrandTotalCases/population)*100 AS PercentageCases, (GrandTotalDeaths/population)*100 AS PercentageTotalDeaths
FROM GlobalCases_Deaths
Order by 2 desc

-- to check accuracy of some results

SELECT location, population, sum(cast(new_cases as int)), sum(cast(new_deaths as int))
FROM CovidDeaths
WHERE location IN ('Canada', 'USA','Tanzania', 'Vietnam', 'Taiwan')
GROUP BY location, population

-- To pull data from both tables

SELECT *
FROM ILearnSQL..CovidDeaths AS CDeaths
JOIN ILearnSQL..CovidVaccinations AS CVac
ON CDeaths.location = CVac.location
AND CDeaths.date = CVac.date
WHERE CVAC. continent IS NOT NULL
ORDER BY 2,4

-- To view total population data with new cases against vaccinations

SELECT CVac.Continent, CVac.Location, CVac.Date, CDeaths.new_cases, CVac.new_vaccinations, SUM(CONVERT(INT,CVac.new_vaccinations)) OVER (PARTITION BY CVac.location ORDER BY CVac.location, CVac.date) AS RollingVacs
FROM ILearnSQL..CovidDeaths AS CDeaths
JOIN ILearnSQL..CovidVaccinations AS CVac
ON CDeaths.location = CVac.location
AND CDeaths.date = CVac.date
WHERE CVAC. continent IS NOT NULL
ORDER BY 2,3

-- To futher query using cte

WITH GlobalCasesNVacs AS
(SELECT CVac.Continent, CVac.Location, CVac.population, CVac.Date, CDeaths.new_cases, CVac.new_vaccinations, SUM(CONVERT(INT, CVac.new_vaccinations)) OVER (PARTITION BY CVac.location ORDER BY CVac.location, CVac.date) Cummulative_Vac
FROM ILearnSQL..CovidDeaths AS CDeaths
JOIN ILearnSQL..CovidVaccinations AS CVac
ON CDeaths.location = CVac.location
AND CDeaths.date = CVac.date
WHERE CVAC.continent IS NOT NULL AND CDeaths.continent IS NOT NULL
)
SELECT *, (cummulative_Vac/population)*100 as percentageRollingVac
FROM GlobalCasesNVacs
ORDER BY 2,4

-- INSERTING AS TEMP TABLE

DROP TABLE IF EXISTS #GlobalVacs
CREATE TABLE #GlobalVacs
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations int,
RollingVacs int
)
INSERT INTO #GlobalVacs
SELECT Cvac.continent, CVac.Location,  CVac.Date, CVac.population,(CVac.new_vaccinations), SUM(CONVERT(INT, CVac.new_vaccinations)) OVER (PARTITION BY CDeaths.location ORDER BY CVac.location, CVac.date) RollingVacs
FROM ILearnSQL..CovidDeaths AS CDeaths
JOIN ILearnSQL..CovidVaccinations AS CVac
ON CDeaths.date = CVac.date
AND CDeaths.location = CVac.location
--WHERE CVac.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingVacs/population)*100 as percentageRollingVacs
FROM #GlobalVacs
ORDER BY 2,4



WITH GlobalNumbers AS(
SELECT CVac.location, CVac.population, SUM(cast(CDeaths.new_cases AS NUMERIC)) As GrandTotalCases, SUM(CAST(CVac.new_vaccinations AS NUMERIC)) AS GrandTotalVacs, SUM(CAST(CDeaths.new_deaths AS NUMERIC)) AS GrandTotalDeaths
FROM ILearnSQL..CovidDeaths CDeaths
JOIN ILearnSQL..CovidVaccinations CVac
ON CVac.date = CDeaths.date
AND CVac.location = CDeaths.location
WHERE CVac.continent IS NOT NULL
GROUP BY CVac.location, CVac.population
)
SELECT Location, Population, (GrandTotalCases/population)*100 AS PercentageCases, (GrandTotalVacs/population)*100 AS PercentageTotalVacs,
(GrandTotalDeaths/population)*100 AS PercentageTotalDeaths
FROM GlobalNumbers
Order by 5 DESC

-- Creating view for viz

CREATE VIEW PercentageGlobalCovidNUmbers AS
WITH GlobalNumbers AS(
SELECT CVac.location, CVac.population, SUM(cast(CDeaths.new_cases AS NUMERIC)) As GrandTotalCases, SUM(CAST(CVac.new_vaccinations AS NUMERIC)) AS GrandTotalVacs, SUM(CAST(CDeaths.new_deaths AS NUMERIC)) AS GrandTotalDeaths
FROM ILearnSQL..CovidDeaths CDeaths
JOIN ILearnSQL..CovidVaccinations CVac
ON CVac.date = CDeaths.date
AND CVac.location = CDeaths.location
WHERE CVac.continent IS NOT NULL
GROUP BY CVac.location, CVac.population
)
SELECT Location, Population, (GrandTotalCases/population)*100 AS PercentageCases, (GrandTotalVacs/population)*100 AS PercentageTotalVacs,
(GrandTotalDeaths/population)*100 AS PercentageTotalDeaths
FROM GlobalNumbers
--Order by 5 DESC


SELECT *
FROM PercentageGlobalCovidNUmbers 

select * from CovidDeaths