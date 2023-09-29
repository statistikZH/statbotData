-- What municipality in the canton Aargau had the most cars per inhabitant in 2020?
SELECT S.name
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2020
ORDER BY T.anzahl_personenwagen_pro_1000_einwohner DESC
LIMIT 1;

-- How many agricultural vehicles were there in the canton Aargau in 2010?
SELECT anzahl_landwirtschaftliche_motorfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name = "Canton Aargau"
    AND T.jahr=2010;

-- What was the number of commercial vehicles in 1960 and 1980 in the canton Aargau?
SELECT T.jahr, anzahl_nutzfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name = "Canton Aargau"
    AND T.jahr IN (1960, 1980);

-- How did the number of motorcycles and personal cars evolve in canton Aargau over the period between 1930 and 1960?
SELECT T.jahr, anzahl_motorrader, anzahl_klein_motorrader, anzahl_motorfahrrader, anzahl_personenwagen
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name = "Canton Aargau"
    AND T.jahr >= 1930
    AND T.jahr <= 1960;

-- What is the proportion of municipalities in canton Aargau where the number of cars per inhabitants increased between 2015 and 2022?
SELECT CAST(SUM(CASE WHEN T1.diff > 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(T1.diff)
FROM (
    SELECT
        SUM(CASE WHEN T.jahr = 2022 THEN T.anzahl_personenwagen_pro_1000_einwohner ELSE 0 END) -
        SUM(CASE WHEN T.jahr = 2015 THEN T.anzahl_personenwagen_pro_1000_einwohner ELSE 0 END) as diff
    FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal=TRUE
        AND T.jahr IN (2015, 2022)
    GROUP BY S.name
) as T1;

-- What was the number of trailers from 1998 to 2001 in Aarburg, AG?
SELECT T.jahr, T.anzahl_anhaenger
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name = "Aarburg"
    AND T.jahr >= 1998
    AND T.jahr <= 2001;

-- What were the top 3 municipalities in Aargau with the highest proportion of motorcycles vs cars in 2015? Also show the proportions.
SELECT
    S.name,
    CAST(T.anzahl_motorrader + T.anzahl_klein_motorrader + T.anzahl_motorfahrrader AS FLOAT) / T.anzahl_personenwagen AS ratio_motorrader_to_personenwagen
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2015
ORDER BY ratio_motorrader_to_personenwagen DESC
LIMIT 3;

-- What was the number of commercial vehicles in Abtwil, AG in 2000 ?
SELECT T.anzahl_nutzfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name = "Abtwil"
    AND T.jahr=2000;

-- How did the number of cars per inhabitant in Aargau evolve over the period between 2010 and 2022?
SELECT T.jahr, T.anzahl_personenwagen_pro_1000_einwohner
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name = "Canton Aargau"
    AND T.jahr >= 2010
    AND T.jahr <= 2022;

-- What were the 5 municipalities in Aargau with the fewest motorcycle per passenger car in 2015?
SELECT S.name
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE T.jahr=2015
    AND S.municipal=TRUE
ORDER BY CAST(T.anzahl_motorrader + T.anzahl_klein_motorrader + T.anzahl_motorfahrrader AS FLOAT) / T.anzahl_personenwagen ASC
LIMIT 5;
