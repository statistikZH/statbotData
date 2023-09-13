-- How many protestants were there in kanton Basel-Landschaft in early 2022?
SELECT SUM(T.anzahl_evangelisch_reformiert)
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2022
    AND T.quartal=1;

-- What proportion of Basel-Landschaft's population were of a known religion in 2021?
SELECT 1 - (
    SUM(CAST(T.anzahl_unbekannt_konfession AS FLOAT)) / SUM(T.gesamt_anzahl_personen)
) AS proportion_known_religion_basel_land_2021
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2021
GROUP BY T.jahr;

-- In 2021, among the foreign residents of Canton Basel-Landschaft, what was the proportion of Roman catholics?
SELECT SUM(CAST(T.anzahl_romisch_katholisch AS FLOAT)) / SUM(T.gesamt_anzahl_personen) AS proportion_foreign_romisch_katholisch_basel_land_2021
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2021
    AND T.nationalitat="Ausland";

-- What were the 5 municipalities with the highest proportion of protestants in Basel-Landschaft in 2008?
SELECT S.name, CAST(SUM(T.anzahl_evangelisch_reformiert) AS FLOAT) / SUM(T.gesamt_anzahl_personen) as proportion_protestants_2008
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2008
GROUP BY S.name
ORDER BY proportion_protestants_2008 DESC
LIMIT 5;

-- What was the proportion of municipalities in Basel-Landschaft where there were more catholics than protestants among Swiss residents in 2018?
SELECT SUM(
    (anzahl_romisch_katholisch + anzahl_christkatholisch) > anzahl_evangelisch_reformiert
) / CAST(COUNT(anzahl_evangelisch_reformiert) AS FLOAT) AS proprtion_municipalities_more_catholics_than_reformed_2018
FROM (
    SELECT
        S.name as municipality,
        AVG(T.anzahl_christkatholisch) as anzahl_christkatholisch,
        AVG(T.anzahl_romisch_katholisch) as anzahl_romisch_katholisch,
        AVG(T.anzahl_evangelisch_reformiert) as anzahl_evangelisch_reformiert
    FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal=TRUE
        AND T.jahr=2018
        AND T.nationalitat="Schweiz"
    GROUP BY S.name
);

-- Show me the evolution of the population of Pratteln, in Basel-Landschaft, between 2017 and 2019.
SELECT T.jahr, T.quartal, SUM(T.gesamt_anzahl_personen) as population
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name="Pratteln"
    AND T.jahr>=2017
    AND T.jahr<=2019
GROUP BY T.jahr, T.quartal
ORDER BY T.jahr, T.quartal ASC;


-- What were the 3 municipalities with the highest proportion of foreign residents in canton Basel-Landschaft in late 2022 ?
SELECT S.name, SUM(CASE WHEN T.nationalitat="Ausland" THEN T.gesamt_anzahl_personen ELSE 0 END) / CAST(SUM(T.gesamt_anzahl_personen) AS FLOAT) AS proportion_foreign_residents
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2022
    AND T.quartal=4
GROUP BY S.name
ORDER BY proportion_foreign_residents DESC
LIMIT 3;

-- How many swiss residents Binningen, BL were roman catholic during the year 2005?
SELECT T.jahr, T.quartal, T.anzahl_romisch_katholisch
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name="Binningen"
    AND T.jahr=2005
    AND T.nationalitat="Schweiz";

-- Among the foreign residents of Ettingen, in Canton Basel-Landschaft, what proportion are of unknown confession?

-- Between the municipalities of Arlesheim and Birsfelden in Basel-Landschaft, which one has a higher proportion of protestants?

-- How did the number of reformed evangelics evolve in Allschwil, in Canton Basel-Landschaft, between 2010 and 2015?
