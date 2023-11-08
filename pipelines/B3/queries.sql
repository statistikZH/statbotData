-- How many divorces were there in canton zurich in 2020?	"SELECT S.name, T.year, sum(T.amount) as total_divorces
FROM divorces_duration_of_marriage_age_classes as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name ilike '%Zurich%'
AND T.year=2020
AND S.canton=True
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_husband='Age class of husband - total'
AND T.age_class_wife='Age class of wife - total'
GROUP BY S.name, T.year;

-- How many men divorced at an age between 60 and 69 in canton zurich in 2020?SELECT S.name, T.year, T.age_class_husband, sum(T.amount) AS total_divorces
FROM divorces_duration_of_marriage_age_classes as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name ilike '%Zurich%'
AND T.year=2020
AND S.canton=True
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_husband='60-69 years'
AND T.age_class_wife='Age class of wife - total'
GROUP BY S.name, T.year, T.age_class_husband;

-- How many women divorced at age between 20 and 29 in canton zurich in 2020?
SELECT S.name, T.year, T.age_class_wife, sum(T.amount) as total_divorces
FROM divorces_duration_of_marriage_age_classes as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name ilike '%Zurich%'
AND T.year=2020
AND S.canton=True
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_husband='Age class of husband - total'
AND T.age_class_wife='20-29 years'
GROUP BY S.name, T.year, T.age_class_wife;

-- Which Kanton had the most divorces in 2015?
SELECT S.name, T.year, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year = 2015
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_husband='Age class of husband - total'
AND T.age_class_wife='Age class of wife - total'
AND S.canton
GROUP BY S.name, T.year
ORDER BY total_divorces DESC
LIMIT 1;

-- How many couples were divorced in Switzerland in the year 2000?
SELECT T.year, S.name, sum(T.amount) as total_divorces
FROM divorces_duration_of_marriage_age_classes as T
JOIN spatial_unit AS S ON T.spatialunit_uid = s.spatialunit_uid
WHERE S.country
AND T.year='2000'
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_husband='Age class of husband - total'
AND T.age_class_wife='Age class of wife - total'
GROUP BY S.name, T.year;

-- How many marriages in Switzerland got divorced after less then 5 years in 2000?
SELECT sum(amount) AS total_divorces
FROM divorces_duration_of_marriage_age_classes as T
JOIN spatial_unit AS S ON T.spatialunit_uid = s.spatialunit_uid
WHERE S.country
AND T.year='2000'
AND T.duration_of_marriage='0-4 years'
AND T.age_class_husband='Age class of husband - total'
AND T.age_class_wife='Age class of wife - total';

-- What was the prominent age for men that divorced in Switzerland in 2000?
SELECT T.age_class_husband, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year = 2000
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_wife='Age class of wife - total'
AND T.age_class_husband!='Age class of husband - total'
AND S.country
GROUP BY T.age_class_husband
ORDER BY total_divorces DESC
LIMIT 1;

-- What was the prominent age for women that divorced in Switzerland in 2000?
SELECT T.age_class_wife, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year = 2000
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_wife!='Age class of wife - total'
AND T.age_class_husband='Age class of husband - total'
AND S.country
GROUP BY T.age_class_wife
ORDER BY total_divorces DESC
LIMIT 1;

-- From 2000 to 2022 which year saw the most divorces in Switzerland?
SELECT T.year, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year >= 2000
AND T.year <= 2022
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_wife='Age class of wife - total'
AND T.age_class_husband='Age class of husband - total'
AND S.country
GROUP BY T.year
ORDER BY total_divorces DESC
LIMIT 1;

-- Did 2020 have more divorces than 2019?
SELECT T.year, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE (T.year=2019 OR T.year=2020)
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_wife='Age class of wife - total'
AND T.age_class_husband='Age class of husband - total'
AND S.country
GROUP BY T.year
ORDER BY T.year DESC;

-- How many divorces happened in Basel in 2015 and after how many years of marriage?
SELECT S.name, S.spatialunit_ontology, T.year, T.duration_of_marriage, SUM(T.amount) AS total_divorces
FROM divorces_duration_of_marriage_age_classes AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE T.year=2015
AND T.duration_of_marriage!='Duration of marriage - total'
AND T.age_class_wife='Age class of wife - total'
AND T.age_class_husband='Age class of husband - total'
AND S.name ilike '%basel%'
GROUP BY T.year, T.duration_of_marriage, S.spatialunit_ontology, S.name;

-- Which Kanton had the most divorces after only a short marriage in 2020?
SELECT S.name, T.duration_of_marriage, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year = 2020
AND T.duration_of_marriage='0-4 years'
AND T.age_class_husband='Age class of husband - total'
AND T.age_class_wife='Age class of wife - total'
AND S.canton
GROUP BY S.name, T.duration_of_marriage
ORDER BY total_divorces DESC
LIMIT 1;

-- Which Kanton had the most divorces after only a very long marriage in 2020?
SELECT S.name, T.duration_of_marriage, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year = 2020
AND T.duration_of_marriage='20 years or more'
AND T.age_class_husband='Age class of husband - total'
AND T.age_class_wife='Age class of wife - total'
AND S.canton
GROUP BY S.name, T.duration_of_marriage
ORDER BY total_divorces DESC
LIMIT 1;

-- How did the amount of divorces in Switzerland develop since 1990?
SELECT T.year, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year >= 1990
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_wife='Age class of wife - total'
AND T.age_class_husband='Age class of husband - total'
AND S.country
GROUP BY T.year
ORDER BY T.year;

-- Which Canton had the least divorces in 2002?
SELECT T.year, T.duration_of_marriage, T.amount AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year >= 1990
AND T.duration_of_marriage!='Duration of marriage - total'
AND T.age_class_wife='Age class of wife - total'
AND T.age_class_husband='Age class of husband - total'
AND S.country
GROUP BY T.year, T.duration_of_marriage, T.amount
ORDER BY T.year, T.duration_of_marriage;

-- Which year between 1990 and 2000 had the least divorces in Stadt Basel?
SELECT S.name, T.year, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year >= 1990
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_husband='Age class of husband - total'
AND T.age_class_wife='Age class of wife - total'
AND S.country
GROUP BY S.name, T.year
ORDER BY T.year;

-- Did any men divorce at an age of 90 or above in Switzerland in 2000?
SELECT S.name, T.age_class_husband, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year = 2000
AND T.duration_of_marriage='Duration of marriage - total'
AND T.age_class_husband='90 years or older'
AND T.age_class_wife='Age class of wife - total'
AND S.country
GROUP BY S.name, T.age_class_husband
ORDER BY total_divorces ASC
LIMIT 1;

-- Did any people divorce at an age of 70 or above in Switzerland in 2000?
SELECT S.name, T.age_class_husband, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year = 2000
AND T.duration_of_marriage='Duration of marriage - total'
AND (T.age_class_husband='90 years or older' OR T.age_class_husband='70-79 years')
AND T.age_class_wife='Age class of wife - total'
AND S.country
GROUP BY S.name, T.age_class_husband;

-- Did any person divorce at an age of 90 or above in Switzerland since 2000?
SELECT S.name, T.age_class_husband, T.age_class_wife, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year >= 2000
AND T.duration_of_marriage='Duration of marriage - total'
AND ((T.age_class_husband='90 years or older'
          AND T.age_class_wife='Age class of wife - total')
        OR (T.age_class_wife='90 years or older'
         AND T.age_class_husband='Age class of husband - total'))
AND S.country
GROUP BY S.name, T.age_class_husband, T.age_class_wife
ORDER BY total_divorces ASC;

-- In Canton Uri how many marriages where divorced in 2003 after more than 10 years?
SELECT S.name, T.duration_of_marriage, SUM(T.amount) AS total_divorces
FROM spatial_unit AS S
INNER JOIN divorces_duration_of_marriage_age_classes AS T
ON S.spatialunit_uid = T.spatialunit_uid
WHERE T.year = 2003
AND (T.duration_of_marriage='10-14 years'
         OR T.duration_of_marriage='15-19 years'
         OR T.duration_of_marriage='20 years or more')
AND T.age_class_husband='Age class of husband - total'
AND T.age_class_wife='Age class of wife - total'
AND S.canton AND S.name ilike '% Uri%'
GROUP BY S.name, T.duration_of_marriage
ORDER BY T.duration_of_marriage DESC;