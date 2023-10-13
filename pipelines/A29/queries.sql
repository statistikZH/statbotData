-- Wann erreichte die Kohlenmonoxidkonzentration in der Luft in der Stadt Zürich ihr Maximum? Geben Sie auch die Konzentration in mg/m3 an.
SELECT T.jahr, T.monat, T.co_mg_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.co_mg_m3 IS NOT NULL
ORDER BY T.co_mg_m3 DESC
LIMIT 1;

-- In welchem Monat gibt es in der Stadt Zürich generell am wenigsten Partikel in der Luft?
SELECT T.monat, SUM(T.pn_1_cm3) / COUNT(T.pn_1_cm3) AS monat_avg_pn_1_cm3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.pn_1_cm3 IS NOT NULL
GROUP BY T.monat
ORDER BY SUM(T.pn_1_cm3) / COUNT(T.pn_1_cm3) ASC
LIMIT 1;

-- Wie hoch war die monatliche Stickoxidkonzentration (in Teilen pro Milliarde) in der Stadt Zürich im Jahr 2019?
SELECT T.monat, T.nox_ppb
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr = 2019
ORDER BY T.monat ASC;

-- Wie hoch war die jährliche Durchschnittskonzentration von Stickstoffmonoxid und Stickstoffdioxid in der Stadt Zürich in den Jahren 1993, 2003, 2013 und 2023?
SELECT T.jahr, SUM(T.no_ug_m3) / COUNT(T.no_ug_m3) AS jahr_avg_no_ug_m3, SUM(T.no2_ug_m3) / COUNT(T.no2_ug_m3) AS avg_no2_ug_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr IN (1993, 2003, 2013, 2023)
    AND T.no_ug_m3 IS NOT NULL
GROUP BY T.jahr;

-- Welches war die niedrigste Feinstaubkonzentration (PM2.5), die je in Zürich gemessen wurde, und in welchem Jahr war dies?
SELECT T.jahr, T.pm2_5_ug_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.pm2_5_ug_m3 IS NOT NULL
ORDER BY T.pm2_5_ug_m3 ASC
LIMIT 1;

-- Wie hoch war die Schwefeldioxidkonzentration in der Luft in Zürich im Jahr 2019? Geben Sie die Konzentration in Milligramm pro Kubikmeter an.
SELECT T.monat, T.so2_ug_m3 / 1000 AS so2_mg_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr = 2019
ORDER BY T.monat ASC;

-- Wie hoch war die CO- und SO2-Konzentration (beide in Mikrogramm/m3) in Zürich zwischen Oktober 1999 und Juli 2000?
SELECT T.jahr, T.monat, T.co_mg_m3 * 1000 AS co_ug_m3, T.so2_ug_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND
    (
        (T.jahr = 1999 AND T.monat >= 10)
        OR (T.jahr = 2000 AND T.monat <= 7)
    )
    AND T.co_mg_m3 IS NOT NULL
ORDER BY T.jahr ASC, T.monat ASC;

-- Zeigen Sie mir die mittlere PM10- und PM2.5-Konzentration in Zürich während jeder Jahreszeit des Jahres 2018.
SELECT
    CASE
        WHEN T.monat IN (12, 1, 2) THEN 'Winter'
        WHEN T.monat IN (3, 4, 5) THEN 'Frühling'
        WHEN T.monat IN (6, 7, 8) THEN 'Sommer'
        WHEN T.monat IN (9, 10, 11) THEN 'Herbst'
    END AS jahreszeit,
    SUM(T.pm10_ug_m3) / COUNT(T.pm10_ug_m3) AS avg_pm10_ug_m3,
    SUM(T.pm2_5_ug_m3) / COUNT(T.pm2_5_ug_m3) AS avg_pm2_5_ug_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr = 2018
    AND T.pm10_ug_m3 IS NOT NULL
    AND T.pm2_5_ug_m3 IS NOT NULL
GROUP BY jahreszeit;

-- Wie hoch ist die relative Veränderung der PM10-Konzentration in Zürich von 2017 bis 2023 in Prozent?
SELECT
    (
        100.0 * SUM(
            CASE
                WHEN T.jahr = 2017 THEN T.pm10_ug_m3
                WHEN T.jahr = 2023 THEN -T.pm10_ug_m3
            END
        ) / SUM(CASE WHEN T.jahr = 2017 THEN T.pm10_ug_m3 END)
    ) AS pm10_anderung_2017_2023_prozent
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr IN (2017, 2023)
    AND T.pm10_ug_m3 IS NOT NULL;

-- Nennen Sie mir die Konzentration von Stickoxiden in der Luft von Zürich, in Teilen pro Million (ppm), für den Monat Januar in den Jahren 2017 bis 2021.
SELECT T.jahr, T.nox_ppb / 1000 AS nox_ppm_januar
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.monat = 1
    AND T.jahr >= 2017
    AND T.jahr <= 2021
ORDER BY T.jahr ASC;

-- Wie viel Ozon war im Jahr 2005 jeden Monat in der Luft der Stadt Zürich?
SELECT T.monat, T.o3_ug_m3 AS o3_ug_m3_2005
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr = 2005;

-- Wie hoch war die durchschnittliche Kohlenmonoxid-Konzentration in der Zürcher Luft im Januar und im Juli, bezogen auf den Zeitraum 1990-2000?
SELECT
    T.monat,
    SUM(T.co_mg_m3) / COUNT(T.co_mg_m3) AS avg_co_mg_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr >= 1990
    AND T.jahr <= 2000
    AND T.co_mg_m3 IS NOT NULL
    AND T.monat IN (1, 7)
GROUP BY T.monat;

-- Zeigen Sie mir die Partikelzahl für jeden Monat in Zürich, im Durchschnitt aller verfügbaren Jahre.
SELECT T.monat, SUM(T.pn_1_cm3) / COUNT(T.pn_1_cm3) AS avg_pn_1_cm3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.pn_1_cm3 IS NOT NULL
GROUP BY T.monat;
