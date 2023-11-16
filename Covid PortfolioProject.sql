Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * from PortfolioProject..CovidVaccinations
--order by 3,4

--Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2

--Total cases vs total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
Where Location like '%states%' and continent is not null
order by 1,2

--Total cases vs population

Select Location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
Where Location like '%india%' and continent is not null
order by 1,2

--Looking at countries with highest infection rates compared to population

Select Location,  Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
--Where Location like '%india%'
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--Countries with highest death count per population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--Where Location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc

--Breaking things down by continent

--Continents with highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--Where Location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
--Where Location like '%states%' 
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
		--RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location=vac.location 
			and dea.date=vac.date
where dea.continent is not null
order by 2,3

--using cte

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
		--RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location=vac.location 
			and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100 as ab
from PopvsVac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
		--RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location=vac.location 
			and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

--Creating view to store data for later visualisations

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
		--RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location=vac.location 
			and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *
from PercentPopulationVaccinated
