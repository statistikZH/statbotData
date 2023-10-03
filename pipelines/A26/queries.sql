-- How much insurance money was claimed in total for fire-related incidents in Aargau in 2017 in CHF?
SELECT T.total_schaden_1000_chf * 1000 AS total_schaden_chf
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2017;

-- How many fire-related incidents were there in Aargau in 2011?
SELECT T.total_anzahl_schadenfalle
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2011;

-- How many explosions and arsons were recorded in Aargau in 2000?
SELECT T.explosion_anzahl_schadenfalle, T.vorsatzliche_brandstift_anzahl_schadenfalle
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2000;

-- In what year were the most arsons reported in Aargau?
SELECT T.jahr
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
ORDER BY T.vorsatzliche_brandstift_anzahl_schadenfalle DESC
LIMIT 1;

-- What were the 3 most frequent causes of fire-related incidents reported in Aargau in 1985?
WITH T1 AS (
    SELECT *
    FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.canton = TRUE
        AND S.name LIKE '%Aargau%'
        AND T.jahr = 1985
)
SELECT T2.source_name
FROM (
    SELECT T1.feuerzeug_rauchzeug_licht_anzahl_schadenfalle as source, 'feuerzeug_rauchzeug_licht_anzahl_schadenfalle' as source_name
    FROM T1
        UNION ALL
    SELECT T1.elektrizitaet_anzahl_schadenfalle as source, 'elektrizitaet_anzahl_schadenfalle' as source_name
    FROM T1
        UNION ALL
    SELECT T1.vorsatzliche_brandstift_anzahl_schadenfalle as source, 'vorsatzliche_brandstift_anzahl_schadenfalle' as source_name
    FROM T1
        UNION ALL
    SELECT T1.feuerungsanlagen_anzahl_schadenfalle as source, 'feuerungsanlagen_anzahl_schadenfalle' as source_name
    FROM T1
        UNION ALL
    SELECT T1.explosion_anzahl_schadenfalle as source, 'explosion_anzahl_schadenfalle' as source_name
    FROM T1
        UNION ALL
    SELECT T1.uebrige_anzahl_schadenfalle as source, 'uebrige_anzahl_schadenfalle' as source_name
    FROM T1
        UNION ALL
    SELECT T1.unbekannt_anzahl_schadenfalle as source, 'unbekannt_anzahl_schadenfalle' as source_name
    FROM T1
) AS T2
ORDER BY T2.source DESC
LIMIT 3;

-- What cause of fire-related incidents cost the most money to insurances in Aargau in 2020?
WITH T1 AS (
    SELECT *
    FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.canton = TRUE
        AND S.name LIKE '%Aargau%'
        AND T.jahr = 2020
)
SELECT T2.source_name
FROM (
    SELECT T1.feuerzeug_rauchzeug_licht_schaden_1000_chf as source, 'feuerzeug_rauchzeug_licht_schaden_1000_chf' as source_name
    FROM T1
        UNION ALL
    SELECT T1.elektrizitaet_schaden_1000_chf as source, 'elektrizitaet_schaden_1000_chf' as source_name
    FROM T1
        UNION ALL
    SELECT T1.vorsatzliche_brandstift_schaden_1000_chf as source, 'vorsatzliche_brandstift_schaden_1000_chf' as source_name
    FROM T1
        UNION ALL
    SELECT T1.feuerungsanlagen_schaden_1000_chf as source, 'feuerungsanlagen_schaden_1000_chf' as source_name
    FROM T1
        UNION ALL
    SELECT T1.explosion_schaden_1000_chf as source, 'explosion_schaden_1000_chf' as source_name
    FROM T1
        UNION ALL
    SELECT T1.uebrige_schaden_1000_chf as source, 'uebrige_schaden_1000_chf' as source_name
    FROM T1
        UNION ALL
    SELECT T1.unbekannt_schaden_1000_chf as source, 'unbekannt_schaden_1000_chf' as source_name
    FROM T1
) AS T2
ORDER BY T2.source DESC
LIMIT 1;

-- In percent, how did the number of electrical fires change from 1990 to 2020 in canton Aargau?
SELECT 100.0 * (T1.anzahl_2020 - T1.anzahl_1990) / T1.anzahl_1990 AS prozent_anderung_elektrizitaet_anzahl_schadenfalle_1990_2020
FROM (
    SELECT
        SUM(CASE WHEN T.jahr = 1990 THEN T.elektrizitaet_anzahl_schadenfalle ELSE 0 END) AS anzahl_1990,
        SUM(CASE WHEN T.jahr = 2020 THEN T.elektrizitaet_anzahl_schadenfalle ELSE 0 END) AS anzahl_2020
    FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.canton = TRUE
        AND S.name LIKE '%Aargau%'
        AND T.jahr IN (1990, 2020)
) AS T1;
-- How much did fire incidents caused by explosions cost in CHF to insurances in canton Aargau in years 1980, 1990, 2000 and 2010?
SELECT T.jahr, T.explosion_schaden_1000_chf * 1000 AS explosion_schaden_chf
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr IN (1980, 1990, 2000, 2010)
ORDER BY T.jahr DESC;

-- What was the cost in CHF of fire-damage caused by electricity and explosions in canton Aargau every year between 2001 and 2007?
SELECT T.jahr, T.elektrizitaet_schaden_1000_chf * 1000 AS elektrizitaet_schaden_chf
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr >= 2001
    AND T.jahr <= 2007
ORDER BY T.jahr DESC;

-- How much CHF did fire incidents from unknown sources cost in Aargau in 2020?
SELECT T.unbekannt_schaden_1000_chf * 1000 AS unbekannt_schaden_chf
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2020;

-- What percentage of the number of fire-related incidents came from unknown causes in Aargau in 2018?
SELECT T.unbekannt_anzahl_schadenfalle * 100.0 / T.total_anzahl_schadenfalle AS unbekannt_anzahl_schadenfalle_prozent
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2018;

-- How many arsons were reported in total from 1980 to 2020 in canton Aargau?
SELECT SUM(T.vorsatzliche_brandstift_anzahl_schadenfalle)
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr >= 1980
    AND T.jahr <= 2020;