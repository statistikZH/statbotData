-- In which year were there the most crimes in Switzerland? Also please provide the number of committed crimes.
SELECT T.year AS year_with_most_crimes, T.number_criminal_offences_registered
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
  AND S.country = TRUE
  AND T.offence_criminal_code='Offence - total'
GROUP BY T.year, T.number_criminal_offences_registered
ORDER BY T.number_criminal_offences_registered DESC LIMIT 1;

-- What is the most committed crime in Switzerland?
SELECT T.offence_criminal_code AS most_common_criminal_offence
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
  AND S.country = TRUE
  AND T.offence_criminal_code!='Offence - total'
  AND T.number_criminal_offences_registered IS NOT NULL
GROUP BY T.offence_criminal_code
ORDER BY SUM(T.number_criminal_offences_registered) DESC LIMIT 1;

-- How many crimes were solved in Bern in 2022?
SELECT T.number_criminal_offences_solved as solved_criminal_offences_2022_bern
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name LIKE '%Bern%'
  AND S.canton = TRUE
  AND T.offence_criminal_code='Offence - total'
  AND T.year=2022;

-- What was the most committed crime in 2020 in the canton of Bern?
SELECT T.offence_criminal_code
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name LIKE '%Bern%'
  AND S.canton=TRUE
  AND T.year=2020
  AND T.offence_criminal_code!='Offence - total'
  AND T.number_criminal_offences_registered IS NOT NULL
GROUP BY T.offence_criminal_code, T.number_criminal_offences_registered
ORDER BY T.number_criminal_offences_registered DESC LIMIT 1;

-- What is the category of the most frequently committed crimes in Switzerland and how many such crimes were commited?
SELECT T.offence_category, SUM(number_criminal_offences_registered) AS number_criminal_offences
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
  AND S.country = TRUE
  AND T.offence_criminal_code!='Offence - total'
GROUP BY T.offence_category, S.name
ORDER BY number_criminal_offences DESC LIMIT 1;

-- What was the clearance rate for bribery in 2021 in Switzerland
SELECT 100 * SUM(T.number_criminal_offences_solved) / SUM(T.number_criminal_offences_registered)
AS clearance_rate_for_bribery
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
  AND S.country = TRUE
  AND T.year = 2021
  AND T.number_criminal_offences_registered IS NOT NULL
  AND T.offence_category='Bribery';

-- Which three crime categories had the lowest crime detection rate in 2019 in Switzerland and what were these rates?
SELECT T.offence_category,
100 * SUM(T.number_criminal_offences_solved) / SUM(T.number_criminal_offences_registered)
AS crime_detection_rate
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
  AND S.country = TRUE
  AND T.year = 2019
  AND T.offence_criminal_code!='Offence - total'
GROUP BY T.offence_category
ORDER BY crime_detection_rate LIMIT 3;

-- How were the crime preventation rates in Switzerland for 2022 per crime category. Also provide the number of attempted and commited crimes? Order by prevention rate.
SELECT T.offence_category, SUM(T.number_criminal_offences_attempted) AS number_of_attempted_crimes,
  SUM(T.number_criminal_offences_registered) AS number_of_committed_crimes,
  ROUND(100 * SUM(T.number_criminal_offences_attempted) / SUM(T.number_criminal_offences_registered), 2) AS prevention_rate
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
  AND S.country = TRUE
  AND T.year = 2022
  AND T.number_criminal_offences_registered != 0
  AND T.offence_criminal_code != 'Offence - total'
GROUP BY T.offence_category
ORDER BY prevention_rate DESC;

-- Which offences had over 10.000 incidents in Switzerland in 2022. Provide the crimnal codes and the number of incidents.
SELECT T.offence_criminal_code,
  SUM(T.number_criminal_offences_registered) AS offences_per_year
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name = 'Switzerland'
  AND S.country = TRUE
  AND T.year = 2022
  AND T.number_criminal_offences_registered > 10000
  AND T.offence_criminal_code != 'Offence - total'
GROUP BY T.year, T.offence_criminal_code
ORDER BY offences_per_year DESC;

-- Compare the years 2019 and 2020 regarding offence categories that had over a 100 incidents in Kanton of Zurich. Provide the difference and order by how much they increased.
SELECT T.offence_category,
   SUM(CASE WHEN T.year = 2019
       THEN T.number_criminal_offences_registered ELSE 0 END) AS number_offences_2019,
   SUM(CASE WHEN T.year = 2020
       THEN T.number_criminal_offences_registered ELSE 0 END) AS number_offences_2020,
   SUM(CASE WHEN T.year = 2020
       THEN T.number_criminal_offences_registered ELSE 0 END) -
   SUM(CASE WHEN T.year = 2019
       THEN T.number_criminal_offences_registered ELSE 0 END) AS increase
FROM criminal_offences_registered_by_police AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND S.name LIKE '%Zurich%'
  AND T.year IN (2019, 2020)
  AND T.offence_criminal_code != 'Offence - total'
GROUP BY T.offence_category
HAVING SUM(CASE WHEN T.year = 2019
       THEN T.number_criminal_offences_registered ELSE 0 END) > 100
ORDER BY increase DESC;
