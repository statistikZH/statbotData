-- What farm animals were bred in the canton of Bern in 2020?
SELECT livestock_beef_cattle_and_cows, livestock_sheep, livestock_goats, livestock_pigs, livestock_poultry, livestock_other_animals
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name LIKE '%Bern%'
    AND S.canton=TRUE
    AND T.year=2020
    AND T.farmholding_system = 'Farmholding system - total';

-- How many farms were there in all of Switzerland between 2012 and 2018?
SELECT year, farmholdings
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
    AND S.country=TRUE
    AND year BETWEEN 2012 AND 2018
    AND T.farmholding_system = 'Farmholding system - total';

-- What was the total agricultural surface area in the canton of Geneva in 2000?
SELECT utilised_agricultural_area_in_hectares as utilised_agricultural_area_in_hectares_canton_geneva
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Canton Geneva'
    AND S.canton=TRUE
    AND year=2000
    AND T.farmholding_system = 'Farmholding system - total';

-- What were the 5 cantons farming the most pigs in 2012?
SELECT S.name as canton_name, livestock_pigs as total_pigs
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND year=2012
    AND T.farmholding_system = 'Farmholding system - total'
ORDER BY livestock_pigs DESC
LIMIT 5;

-- What was the average number of cows per farm in the canton of Vaud since 2017?
SELECT year, livestock_beef_cattle_and_cows / farmholdings AS average_cows_per_farmholding_vaud
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Canton Vaud'
    AND S.canton=TRUE
    AND year >= 2017
    AND T.farmholding_system = 'Farmholding system - total';

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
    AND S.name='Switzerland'
    AND S.country=TRUE
    AND T.farmholding_system IN ('Organic farming', 'Conventional farming');

-- How did organic versus conventional farming develop in Kanton Uri between 2010 and 2020? Consider the farm area and the number of farms and give the differences.
SELECT
   SUM(CASE WHEN T.year = 2020 AND T.farmholding_system = 'Organic farming'
       THEN T.utilised_agricultural_area_in_hectares ELSE 0 END) -
   SUM(CASE WHEN T.year = 2010 AND T.farmholding_system = 'Organic farming'
       THEN T.utilised_agricultural_area_in_hectares ELSE 0 END) AS increase_organic_farm_area_in_ha,
   SUM(CASE WHEN T.year = 2020 AND T.farmholding_system = 'Organic farming'
       THEN T.farmholdings ELSE 0 END) -
   SUM(CASE WHEN T.year = 2010 AND T.farmholding_system = 'Organic farming'
       THEN T.farmholdings ELSE 0 END) AS increase_number_of_organic_farms,
   SUM(CASE WHEN T.year = 2020 AND T.farmholding_system = 'Conventional farming'
       THEN T.utilised_agricultural_area_in_hectares ELSE 0 END) -
   SUM(CASE WHEN T.year = 2010 AND T.farmholding_system = 'Conventional farming'
       THEN T.utilised_agricultural_area_in_hectares ELSE 0 END) AS increase_conventional_farm_area_in_ha,
   SUM(CASE WHEN T.year = 2020 AND T.farmholding_system = 'Conventional farming'
       THEN T.farmholdings ELSE 0 END) -
   SUM(CASE WHEN T.year = 2010 AND T.farmholding_system = 'Conventional farming'
       THEN T.farmholdings ELSE 0 END) AS increase_number_of_conventional_farms
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND S.name LIKE '%Uri%'
  AND T.year IN (2010, 2020)
  AND T.farmholding_system IN ('Organic farming', 'Conventional farming');

-- Which 5 cantons had 2022 the biggest precentage of their farm area used by organic farming? Order by the percentage of area used for oraganic farming.
SELECT S.name,
   ROUND(100 * SUM(CASE WHEN T.farmholding_system = 'Organic farming'
       THEN T.utilised_agricultural_area_in_hectares ELSE 0 END) /
   NULLIF(SUM(CASE WHEN T.farmholding_system = 'Farmholding system - total'
       THEN T.utilised_agricultural_area_in_hectares ELSE 0 END), 0), 2) AS percentage_of_organically_used_farmarea
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE T.year = 2022
    AND S.canton = TRUE
    AND T.farmholding_system IN ('Organic farming', 'Farmholding system - total')
GROUP BY S.name
ORDER BY percentage_of_organically_used_farmarea DESC LIMIT 5;

--How was the split between Swiss population and foreign nationlas on Swiss farms in 2022?
SELECT ROUND(100 * employees_swiss / employees_total, 2) AS percentage_of_swiss_employees,
  ROUND(100 * employees_foreign_nationals / employees_total, 2) AS percentage_foreign_nationals_employees
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
    AND year = 2022
    AND T.farmholding_system = 'Farmholding system - total';

-- What was the precentage of family employees in organic and conventional farming in 2022?
SELECT
   ROUND(100 * SUM(CASE WHEN T.farmholding_system = 'Organic farming'
       THEN T.family_employees ELSE 0 END) /
   SUM(CASE WHEN T.farmholding_system = 'Organic farming'
       THEN T.employees_total ELSE 0 END), 2) AS percentage_family_employees_organic_farming,
   ROUND(100 * SUM(CASE WHEN T.farmholding_system = 'Conventional farming'
       THEN T.family_employees ELSE 0 END) /
   SUM(CASE WHEN T.farmholding_system = 'Conventional farming'
       THEN T.employees_total ELSE 0 END), 2) AS percentage_family_employees_conventional_farming
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE T.year = 2022
    AND S.country = TRUE
    AND T.farmholding_system IN ('Organic farming', 'Conventional farming');

-- How was the split between men and women in farm employment in canton Uri in 2015?
SELECT ROUND(100 * employees_women / employees_total, 2) AS percentage_of_female_employees,
  ROUND(100 * employees_men / employees_total, 2) AS percentage_of_male_employees
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
    AND year = 2015
    AND T.farmholding_system = 'Farmholding system - total';

-- What are the percentages of part time work in Organic Farming?
SELECT ROUND(100 * full_time_employees_75_percent_or_more / employees_total, 2) AS precentage_75_percent_and_above,
  ROUND(100 * part_time_employees_50_75_percent / employees_total, 2) AS percentage_of_between_50_and_75_percent,
  ROUND(100 * part_time_employees_50_75_percent / employees_total, 2) AS percentage_below_50_precent
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
    AND year = 2015
    AND T.farmholding_system = 'Organic farming';

-- How was the farmland used in organic farming in 2017? Provide land usage in percentage of the farming area.
SELECT ROUND(100 * T.arable_land_in_hectares / T.utilised_agricultural_area_in_hectares, 2) AS percentage_arable_land,
  ROUND(100 * T.grassland_in_hectares / T.utilised_agricultural_area_in_hectares, 2) AS percentage_grassland,
  ROUND(100 * T.permanent_crops_in_hectares / T.utilised_agricultural_area_in_hectares, 2) AS percentage_permanent_crops,
  ROUND(100 * T.other_utilised_agricultural_area_in_hectares / T.utilised_agricultural_area_in_hectares, 2) AS precentage_other_usage
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
    AND year = 2015
    AND T.farmholding_system = 'Organic farming';

-- What kind of animal farms existed in Kanton Uri in 2012? Give the number of each farm type.
SELECT beef_cattle_and_cows_farm, horse_and_other_equine_farm,
  sheep_farm, goat_farm, pig_farms, poultry_farm, farms_with_other_animals
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name LIKE '%Uri%'
    AND S.canton=TRUE
    AND T.year=2012
    AND T.farmholding_system = 'Farmholding system - total';

-- Which five cantons had in 2022 the highest percentage of women farmers in mangement position? Also provide the precentage of women who had a manager position.
SELECT S.name as canton,
  ROUND(100 * SUM(T.employees_women_manager_label) / SUM(T.employees_women), 2) AS percentage_women_managers
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND year = 2022
    AND T.farmholding_system = 'Farmholding system - total'
GROUP BY S.name
ORDER BY percentage_women_managers DESC
LIMIT 5;
