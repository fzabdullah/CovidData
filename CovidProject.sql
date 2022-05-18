# Covid deaths have reached 1 million in the United States. This short project explores data for covid cases up until 5/16/2022.

use portfolioproject;

# Allow for load infile:

show variables like 'local_infile';

# It is showing as off, so turn it on:

SET GLOBAL local_infile=1;

# Check that it is on:

show variables like 'local_infile';

# Good. It is.

# Now create table for covid_vaccinations data:

DROP TABLE IF EXISTS covid_vaccinations;

CREATE TABLE covid_vaccinations (
    iso_code VARCHAR(8) DEFAULT NULL,
    continent VARCHAR(13) DEFAULT NULL,
    location VARCHAR(56) DEFAULT NULL,
    date DATE DEFAULT NULL,
    new_tests INT DEFAULT NULL,
    total_tests INT DEFAULT NULL,
    total_tests_per_thousand FLOAT DEFAULT NULL,
    new_tests_per_thousand FLOAT DEFAULT NULL,
    new_tests_smoothed INT DEFAULT NULL,
    new_tests_smoothed_per_thousand FLOAT DEFAULT NULL,
    positive_rate FLOAT DEFAULT NULL,
    tests_per_case FLOAT DEFAULT NULL,
    tests_units VARCHAR(20) DEFAULT NULL,
    total_vaccinations INT DEFAULT NULL,
    people_vaccinated INT DEFAULT NULL,
    people_fully_vaccinated INT DEFAULT NULL,
    total_boosters INT DEFAULT NULL,
    new_vaccinations INT DEFAULT NULL,
    new_vaccinations_smoothed INT DEFAULT NULL,
    total_vaccinations_per_hundred FLOAT DEFAULT NULL,
    people_vaccinated_per_hundred FLOAT DEFAULT NULL,
    people_fully_vaccinated_per_hundred FLOAT DEFAULT NULL,
    total_boosters_per_hundred FLOAT DEFAULT NULL,
    new_vaccinations_smoothed_per_million INT DEFAULT NULL,
    new_people_vaccinated_smoothed INT DEFAULT NULL,
    new_people_vaccinated_smoothed_per_hundred FLOAT DEFAULT NULL,
    stringency_index FLOAT DEFAULT NULL,
    population INT DEFAULT NULL,
    population_density FLOAT DEFAULT NULL,
    median_age FLOAT DEFAULT NULL,
    aged_65_older FLOAT DEFAULT NULL,
    aged_70_older FLOAT DEFAULT NULL,
    gdp_per_capita FLOAT DEFAULT NULL,
    extreme_poverty FLOAT DEFAULT NULL,
    cardiovasc_death_rate FLOAT DEFAULT NULL,
    diabetes_prevalence FLOAT DEFAULT NULL,
    female_smokers FLOAT DEFAULT NULL,
    male_smokers FLOAT DEFAULT NULL,
    handwashing_facilities FLOAT DEFAULT NULL,
    hospital_beds_per_thousand FLOAT DEFAULT NULL,
    life_expectancy FLOAT DEFAULT NULL,
    human_development_index FLOAT DEFAULT NULL,
    excess_mortality_cumulative_absolute FLOAT DEFAULT NULL,
    excess_mortality_cumulative FLOAT DEFAULT NULL,
    excess_mortality FLOAT DEFAULT NULL,
    excess_mortality_cumulative_per_million FLOAT DEFAULT NULL
);

# Avoid using Data Import Wizard, and import data via local infile:

load data local infile '/Users/faisal/Desktop/Portfolio Projects/Covid_Vaccinations_2_20_2020_to_5_17_2022.csv' INTO TABLE covid_vaccinations
fields terminated by ','
ignore 1 rows;

UPDATE covid_vaccinations SET continent=NULL where continent='';

SELECT 
    *
FROM
    covid_vaccinations
LIMIT 10;

# Create table for covid_deaths data:

DROP TABLE IF EXISTS covid_deaths;

CREATE TABLE covid_deaths (
    iso_code VARCHAR(8) DEFAULT NULL,
    continent VARCHAR(13) DEFAULT NULL,
    location VARCHAR(56) DEFAULT NULL,
    date DATE DEFAULT NULL,
    population INTEGER DEFAULT NULL,
    total_cases INTEGER DEFAULT NULL,
    new_cases INTEGER DEFAULT NULL,
    new_cases_smoothed FLOAT DEFAULT NULL,
    total_deaths INTEGER DEFAULT NULL,
    new_deaths INTEGER DEFAULT NULL,
    new_deaths_smoothed FLOAT DEFAULT NULL,
    total_cases_per_million FLOAT DEFAULT NULL,
    new_cases_per_million FLOAT DEFAULT NULL,
    new_cases_smoothed_per_million FLOAT DEFAULT NULL,
    total_deaths_per_million FLOAT DEFAULT NULL,
    new_deaths_per_million FLOAT DEFAULT NULL,
    new_deaths_smoothed_per_million FLOAT DEFAULT NULL,
    reproduction_rate FLOAT DEFAULT NULL,
    icu_patients INTEGER DEFAULT NULL,
    icu_patients_per_million FLOAT DEFAULT NULL,
    hosp_patients INTEGER DEFAULT NULL,
    hosp_patients_per_million FLOAT DEFAULT NULL,
    weekly_icu_admissions INTEGER DEFAULT NULL,
    weekly_icu_admissions_per_million FLOAT DEFAULT NULL,
    weekly_hosp_admissions INTEGER DEFAULT NULL,
    weekly_hosp_admissions_per_million FLOAT DEFAULT NULL
);

load data local infile '/Users/faisal/Desktop/Portfolio Projects/Covid_Deaths_2_20_2020_to_5_17_2022.csv' INTO TABLE covid_deaths
fields terminated by ','
ignore 1 rows;

UPDATE covid_deaths 
SET 
    continent = NULL
WHERE
    continent = '';

SELECT 
    *
FROM
    covid_deaths
LIMIT 10;


#Select data for project:

SELECT 
    location,
    continent,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

-- Total death as a percentage of total cases:
-- Shows likelihood of death based on contracting covid, per country

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    CONCAT(ROUND((total_deaths / total_cases) * 100, 2),
            '%') AS percent_deaths_to_cases
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY location , date;


-- Total covid cases relative to population:
-- Shows percentage of population infected with covid

SELECT 
    location,
    date,
    total_cases,
    population,
    CONCAT(ROUND((total_cases / population) * 100, 2),
            '%') AS percent_cases_to_population
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

-- Countries ranked based on infection rate compared to population:

SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    ROUND(MAX((total_cases / population) * 100), 2) AS percent_cases_to_population
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY location , population
ORDER BY percent_cases_to_population DESC;

-- Countries ranked based on death count:

SELECT 
    continent,
    location,
    MAX(total_deaths) AS total_death_count,
    population
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY continent , location , population
ORDER BY total_death_count DESC;

-- Continents ranked based on total death count:
# Nestling a select statement within a select statement

SELECT 
    continent,
    SUM(total_death_count_per_country) AS total_death_count
FROM
    (SELECT 
        continent,
            location,
            MAX(total_deaths) AS total_death_count_per_country
    FROM
        covid_deaths
    WHERE
        continent IS NOT NULL
    GROUP BY continent , location) AS top_countries_death
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global numbers, per day

SELECT 
    date,
    SUM(new_cases) AS total_new_cases_global,
    SUM(new_deaths) AS total_new_deaths_global,
    ROUND(SUM(new_deaths) / SUM(new_cases) * 100,
            2) AS global_deaths_per_cases
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY date
ORDER BY 1;

-- Global numbers, total

SELECT 
    SUM(new_cases) AS total_cases_global,
    SUM(new_deaths) AS total_deaths_global,
    ROUND(SUM(new_deaths) / SUM(new_cases) * 100,
            2) AS global_deaths_per_cases
FROM
    covid_deaths
WHERE
    continent IS NOT NULL;


-- New vaccinations, by country:
# Using Common Table Expressions (CTE) [making a table that can be used elsewhere in the same query]


With PopVsVac (continent, location, date, population, new_vaccination, rolling_sum_vaccinations) as 
(SELECT 
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(new_vaccinations) OVER(Partition by d.location ORDER BY d.location, d.date) as rolling_sum_vaccinations
FROM
    covid_deaths d
        JOIN
    covid_vaccinations v ON d.location = v.location
        AND d.date = v.date
WHERE
    d.continent IS NOT NULL)
#The below is from the same querry, but will select from the above pre-set table
SELECT *, ROUND((rolling_sum_vaccinations/population)*100, 2) as percentage_vaccinated FROM PopVsVac;


### Doing the same as above, except with an alternative method, using a Temporary Table:
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated (
	Continent VARCHAR(255),
    location VARCHAR(255),
    Date DATE,
    population INTEGER,
    new_vaccinations INTEGER,
    rolling_sum_vaccinations FLOAT
);

INSERT INTO PercentPopulationVaccinated
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(new_vaccinations) OVER(Partition by d.location ORDER BY d.location, d.date) as rolling_sum_vaccinations
FROM
    covid_deaths d
        JOIN
    covid_vaccinations v ON d.location = v.location
        AND d.date = v.date
WHERE
    d.continent IS NOT NULL;

SELECT *, ROUND((rolling_sum_vaccinations/population)*100, 2) as percentage_vaccinated FROM PercentPopulationVaccinated;

-- Create View of the prior table for later data visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(new_vaccinations) OVER(Partition by d.location ORDER BY d.location, d.date) as rolling_sum_vaccinations
FROM
    covid_deaths d
        JOIN
    covid_vaccinations v ON d.location = v.location
        AND d.date = v.date
WHERE
    d.continent IS NOT NULL;