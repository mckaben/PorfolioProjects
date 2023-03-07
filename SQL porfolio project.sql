SELECT*
FROM CovidDeaths
ORDER BY 1,2

-- SELECT Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null and continent <> ''
order by 1,2


-- Let's look at Total cases vs Total Deaths
-- let's fix "Operand data type varchar is invalid for divide operator" by 
-- converting to float.

SELECT location, date,population, total_cases, total_deaths,(CONVERT(float,total_deaths)/CONVERT(float, total_cases))*100
 as PercentDeathPercentage
FROM CovidDeaths
WHERE location like 'Nigeri%' and continent is not null and continent <> ''
ORDER BY 1,2

-- shows what percent of population got Covid

SELECT location, date,population, total_cases,(CONVERT(float,total_cases)/CONVERT(float, population))*100
 as PercentPopulationPercentage
FROM CovidDeaths
WHERE location like 'Ghana%' and continent is not null and continent <> ''
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population
-- The NULLIF CLAUSE is used to avoid a "Division by Zero" error .

SELECT location, population, MAX(total_cases) as HighestInfectionCount,MAX(CONVERT(float,total_cases)/NULLIF(CONVERT(float, population), 0))*100
as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%state%'
WHERE continent is not null and continent <> ''
GROUP BY population, location
ORDER BY PercentPopulationInfected desc


-- showing countries with highest Death count per population

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
-- Where location like '%states%'
WHERE continent is not null and continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount desc

--Let's create view for this table above
CREATE VIEW DeathCountPopulation as
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
-- Where location like '%states%'
WHERE continent is not null and continent <> ''
GROUP BY continent
--ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(CONVERT(float,new_cases)) as total_cases, SUM(cast(CONVERT(float,new_deaths) as int)) as total_deaths,
SUM(cast(CONVERT(float,new_deaths) as int))/SUM(CONVERT(float,new_cases))*100 as DeathPercentage
FROM CovidDeaths
-- WHERE location like 'Nigeri%'
WHERE continent is not null and continent <> ''
ORDER BY 1,2


---Let's look at the total population vs vaccinations
---------------------------------------------
-----------------------------------------


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and dea.continent <> ''
order by 1,2,3

--- Total population vs vaccinations using partition
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and dea.continent <> ''
order by 1,2,3


---USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and dea.continent <> ''
--order by 1,2,3
)
SELECT*
FROM PopvsVac



--- Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations varchar(225),
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and dea.continent <> ''
--SUM(convert(int,vac.new_vaccinations))


SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- CREATE view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and dea.continent <> ''

