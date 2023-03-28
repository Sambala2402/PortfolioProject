select * from PortfolioProject..CovidDeaths
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

-- select Data that we are going to use


select location,date,total_cases,new_cases,total_deaths 
from PortfolioProject..CovidDeaths 
order by 1,2


--Looking at total deaths vs total cases

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2


--Lookig at the total cases vs populAtion
--shows what percentage of population got covid

select location,date,total_cases,population,(total_cases/population)*100 as casesaffected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--what country has the highest infected rate compared to population

select location,Max(total_cases) as highlyinfected, population,Max((total_cases/population))*100 as casesaffected
from PortfolioProject..CovidDeaths
--where location like '%India%'
group by location,population
order by casesaffected desc

--showing countries with hiighest death count per population

select location,Max(cast(total_deaths as int)) as totaldeathcount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc

--break things by continent

select location,Max(cast(total_deaths as int)) as totaldeathcount 
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by totaldeathcount desc

--showing continent with hiighest death count per population

select continent,Max(cast(total_deaths as int)) as totaldeathcount 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

--calculate complete world records

select sum(new_cases),SUM(cast(new_deaths as int)),
SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercent
--total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpecent
from PortfolioProject..CovidDeaths
where continent is not null
--group by date,total_cases,total_deaths
order by 1,2


--Join
--looking at total population vs vaccinations
--convert(int,value)/cast(value as int)
--use cte-common table expression -created a temp table  
--like this
with popvsvacc (continent,location,date,population,new_vaccinations,rollingofpeoplevaccinated) 
as(
select cd.location,cd.continent,cd.date,cd.population,cv.new_vaccinations
,SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,cd.date) as rollingofpeoplevaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject.._xlnm#_FilterDatabase  cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *, (rollingofpeoplevaccinated/population)*100 as populationvaccinated from popvsvacc

--or like this creating a temp table


Drop table if exists PercentageofPeoplevaccinated
Create table PercentageofPeoplevaccinated(
location nvarchar(255),
continent nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingofpeoplevaccinated numeric 
)

insert into PercentageofPeoplevaccinated
select cd.location,cd.continent,cd.date,cd.population,cv.new_vaccinations
,SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,cd.date) as rollingofpeoplevaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject.._xlnm#_FilterDatabase  cv
on cd.location = cv.location 
and cd.date = cv.date

select *, (rollingofpeoplevaccinated/population)*100 as populationvaccinated from PercentageofPeoplevaccinated 


-- create view to store data for later visualization
Drop view  if exists PercentagePeoplevaccinated

create view PercentagePeoplevaccinated as 
select cd.location,cd.continent,cd.date,cd.population,cv.new_vaccinations
,SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location,cd.date) as rollingofpeoplevaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations  cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null

select * from PercentagePeoplevaccinated