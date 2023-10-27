-- Show the percentage of deaths per case for every entry
SELECT [location],
       [date],
       total_cases,
       total_deaths,
       CONVERT(float, Deaths.total_deaths) / CONVERT(float, Deaths.total_cases) * 100 AS deaths_percentage
FROM PortfolioCovidProject..Deaths
WHERE [location] = 'Portugal'


-- Show the percentage of deaths per case for every Portugal entry
SELECT [location],
       [date],
       total_cases,
       total_deaths,
       CONVERT(float, Deaths.total_deaths) / CONVERT(float, Deaths.total_cases) * 100 AS deaths_percentage
FROM PortfolioCovidProject..Deaths
WHERE [location] = 'Portugal'


-- Show the percentage of population that got COVID for every Portugal entry
SELECT [location],
       [date],
       population,
       total_cases,
       CONVERT(float, Deaths.total_cases) / population * 100 AS cases_percentage
FROM PortfolioCovidProject..Deaths
WHERE [location] = 'Portugal'


-- Show max infection rates per population for every country,
-- ordered by the infection rate
SELECT [location],
       MAX(population) AS total_population,
       MAX(CONVERT(float, Deaths.total_cases)) AS highest_case_number,
       MAX(CONVERT(float, Deaths.total_cases)) / MAX(population) * 100 AS highest_infection_percentage
FROM PortfolioCovidProject..Deaths
GROUP BY [continent], [location]
ORDER BY [highest_infection_percentage] DESC


-- Show highest death count for each country,
-- exclude continents
SELECT [location],
       MAX(population) AS total_population,
       MAX(CONVERT(int, total_deaths)) as max_deaths
FROM PortfolioCovidProject..Deaths
WHERE [continent] is not NULL
GROUP BY continent, [location]
ORDER BY max_deaths DESC


-- Show highest death count for each group of countries reported:
-- continents and income based grouping, plus European Union
SELECT [location],
       MAX(population) as total_population,
       MAX(CONVERT(int, total_deaths)) AS max_deaths
FROM PortfolioCovidProject..Deaths
WHERE continent is NULL
GROUP BY [location]
ORDER BY max_deaths desc


-- New cases, deaths and ration of new cases to deaths registered
-- each day, globally
SELECT [date],
       SUM(new_cases) AS new_cases_global,
       SUM(new_deaths) AS new_deaths_global,
       SUM(new_deaths) / SUM(new_cases) * 100 AS new_death_to_cases_percentage
FROM PortfolioCovidProject..Deaths
WHERE continent is not Null
GROUP BY [date]