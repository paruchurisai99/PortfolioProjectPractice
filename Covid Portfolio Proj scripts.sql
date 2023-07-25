--Exec sp_help covidvaccinations;
--Exec sp_help coviddeaths;

Select *
From PortfolioProj_Covid..CovidVaccinations
Where continent is not null
Order by 3,4;

-- Total cases vs Total Deaths % of people
-- Shows likelihood of dying if you conrtact covid in your country
Select location, date, population,
total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_diff
From PortfolioProj_Covid..CovidDeaths
WHERE location like 'India' and continent is not null
Order by 1,2;


--Total Cases vs Population  % of population died by covid                                                                                                                                                                                                                                                                                                                                                                                                                                       
Select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentCovid
From PortfolioProj_Covid..CovidDeaths
WHERE location like 'India' and continent is not null
Order by 1,2;

--Countries with highest % of Covid cases based on population
Select location, population, MAX(total_cases) as TotalCases, MAX((total_cases/population))*100 as PopulationPercentcovid
From PortfolioProj_Covid..CovidDeaths
--WHERE location like 'India' and continent is not null
Group by location, population
Order by 4 desc;

--Locations with Highest Death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProj_Covid..CovidDeaths
where continent is null
Group by location
Order by TotalDeaths desc;

--Breaking things down by continent

--Continents with Highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProj_Covid..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeaths desc;

-- Global Num's
Select date, SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths,
SUM(cast(new_Deaths as int))/SUM(new_cases) * 100 as DeathPercent
From PortfolioProj_Covid..CovidDeaths
--Where location like 'India'
Where continent is not null 
Group by date
Order by 1,2;

Select SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths,
SUM(cast(new_Deaths as int))/SUM(new_cases) * 100 as DeathPercent
From PortfolioProj_Covid..CovidDeaths
--Where location like 'India'
Where continent is not null 
--Group by date
Order by 1,2;

-- Joins

Select dth.continent, dth.location, dth.date, dth.population, cast(cvac.new_vaccinations as int) as new_vaccinations,
SUM(Convert(int,cvac.new_vaccinations)) OVER (Partition by dth.location Order by dth.location, dth.date) as Rollpeoplevaccinated
FROM PortfolioProj_Covid..CovidDeaths dth
JOIN PortfolioProj_Covid..CovidVaccinations cvac
	On dth.location = cvac.location
	and dth.date = cvac.date
Where dth.continent is not null
Order by 2,3;

-- Using CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, Rollpeoplevaccinated)
as
(
	Select dth.continent, dth.location, dth.date, dth.population, cast(cvac.new_vaccinations as int) as new_vaccinations,
	SUM(cast(cvac.new_vaccinations as int)) OVER (Partition by dth.location Order by dth.location, dth.date) as Rollpeoplevaccinated
	FROM PortfolioProj_Covid..CovidDeaths dth
	JOIN PortfolioProj_Covid..CovidVaccinations cvac
		On dth.location = cvac.location
		And dth.date = cvac.date
	Where dth.continent is not null
	--Order by 2,3;
)
Select *, (Rollpeoplevaccinated/population)*100 as DeathPercent
From PopvsVac


--Creating Views for later visualizations
Create View PercentPopulationVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, cast(cvac.new_vaccinations as int) as new_vaccinations,
	SUM(cast(cvac.new_vaccinations as int)) OVER (Partition by dth.location Order by dth.location, dth.date) as Rollpeoplevaccinated
	FROM PortfolioProj_Covid..CovidDeaths dth
	JOIN PortfolioProj_Covid..CovidVaccinations cvac
		On dth.location = cvac.location
		And dth.date = cvac.date
	Where dth.continent is not null
	--Order by 2,3;

