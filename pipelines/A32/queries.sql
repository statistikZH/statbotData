-- What was residential area in Basel Stadt with the highest unemployment rate in 2016? Also report its unemployment rate.
SELECT S.name, T.arbeitslosenquote
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2016
ORDER BY T.arbeitslosenquote DESC
LIMIT 1;

-- What was the relative change (in %) in the proportion of foreigners between 2018 and 2023 in each residential area of Basel-Stadt?
SELECT
    S.name,
    (   100.0 *
        SUM(CASE WHEN T.jahr = 2023 THEN T.anteil_auslander ELSE -T.anteil_auslander END) /
        SUM(CASE WHEN T.jahr = 2018 THEN T.anteil_auslander END)
    ) AS prozent_aenderung_anteil_auslander_2018_2023
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr IN (2018, 2023)
GROUP BY S.name ;

-- What were the Altersquotient and Jugendquotient in Gundelingen, BS in 2015, 2017 and 2019?
SELECT T.jahr, T.altersquotient_uber_64_jahr, T.jugendquotient_unter_20_jahr
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Gundeldingen'
    AND T.jahr IN (2015, 2017, 2019);

-- What are the names of the 3 Basel-Stadt residential areas with the smallest living area per inhabitant in 2020?
SELECT S.name
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2020
ORDER BY T.wohnflache_pro_person_m2 ASC
LIMIT 3;

-- What year had the highest recorded unemployment rate in Vorstädte (BS)?
SELECT T.jahr
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Vorstädte'
ORDER BY T.arbeitslosenquote ASC
LIMIT 1;

-- What was the proportion of people without religious affiliation in 2015 and 2018 for Bachletten and St. Alban, BS?
SELECT
    S.name,
    T.jahr,
    T.anteil_personen_ohne_religionszugehorigkeit
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr IN (2015, 2018)
    AND S.name IN ('St. Alban', 'Bachletten');

-- Which residential area in Basel-Stadt had the oldest buildings on average in 2023, and what was the average construction date?
SELECT S.name, T.baujahr_der_wohngebaude
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2023
ORDER BY T.baujahr_der_wohngebaude ASC
LIMIT 1;

-- Show me employment related statistics about Iselin (BS)
SELECT T.jahr, T.arbeitsplatze_pro_einwohner, T.arbeitslosenquote
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Iselin'
ORDER BY T.jahr ASC;

-- How did the living area per inhabitant evolve throughout the period 2015 - 2019 in Altstadt Grossbasel?
SELECT T.jahr, T.wohnflache_pro_person_m2
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Altstadt Grossbasel'
    AND T.jahr >= 2015
    AND T.jahr <= 2019
ORDER BY T.jahr ASC;

-- Which 3 residential areas in Basel had the lowest proportion of social welfare recipients in 2015, and what were the proportions?
SELECT S.name, T.anteil_sozialhilfeempfanger
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2015
ORDER BY T.anteil_sozialhilfeempfanger ASC
LIMIT 3;

-- What is the time-range for which employment-related statistics are available about Basel-stadt residential areas?
SELECT MIN(T.jahr) erste_jahr, MAX(T.jahr) AS letzte_jahr
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE ;

-- How did the proportion of green area change (in percent) from 2015 to 2022 in each residential area of Basel-Stadt?
SELECT
    S.name,
    (   100.0 *
        SUM(CASE WHEN T.jahr = 2022 THEN T.anteil_grunflachen ELSE -T.anteil_grunflachen END) /
        SUM(CASE WHEN T.jahr = 2015 THEN T.anteil_grunflachen END)
    ) AS prozent_aenderung_anteil_grunflachen_2018_2022
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr IN (2015, 2022)
GROUP BY S.name
ORDER BY prozent_aenderung_anteil_grunflachen_2018_2022 DESC;

-- What proportion of secondary school students in BruderHolz, in Basel-Stadt, were in progymnasium classes in 2016 and 2020?
SELECT T.jahr, T.gymnasialquote_anteil_progymnasium
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Bruderholz'
    AND T.jahr IN (2016, 2020);