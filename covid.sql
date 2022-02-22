-- overall data
SELECT
	*
FROM
	CovidDeath
WHERE
	continent = '';

-- BREAKS BY CONTINENT

-- total Death by continent

SELECT
	location ,
	MAX(total_deaths) AS TotalDeathCount
FROM
	CovidDeath cd
WHERE
	continent = ''
	/*continent IS NOT NULL
	AND continent  != ''*/
GROUP BY
	location 
ORDER BY
	HighestDeathCount DESC;




-- BREAKS BY LOCATION
-- Data that will using
SELECT
	location ,
	`date` ,
	total_cases ,
	new_cases ,
	total_deaths ,
	population
FROM
	CovidDeath
WHERE
	continent IS NOT NULL;

-- total cases Vs Total Death
SELECT
	location ,
	total_cases ,
	total_deaths ,
	(total_deaths / total_cases)* 100 AS DeathPercentage
FROM
	CovidDeath
WHERE
	continent IS NOT NULL;

-- total case Vs population 
SELECT
	location ,
	`date`,
	total_cases ,
	population ,
	(total_cases / population)* 100 AS percentage
FROM
	CovidDeath
WHERE
	continent IS NOT NULL
;

-- Population VS HighestInfectionCount 
SELECT
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases / population)* 100) AS PercentagePopulationInfected
FROM
	CovidDeath cd
GROUP BY
	location,
	population
ORDER BY
	PercentagePopulationInfected DESC;

-- Countries with Highest death per population 
SELECT
	location,
	population,
	MAX(total_deaths) AS HighestDeathCount,
	MAX((total_deaths / population)* 100) AS PercentageDeath
FROM
	CovidDeath cd
WHERE
	continent IS NOT NULL
GROUP BY
	location,
	population
ORDER BY
	PercentageDeath DESC;

-- Global numbers

-- overall 
SELECT
	SUM(new_cases) AS TotalCases  ,
	SUM(new_deaths) TotalDeaths,
	SUM(new_deaths)/SUM(new_cases)*100  AS DeathPercentage
FROM
	CovidDeath
WHERE
	continent IS NOT NULL;

-- drill down
SELECT
	date ,
	SUM(new_cases) AS TotalCases  ,
	SUM(new_deaths) TotalDeaths,
	SUM(new_deaths)/SUM(new_cases)*100  AS DeathPercentage
FROM
	CovidDeath
WHERE
	continent IS NOT NULL
GROUP BY date;

-- covidVaccines

SELECT * FROM CovidVaccinations vac

-- Total Population VS Vaccinations

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (PARTITION BY location ORDER BY dea.location, dea.`date`) AS RollingPeopleVaccinated, -- rolling count
	
FROM
	CovidDeath dea
JOIN CovidVaccinations vac 
ON
	dea.location = vac.location
	AND dea.date = vac.`date`
WHERE
	dea.continent <> ''
ORDER BY
	2,3;


-- Use CTE
WITH PopVsVac (Continent,
Location,
Date,
Population,
New_Vaccination,
RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (PARTITION BY location
ORDER BY
	dea.location,
	dea.`date`) AS RollingPeopleVaccinated
	-- rolling count
FROM
	CovidDeath dea
JOIN CovidVaccinations vac 
ON
	dea.location = vac.location
	AND dea.date = vac.`date`
WHERE
	dea.continent <> ''
)
SELECT
	*,
	(RollingPeopleVaccinated / Population)* 100
FROM
	PopVsVac
ORDER BY
	2,3
	
	
-- temp table optional
DROP TABLE PercentPopulationVaccinated;

CREATE table IF NOT EXISTS PercentPopulationVaccinated
(Continent varchar(255),
Location varchar(255),
date date,
Population  bigint ,
New_Vaccinations bigint ,
RollingPeopleVaccinated bigint);
	
INSERT INTO PercentPopulationVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (PARTITION BY location
ORDER BY
	dea.location,
	dea.`date`) AS RollingPeopleVaccinated
	-- rolling count
FROM
	CovidDeath dea
JOIN CovidVaccinations vac 
ON
	dea.location = vac.location
	AND dea.date = vac.`date`
WHERE
	dea.continent <> ''
	
SELECT * FROM PercentPopulationVaccinated 

-- Create view

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (PARTITION BY location
ORDER BY
	dea.location,
	dea.`date`) AS RollingPeopleVaccinated
	-- rolling count
FROM
	CovidDeath dea
JOIN CovidVaccinations vac 
ON
	dea.location = vac.location
	AND dea.date = vac.`date`
WHERE
	dea.continent <> ''
CALL per