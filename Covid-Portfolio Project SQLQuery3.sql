/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select*
From CovidDeaths$
Where continent is not null
Order by 3,4

Select*
From CovidVacinations$
Order by 3,4

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Order by 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows the Percentage rate of dying if you contract Covid in Nigeria

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From CovidDeaths$
Where location like '%Nigeria%'
Order by 1,2

-- Toal Cases vs Population
-- Shows the Percentage rate of Population infected covid

Select location, date, total_cases, population, (total_cases/population)*100 As Percent_Of_Population_Infected
From CovidDeaths$
Where location like '%Nigeria%'
Order by 1,2


-- Countries with Highest Infection Rate Compared to population


Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as Percent_Of_Population_Infected
From CovidDeaths$
--Where location like '%Nigeria%'
Group by location, population
Order by Percent_Of_Population_Infected Desc


-- Countries with Highest Death Count per Population


Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
From CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null 
Group by Location
order by Total_Death_Count desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents With Highest Death-Count Per Popolation

Select continent, Max(Cast(total_deaths as int)) as Total_Death_Count
From CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null
Group by continent
Order by Total_Death_Count Desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From CovidDeaths$
--Where location like '%Nigeria%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as Rolling_People_Vaccinated
--,( Rolling_People_Vaccinated/population)*100
From CovidDeaths$ dea
Join CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, New_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as Rolling_People_Vaccinated
--,( Rolling_People_Vaccinated/population)*100
From CovidDeaths$ dea
Join CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists  #Percentage_of_Population_Vaccinated
Create Table #Percentage_of_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric,
)

Insert into #Percentage_of_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as Rolling_People_Vaccinated
--,( Rolling_People_Vaccinated/population)*100
From CovidDeaths$ dea
Join CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
From #Percentage_of_Population_Vaccinated


-- Creating View to store data for later visualizations

Create View Percentage_of_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as Rolling_People_Vaccinated
--, ( Rolling_People_Vaccinated/population)*100
From CovidDeaths$ dea
Join CovidVacinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

