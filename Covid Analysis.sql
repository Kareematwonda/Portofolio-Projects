select * 
from MyProject..CovidDeaths
where continent is not null
order by 3, 4

--select * 
--from MyProject..CovidVaccinations
--order by 3, 4

-- select data to be used

select location,date, total_cases, new_cases, total_deaths, population
from MyProject..CovidDeaths
where continent is not null
order by 1, 2


--looking at the total cases vs total deaths in Nigeria
--shows the likelyhood of dying after contracting covid

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from MyProject..CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1, 2

--looking at the total cases vs the population in Nigeria
--shows what percentage of the population got covid

select location,date, population, total_cases, (total_cases/population)*100 as PercentageInfected
from MyProject..CovidDeaths
--where location like '%nigeria%'
order by 1, 2


--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageInfected
from MyProject..CovidDeaths
--where location like '%nigeria%'
group by location, population
order by  PercentageInfected desc

--showing the countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from MyProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location
order by 2 desc


--CATEGORIZING BY CONTINENT

--showing continents with the highest death counts

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from MyProject..CovidDeaths
--where location like '%nigeria%'
where continent is null
group by continent
order by 2 desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from MyProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1, 2


--looking at total population vs populationVacinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from MyProject..CovidDeaths dea
join MyProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--using CTE

with PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from MyProject..CovidDeaths dea
join MyProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from MyProject..CovidDeaths dea
join MyProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from MyProject..CovidDeaths dea
join MyProject..CovidVac vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


select * 
from PercentPopulationVaccinated