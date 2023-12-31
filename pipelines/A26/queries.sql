-- Wie hoch waren die Versicherungssummen für Brandschäden im Aargau im Jahr 2017 insgesamt in CHF?
SELECT T.total_schaden_1000_chf * 1000 AS total_schaden_chf
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2017;

-- Wie viele Brandfälle gab es im Jahr 2011 im Aargau?
SELECT T.total_anzahl_schadenfalle
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2011;

-- Wie viele Explosionen und Brandstiftungen wurden im Jahr 2000 im Aargau registriert?
SELECT T.explosion_anzahl_schadenfalle, T.vorsatzliche_brandstift_anzahl_schadenfalle
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2000;

-- In welchem Jahr wurden im Aargau die meisten Brandstiftungen gemeldet?
SELECT T.jahr
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
ORDER BY T.vorsatzliche_brandstift_anzahl_schadenfalle DESC
LIMIT 1;

-- Welches waren die 3 häufigsten Ursachen für Brandfälle im Aargau im Jahr 1985?
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

-- Welche Brandursache kostet die Aargauer Versicherungen im Jahr 2020 am meisten Geld?
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

-- In Prozent, wie hat sich die Zahl der Elektrobrände im Kanton Aargau von 1990 bis 2020 verändert?
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

-- Wie viel kosteten Brandfälle durch Explosionen die Versicherer im Kanton Aargau in den Jahren 1980, 1990, 2000 und 2010 in CHF?
SELECT T.jahr, T.explosion_schaden_1000_chf * 1000 AS explosion_schaden_chf
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr IN (1980, 1990, 2000, 2010)
ORDER BY T.jahr DESC;

-- Wie hoch waren die jährlichen Kosten in CHF für die durch Elektrizität und Explosionen verursachten Brandschäden im Kanton Aargau in den Jahren 2001 bis 2007?
SELECT T.jahr, T.elektrizitaet_schaden_1000_chf * 1000 AS elektrizitaet_schaden_chf
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr >= 2001
    AND T.jahr <= 2007
ORDER BY T.jahr DESC;

-- Wie viel Franken kosteten Brandeinsätze aus unbekannter Ursache im Aargau im Jahr 2020?
SELECT T.unbekannt_schaden_1000_chf * 1000 AS unbekannt_schaden_chf
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2020;

-- Wie hoch (in prozent) ist der Anteil unbekannter Ursachen an der Zahl der Brandfälle im Aargau im Jahr 2018?
SELECT T.unbekannt_anzahl_schadenfalle * 100.0 / T.total_anzahl_schadenfalle AS unbekannt_anzahl_schadenfalle_prozent
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr = 2018;

-- Wie viele Brandstiftungen wurden von 1980 bis 2020 im Kanton Aargau insgesamt gemeldet?
SELECT SUM(T.vorsatzliche_brandstift_anzahl_schadenfalle)
FROM aargau_brandversicherung_brandschaden_anzahl_schadensummen AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE '%Aargau%'
    AND T.jahr >= 1980
    AND T.jahr <= 2020;