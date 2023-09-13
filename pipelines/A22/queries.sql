-- How many protestants were there in kanton Basel-Landschaft in early 2022?
SELECT SUM(T.anzahl_evangelisch_reformiert)
FROM bevolkerungsbestand_nach_nationalitat_konfession_gemeinde_und_quartal_seit_2003 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr="2022"
    AND T.quartal="1";

-- What proportion of Basel-Landschaft's population were of a known religion in 2021?
SELECT 1 - (
    SUM(CAST(T.anzahl_unbekannt_konfession AS FLOAT)) / SUM(T.gesamt_anzahl_personen)
) AS proportion_known_religion_basel_land_2021
FROM bevolkerungsbestand_nach_nationalitat_konfession_gemeinde_und_quartal_seit_2003 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr="2021"
GROUP BY T.jahr;

-- In 2021, among the foreign residents of Canton Basel-Landschaft, what was the proportion of Roman catholics?
SELECT SUM(CAST(T.anzahl_romisch_katholisch AS FLOAT)) / SUM(T.gesamt_anzahl_personen) AS proportion_foreign_romisch_katholisch_basel_land_2021
FROM bevolkerungsbestand_nach_nationalitat_konfession_gemeinde_und_quartal_seit_2003 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr="2021"
    AND T.nationalitat="Ausland";

-- What were the 5 municipalities with the highest proportion of protestants in Basel-Landschaft in 2008?
SELECT S.name, CAST(SUM(T.anzahl_evangelisch_reformiert) AS FLOAT) / SUM(T.gesamt_anzahl_personen) as proportion_protestants_2008
FROM bevolkerungsbestand_nach_nationalitat_konfession_gemeinde_und_quartal_seit_2003 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr="2008"
GROUP BY S.name
ORDER BY proportion_protestants_2008 DESC
LIMIT 5;

-- What was the proportion of municipalities in Basel-Landschaft where there were more catholics than reformed among Swiss residents in 2018?
SELECT SUM(
    (anzahl_romisch_katholisch + anzahl_christkatholisch) > anzahl_evangelisch_reformiert
) / CAST(COUNT(anzahl_evangelisch_reformiert) AS FLOAT) AS proprtion_municipalities_more_catholics_than_reformed_2018
FROM (
    SELECT
        S.name as municipality,
        AVG(T.anzahl_christkatholisch) as anzahl_christkatholisch,
        AVG(T.anzahl_romisch_katholisch) as anzahl_romisch_katholisch,
        AVG(T.anzahl_evangelisch_reformiert) as anzahl_evangelisch_reformiert
    FROM bevolkerungsbestand_nach_nationalitat_konfession_gemeinde_und_quartal_seit_2003 as T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal=TRUE
        AND T.jahr="2018"
        AND T.nationalitat="Schweiz"
    GROUP BY S.name
);

-- How did the proportion of christians change between 2006 and 2022 in Basel-Landschaft?

-- How many municipalities are there in Basel-Landschaft where each religious confession is in majority?

-- What are the top 5 municipalities with the highest proportion of foreign residents in canton Basel-Landschaft in 2022 ?

-- How many swiss residents Binningen, BL are roman catholic?

-- Among the foreign residents of Ettingen, in Canton Basel-Landschaft, what proportion are of unknown confession?

-- Between the municipalities of Arlesheim and Birsfelden in Basel-Landschaft, which one has a higher proportion of protestants?

-- How did the number of reformed evangelics evolve in Allschwil, in Canton Basel-Landschaft, between 2010 and 2015?
