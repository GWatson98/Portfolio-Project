select *
from [Portfolio Project Covid]..CovidDeaths$
order by 3,4

select *
from [Portfolio Project Covid]..CovidVaccinations$
where continent is not null
order by 3,4

-- select data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project Covid]..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths
--shows liklihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project Covid]..CovidDeaths$
where location like '%kingdom%'
order by 1,2


-- looking at total cases vs population
-- shows what % of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as CovidInfection
from [Portfolio Project Covid]..CovidDeaths$
where location like '%kingdom%'
order by 1,2

-- countries with highest infection rates compare to population
select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentOfPopInfected
from [Portfolio Project Covid]..CovidDeaths$
group by location, population
order by PercentOfPopInfected desc

-- showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project Covid]..CovidDeaths$
where continent is not null
group by location, population
order by totaldeathcount desc

-- break down by continent


-- showing the continents with the highest death count
select continent,max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project Covid]..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc



-- global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from [Portfolio Project Covid]..CovidDeaths$ 
--where location like '%kingdom%'
where continent is not null
--group by date
order by 1,2 


-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rollingVaccintion
, (rollingvaccination/population)*100
from [Portfolio Project Covid]..CovidDeaths$ dea
join [Portfolio Project Covid]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- use CTE

with PopVsVac (continent, location, date, population, new_vaccinations, rollingvaccination)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rollingVaccintion
--, (rollingVaccination/population)*100
from [Portfolio Project Covid]..CovidDeaths$ dea
join [Portfolio Project Covid]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (rollingvaccination/population)*100
from PopVsVac


-- temp table

drop table if exists #PercentPopVacc
create table #PercentPopVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccination numeric
)

insert into #PercentPopVacc
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rollingVaccintion
--, (rollingVaccination/population)*100
from [Portfolio Project Covid]..CovidDeaths$ dea
join [Portfolio Project Covid]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *, (rollingvaccination/population)*100
from #PercentPopVacc



-- creating a view to store data for later visulisations

create view percentpopvacc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as rollingVaccintion
--, (rollingVaccination/population)*100
from [Portfolio Project Covid]..CovidDeaths$ dea
join [Portfolio Project Covid]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


select * 
from percentpopvacc
