-- EDA
select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM portfolioproject.coviddeaths
-- where location like '%kenya%' 
 where continent is not null and continent <>''  -- some continent fields are either null or blank
order by 1, cast(date as DATE);


 
-- TOTAL DEATHS Vs TOTAL CASES (Likelihood of dying if you contract the virus in Kenya)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM portfolioproject.coviddeaths
-- where location like '%kenya%' 
where continent is not null and continent <>''
order by 1, cast(date as DATE); -- date is stored as text

-- TOTAL CASES vs the POPULATION
-- What percentage of the population contracted COVID?

select location, date, population, total_cases,  (total_cases/population)*100 as percentageofcases
FROM portfolioproject.coviddeaths
-- where location like '%kenya%'
where continent is not null and continent <>''
order by 1, cast(date as DATE);

-- COUNTRIES WITH HIGHEST Infection rate in AFRICA

select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as percentageofinfections
FROM portfolioproject.coviddeaths
where continent like '%africa%' and continent is not null and continent <>''
group by 1,2
order by percentageofinfections desc;

-- HIGHEST DEATHs COUNT per country

select location, max(cast(total_deaths as signed)) as TotalDeathCount -- signed=int
FROM portfolioproject.coviddeaths
where continent <>''
Group by location
order by TotalDeathCount  desc;

--  CONTINENTs with highest death counts

select continent, max(cast(total_deaths as signed)) as TotalDeathCount -- signed=int
FROM portfolioproject.coviddeaths
where continent <>''
Group by continent
order by TotalDeathCount  desc;

-- ACROSS THE WORLD Cases and Deaths 

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, 
sum(cast(new_deaths as signed))/sum(new_cases)*100 as PercentofDeaths
from portfolioproject.coviddeaths
where continent is not null and continent <>''
group by date
order by cast(date as DATE),2;

-- JOIN the VACCINATION TABLE
-- Looking at the total population vaccinated against COVID cumulatively 

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as signed)) OVER (partition by d.location order by d.location, d.date) as runningvaccination_total
FROM portfolioproject.coviddeaths d
JOIN portfolioproject.covidvaccinations v
ON d.location = v.location AND d.date=v.date
where d.continent is not null and d.continent <>'' -- and d.location like '%albania%'
order by d.location, cast(d.date as DATE);

-- VACCINATED POPULATION per country based on new vaccinations

With VaccinatedPop (continent, location, date, population, new_vaccinations, runningvaccination_total)
as (Select d.continent, d.location, d.date as DATE, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as signed)) OVER (partition by d.location order by d.location, d.date) as runningvaccination_total
FROM portfolioproject.coviddeaths d
JOIN portfolioproject.covidvaccinations v
ON d.location = v.location AND d.date=v.date
where d.continent is not null and d.continent <>'' -- and d.location like '%kenya%'
)
select *,(runningvaccination_total/Population)*100 as rollingpercentageVaccinated
from VaccinatedPop;

-- CREATING VIEWS FOR VISUALIZATION
-- A view of vaccinated population percentage 

Create view VaccinatedPopulation as 
With VaccinatedPop (continent, location, date, population, new_vaccinations, runningvaccination_total)
as (Select d.continent, d.location, d.date as DATE, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as signed)) OVER (partition by d.location order by d.location, d.date) as runningvaccination_total
FROM portfolioproject.coviddeaths d
JOIN portfolioproject.covidvaccinations v
ON d.location = v.location AND d.date=v.date
where d.continent is not null and d.continent <>'') 
-- Query data from the view
select *,(runningvaccination_total/Population)*100 as rollingpercentageVaccinated
from VaccinatedPop;

-- A view of covid cases vs deaths

Create view PercentofDeathsPerCases as 
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, 
sum(cast(new_deaths as signed))/sum(new_cases)*100 as PercentofDeaths
from portfolioproject.coviddeaths
where continent is not null and continent <>''
group by date
order by cast(date as DATE),2;





