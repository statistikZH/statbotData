-- When did the concentration of carbon monoxide in the air reach its maximum in the city of Zürich? Also report the concentration in mg/m3.
SELECT T.jahr, T.monat, T.co_mg_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
ORDER BY T.co_mg_m3 DESC
LIMIT 1;

-- What month typically has the fewest particles in the air in Stadt Zürich?
SELECT T.monat, SUM(T.pn_1_cm3) / COUNT(T.pn_1_cm3) AS monat_avg_pn_1_cm3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
GROUP BY T.monat
ORDER BY SUM(T.pn_1_cm3) / COUNT(T.pn_1_cm3) ASC
LIMIT 1;

-- What was the concentration (in parts per billion) of nitric oxides per month in Stadt Zürich in 2019?
SELECT T.monat, T.nox_ppb
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr = 2019
ORDER BY T.monat ASC;

-- What was the yearly average concentration of nitric monoxide and nitric dioxide in Stadt Zürich, for years 1993, 2003, 2013 and 2023?
SELECT T.jahr, SUM(T.no_ug_m3) / COUNT(T.no_ug_m3) AS jahr_avg_no_ug_m3, SUM(T.no2_ug_m3) / COUNT(T.no2_ug_m3) AS avg_no2_ug_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr IN (1993, 2003, 2013, 2023)
GROUP BY T.jahr;
-- What was the lowest concentration of fine particulate matter (PM2.5) ever recorded in Zürich, and on what year was it?
SELECT T.jahr, T.pm2_5_ug_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.pm2_5_ug_m3 IS NOT NULL
ORDER BY T.pm2_5_ug_m3 ASC
LIMIT 1;

-- What was the concentration of sulfur dioxide in the air in Zürich through 2019? Show the concentration in milligram per cubic meter.
SELECT T.monat, T.so2_ug_m3 / 1000 AS so2_mg_m3
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.jahr = 2019
ORDER BY T.monat ASC;

-- What was the concentration of CO and SO2 (both in microgram/m3) in Zürich in from October 1999 to July 2000?
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
ORDER BY T.jahr ASC, T.monat ASC;

-- Show me the mean PM10 and PM2.5 concentration in Zurich during each season from the year 2018.
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
GROUP BY jahreszeit;

-- What was the relative change, in percent, of the concentration of PM10 in Zürich from 2017 to 2023?
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
    AND T.jahr IN (2017, 2023);

-- Give me the concentration of nitric oxides in the air of Zürich, in part per million (ppm), for the month of January in the years 2017 to 2021.
SELECT T.jahr, T.monat, T.nox_ppb / 1000 AS nox_ppm
FROM stadt_zurich_monatlich_luftqualitatsmessungen_seit_1983 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name = 'Zürich'
    AND T.monat = 1
    AND T.jahr >= 2017
    AND T.jahr <= 2021
ORDER BY T.jahr ASC;
-- How much ozon was in the air of stadt Zurich during the year 2005?
-- Is the concentration of carbon monoxide generally higher during the winter or the summer in Zürich?
-- Show me the particle count for each month in Zurich, averaging all available years.