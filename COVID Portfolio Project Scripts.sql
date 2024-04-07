select *
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

-- Select Data that we are going to be starting with

SELECT location, date,total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
order by 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country...

select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
Order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as float)/cast(population as float))*100 
as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group By population, location
Order by PercentPopulationInfected DESC

-- Showing countries with Highest Death count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group By location
Order by TotalDeathCount DESC

-- LET'S BREAK DOWN THINGS BY CONTINENT

-- Showing contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC

-- GLOBAL NUMBERS
--SET ARITHABORT OFF
--SET ANSI_WARNINGS OFF
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location,dea.date, dea.population, convert(float,vac.new_vaccinations) as new_vaccinations,
SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

-- Use CTE

with PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date, dea.population, convert(float,vac.new_vaccinations) as new_vaccinations,
SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population)
from PopvsVac

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, convert(float,vac.new_vaccinations) as new_vaccinations,
SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population) 
from #PercentPopulationVaccinated

-- Creating a view to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location,dea.date, dea.population, convert(float,vac.new_vaccinations) as new_vaccinations,
SUM(CONVERT(float,new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 1,2,

select * from PercentPopulationVaccinated
