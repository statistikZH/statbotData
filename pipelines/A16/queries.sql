-- How many residents were in Switzerland in 2018?
SELECT total_population as total_population_of_switzerland_in_2018
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name="Switzerland"
    AND S.country=TRUE
    AND T.year=2018
    AND T.citizenship_category="Citizenship (category) - total";

-- What was the net migration of Switzerland from 2012 to 2022?
SELECT year, net_migration as net_migration_of_switzerland
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name="Switzerland"
    AND S.country=TRUE
    AND T.year>=2012
    AND T.year<=2022
    AND T.citizenship_category="Citizenship (category) - total";

-- What cantons had a population decrease in 2017, and by how much?
SELECT S.name, population_change
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.population_change<0
    AND T.year=2017
    AND T.citizenship_category="Citizenship (category) - total";

-- What were the 5 cantons with the most acquisition of Swiss citizensip in 2017 relative to their population?
SELECT S.name, acquisition_of_swiss_citizenship / total_population as relative_acquisition
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year=2017
    AND T.citizenship_category="Switzerland"
ORDER BY relative_acquisition DESC
LIMIT 5;

-- What canton has the most immigrants from other cantons?
SELECT S.name, acquisition_of_swiss_citizenship / total_population as relative_acquisition
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year=2017
    AND T.citizenship_category="Switzerland"
ORDER BY relative_acquisition DESC
LIMIT 5;

-- What are the 5 cantons with the highest relative population growth between 2000 and 2022?
SELECT S.name, acquisition_of_swiss_citizenship / total_population as relative_acquisition
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year=2017
    AND T.citizenship_category="Switzerland"
ORDER BY relative_acquisition DESC
LIMIT 5;

-- What was the natural population change of the Swiss residents in Canton Vaud between 2015 and 2020?
SELECT year, births - deaths
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name="Canton Vaud"
    AND T.year>=2015
    AND T.year>=2020
    AND T.citizenship_category="Switzerland";

-- Give me the total population of each canton in 2019.
SELECT S.name as canton, total_population as total_population_2019
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year=2019
    AND T.citizenship_category="Citizenship (category) - total"
ORDER BY total_population DESC;

-- Show me the canton with the highest birthrate every year between 1995 and 2010.
SELECT year, S.name as most_populout_canton, MAX(births / total_population) as birthrate
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year>=1995
    AND T.year<=2010
    AND T.citizenship_category="Citizenship (category) - total"
GROUP BY T.year
ORDER BY year ASC;

-- What year saw the highest birt rate in Switzerland?
SELECT year, births / total_population as birthrate
FROM demographic_balance_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country=TRUE
    AND S.name="Switzerland"
    AND T.citizenship_category="Citizenship (category) - total"
GROUP BY T.year
ORDER BY birthrate DESC
LIMIT 1;