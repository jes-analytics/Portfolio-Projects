select *
FROM CovidDeaths
WHERE continent is not null
order by 3,4

--select * 
--FROM CovidVaccinations
--order by 3,4


--select the data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if contracting covid in United States

SELECT Location, date, total_cases, total_deaths, (Total_deaths / total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2


-- Looking at total cases vs population
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentageInfected
FROM CovidDeaths
--WHERE location like '%states%'
order by 1,2

--Looking at what countries have the highest infection rates compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageInfected
FROM CovidDeaths
--WHERE location like '%states%'
Group By location, population
order by 4 DESC

-- Showing countries with highest death count per population 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--WHERE location like '%states%'
WHERE  continent is not null
Group By location
order by 2 desc

--Break down by continent 
-- Showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
WHERE  continent is not null
Group By continent 
order by 2 desc


 -- Global numbers 

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
where continent is not null 
group by date
order by 1,2

SELECT  SUM(new_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
where continent is not null 
--group by date
order by 1,2


--Looking at total population vs vaccination 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From CovidDeaths dea
JOIN  CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From CovidDeaths dea
JOIN  CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select * , (RollingVaccinationCount/Population)*100 as VaccinationPercentage
FROM PopvsVac



-- Use Temp Table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255), 
Location nvarchar(255),
date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingVaccinationCount numeric
)

insert into  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From CovidDeaths dea
JOIN  CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
Select * , (RollingVaccinationCount/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinationCount
From CovidDeaths dea
JOIN  CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null


Select * 
FROM PercentPopulationVaccinated
	

Create View GlobalDeaths as 
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
where continent is not null 
group by date


Create View ContinentalDeathCount as 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
WHERE  continent is not null
Group By continent 


Create View DeathCountbyCountry as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--WHERE location like '%states%'
WHERE  continent is not null
Group By location


Create View InfectionRatesbyCountry as
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageInfected
FROM CovidDeaths
Group By location, population