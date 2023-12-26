select *
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from [Portfolio Project].dbo.CovidVaccinations
--order by 3,4  

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at the Total Cases vs Population
-- Show what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 1,2


--Looking at countires with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc
 

 -- Showing countries with highest death count per population

 select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population

 select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where continent is not null
group by date
order by 1,2


-- Looking at total population vs 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project].dbo.CovidDeaths dea
join [Portfolio Project].dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated
