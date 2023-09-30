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

-- How many of each private vehicle type were there in Ueken, in canton Aargau, in 2010?
SELECT
    T.anzahl_anhaenger,
    T.anzahl_arbeitsmotorfahrzeuge,
    T.anzahl_klein_motorrader,
    T.anzahl_kollektivfahrzeuge,
    T.anzahl_landwirtschaftliche_motorfahrzeuge,
    T.anzahl_motorfahrrader,
    T.anzahl_motorrader,
    T.anzahl_nutzfahrzeuge,
    T.anzahl_personenwagen,
    T.anzahl_ubrige_personen_transportfahrzeuge_kleinbusse_cars
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE T.jahr = 2010
    AND S.municipal = TRUE
    AND S.name = "Ueken";

-- In what year where there the most motorized work vehicles in Zuzgen, AG?
SELECT T.jahr
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = "Zuzgen"
GROUP BY T.jahr
ORDER BY T.anzahl_arbeitsmotorfahrzeuge DESC
LIMIT 1;

-- Where there more personal cars in 1930 or 1940 in canton Aargau?
SELECT T.jahr
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND T.jahr IN (1930, 1940)
GROUP BY T.jahr
ORDER BY T.anzahl_personenwagen DESC
LIMIT 1;

-- Show me 3 municipalities in Aargau where the number of personal cars per inhabitant has decreased the most between 2018 and 2022.
SELECT S.name
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr IN (2018, 2022)
GROUP BY S.name
ORDER BY
    (
        SUM(CASE WHEN T.jahr = 2022 THEN T.anzahl_personenwagen_pro_1000_einwohner ELSE 0 END) -
        SUM(CASE WHEN T.jahr = 2018 THEN T.anzahl_personenwagen_pro_1000_einwohner ELSE 0 END)
    ) DESC
LIMIT 3;

-- How municipalities in Aargau did not count any personal cars in 2020?
SELECT COUNT(*)
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten
WHERE jahr = 2020
    AND anzahl_personenwagen = 0;

-- How many small motorcycles where there in canton Aargau between 2000 and 2016?
SELECT T.jahr, T.anzahl_klein_motorrader
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND T.jahr <= 2016
    AND T.jahr >= 2000;


-- In Aargau, which of Zeihen and Zufikon had more personal cars per inhabitant in 2001?
SELECT S.name
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2001
    AND S.name IN ("Zeihen", "Zufikon")
ORDER BY T.anzahl_personenwagen_pro_1000_einwohner DESC
LIMIT 1;


-- How many agricultural vehicles where there in Rekingen, in Aargau between 1998 and 2000?
SELECT T.jahr, T.anzahl_landwirtschaftliche_motorfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name LIKE "Rekingen%"
    AND T.jahr >= 1998
    AND T.jahr <= 2000
ORDER BY T.jahr ASC;


-- How many collective vehicles where there in Wettingen, AG in 2022?
SELECT T.anzahl_kollektivfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = "Wettingen"
    AND T.jahr = 2022;

-- How many trailers where there in Suhr, Aargau in 2000?
SELECT T.anzahl_anhaenger
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = "Suhr"
    AND T.jahr = 2000;