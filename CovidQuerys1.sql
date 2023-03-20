SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
order by 3,4
--SELECT *
--FROM CovidVaccinations$
--order by 3,4


--Seleccionar la data que usaremos
SELECT location, date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths$
order by 1,2

-- Probabilidad de morir si te contagias de covid en Perú
SELECT location, date, total_cases, total_deaths,
CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%peru%'
ORDER BY 1, 2

--Porcentaje de población infectada día a día en Perú
SELECT location, date, population,total_cases, 
CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%peru%'
ORDER BY 1, 2

--País con mayor cantidad de infectados por población
SELECT location, population,max(total_cases) as HighestInfectionCount,
MAX(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--País con mayor cantidad de muertos por población
SELECT location,max(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--POR CONTINENTE

--Cantidad de muertos por continente
SELECT continent,max(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--NUMEROS GLOBALES

--Casos y Muertos por día
SELECT date, SUM(new_cases) as New_cases, sum(new_deaths) as New_Deaths,
sum(CAST(new_deaths AS FLOAT))/nullif(sum(CAST(new_cases AS FLOAT)),0)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--Casos y Muertos Totales
SELECT SUM(new_cases) as New_cases, sum(new_deaths) as New_Deaths,
sum(CAST(new_deaths AS FLOAT))/nullif(sum(CAST(new_cases AS FLOAT)),0)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2


SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations as bigint)) OVER (Partition  by d.location Order by d.location, d.date) as Acc_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccinations$ v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
order by 2,3

--CTE (Common Table Expression)

With PopvsVac (Continent, Location, Date, Population, New_Vaccionations, Acc_People_Vaccinated)
as
(SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations as bigint)) OVER (Partition  by d.location Order by d.location, d.date) as Acc_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccinations$ v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
)
SELECT *, (Acc_People_Vaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP TABLE IF  exists #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Acc_People_Vaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations as bigint)) OVER (Partition  by d.location Order by d.location, d.date) as Acc_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccinations$ v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null

SELECT *, (Acc_People_Vaccinated/Population)*100
From #PercentPopulationVaccinated


-- CREAR VISTA
CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CAST(v.new_vaccinations as bigint)) OVER (Partition  by d.location Order by d.location, d.date) as Acc_People_Vaccinated
FROM PortfolioProject..CovidDeaths$ d
JOIN PortfolioProject..CovidVaccinations$ v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null


