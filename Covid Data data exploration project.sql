/*
Tyler Braxton
Description: Date exploration of Covid Data 
*/

-- SELECT data that we are going to be using 

SELECT  
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM    
    CovidDeaths
ORDER BY
    1, 2;
    
    
-- Looking at total cases vs total deaths as a percentage in the US
-- Gives a rough estimate of dying from covid in your country

SELECT  
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS deathpercentage
FROM    
    CovidDeaths
WHERE
    location LIKE '%states%'
ORDER BY
    1, 2;
    

-- Looking at total cases vs population in the US
-- Shows the percentage of population that got covid 
SELECT  
    location,
    date,
    total_cases,
    population,
    (total_cases / population) * 100 AS covidpopulation
FROM    
    CovidDeaths
WHERE
    location LIKE '%states%'
ORDER BY
    1, 2;
    

-- Looking at countries with highest infection rate compared to population

SELECT  
    location,
    population,
    MAX(total_cases) AS highestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM    
    CovidDeaths
GROUP BY
    location,
    population
ORDER BY
    PercentPopulationInfected DESC;
    
-- Looking for countries with highest death count per country

SELECT  
    location,
    MAX(cast(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM    
    CovidDeaths
WHERE
    continent IS NOT null
GROUP BY
    location
ORDER BY
    TotalDeathCount DESC;
    

-- Breaking things down by continent
    
    
-- Showing continents with the highest death count per population

SELECT  
    continent,
    MAX(cast(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM    
    CovidDeaths
WHERE
    continent IS NOT null
GROUP BY
    continent
ORDER BY
    TotalDeathCount DESC;
    
-- Looking at continents with highest infection rate compared to population

SELECT  
    continent,
    population,
    MAX(total_cases) AS highestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM    
    CovidDeaths
WHERE
    continent IS NOT null
GROUP BY
    continent,
    population
ORDER BY
    PercentPopulationInfected DESC;
    

-- Global Numbers

-- Showing the death percentage, total # of cases and total # of deaths by a daily basis

SELECT
    date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_cases) / SUM(total_deaths) * 100 AS DeathPercentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY 
    1, 2;
    

-- Looking at total population vs vaccinations 
-- Shows the n of people that have been vaccinated compared to the population 
-- Created a CTE because we cannot divide a coloumn that was just created
-- Need to match the number of columns in CTE with the number of columns within the statement
-- Cannot have order by in CTE 
 WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 

(
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(v.new_vaccinations) OVER (Partition BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM
    CovidDeaths d 
JOIN 
    CovidVaccination v 
ON 
    d.location = v.location AND d.date = v.date
WHERE
    d.continent IS NOT NULL
)

SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS VaccinatedPercentage
FROM
    PopVsVac
ORDER BY
    2, 3;



-- Lets take a look at the Covid Vaccination data 

SELECT
    *
FROM
    CovidVaccination;
    
-- People fully vaccinated vs population 

-- Input: location, date, people full vaccinated, population
-- Output: shows the % of people being fully vaccinated compared to its population 

WITH CTE (location, date, population, people_fully_vaccinated, FullyVacPercent)
AS (
SELECT
    d.location,
    d.date,
    d.population,
    v.people_fully_vaccinated,
    round((v.people_fully_vaccinated / d.population),4) * 100 AS FullyVacPercent
FROM
    CovidDeaths d 
JOIN
    CovidVaccination v 
ON 
    d.location = v.location and d.date = v.date
)

SELECT
    *
FROM
    CTE 
WHERE
    FullyVacPercent != 0
ORDER BY
    1, 2 DESC; 
    
    
-- Highest Vac amount by date 

SELECT
    location,
    date, 
    MAX(total_vaccinations) AS HighestVacAmount
FROM
    CovidVaccination
GROUP BY 
    location,
    date 
HAVING
    HighestVacAmount
ORDER BY
    1, 2 DESC;
    
    
-- Average positive rate for each country

SELECT
    location,
    AVG(positive_rate) * 100  AS AvgPosRate
FROM
    CovidVaccination
GROUP BY
    location
ORDER BY
    AvgPosRate DESC;
    


--  Average weekly icu admissions for countries by date 

SELECT
    location,
    date,
    AVG(weekly_icu_admissions) AS AvgWeekIcu 
FROM
    CovidDeaths
GROUP BY
    location, 
    date
HAVING
    AvgWeekIcu > 0
ORDER BY
    location,
    date DESC;
    
    
-- Average weekly hopsital admissions for countries by date 

SELECT
    location,
    date,
    AVG(weekly_hosp_admissions) AS AvgWeekHosp 
FROM
    CovidDeaths
GROUP BY
    location, 
    date
HAVING
    AvgWeekHosp > 0
ORDER BY
    location,
    date DESC;
    
    
-- Average number of icu patients by age 

SELECT
    d.location, 
    v.median_age,
    AVG(d.icu_patients) AS AvgIcuPat
FROM
    CovidDeaths d 
JOIN
    CovidVaccination v 
ON 
    d.location = v.location and d.date = v.date 
GROUP BY
    d.location,
    v.median_age
ORDER BY
    AvgIcuPat DESC;
    
    
    
    


   
    


    

