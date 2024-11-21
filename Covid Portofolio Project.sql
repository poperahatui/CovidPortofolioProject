
SELECT *
From PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

SELECT *
From PortofolioProject..CovidVaccinations
order by 3,4

-- select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_tests, population
From PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- looking at total cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
From PortofolioProject..CovidDeaths
order by 1,2

-- looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfection
From PortofolioProject..CovidDeaths
Group by location, population
order by HighestInfection desc

-- showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- showing continent with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Global numbers per day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as GrowthPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, GrowthPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as GrowthPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select * ,(GrowthPeopleVaccinated/Population)*100 as Percentage
From PopvsVac


-- Temp Table

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
GrowthPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as GrowthPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select * ,(GrowthPeopleVaccinated/Population)*100 as Percentage
From #PercentPopulationVaccinated


-- Create View to store data

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location Order by dea.location, dea.date) as GrowthPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated