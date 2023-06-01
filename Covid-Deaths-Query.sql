select * from CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3, 4

select * from CovidVaccinations
WHERE continent is NOT NULL
ORDER BY 3, 4

--The data that I am using is as shown below

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
ORDER BY 1, 2

-- Looking at total cases versus total deaths and the percentage of total deaths from the cases recorded
-- Shows likelihood of dying if you contract covid in Africa

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_percentage
from CovidDeaths
WHERE location like '%africa%'
ORDER BY 1, 2

-- Looking at total cases versus total population
--Shows the percentage of the population that has contracted covid in Africa

select location, date, population, total_cases, (total_cases/population)*100 AS covid_contraction_percentage
from CovidDeaths 
WHERE location like '%africa%' 
ORDER BY 1, 2

--Looking at countries with the highest infection rate compared to population
select location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percentage_of_infected_population
from CovidDeaths 
--WHERE location like '%africa%'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY percentage_of_infected_population DESC


--Looking at continents with the highest death count 
select continent, MAX(cast(total_deaths as int)) AS total_death_count
from CovidDeaths 
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

select location, MAX(cast(total_deaths as int)) AS total_death_count
from CovidDeaths 
WHERE continent is NULL
GROUP BY location
ORDER BY total_death_count DESC


--Looking at the countries with the highest death count 
select location, MAX(cast(total_deaths as int)) AS total_death_count
from CovidDeaths 
WHERE continent is NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

--Looking at country (Kenya's) total death count
select location, MAX(cast(total_deaths as int)) AS total_death_count
from CovidDeaths 
WHERE location like '%kenya%' 
GROUP BY location
ORDER BY total_death_count 


-- A LOOK AT GLOBAL NUMBERS
-- Shows the total covid cases, total deaths and death percentage in the world by date
 select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
 SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as death_percentage
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY date
 ORDER BY 1,2

 --Shows the total covid cases, total deaths and death percentage in the world
 select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
 SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as death_percentage
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 ORDER BY 1,2

 ----------------------------------------------------------------------------------------------------------
-- COVID VACCINATIONS
 select * from CovidVaccinations

-- Joining both the covid deaths table and the covid vaccinations table
select * from CovidVaccinations AS vacc
JOIN
CovidDeaths AS dea
ON dea.location = vacc.location
and dea.date = vacc.date


-- GLOBAL NUMBERS
-- Looking at total population against vaccinations
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(INT, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
--OR
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using a CTE

WITH covid_CTE (continent, location, date, population, new_vaccinations, sum_of_new_vaccinations)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
)
select * , (sum_of_new_vaccinations / population) * 100  AS vaccinated_population_percentage from covid_CTE

-- Temp Table

DROP TABLE IF EXISTS #vaccinated_population_percentage
 create table #vaccinated_population_percentage
 (
 continent nvarchar (255),
 location nvarchar (255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 sum_of_new_vaccinations numeric
 )
 insert into #vaccinated_population_percentage
 select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL

select * , (sum_of_new_vaccinations / population) * 100  AS vaccinated_population_percentage from #vaccinated_population_percentage


-- Creating a View
create view vaccinated_population_percentage
AS
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(INT, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_of_new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vacc
ON dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL


select * from vaccinated_population_percentage