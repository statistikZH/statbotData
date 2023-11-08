-- How many 98 y.o. people have been registered in Bern in 2020?
SELECT SUM(value)
FROM resident_population_type_citizenship_category_gender_age
WHERE age_group_1 LIKE '98%'
AND EXTRACT(YEAR FROM time_value) = '2020'
AND spatialunit_name LIKE 'Bern%'

-- Which town or village had the smallest number of the residents of non-Swiss citizenship?
SELECT spatialunit_name
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category NOT LIKE 'Switzerland'
GROUP BY spatialunit_name
ORDER BY COUNT(*) ASC
LIMIT 1;

-- Which ten towns and village had the smallest number of the residents of non-Swiss citizenship?
SELECT spatialunit_name
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category NOT LIKE 'Switzerland'
GROUP BY spatialunit_name
ORDER BY COUNT(*) ASC
LIMIT 10;

-- How many Switzerland citizen lived in Schwyz at 2013?
SELECT value FROM resident_population_type_citizenship_category_gender_age
WHERE gender = 'Female' AND citizenship_category = 'Switzerland'
AND population_type = 'Permanent resident population'
AND spatialunit_name = 'Schwyz'
AND EXTRACT(YEAR from time_value) = 2013);
-- How many therewere registered Swiss women in Küttigen in 2020?
SELECT value
FROM resident_population_type_citizenship_category_gender_age
WHERE gender = 'Female'
AND citizenship_category = 'Switzerland'
AND population_type = 'Permanent resident population'
AND spatialunit_name = 'Küttigen'
AND EXTRACT(YEAR from time_value) = 2020;

-- How many Swiss citizen of 62 y.o. had been registered in 2013 in Payerne?
SELECT SUM(value)
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category = 'Switzerland'
AND population_type = 'Permanent resident population'
AND gender = 'Sex - total'
AND age_group_1 = '62 years'
AND EXTRACT(YEAR FROM time_value) = 2013
AND spatialunit_name = 'Payerne';

-- What was the ratio of foreigners vs Swiss men in Basel in 2020?
SELECT
(SELECT SUM(value)
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category = 'Switzerland'
AND spatialunit_name = 'Basel'
AND EXTRACT(YEAR FROM time_value) = 2020)
/
(SELECT SUM(value)
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category = 'Foreign country'
AND spatialunit_name = 'Basel'
AND EXTRACT(YEAR FROM time_value) = 2020)
AS ratio;

-- How many Swiss citizen of 86 y.o. had been registered in 2020 in Basel?
SELECT value
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category = 'Switzerland'
AND age_group_1 = '86 years'
AND spatialunit_name = 'Basel'
AND EXTRACT(YEAR FROM time_value) = 2020;

-- What was the sum of women of 38 y.o. registered in Basel in 2013?
SELECT SUM(value)
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category = 'Switzerland'
AND gender = 'Female'
AND age_group_1 = '38 years'
AND EXTRACT(YEAR FROM time_value) = 2013
AND spatialunit_name = 'Basel';

-- What was the number of women of all age groups registered in The Canton of Zurich, the foreign countries, but having a permanent residence permit in Switzerland in 2013?
SELECT SUM(value)
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category = 'Foreign country'
AND population_type = 'Permanent resident population'
AND gender = 'Female'
AND age_group_1 = 'Age - total'
AND EXTRACT(YEAR FROM time_value) = 2019
AND spatialunit_name = 'Canton of Zurich';

-- How many men of 76 y.o. of Swtitzerland citizenship have been registered in Bezirk Meilen in 2019?
SELECT SUM(value)
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category = 'Switzerland'
AND population_type = 'Permanent resident population'
AND gender = 'Male' AND age_group_1 = '76 years'
AND EXTRACT(YEAR FROM time_value) = 2019
AND spatialunit_name = 'Bezirk Meilen';

-- What was the average of the Swss men of all ages registered in Bezirk Meilen in 2019?
SELECT AVG(value)
FROM resident_population_type_citizenship_category_gender_age
WHERE citizenship_category = 'Switzerland'
AND population_type = 'Permanent resident population'
AND gender = 'Male'
AND EXTRACT(YEAR FROM time_value) = 2019
AND spatialunit_name = 'Bezirk Meilen';

-- How many Swiss men have been registered in Friburg in 2020?
SELECT rp.amount
FROM experiment.resident_population_type_citizenship_category_gender_age as rp
JOIN experiment.spatial_unit as su ON rp.spatialunit_uid = su.spatialunit_uid
WHERE rp.year = '2019'
AND rp.citizenship_category = 'Switzerland'
AND rp.population_type = 'Permanent resident population'
AND rp.gender = 'Male'
AND rp.spatialunit_uid = '2196_A.ADM3'
AND rp.age_group = '30 years';