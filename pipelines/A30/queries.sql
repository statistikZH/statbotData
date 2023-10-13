-- How many sales of residential building land were there in kanton Zürich in 2015 and 2021?
SELECT T.jahr, T.faelle
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr IN (2015, 2021);

-- In what year did the average price for housing land in canton Zurich increase the most (in CHF) compared to the previous year?
SELECT T.jahr
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
ORDER BY T.durschnitt_preis_chf_pro_m2 - LAG(T.durschnitt_preis_chf_pro_m2) OVER (ORDER BY T.jahr) DESC
LIMIT 1;

-- What was the average price per square meter for residential building land in canton Zurich between 1980 and 2000?
SELECT AVG(T.durschnitt_preis_chf_pro_m2) AS durschnitt_preis_chf_pro_m2_1980_2000
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr >= 1980
    AND T.jahr <= 2000;

-- In what year was the interquartile range of the price per square meter for residential building land the highest in canton Zurich, and how much was it?
SELECT T.jahr, T.quantil_75_preis_chf_pro_m2 - T.quantil_25_preis_chf_pro_m2 AS interquartilabstand_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
ORDER BY interquartilabstand_preis_chf_pro_m2 DESC
LIMIT 1;

-- What is the ratio between the price of housing land in canton Zurich in 2020 and 1980?
SELECT
    (
        SUM(CASE WHEN T.jahr = 2020 THEN T.durschnitt_preis_chf_pro_m2 END) /
        SUM(CASE WHEN T.jahr = 1980 THEN T.durschnitt_preis_chf_pro_m2 END)
    ) AS preis_ratio_2020_1980
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr IN (1980, 2020);

-- When did the median price of residential building land reach its peak in canton Zürich?
SELECT T.jahr
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
ORDER BY T.median_preis_chf_pro_m2 DESC
LIMIT 1;

-- Show me the median price of residential land in canton Zurich for each year between 2010 and 2020.
SELECT T.jahr, T.median_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr >= 2010
    AND T.jahr <= 2020;

-- Show me all available statistical indicators for the price of residential land in canton Zurich for each year between 2017 and 2021.
SELECT
    T.jahr,
    T.quantil_25_preis_chf_pro_m2,
    T.median_preis_chf_pro_m2,
    T.quantil_75_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr >= 2017
    AND T.jahr <= 2021;

-- What was the 3rd quartile of the price of residential land in canton Zurich in 2015?
SELECT T.quantil_75_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr = 2015;

-- What was the 50th percentile of the price of residential land in canton Zurich in 2012 and 2014?
SELECT T.jahr, T.median_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr IN (2012, 2014);

-- How many sales of residential building land were there in total in kanton Zürich over the period 1990-2010?
SELECT SUM(T.faelle) AS faelle_1990_2010
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE
    S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr >= 1990
    AND T.jahr <= 2010;