-- How many residents were in Switzerland in 2018?
SELECT total_population as total_population_of_switzerland_in_2018
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
    AND S.country=TRUE
    AND T.year=2018
    AND T.citizenship_category='Citizenship (category) - total';

-- What was the net migration of Switzerland from 2012 to 2022?
SELECT year, net_migration as net_migration_of_switzerland
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
    AND S.country=TRUE
    AND T.year>=2012
    AND T.year<=2022
    AND T.citizenship_category='Citizenship (category) - total';

-- Which cantons experienced a population decline in 2017, and by how much?
SELECT S.name, population_change
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.population_change<0
    AND T.year=2017
    AND T.citizenship_category='Citizenship (category) - total';

-- Which five cantons had the highest number of Swiss citizenship acquisitions in 2017 relative to their population?
SELECT S.name, acquisition_of_swiss_citizenship / total_population as relative_acquisition
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year=2017
    AND T.citizenship_category='Switzerland'
ORDER BY relative_acquisition DESC
LIMIT 5;

-- Which canton has the highest number of residents who have moved from other cantons in 2016?
SELECT S.name, T.in_migration_from_another_canton
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year=2016
    AND T.citizenship_category='Citizenship (category) - total'
ORDER BY T.in_migration_from_another_canton DESC
LIMIT 1;

-- Which five cantons experienced the most significant population growth relative to their size between 2000 and 2022?
SELECT
    S.name, (
        (
            SUM(CASE WHEN T.year = 2022 THEN total_population ELSE 0 END) -
            SUM(CASE WHEN T.year = 2000 THEN total_population ELSE 0 END)
        ) / SUM(CASE WHEN T.year = 2000 THEN total_population ELSE 0 END)
    ) as relative_population_growth
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year>=2000
    AND T.year<=2022
    AND T.citizenship_category='Citizenship (category) - total'
GROUP BY S.name
ORDER BY relative_population_growth DESC
LIMIT 5;

-- What was the population change due to natural factors among the residents of Canton Vaud between 2015 and 2020?
SELECT year, births - deaths
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name LIKE '%Vaud%'
    AND T.year>=2015
    AND T.year>=2020
    AND T.citizenship_category='Citizenship (category) - total';

-- Give me the total population of each canton in 2019.
SELECT S.name as canton, total_population as total_population_2019
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year=2019
    AND T.citizenship_category='Citizenship (category) - total'
ORDER BY total_population DESC;

-- Show me the cantons with the highest birth rates every year between 1995 and 2010.
SELECT year, S.name as most_populout_canton, MAX(births / total_population) as birthrate
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year>=1995
    AND T.year<=2010
    AND T.citizenship_category='Citizenship (category) - total'
GROUP BY T.year, S.name, T.births
ORDER BY year ASC;

-- In which year did Switzerland experience its highest birth rate?
SELECT T.year, T.births / T.total_population as birthrate
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country=TRUE
    AND S.name='Switzerland'
    AND T.citizenship_category='Citizenship (category) - total'
GROUP BY T.year, T.births, T.total_population
ORDER BY birthrate DESC
LIMIT 1;
