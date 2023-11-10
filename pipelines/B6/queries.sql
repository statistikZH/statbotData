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

-- How many of the permanent population of Switzerlan have been born Aborad on the year of 2020?
SELECT T1.year, T1.population_type,T1.place_of_birth,T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True AND T1.year=2020 AND T1.population_type ='Permanent resident population' AND T1.place_of_birth ='Abroad' AND T1.citizenship='Citizenship - total';

-- How many individuals with Swiss permanent residency were born within the country's borders on 2006?
SELECT T1.year,T1.population_type,T1.place_of_birth,T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True AND T1.year=2019 AND T1.population_type ='Permanent resident population' AND T1.place_of_birth ='Switzerland' AND T1.citizenship='Citizenship - total';

-- In year 2019, how many individuals in Switzerland's permanent population were not born within the country's territory?
SELECT T1.year, T1.population_type,T1.place_of_birth,T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True AND T1.year=2019 AND T1.population_type ='Permanent resident population' AND T1.place_of_birth ='Abroad' AND T1.citizenship='Citizenship - total';

-- In 2021, how many people were living in Switzerland who were not born there and did not have permanent residency?
SELECT T1.year,T1.population_type,T1.place_of_birth,T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True AND T1.year=2021 AND T1.population_type ='Non permanent resident population' AND T1.place_of_birth ='Abroad' AND T1.citizenship='Citizenship - total';

-- Can you provide a breakdown of the number of people who hold Swiss permanent residency and were born in Switzerland in 2020, categorized by their respective citizenships?
SELECT T1.population_type,T1.place_of_birth,T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True AND T1.year=2020 AND T1.population_type ='Permanent resident population' AND T1.place_of_birth ='Switzerland' AND T1.citizenship !='Citizenship - total';

-- What was the percentage of the population in Switerland who were born in a foreign country on 2017?
SELECT sum(un.in), sum(un.out) , sum(un.out)/(sum(un.in)+sum(un.out)) AS percentage FROM
(SELECT T1.year,T1.place_of_birth,T1.citizenship, Sum(T1.amount) as in, sum(0) as out  from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True AND T1.year=2017  AND T1.place_of_birth ='Switzerland' AND T1.citizenship='Citizenship - total'
GROUP BY T1.year,  T1.place_of_birth, T1.citizenship
UNION
SELECT T1.year,T1.place_of_birth,T1.citizenship, sum(0) as in, Sum(T1.amount) as out from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True AND T1.year=2017  AND T1.place_of_birth ='Abroad' AND T1.citizenship='Citizenship - total'
GROUP BY T1.year, T1.place_of_birth, T1.citizenship
) AS un;

-- In 2021, what percentage of the population in Switzerland consisted of individuals who were born within the country's borders?
SELECT un.in, un.out , un.in/(un.in+un.out) AS percentage FROM
(SELECT T1.year,T1.population_type,T1.place_of_birth,T1.citizenship, T1.amount as in, 0 as out from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True AND T1.year=2001 AND T1.population_type ='total' AND T1.place_of_birth ='Switzerland' AND T1.citizenship='Citizenship - total'
UNION
SELECT T1.year,T1.population_type,T1.place_of_birth,T1.citizenship, 0 as in, T1.amount as out from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True AND T1.year=2001 AND T1.population_type ='total' AND T1.place_of_birth ='Abroad' AND T1.citizenship='Citizenship - total'
) AS un;

-- In 2020, what was the number of individuals categorized as non-permanent residents in the Canton of Zug?
SELECT T1.year,T1.population_type,T1.place_of_birth,T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.canton=True AND T2.name ilike '%Zug%' AND T1.year=2020 AND T1.population_type ='Non permanent resident population' AND T1.place_of_birth ='Place of birth - total' AND T1.citizenship='Citizenship - total';

-- How many of the people were born abroad in municipality level  had the permanent residenship on 2010?
SELECT T1.year, T2.spatialunit_ontology, T2.name, T1.population_type,T1.place_of_birth, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal=True  AND T1.year=2010 AND T1.population_type ='Permanent resident population' AND T1.place_of_birth ='Abroad' AND T1.citizenship='Citizenship - total';

-- How many people who were born in Switzerland  did not possess permanent residency status by 2010?
SELECT T1.year, T1.population_type,T1.place_of_birth, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True  AND T1.year=2015 AND T1.population_type ='Non permanent resident population' AND T1.place_of_birth ='Switzerland' AND T1.citizenship='Citizenship - total';

-- How many people who were born in Switzerland did not possess permanent residency status by 2015? List by citizenship
SELECT T1.year, T1.population_type,T1.place_of_birth, T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True  AND T1.year=2015 AND T1.population_type ='Non permanent resident population' AND T1.place_of_birth ='Switzerland' AND T1.citizenship!='Citizenship - total';

-- Which municipalities had the largest population of people born in Switzerland who did not have permanent residency by 2020? show me top 5.
SELECT T1.year, T2.name, T1.population_type,T1.place_of_birth, T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal=True  AND T1.year=2020 AND T1.population_type ='Non permanent resident population' AND T1.place_of_birth ='Switzerland' AND T1.citizenship='Citizenship - total'
ORDER BY T1.amount DESC
LIMIT 5;

-- How many of Swiss residenc were born within the country and had Iranian Citizenship on 2018?
SELECT T1.year, T1.population_type, T1.place_of_birth, T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True  AND T1.year=2018 AND T1.place_of_birth ='Switzerland' AND T1.citizenship ilike '%iran%';

-- What was the total population count in each canton , considering both non-permanent and permanent residents on the year of 2018?
SELECT T1.year, T2.name, T1.population_type, T1.place_of_birth, T1.citizenship, T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.canton=True  AND T1.year=2018 AND T1.place_of_birth ='Place of birth - total' AND T1.citizenship ='Citizenship - total'
ORDER BY  T1.amount DESC;

-- How many individuals born abroad in canton zurich hold citizenship from Brazil?
SELECT T2.name, T1.place_of_birth, T1.citizenship, Sum(T1.amount) from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.canton=True AND T2.name ilike '%Z_rich%'  AND T1.place_of_birth ='Abroad' AND T1.citizenship ilike '%Brazil%'
GROUP BY T2.name, T1.place_of_birth, T1.citizenship;

-- How many individuals in each canton of Switzerland were born abroad and hold Swiss citizenship?
SELECT T2.name, T1.place_of_birth, T1.citizenship, Sum(T1.amount) from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.canton=True   AND T1.place_of_birth ='Abroad' AND T1.citizenship ilike '%Switzerland%'
GROUP BY T2.name, T1.place_of_birth, T1.citizenship;

-- Can you provide the breakdown of the population by different citizenships, different place of the birth and different residentship in the Canton of Obwaldent in 2011?
SELECT T1.citizenship, T1.population_type, T1.place_of_birth,  T1.amount from resident_population_birthplace_citizenship_type AS T1
JOIN spatial_unit AS T2 ON T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.canton=True AND T2.name ilike '%Obwalden%' AND T1.year=2011  AND T1.place_of_birth !='Place of birth - total' AND T1.citizenship !='Citizenship - total'
ORDER BY citizenship;