
Select *
From [Portfolio Project]..['covid deaths$']
where continent is not null
order by 3,4



Select *
From [Portfolio Project]..['covid vaccinations$']
order by 3,4


-- selecting the data that I want to use

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..['covid deaths$']
order by 1,2



-- total cases vs total deaths
-- shows the liklihood of dying of contracting covid in the various country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
From [Portfolio Project]..['covid deaths$']
where Location like '%states%'
order by 1,2

--total cases vs population
-- shows who got it

Select Location, date, Population, total_cases, (total_cases/Population)*100 as percentofpopinfected
From [Portfolio Project]..['covid deaths$']
--where Location like '%states%'
order by 1,2


--countries with highest counry rate per population

Select Location, Population, MAX(total_cases) as highestinfectioncount, Max((total_cases/Population))*100 as percentofpopinfected
From [Portfolio Project]..['covid deaths$']
--where Location like '%states%'
group by Location, Population
order by percentofpopinfected desc

--countires with the highest death count per pop


Select Location, MAX(cast(Total_deaths as int)) as totaldeathcount
From [Portfolio Project]..['covid deaths$']
--where Location like '%states%'
where continent is not null
group by Location 
order by totaldeathcount desc


-- lets break it by continent

Select location, MAX(cast(Total_deaths as int)) as totaldeathcount
From [Portfolio Project]..['covid deaths$']
--where Location like '%states%'
where continent is null
group by location
order by totaldeathcount desc

-- global numbers

Select date, Sum(new_cases) as totalcases, Sum(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
From [Portfolio Project]..['covid deaths$']
where continent is not null 
group by date
order by 1,2


Select Sum(new_cases) as totalcases, Sum(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
From [Portfolio Project]..['covid deaths$']
where continent is not null 
--group by date
order by 1,2


--tables joined
select *
from [Portfolio Project] .. ['covid deaths$'] 
join [Portfolio Project] .. ['covid vaccinations$'] 
	On ['covid deaths$'].location = ['covid vaccinations$'].location
	and ['covid deaths$'].date = ['covid vaccinations$'].date


-- total pop vs vacc
select ['covid deaths$'].continent, ['covid deaths$'].location, ['covid deaths$'].date, ['covid vaccinations$'].new_vaccinations
from [Portfolio Project] .. ['covid deaths$'] 
join [Portfolio Project] .. ['covid vaccinations$'] 
	On ['covid deaths$'].location = ['covid vaccinations$'].location
	and ['covid deaths$'].date = ['covid vaccinations$'].date
where ['covid deaths$'].continent is not null
order by 2,3


-- new vaccinations added on each time

select ['covid deaths$'].continent, ['covid deaths$'].location, ['covid deaths$'].population, ['covid deaths$'].date, ['covid vaccinations$'].new_vaccinations
, SUM(Cast(['covid vaccinations$'].new_vaccinations as int)) Over (Partition by ['covid deaths$'].location order by ['covid deaths$'].location, 
['covid deaths$'].date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from [Portfolio Project] .. ['covid deaths$'] 
join [Portfolio Project] .. ['covid vaccinations$'] 
	On ['covid deaths$'].location = ['covid vaccinations$'].location
	and ['covid deaths$'].date = ['covid vaccinations$'].date
where ['covid deaths$'].continent is not null
order by 2,3


-- Use CTE

with PopvsVac (Continent, location, date, Population,new_vaccinations, rollingpeoplevaccinated)
as
(select ['covid deaths$'].continent, ['covid deaths$'].location, ['covid deaths$'].date,['covid deaths$'].population, ['covid vaccinations$'].new_vaccinations
, SUM(Cast(['covid vaccinations$'].new_vaccinations as int)) Over (Partition by ['covid deaths$'].location order by ['covid deaths$'].location, 
['covid deaths$'].date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from [Portfolio Project] .. ['covid deaths$'] 
join [Portfolio Project] .. ['covid vaccinations$'] 
	On ['covid deaths$'].location = ['covid vaccinations$'].location
	and ['covid deaths$'].date = ['covid vaccinations$'].date
where ['covid deaths$'].continent is not null
--order by 2,3
)

Select*, (rollingpeoplevaccinated/population)*100
From PopvsVac


-- creating view to store data for later visualization

create view globalnumber as
Select date, Sum(new_cases) as totalcases, Sum(cast(new_deaths as int)) as totaldeaths, Sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
From [Portfolio Project]..['covid deaths$']
where continent is not null 
group by date
--order by 1,2
 


create view PopvsVac1 as 
select ['covid deaths$'].continent, ['covid deaths$'].location, ['covid deaths$'].date,['covid deaths$'].population, ['covid vaccinations$'].new_vaccinations
, SUM(Cast(['covid vaccinations$'].new_vaccinations as int)) Over (Partition by ['covid deaths$'].location order by ['covid deaths$'].location, 
['covid deaths$'].date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from [Portfolio Project] .. ['covid deaths$'] 
join [Portfolio Project] .. ['covid vaccinations$'] 
	On ['covid deaths$'].location = ['covid vaccinations$'].location
	and ['covid deaths$'].date = ['covid vaccinations$'].date
where ['covid deaths$'].continent is not null
--order by 2,3


select *
from PopvsVac1