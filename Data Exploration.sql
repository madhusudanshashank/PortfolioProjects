Select *
From PortfolioProject..CovidDeaths
WHERE continent is null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,
(cast(total_deaths as decimal))/(cast(total_cases as decimal)) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases,
(cast(total_cases as decimal))/(cast(population as decimal)) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at Countries with highest Infection Rate Compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount,
Max((cast(total_cases as decimal))/(cast(population as decimal)))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by location,population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

-- showing continents with the highest death count per population

SelecT continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is NOT null
Group by continent
order by TotalDeathCount desc


--SelecT location, Max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
--where continent is null
--Group by location
--order by TotalDeathCount desc


--Global Numbers

Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where  new_deaths > 1 AND continent IS NOT NULL
Group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where  new_deaths > 1 AND continent IS NOT NULL
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using Temp Table to perform calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 