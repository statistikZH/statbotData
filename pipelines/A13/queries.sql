-- Which canton had the most private forests in 2019?
SELECT S.name as canton
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
  AND T.year=2019
  AND T.forest_zone='Switzerland'
  AND T.wood_species='Species - total'
  AND T.type_of_owner='Private forest'
ORDER BY number_of_plantations DESC LIMIT 1;

-- What was the proportion of deciduous to coniferous forests in Switzerland in 2020?
SELECT
  ROUND(100 * SUM(CASE WHEN LOWER(wood_species) LIKE '%deciduous%'
       THEN number_of_plantations ELSE 0 END) /
  SUM(CASE WHEN LOWER(wood_species) LIKE '%total%'
       THEN number_of_plantations ELSE 0 END),
  2) AS procentage_deciduous_forests,
    ROUND(100 * SUM(CASE WHEN LOWER(wood_species) LIKE '%conifers%'
       THEN number_of_plantations ELSE 0 END) /
   SUM(CASE WHEN LOWER(wood_species) LIKE '%total%'
       THEN number_of_plantations ELSE 0 END),
  2) AS procentage_coniferous_forests
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
  AND T.year = 2020
  AND S.name = 'Switzerland'
  AND T.type_of_owner='Type of owners - total';

-- What was the proportion of private to public forests in Switzerland in 2022?
SELECT
  ROUND(100 *
    SUM(CASE WHEN LOWER(type_of_owner) LIKE '%private%'
        THEN number_of_plantations ELSE 0 END) /
    SUM(CASE WHEN LOWER(type_of_owner) LIKE '%total%'
        THEN number_of_plantations ELSE 0 END), 2) AS percentage_private_forests,
  ROUND(100 *
    SUM(CASE WHEN LOWER(type_of_owner) LIKE '%public%'
       THEN number_of_plantations ELSE 0 END) /
    SUM(CASE WHEN LOWER(type_of_owner) LIKE '%total%'
       THEN number_of_plantations ELSE 0 END), 2) AS percentage_public_forests
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
  AND T.year = 2022
  AND S.name = 'Switzerland'
  AND T.wood_species='Species - total';

-- How much did the number of Swiss forest change from 1975 to 2022? Show the change in total and by forest type as conifers or deciduous.
SELECT
  (SUM(CASE WHEN LOWER(wood_species) LIKE '%deciduous%' AND year = 2022
       THEN number_of_plantations ELSE 0 END) -
   SUM(CASE WHEN LOWER(wood_species) LIKE '%deciduous%' AND year = 1975
       THEN number_of_plantations ELSE 0 END)) AS difference_deciduous_number_of_forests_1975_to_2022,
  (SUM(CASE WHEN LOWER(wood_species) LIKE '%conifers%' AND year = 2022
       THEN number_of_plantations ELSE 0 END) -
   SUM(CASE WHEN LOWER(wood_species) LIKE '%conifers%' AND year = 1975
       THEN number_of_plantations ELSE 0 END)) AS difference_conifers_number_of_forests_1975_to_2022,
  (SUM(CASE WHEN LOWER(wood_species) LIKE '%total%' AND year = 2022
       THEN number_of_plantations ELSE 0 END) -
   SUM(CASE WHEN LOWER(wood_species) LIKE '%total%' AND year = 1975
       THEN number_of_plantations ELSE 0 END)) AS difference_total_number_of_forests_1975_to_2022
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
  AND T.year IN (1975, 2022)
  AND S.name = 'Switzerland'
  AND T.forest_zone = 'Switzerland'
  AND T.type_of_owner='Type of owners - total';

-- What canton contribute how many forests to the forestzone Jura by the latest count?
WITH MostRecentYear AS (
  SELECT MAX(year) as most_recent_year
  FROM number_of_plantations_in_swiss_forest
  WHERE type_of_owner = 'Type of owners - total'
)
SELECT
  S.name_de as canton,
  SUM(T.number_of_plantations) as number_of_plantations_in_jura
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
JOIN MostRecentYear ON T.year = MostRecentYear.most_recent_year
WHERE S.canton = TRUE
  AND T.type_of_owner = 'Type of owners - total'
  AND T.forest_zone = 'Jura'
  AND T.number_of_plantations != 0 AND number_of_plantations IS NOT NULL
GROUP BY S.name_de, MostRecentYear.most_recent_year
ORDER BY number_of_plantations_in_jura DESC;

-- By 2022: Which three forest zones had the most plantations in Switzerland? Provide the forest zones together with the number of plantations.
SELECT T.forest_zone, SUM(T.number_of_plantations) as number_of_plantations
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
  AND T.type_of_owner = 'Type of owners - total'
  AND T.year = 2022
  AND T.number_of_plantations != 0 AND number_of_plantations IS NOT NULL
  AND T.forest_zone != 'Switzerland'
GROUP BY T.forest_zone
ORDER BY number_of_plantations DESC LIMIT 3;

-- Which cantons had in 2022 only public forests?
SELECT S.name_de as canton
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND T.type_of_owner = 'Private forest'
  AND T.year = 2022
GROUP BY S.name_de
HAVING SUM(T.number_of_plantations) = 0;

-- To which Forestzones belongs the canton Jura and how many plantations of Jura are located in that forest zone?
SELECT T.forest_zone as forest_zone_for_jura, SUM(T.number_of_plantations) AS number_of_plantations_canton_jura
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE AND S.name_de LIKE '%Jura%'
  AND T.type_of_owner = 'Type of owners - total'
  AND T.wood_species = 'Species - total'
  AND T.forest_zone != 'Switzerland'
  AND T.number_of_plantations != 0
GROUP BY T.forest_zone
HAVING SUM(T.number_of_plantations) != 0
ORDER BY number_of_plantations_canton_jura DESC;

-- List for each year the change in number of forests in Kanton Uri?
SELECT T.year, SUM(T.number_of_plantations) AS number_of_plantations_canton_uri
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE AND S.name_de LIKE '%Uri%'
  AND T.type_of_owner = 'Type of owners - total'
  AND T.wood_species = 'Species - total'
  AND T.forest_zone != 'Switzerland'
  AND T.number_of_plantations != 0
GROUP BY T.year
ORDER BY T.year DESC;

-- Provide the change over the years of the total number of forests registered in Switzerland. The change should be given in percentage of the number of the previous year.
WITH PlantationsByYear AS (
  SELECT T.year,
    SUM(T.number_of_plantations) AS number_of_plantations_switzerland
  FROM number_of_plantations_in_swiss_forest AS T
  JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
  WHERE S.country = TRUE
    AND T.type_of_owner = 'Type of owners - total'
    AND T.wood_species = 'Species - total'
    AND T.forest_zone != 'Switzerland'
    AND T.number_of_plantations != 0
  GROUP BY T.year
)
SELECT
  Curr.year,
  Curr.number_of_plantations_switzerland,
  ROUND(100 * (Curr.number_of_plantations_switzerland - Prev.number_of_plantations_switzerland) / (Prev.number_of_plantations_switzerland), 2) AS change_from_previous_year
FROM PlantationsByYear AS Curr
LEFT JOIN PlantationsByYear AS Prev ON Curr.year = Prev.year + 1
ORDER BY Curr.year DESC;

