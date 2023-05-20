--select * from Project2..CovidDeaths$
select Location, date, total_cases, new_cases,total_deaths, population
from Project2..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying
--select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from Project2..CovidDeaths$
--where location like '%states%'
--order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of Population has gotten Covid
select Location, date, total_cases, Population, (total_cases/Population)*100 as DeathPercentage
from Project2..CovidDeaths$
--where location like '%states%'
order by 1,2

--Looking at countries with Highest infection rate compared to population

select Location, MAX(total_cases) as HighestInfectionCount, Population, MAX(total_cases/Population)*100 as PercentPopulationInfected
from Project2..CovidDeaths$
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--This is showing the countries with the highest death count per population
--Use "cast" to convert to Integer because the data type was observed to be NVCHAR
--Where Location id not null was introduced to remove the continents

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount, Population, MAX(total_cases/Population)*100 as PercentPopulationInfected
from Project2..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by Location, Population
order by TotalDeathCount desc

--BY CONTINENT

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Project2..CovidDeaths$
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Project2..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing the Continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Project2..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, Sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Project2..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by date
order by 1,2


select Sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Project2..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

select * from Project2..CovidVaccinations$

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

select * from Project2..CovidDeaths$ dea 
join Project2..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
-- or sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
from Project2..CovidDeaths$ dea 
join Project2..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent,location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
-- or sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
from Project2..CovidDeaths$ dea 
join Project2..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100 from PopvsVac

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
-- or sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
from Project2..CovidDeaths$ dea 
join Project2..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select * , (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
-- or sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
from Project2..CovidDeaths$ dea 
join Project2..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
