-- Wie viele Reformierte gab es im Kanton Basel-Landschaft Anfang 2022?
SELECT SUM(T.anzahl_evangelisch_reformiert)
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2022
    AND T.quartal=1;

-- Welcher Anteil der Bevölkerung von Basel-Landschaft gehörte 2021 einer bekannten Religion an?
SELECT 1 - (
    SUM(CAST(T.anzahl_unbekannt_konfession AS FLOAT)) / SUM(T.gesamt_anzahl_personen)
) AS proportion_known_religion_basel_land_2021
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2021
GROUP BY T.jahr;

-- Wie hoch war der Anteil der römisch-katholischen Personen an der ausländischen Bevölkerung des Kantons Basel-Landschaft im Jahr 2021?
SELECT SUM(CAST(T.anzahl_romisch_katholisch AS FLOAT)) / SUM(T.gesamt_anzahl_personen) AS proportion_foreign_romisch_katholisch_basel_land_2021
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2021
    AND T.nationalitat="Ausland";

-- Welche 5 Gemeinden hatten 2008 den höchsten Anteil an Reformierten im Kanton Basel-Landschaft?
SELECT S.name, CAST(SUM(T.anzahl_evangelisch_reformiert) AS FLOAT) / SUM(T.gesamt_anzahl_personen) as proportion_protestants_2008
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2008
GROUP BY S.name
ORDER BY proportion_protestants_2008 DESC
LIMIT 5;

-- Wie hoch war der Anteil der Gemeinden im Kanton Basel-Landschaft, in denen es 2018 mehr Katholiken als Protestanten unter der Schweizer Bevölkerung gab?
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

-- Zeigen Sie mir die Entwicklung der Bevölkerung von Pratteln, in Basel-Landschaft, zwischen 2017 und 2019.
SELECT T.jahr, T.quartal, SUM(T.gesamt_anzahl_personen) as population
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name="Pratteln"
    AND T.jahr>=2017
    AND T.jahr<=2019
GROUP BY T.jahr, T.quartal
ORDER BY T.jahr, T.quartal ASC;


-- Welches waren Ende 2022 die 3 Gemeinden mit dem höchsten Ausländeranteil im Kanton Basel-Landschaft?
SELECT S.name, SUM(CASE WHEN T.nationalitat="Ausland" THEN T.gesamt_anzahl_personen ELSE 0 END) / CAST(SUM(T.gesamt_anzahl_personen) AS FLOAT) AS proportion_foreign_residents
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2022
    AND T.quartal=4
GROUP BY S.name
ORDER BY proportion_foreign_residents DESC
LIMIT 3;

-- Wie viele Schweizer Einwohner hatte Binningen, BL im Jahr 2005?
SELECT T.jahr, T.quartal, T.anzahl_romisch_katholisch
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name="Binningen"
    AND T.jahr=2005
    AND T.nationalitat="Schweiz";

-- Welcher Anteil der ausländischen Bevölkerung von Ettingen, BL, hatte 2011 eine unbekannte Konfession?
SELECT SUM(CAST(T.anzahl_unbekannt_konfession AS FLOAT)) / SUM(T.gesamt_anzahl_personen) AS proportion_unknown_religion_ettingen_2011
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name="Ettingen"
    AND T.nationalitat="Ausland"
    AND T.jahr=2011;

-- Zwischen den Gemeinden Arlesheim und Birsfelden im Kanton Basel-Landschaft, welche hatte 2003 einen höheren Anteil an Protestanten?
SELECT S.name, CAST(SUM(T.anzahl_evangelisch_reformiert) AS FLOAT) / SUM(T.gesamt_anzahl_personen) as proportion_protestants_2003
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name IN ("Ettingen", "Birsfelden")
    AND T.jahr=2003
GROUP BY S.name
ORDER BY proportion_protestants_2003 DESC;

-- Wie hat sich die Anzahl der Reformierten in Allschwil, im Kanton Basel-Landschaft, zwischen 2010 und 2015 entwickelt?
SELECT T.jahr, T.quartal, SUM(T.anzahl_evangelisch_reformiert) as number_reformed_evangelics
FROM basel_land_bevolkerung_nach_nationalitat_konfession_gemeinde as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name="Allschwil"
    AND T.jahr>=2010
    AND T.jahr<=2015
GROUP BY T.jahr, T.quartal;
