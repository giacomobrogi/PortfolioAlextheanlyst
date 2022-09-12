select * 
from CovidDeaths
where continent is not null

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2
where continent is not null

-- Looking at total cases vs total deaths 


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where location like '%Ital%' and continent is not null
order by 1,2


-- Looking at total cases vs population
-- Shows what % of popolation got Covid

select location, date,population,  total_cases, (total_cases/population)*100 as Totcases_Percentage
from CovidDeaths
where location like '%Ital%' and continent is not null
order by 1,2



-- looking at countries with highst Infection rate compared to population

select location, population, MAX (total_cases) as HighestInfectionCount,
	   MAX (total_cases/population)*100 as PercentageofPopInfection
from   CovidDeaths
where continent is not null
group by location, population
order by PercentageofPopInfection desc


-- Showing Countries with Highest Death Count per Population

select location, MAX (cast(total_deaths as int)) as totalDeathCount
from   CovidDeaths
where continent is not null
group by location
order by totalDeathCount desc


-- let's break data by continent

select location, MAX (cast(total_deaths as int)) as totalDeathCount
from   CovidDeaths
where continent is null
group by location
order by totalDeathCount desc


-- Showing continents with highest death count per population

select continent, MAX (cast(total_deaths as int)) as totalDeathCount
from   CovidDeaths
where continent is not null
group by continent
order by totalDeathCount desc


--Global numbers

select [date], SUM(new_cases) as total_cases, 
		SUM(cast(new_deaths as int)) as total_deaths, 
		SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
from   CovidDeaths
where continent is not null
group by date
order by 1,2

-- Looking at total population vs vaccination

select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as int)) over (partition by D.location order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from  CovidDeaths as D
JOIN  Covidvac as V
ON    D.location = V.location AND D.date = V.date
where D.continent is not null
order by 2, 3

--use cte

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as int)) over (partition by D.location order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from  CovidDeaths as D
JOIN  Covidvac as V
ON    D.location = V.location AND D.date = V.date
where D.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 
from popvsvac


-- creating view for visualizations

create view PercPopvsvaccinated as
select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as int)) over (partition by D.location order by d.location, d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from  CovidDeaths as D
JOIN  Covidvac as V
ON    D.location = V.location AND D.date = V.date
where D.continent is not null
order by 2, 3