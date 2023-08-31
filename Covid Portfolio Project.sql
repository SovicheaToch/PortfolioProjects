Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidData
order by 1,2

-- Total Deaths vs Total Cases
-- Shows likelyhood of dying if you are infected in Cambodia
Select location, date, total_cases, total_deaths,
(convert(float, total_deaths)/convert(float, total_cases))*100 as DeathPercentage
From PortfolioProject..CovidData
Where location like 'Cambodia'
order by 1,2

-- Total Cases vs Population
-- Shows percentage of population that got covid in United States
Select location, date, total_cases, population,
(convert(float, total_cases)/convert(float, population))*100 as InfectionRate
From PortfolioProject..CovidData
Where location like 'United States'
order by 1,2

-- Countries with Highest Total Cases
Select location, MAX(convert(int, total_cases)) as HighestTotalCases
From PortfolioProject..CovidData
Where continent is not nULL
Group by location
Order by HighestTotalCases desc 

-- Countries with Highest Death Counts

Select location, MAX(convert(int, total_deaths)) as HighestTotalDeaths
From PortfolioProject..CovidData
Where continent is not nULL
Group by location
Order by HighestTotalDeaths desc

-- Countries with Highest Death Count per Population

Select location, MAX(convert(int, total_deaths)) as HighestTotalDeath,
population, MAX((convert(float, total_deaths)/convert(float, population))) as DeathCountPerPopulation
From PortfolioProject..CovidData
Group by location, population
order by DeathCountPerPopulation desc

-- Countries with Highest Infection Rates
Select location, MAX(convert(int, total_cases)), population,
MAX((convert(float, total_cases)/convert(float, population))*100) as InfectionRate
From PortfolioProject..CovidData
Group by location, population
order by InfectionRate desc

-- Overview of Covid Data by Continents
Select location, population, MAX(cast(total_cases as int)) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths,
MAX(cast(total_deaths as int))/MAX(cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidData
Where continent is null AND location not like '%income%'
Group by location, population
order by population desc

-- Total Vaccinations Given in Cambodia over time
Select location, date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) over (partition by location order by date) as TotalVaccinationsGiven
From PortfolioProject..CovidData
Where location = 'Cambodia'
order by location

-- Shows total vaccinations given over population in the US
-- Use CTE
With CTE_VacData as (
Select location, date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) over (partition by location order by date) as TotalVaccinationsGiven
From PortfolioProject..CovidData
)
Select *, (cast(TotalVaccinationsGiven as float)/cast(population as float)) as VaccinationsGivenPerPopulation
From CTE_VacData
Where location = 'United States'

--Use temp table
Drop table if exists #tempVacData
Create Table #tempVacData (
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
TotalVaccinationsGiven numeric
)

Insert into #tempVacData
Select location, date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) over (partition by location order by date) as TotalVaccinationsGiven
From PortfolioProject..CovidData

Select *, (cast(TotalVaccinationsGiven as float)/cast(population as float)) as VaccinationsGivenPerPopulation
From #tempVacData
Where location = 'United States'

-- Create view for visualizations
Create View CovidVaccinationData as
Select location, date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) over (partition by location order by date) as TotalVaccinationsGiven
From PortfolioProject..CovidData
Where continent is not null

Select *
From CovidVaccinationData