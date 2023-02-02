--- This is the data  fetched from https://ourworldindata.org/covid-deaths

select *
from Project1..CovidDeaths$
order by 3,4

select * 
from Project1..CovidVaccination$
order by 3,4


--Need to select the data which will be used for analysis 

select continent , location , date ,population ,total_cases , total_deaths
from Project1..CovidDeaths$
where continent is not null
order by 1,2

-- What is the percentage of people dying in India who were  infected 

select continent , location , date ,population ,total_cases , total_deaths , (total_deaths /total_cases)*100 as DeathRatePerCase
from Project1..CovidDeaths$
where continent is not null and location like '%India'
order by 1,2 ,DeathRatePerCase

---Death rate might be  high because of low cases 

----country having maximum of total cases

select  location ,population, max(total_cases) as highe , Max((total_cases/population))*100 as TotalPopulationInfected
from Project1..CovidDeaths$ 
---where date between '2020-01-28' and '2021-04-30'
--where location like 'India%'
group by  location,population

ORDER BY TotalPopulationInfected  DESC


----Country wise Highest death count 
----Total death data relly matches with googole data 

select location,population,max(CAST(total_deaths AS int)) AS DEATHS
from Project1..CovidDeaths$
WHERE continent IS NOT NULL
----ADD WHERE CONTINENT IS NOT NULL 
---WHERE LOCATION LIKE '%INDIA%'
group by location ,population
order by DEATHS desc



----Continet wise highest death count 


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From Project1..CovidDeaths$
Where continent is not null 
Group by continent 
order by TotalDeathCount desc


-------------------------------------------- Total Global numbers---------

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project1..CovidDeaths$
--Where location like '%India%'
where continent is not null 
--Group By date
order by 1,2


------------------------------------------------------------------------------
--With table CovidVaccination
-----Total Population vaccinated ------------



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths$ dea
Join Project1..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--- Not working 

----learn about this 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths$ dea
Join Project1..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths$ dea
Join Project1..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 