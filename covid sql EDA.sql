SELECT TOP 5 *
FROM [;PortfolioProject]..covidDeaths

--SELECT TOP 5 *
--FROM [;PortfolioProject]..covidVaccine

--SELECT location, date, total_cases,new_cases, total_deaths, population_density
--FROM [;PortfolioProject]..covidDeaths
--ORDER BY 1,2

DROP TABLE IF EXISTS #tempDeaths
SELECT * INTO #tempDeaths
FROM [;PortfolioProject]..covidDeaths
WHERE total_cases != 0 and new_cases !=0


SELECT location, date, total_cases,new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM #tempDeaths
WHERE location LIKE 'Nigeria%'
ORDER BY 1,2

SELECT location, MAX(total_deaths) AS MaxDeaths
FROM #tempDeaths
where continent is not null
GROUP BY location
ORDER BY MaxDeaths DESC

SELECT date, SUM(new_cases) AS casesPerDay, SUM(new_deaths) AS deathPerDay,(SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM #tempDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

CREATE VIEW PercentageVaccinated as
WITH POPVSVAC (Continent, Location, Date, Population, New_Vaccination, People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations))
OVER (partition by dea.location order by dea.location, dea.date) as peopleVaccinated
from [;PortfolioProject]..covidDeaths dea
join [;PortfolioProject]..covidVaccine vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null 
)

SELECT *, (People_Vaccinated/Population)*100 as Percentage_Vaccinated
FROM POPVSVAC
