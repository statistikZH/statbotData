-- What greenhouse gas footprint had Switzerland in 2000 through consumption?
SELECT T.emissions_in_million_tons_co2_equivalent
FROM greenhouse_gas_emissions_through_consumption as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
  AND S.country=TRUE
  AND T.year=2000;

-- What years did the greenhouse gas footprint of Switzerland decrease compared to the previous year and by how much? Order by magnitude of decrease
WITH EmissionsChange AS (
    SELECT
        T1.year AS current_year,
        T1.emissions_in_million_tons_co2_equivalent AS emissions_current_year,
        (T1.year - 1) AS previous_year,
        T2.emissions_in_million_tons_co2_equivalent AS emissions_previous_year,
        T1.emissions_in_million_tons_co2_equivalent - T2.emissions_in_million_tons_co2_equivalent
          AS decrease_from_previous_year
    FROM greenhouse_gas_emissions_through_consumption AS T1
    JOIN greenhouse_gas_emissions_through_consumption AS T2 ON T1.year = T2.year + 1
    WHERE T1.year > 2000
)
SELECT current_year, decrease_from_previous_year
FROM EmissionsChange
WHERE decrease_from_previous_year < 0
ORDER BY decrease_from_previous_year ASC;

-- In which years did the greenhouse footprint increase and by how much? Order by years and start from the present
WITH EmissionsChange AS (
    SELECT
        T1.year AS current_year,
        T1.emissions_in_million_tons_co2_equivalent AS emissions_current_year,
        (T1.year - 1) AS previous_year,
        T2.emissions_in_million_tons_co2_equivalent AS emissions_previous_year,
        T1.emissions_in_million_tons_co2_equivalent - T2.emissions_in_million_tons_co2_equivalent
          AS increase_from_previous_year
    FROM greenhouse_gas_emissions_through_consumption AS T1
    JOIN greenhouse_gas_emissions_through_consumption AS T2 ON T1.year = T2.year + 1
    WHERE T1.year > 2000
)
SELECT current_year, increase_from_previous_year
FROM EmissionsChange
WHERE increase_from_previous_year > 0
ORDER BY current_year DESC;

-- How did the greenhouse gas footprint develop overall? Did it go up or down and by how much? Compare the first and last year in the data and show both years and the change of the footprint.
WITH FirstYearEmissions AS (
    SELECT
        year AS first_observation_year,
        emissions_in_million_tons_co2_equivalent AS emissions_first_year
    FROM greenhouse_gas_emissions_through_consumption
    ORDER BY year ASC
    LIMIT 1
),
LastYearEmissions AS (
    SELECT
        year AS last_observation_year,
        emissions_in_million_tons_co2_equivalent AS emissions_last_year
    FROM greenhouse_gas_emissions_through_consumption
    ORDER BY year DESC
    LIMIT 1
)
SELECT
    first_observation_year,
    last_observation_year,
    emissions_last_year - emissions_first_year AS emission_change_in_observered_period
FROM FirstYearEmissions
CROSS JOIN LastYearEmissions;

-- How much was the greenhouse gas footprint reduced as percentage of the total footprint in the observation period?
WITH FirstYearEmissions AS (
    SELECT
        year AS first_observation_year,
        emissions_in_million_tons_co2_equivalent AS emissions_first_year
    FROM greenhouse_gas_emissions_through_consumption
    ORDER BY year ASC
    LIMIT 1
),
LastYearEmissions AS (
    SELECT
        year AS last_observation_year,
        emissions_in_million_tons_co2_equivalent AS emissions_last_year
    FROM greenhouse_gas_emissions_through_consumption
    ORDER BY year DESC
    LIMIT 1
)
SELECT
    first_observation_year,
    last_observation_year,
    ((emissions_last_year - emissions_first_year) * 100 / emissions_first_year) AS emission_precentage_change_in_observered_period
FROM FirstYearEmissions
CROSS JOIN LastYearEmissions;


