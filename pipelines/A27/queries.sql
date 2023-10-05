-- What was the break down of renewable energy production in canton Thurgau each year since 2018?
SELECT
    T.jahr,
    SUM(biogasanlagen_abwasser_gwh),
    SUM(biogasanlagen_industrie_gwh),
    SUM(biogasanlagen_landwirtschaft_gwh),
    SUM(biomasse_holz_gwh),
    SUM(kehricht_gwh),
    SUM(photovoltaik_gwh),
    SUM(wasserkraft_gwh),
    SUM(wind_gwh),
    SUM(total_gwh)
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr >= 2018
GROUP BY T.jahr;

-- What percentage of the renewable energy in Frauenfeld, TG was produced by solar energy in 2021?
SELECT
    100 * photovoltaik_gwh/total_gwh AS photovoltaik_prozent_frauenfeld_2021
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2021
    AND S.name LIKE 'Frauenfeld%';

-- How many municipalities in canton Thurgau were producing energy from wind in 2019?
SELECT
    COUNT(*)
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2019
    AND T.wind_gwh > 0;

-- What is the municipality in canton Thurgau that produced the most renewable energy relative to its population in 2020?
SELECT S.name
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2020
ORDER BY T.total_gwh / T.einwohner DESC
LIMIT 1;

-- What is the proportion (in percent) of municipalities in Thurgau which did not produce any renewable energy in 2017?
SELECT 100 * SUM(CASE WHEN T.total_gwh = 0 THEN 1 ELSE 0 END) / CAST(COUNT(*) AS FLOAT) AS prozent_kein_erneurerbare_energie_2017
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2017;

-- How much renewable energy is produced by the top 5 largest municipalities in Thurgau in 2021?
SELECT S.name, T.total_gwh
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2021
ORDER BY T.einwohner DESC
LIMIT 5;

-- What 3 municipalities in Thurgau showed the largest increase in renewable energy production between 2018 and 2021? Also show the percentage increase.
SELECT
    S.name,
    (
        100.0 * SUM( CASE WHEN T.jahr = 2021 THEN T.total_gwh ELSE 0 END) /
        SUM( CASE WHEN T.jahr = 2018 THEN T.total_gwh ELSE 0 END
    )) AS prozent_anstieg
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr IN (2018, 2021)
GROUP BY S.name
ORDER BY prozent_anstieg DESC
LIMIT 3;

-- In total, how many MWh of renewable energy did Amriswil, in Kanton Thurgau, produce from 2016 to 2020?
SELECT SUM(T.total_gwh) * 1000 AS total_mwh
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name LIKE "Amriswil%"
    AND T.jahr >= 2016
    AND T.jahr <= 2020;

-- Show me 2 municipalities in Aargau which were the most important producer of energy from wood biomass in 2019.
SELECT S.name
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2019
ORDER BY T.biomasse_holz_gwh DESC
LIMIT 2;

-- What is the total amount of renewable energy produced from waste incineration in canton Thurgau in 2020?
SELECT S.name
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2019
ORDER BY T.biomasse_holz_gwh DESC
LIMIT 2;

-- How many GWh of energy were produced from each type of biogas plant in canton Thurgau in 2015?
SELECT SUM(biogasanlagen_abwasser_gwh), SUM(biogasanlagen_industrie_gwh), SUM(biogasanlagen_landwirtschaft_gwh)
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2015;

-- What was the smallest municipality (in inhabitants) to produce energy from waste incineration in canton Thurgau in 2021?
SELECT S.name
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2021
    AND T.kehricht_gwh > 0
ORDER BY T.einwohner ASC
LIMIT 1;

-- Show me the production of energy from sun and wind in Berg, TG in 2018.
SELECT T.photovoltaik_gwh, T.wind_gwh
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name LIKE 'Berg%'
    AND T.jahr = 2018;

-- Which 3 municipalities in Thurgau had the highest share of hydroenergy in their total renewable energy production in 2019?

-- What proportion of municipalities in canton Thurgau had a decrease in renewable energy production between 2015 and 2021?
-- What source of renewable energy showed the strongest relative production increase between 2018 and 2021 in canton Thurgau?
-- Show me the production of energy from agricultural biogas in Fischingen, canton Thurgau, in 2018.
-- How much renewable energy did canton Thurgau produce in total over the period 2017-2021?
-- What was the production of solar energy from Roggwil and Langrickenbach, TG in 2019 and 2020?