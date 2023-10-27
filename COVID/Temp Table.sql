-- Create temp table to store increase in poeple vacinated daily
DROP TABLE IF EXISTS #total_vaccinations_table

CREATE TABLE #total_vaccinations_table (
    continent varchar(255),
    location varchar(255),
    date datetime,
    population float,
    new_vaccinations int,
    total_vaccinations bigint
)


-- Save rolling total of people vacinated for each country
INSERT INTO #total_vaccinations_table
SELECT dea.continent,
       dea.[location],
       dea.[date],
       dea.population,
       CONVERT(int, vac.new_vaccinations),
       SUM(CONVERT(bigint, vac.new_vaccinations))
             OVER (PARTITION by dea.location
             ORDER BY dea.location, dea.date)
FROM PortfolioCovidProject..Deaths AS dea
JOIN PortfolioCovidProject..Vaccines AS vac
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent is not NULL


-- Show percentage of vacines per population per each day
-- The number can now go over 100% since people can get more than one vacine
SELECT [continent], [location], [date], total_vaccinations / [population] * 100
FROM #total_vaccinations_table
ORDER BY [location]