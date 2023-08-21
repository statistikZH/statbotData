-- What farm animals were bred in the canton of Bern in 2020?
SELECT livestock_beef_cattle_and_cows, livestock_sheep, livestock_goats, livestock_pigs, livestock_poultry, livestock_other_animals
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name="Canton of Bern"
    AND S.canton=TRUE
    AND T.year=2020
    AND T.farmholding_system == "Farmholding system - total";

-- How many farms were there in all of Switzerland between 2012 and 2018?
SELECT year, farmholdings
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name="Switzerland"
    AND S.country=TRUE
    AND year BETWEEN 2012 AND 2018
    AND T.farmholding_system == "Farmholding system - total";

-- What was the total agricultural surface area in the canton of Geneva in 2000?
SELECT utilised_agricultural_area_in_hectares as utilised_agricultural_area_in_hectares_canton_geneva
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name="Canton Geneva"
    AND S.canton=TRUE
    AND year=2000
    AND T.farmholding_system == "Farmholding system - total";

-- What were the 5 cantons farming the most pigs in 2012?
SELECT S.name as canton_name, livestock_pigs as total_pigs
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND year=2012
    AND T.farmholding_system == "Farmholding system - total"
ORDER BY livestock_pigs DESC
LIMIT 5;

-- What was the average number of cows per farm in the canton of Vaud since 2017?
SELECT year, livestock_beef_cattle_and_cows / farmholdings AS average_cows_per_farmholding_vaud
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name="Canton Vaud"
    AND S.canton=TRUE
    AND year >= 2017
    AND T.farmholding_system == "Farmholding system - total";


-- What canton has the highest percentage of organic farms most recently?
SELECT
    year,
    S.name AS canton_name,
    (
        SUM(
            CASE WHEN farmholding_system = 'Organic farming'
            THEN farmholdings
            ELSE 0 END
        ) * 100.0 /
        SUM(
            CASE WHEN farmholding_system = 'Farmholding system - total'
            THEN farmholdings
            ELSE 0 END
        )
    ) AS percentage_organic_farms
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE year = (
    SELECT MAX(year)
    FROM employees_farmholdings_agricultural_area_livestock_per_canton
)
GROUP BY year, S.name
ORDER BY percentage_organic_farms DESC
LIMIT 1;

-- Does the average organic farm have less employees than the average non-organic farm in 2022?
SELECT farmholding_system, employees_total / farmholdings AS average_employees_per_farm
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE T.year=2022
    AND S.name="Switzerland"
    AND S.country=TRUE
    AND T.farmholding_system IN ("Organic farming", "Conventional farming");