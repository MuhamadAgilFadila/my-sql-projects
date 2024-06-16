-- Show Total Deaths by Country (from highest to lowest)
SELECT location, MAX(CAST(total_deaths AS float)) AS total_death_counts,
(MAX(CAST(total_deaths AS float))/population)*100 AS total_death_percentage_per_population,
population
FROM PortfolioDB..CovidDeaths
GROUP BY location, population
ORDER BY total_death_counts DESC

-- Show Total Deaths by Continent
WITH continent_covid AS (
SELECT location,  MAX(CAST(total_deaths AS float)) AS total_death_counts,
(MAX(CAST(total_deaths AS float))/SUM(CAST(population AS float)))*100 AS total_death_percentage,
SUM(CAST(population AS float)) AS continent_population
FROM PortfolioDB..CovidDeaths
WHERE continent is null and location IN (SELECT DISTINCT(continent) FROM PortfolioDB..CovidDeaths)
GROUP BY location )

SELECT * FROM continent_covid
ORDER BY total_death_counts DESC


-- Total Global Deaths Per-Day
SELECT date, SUM(CAST(total_deaths AS float)) AS total_deaths_counts_perday
FROM PortfolioDB..CovidDeaths
GROUP BY date
ORDER BY 1

-- Total Vaccinations Data by Country
WITH vaccination_cte AS
( SELECT date, continent, location, CAST(total_vaccinations AS float) AS total_vaccinations
FROM PortfolioDB..CovidDeaths
WHERE total_vaccinations is NOT NULL 
AND location NOT IN (SELECT location FROM PortfolioDB..CovidDeaths WHERE continent is NULL) )

SELECT location, MAX(total_vaccinations) AS total_vaccination
FROM vaccination_cte
GROUP BY location
ORDER BY 2 DESC

SELECT continent, location, population,
MAX(CAST(total_vaccinations AS float)) AS total_vaccinations,
( MAX(CAST(total_vaccinations AS float))/population ) AS vaccination_percentage_over_population
FROM PortfolioDB..CovidDeaths
WHERE total_vaccinations is not null
AND continent is not null
GROUP BY continent, location, population
ORDER BY continent


-- Total Vaccination by Continent
DROP TABLE IF EXISTS #ContinentVaccination
CREATE TABLE #ContinentVaccination (
	Continent varchar(100),
	Country varchar(100),
	Population float,
	Total_Vaccination float,
	vaccination_percentage_over_population float
);

INSERT INTO #ContinentVaccination
SELECT continent, location, population,
MAX(CAST(total_vaccinations AS float)) AS total_vaccinations,
( MAX(CAST(total_vaccinations AS float))/population ) AS vaccination_percentage_over_population
FROM PortfolioDB..CovidDeaths
WHERE total_vaccinations is not null
AND continent is not null
GROUP BY continent, location, population

--
SELECT Continent,
SUM(Population) AS Total_Population,
SUM(Total_Vaccination) AS Total_Vaccination_PerContinent,
(SUM(Total_Vaccination)/SUM(Population))*100 AS vaccination_percentage_over_population
FROM #ContinentVaccination
GROUP BY Continent