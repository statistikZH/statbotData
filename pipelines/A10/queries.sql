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
GROUP BY T.offence_criminal_code,
  T.number_criminal_offences_registered
ORDER BY T.number_criminal_offences_registered DESC LIMIT 1;

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
