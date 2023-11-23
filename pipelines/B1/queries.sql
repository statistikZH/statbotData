-- What was the proportion of electric vehicles in Geneva in 2010?
SELECT
    SUM(CASE WHEN sv.fuel_type ILIKE '%electric%' THEN sv.amount ELSE 0 END) AS electric_vehicles,
    SUM(sv.amount) AS total_vehicles,
    (
        SUM(CASE WHEN sv.fuel_type ILIKE '%electric%' THEN sv.amount ELSE 0 END) * 100.0 /
        NULLIF(SUM(sv.amount), 0)
    ) AS proportion_electric_vehicles
FROM spatial_unit su
INNER JOIN stock_vehicles sv
ON su.spatialunit_uid = sv.spatialunit_uid
WHERE su.name ILIKE '%geneva%'
    AND sv.year = 2010;

-- What was the city with the most cars in 2015?
SELECT
    su.name AS city,
    SUM(sv.amount) AS total_cars
FROM spatial_unit su
INNER JOIN stock_vehicles sv
ON su.spatialunit_uid = sv.spatialunit_uid
WHERE sv.year = 2015
    AND su.municipal = True
    AND sv.fuel_type = 'total'
GROUP BY
    su.name
ORDER BY total_cars DESC
LIMIT 1;
-- What is the most popular car type in the canton of Zurich?
SELECT
    sv.vehicle_type AS car_type,
    SUM(sv.amount) AS total_cars
FROM spatial_unit su
INNER JOIN stock_vehicles sv
ON su.spatialunit_uid = sv.spatialunit_uid
WHERE su.name ILIKE '%zurich%'
    AND su.canton = True
    AND sv.fuel_type = 'total'
    AND sv.year BETWEEN 2013 AND 2018
GROUP BY sv.vehicle_type
ORDER BY total_cars DESC
LIMIT 1;
-- What types of fuel are there?
SELECT DISTINCT fuel_type FROM stock_vehicles;
-- What year saw the biggest year-on-year increase in electric cars in the city of Basel?
SELECT
    year,
    year_on_year_increase
FROM (
    SELECT
        sv.year,
        (sv.amount - lag(sv.amount) OVER (ORDER BY sv.year)) AS year_on_year_increase
    FROM
        spatial_unit su
        INNER JOIN stock_vehicles sv ON su.spatialunit_uid = sv.spatialunit_uid
    WHERE
        su.name = 'Basel' and su.municipal = True
        AND sv.fuel_type ILIKE '%electric%'
) AS subquery
WHERE
    year_on_year_increase IS NOT NULL
ORDER BY
    year_on_year_increase DESC
LIMIT 1;
-- How did the proportion of fuel types evolve since 2010?
SELECT
    sv.year,
    sv.fuel_type,
    SUM(sv.amount) AS total_cars,
    (SUM(sv.amount) * 100.0 / NULLIF(SUM(SUM(sv.amount)) OVER (PARTITION BY sv.year), 0)) AS proportion
FROM
    stock_vehicles sv
WHERE
    sv.year >= 2010 and sv.fuel_type != 'total'
GROUP BY
    sv.year, sv.fuel_type
ORDER BY
    sv.year, sv.fuel_type;
-- What are the top 10 cities with the highest proportion of diesel cars?
SELECT
    su.name AS city,
    (SUM(CASE WHEN sv.fuel_type ILIKE '%diesel%' THEN sv.amount ELSE 0 END) * 100.0 / SUM(CASE WHEN sv.fuel_type = 'total' THEN sv.amount ELSE 0 END) ) AS proportion_diesel
FROM
    spatial_unit su
    INNER JOIN stock_vehicles sv ON su.spatialunit_uid = sv.spatialunit_uid
WHERE
    su.name IS NOT NULL
GROUP BY
    su.name
ORDER BY
    proportion_diesel DESC
LIMIT 10;
-- When was the first record of an electric vehicle?
SELECT
    MIN(year) AS first_record_year
FROM stock_vehicles
WHERE fuel_type ILIKE '%electric%';

-- In how many cities are vehicles records available?
SELECT COUNT(DISTINCT spatialunit_uid) AS total_cities
FROM stock_vehicles;
-- What are fuel types starting with d?
SELECT DISTINCT fuel_type
FROM stock_vehicles
WHERE fuel_type ILIKE 'd%';

-- How many electric-only cars are registered in 2013?
SELECT SUM(amount) AS total_electric_cars
FROM stock_vehicles
WHERE fuel_type = 'Electric'
    AND year = 2013;
-- What is the proportion of electric vehicles of each type in the most recent year, in descending order?
SELECT
    vehicle_type,
    SUM(CASE WHEN fuel_type ILIKE '%electric%' THEN amount ELSE 0 END) AS electric_cars,
    SUM(amount) AS total_cars,
    (
        SUM(CASE WHEN fuel_type ILIKE '%electric%' THEN amount ELSE 0 END) * 100.0 /
        NULLIF(SUM(amount), 0)
    ) AS proportion_electric
FROM stock_vehicles
WHERE year = (
    SELECT MAX(year)
    FROM stock_vehicles
    )
GROUP BY vehicle_type
ORDER BY proportion_electric DESC;
-- What cities do not have any electric cars registered?
SELECT su.name AS city
FROM spatial_unit su
WHERE NOT EXISTS (
    SELECT 1
    FROM stock_vehicles sv
    WHERE su.spatialunit_uid = sv.spatialunit_uid
        AND sv.fuel_type = 'Electric'
);
-- What type of vehicle is the most frequent in the canton of Basel?
SELECT
    vehicle_type,
    SUM(amount) AS total_amount
FROM
    spatial_unit su
    INNER JOIN stock_vehicles sv ON su.spatialunit_uid = sv.spatialunit_uid
WHERE
    su.canton = true
    AND su.name ILIKE '%basel%'
GROUP BY
    vehicle_type
ORDER BY
    total_amount DESC
LIMIT 1;
-- What is the percent change in the number of hybrid cars change in the city of Basel between 2013 and 2014?
SELECT
    vehicle_type,
    SUM(CASE WHEN fuel_type ILIKE '%hybrid%' AND year = 2014 THEN amount ELSE 0 END) -
    SUM(CASE WHEN fuel_type ILIKE '%hybrid%' AND year = 2013 THEN amount ELSE 0 END) AS hybrid_change,
    (SUM(CASE WHEN fuel_type ILIKE '%hybrid%' AND year = 2014 THEN amount ELSE 0 END) -
    SUM(CASE WHEN fuel_type ILIKE '%hybrid%' AND year = 2013 THEN amount ELSE 0 END)) * 100.0 /
    NULLIF(SUM(CASE WHEN fuel_type ILIKE '%hybrid%' AND year = 2013 THEN amount ELSE 0 END), 0) AS hybrid_percent_change
FROM
    spatial_unit su
    INNER JOIN stock_vehicles sv ON su.spatialunit_uid = sv.spatialunit_uid
WHERE
    su.name ILIKE 'Basel'
    AND su.municipal = True AND fuel_type ILIKE '%hybrid%'
    AND (year = 2013 OR year = 2014)
GROUP BY
    vehicle_type;
-- What canton has the most agricultural vehicles across all years?
SELECT
    su.name AS city,
    SUM(sv.amount) AS total_agricultural_vehicles
FROM
    spatial_unit su
    INNER JOIN stock_vehicles sv ON su.spatialunit_uid = sv.spatialunit_uid
WHERE
    sv.vehicle_type ILIKE '%agricultural%'
    AND su.canton = True
GROUP BY
    su.name
ORDER BY
    total_agricultural_vehicles DESC
LIMIT 1;
-- What are the 5 cantons with the most agricultural vehicles per passenger transportation vehicle in 2010?
SELECT
    su.name AS canton,
    SUM(CASE WHEN sv.vehicle_type ILIKE '%agricultural%' THEN sv.amount ELSE 0 END) AS total_agricultural_vehicles,
    SUM(CASE WHEN sv.vehicle_type ILIKE '%passenger transportation%' THEN sv.amount ELSE 0 END) AS total_passenger_vehicles,
    (SUM(CASE WHEN sv.vehicle_type ILIKE '%agricultural%' THEN sv.amount ELSE 0 END) * 1.0 / NULLIF(SUM(CASE WHEN sv.vehicle_type ILIKE '%passenger transportation%' THEN sv.amount ELSE 0 END), 0)) AS ratio_agricultural_to_passenger
FROM spatial_unit su
INNER JOIN stock_vehicles sv
ON su.spatialunit_uid = sv.spatialunit_uid
WHERE sv.year = 2010
    AND su.canton = True
GROUP BY su.name
ORDER BY ratio_agricultural_to_passenger DESC
LIMIT 5;
-- What fuel type is most frequently used for motorcycles?
SELECT
    fuel_type,
    SUM(amount) AS total_amount
FROM stock_vehicles
WHERE vehicle_type ILIKE '%motorcycle%'
    AND fuel_type != 'total'
GROUP BY fuel_type
ORDER BY total_amount DESC
LIMIT 1;
-- How many diesel industrial vehicles were there in Switzerland in 2013?
SELECT SUM(amount) AS total_diesel_industrial_vehicles
FROM spatial_unit su
INNER JOIN stock_vehicles sv ON su.spatialunit_uid = sv.spatialunit_uid
WHERE su.name = 'Switzerland'
    AND sv.vehicle_type = 'industrial vehicles'
    AND sv.fuel_type = 'Diesel'
    AND sv.year = 2013;

-- How many vehicles do we have in canton zurich in 2020?
SELECT S.name, sum(T.amount) as amount from stock_vehicles as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name ilike '%Zurich%'  and T.year=2020 and S.canton=True
GROUP BY S.name;

-- How many vehicles do we have in the city of zurich in 2021?
SELECT S.name, S.spatialunit_ontology, sum(T.amount) as amount from stock_vehicles as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name ilike '%Z_rich%'  and T.year=2021 and S.municipal=True and T.fuel_type != 'total'
GROUP BY S.name, S.spatialunit_ontology;

-- How many vehicles do we have in zurich in 2020?
SELECT S.name, S.spatialunit_ontology, sum(T.amount) as amount from stock_vehicles as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name ilike '%Z_rich%'  and T.year=2020 and (S.canton=True or S.municipal=True or S.district=True)
GROUP BY S.name, S.spatialunit_ontology;

-- How many electric cars do we have in the city of basel?
SELECT S.name, S.spatialunit_ontology,T.fuel_type,T.year, sum(T.amount) as amount from stock_vehicles as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name ilike '%basel%'  and S.municipal=True and T.fuel_type ='Electric'
GROUP BY S.spatialunit_ontology, S.name,T.fuel_type, T.year;

-- How many hybrid cars do we have in the city of basel?
SELECT S.name, S.spatialunit_ontology,T.fuel_type,T.year, sum(T.amount) as amount from stock_vehicles as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name ilike '%basel%'  and S.municipal=True and T.fuel_type ilike '%hybrid%'
GROUP BY S.spatialunit_ontology, S.name,T.fuel_type, T.year;

-- give me the total number of passenger cars that are using diesel in each canton?
SELECT S.name, S.spatialunit_ontology,T.fuel_type, sum(T.amount) as amount from stock_vehicles as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE  S.canton=True and T.fuel_type ilike '%diesel%' and T.vehicle_type ='passenger_cars'
GROUP BY S.spatialunit_ontology, S.name,T.fuel_type;
