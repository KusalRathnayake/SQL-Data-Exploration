SELECT *
FROM Project1.dbo.CovidDeaths
WHERE continent is not NULL
order by 3,4

--SELECT *
--FROM Project1.dbo.CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Project1.dbo.CovidDeaths
WHERE continent is not NULL
order by 1,2

-- Looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in yopur country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage
FROM Project1.dbo.CovidDeaths
WHERE Location like '%states%'
and continent is not NULL
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM Project1.dbo.CovidDeaths
-- WHERE Location like '%states%'
order by 1,2

-- Looking at countries with highest infection population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Project1.dbo.CovidDeaths
-- WHERE Location like '%states%'
GROUP BY Location, population
order by PercentPopulationInfected DESC


-- showing countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Project1.dbo.CovidDeaths
-- WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY Location
order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- showing the continents with the highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Project1.dbo.CovidDeaths
-- WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY continent
order by TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage  --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1.dbo.CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY date
order by 1,2

-- Looking at total population vs vaccination
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
    ON dea.Location = vac.Location
    and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- USE CTE


WITH PopvsVac (continent, Location, date, Population, new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
    ON dea.Location = vac.Location
    and dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(225),
Location NVARCHAR(225),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
    ON dea.Location = vac.Location
    and dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(225),
Location NVARCHAR(225),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
    ON dea.Location = vac.Location
    and dea.date = vac.date
-- WHERE dea.continent is not NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- CREATING VIEW FOR LATER DATA VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Project1.dbo.CovidDeaths dea
JOIN Project1.dbo.CovidVaccinations vac
    ON dea.Location = vac.Location
    and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated










