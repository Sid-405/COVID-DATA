
--COVID DATA

--Exploring Data
--Checking COVID19 Deaths Data
select
*
from
Portfolio_Project..COVID19_Deaths


--Checking COVID19 Vaccination Data
select
*
from
Portfolio_Project..COVID19_Vaccinations


--Selecting important columns needed for analysis

SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM
  Portfolio_Project..COVID19_Deaths
ORDER BY
  1, 2

  
 --Calculations
  --Total Cases vs Total deaths IN Canada
	SELECT
  location,
  date,
  total_cases,
  total_deaths,
  ROUND((total_deaths/total_cases)*100, 2) AS Cal_Percent
FROM
  Portfolio_Project..COVID19_Deaths
WHERE
  location LIKE '%Cana%'

  
  --Percent OF population having  COVID IN Canada
SELECT
  location,
  date,
  total_cases,
  population,
  ROUND((total_cases/population)*100, 2) AS Cal_Percent
FROM
  Portfolio_Project..COVID19_Deaths
WHERE
  location LIKE '%Cana%'

--Highest infection rate compared to population
SELECT
  location,
  population,
  MAX(total_cases) AS Highest_Infection_count,
  MAX(ROUND((total_cases/population)*100, 2)) AS Max_Percent
FROM
  Portfolio_Project..COVID19_Deaths
GROUP BY
  population,
  location
ORDER BY
  Max_Percent DESC 

--Continents with highest death count

SELECT
 continent,
  CAST(MAX(total_deaths) AS int) AS Max_deaths
FROM
  Portfolio_Project..COVID19_Deaths
  where
  continent is not null
GROUP BY
  continent
ORDER BY
  Max_deaths DESC
  
--Countries WITH highest death count per population
SELECT
  location,
  population,
  MAX(CAST(total_deaths AS int)) AS Max_deaths
FROM
  Portfolio_Project..COVID19_Deaths
GROUP BY
  population,
  location
ORDER BY
  Max_deaths DESC

--Global Numbers

SELECT
  date,
  SUM(CAST(new_deaths AS int)) AS Tot_deaths,
  SUM(new_cases) AS Tot_cases,
  ROUND(SUM(CAST(new_deaths AS int))/sum(new_cases) ,2) * 100 as Death_percent

FROM
  Portfolio_Project..COVID19_Deaths
WHERE
continent is not null

GROUP BY
  date
ORDER BY
2,3 DESC

--Total population vs Vaccination

WITH
PopVsVac (Continent, Location, Date, Population, New_vaccinations, People_Vacc_asof_now)
as
(
SELECT
dea.date,
dea.continent,
dea.location,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as People_Vacc_asof_now
FROM
Portfolio_Project..COVID19_Deaths dea
JOIN  Portfolio_Project..COVID19_Vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select
*,
People_Vacc_asof_now/population *100 as Vacc_Percent
from PopVsVac



--TEMP TABLE People Vaccinated as of now

Drop table if exists Portfolio_Project..COVID19_Population_Vaccinated
Create table Portfolio_Project..COVID19_Population_Vaccinated
(
  date datetime,
  continent nvarchar(255),
  location nvarchar(255),
  population bigint,
  new_vaccinations bigint,
  People_Vacc_asof_now bigint
)
insert into Portfolio_Project..COVID19_Population_Vaccinated
SELECT
dea.date,
dea.continent,
dea.location,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as People_Vacc_asof_now
FROM
Portfolio_Project..COVID19_Deaths dea
JOIN  Portfolio_Project..COVID19_Vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


--Creating View 

Create View Percent_people_Vaccinated
As
SELECT
dea.date,
dea.continent,
dea.location,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as People_Vacc_asof_now
FROM
Portfolio_Project..COVID19_Deaths dea
JOIN  Portfolio_Project..COVID19_Vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
