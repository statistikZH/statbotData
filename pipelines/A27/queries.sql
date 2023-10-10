-- Wie setzt sich die erneuerbare Energieproduktion im Kanton Thurgau seit 2018 jährlich zusammen?
SELECT
    T.jahr,
    SUM(biogasanlagen_abwasser_gwh),
    SUM(biogasanlagen_industrie_gwh),
    SUM(biogasanlagen_landwirtschaft_gwh),
    SUM(biomasse_holz_gwh),
    SUM(kehricht_gwh),
    SUM(photovoltaik_gwh),
    SUM(wasserkraft_gwh),
    SUM(wind_gwh),
    SUM(total_gwh)
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr >= 2018
GROUP BY T.jahr;

-- Wie viel Prozent der erneuerbaren Energie in Frauenfeld TG wurde im Jahr 2021 durch Solarenergie erzeugt?
SELECT
    100 * photovoltaik_gwh/total_gwh AS photovoltaik_prozent_frauenfeld_2021
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2021
    AND S.name IN ('Frauenfeld', 'Frauenfeld (TG)');

-- Wie viele Gemeinden im Kanton Thurgau produzierten im Jahr 2019 Energie aus Wind?
SELECT
    COUNT(*) AS anzahl_gemeinden_wind_2019
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2019
    AND T.wind_gwh > 0;

-- Welche Gemeinde im Kanton Thurgau produziert im Jahr 2020 im Verhältnis zur Einwohnerzahl am meisten erneuerbare Energie?
SELECT S.name AS gemeinde
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2020
ORDER BY T.total_gwh / T.einwohner DESC
LIMIT 1;

-- Wie hoch ist der Anteil (in Prozent) der Thurgauer Gemeinden, die im Jahr 2017 keine erneuerbare Energie produziert haben?
SELECT 100 * SUM(CASE WHEN T.total_gwh = 0 THEN 1 ELSE 0 END) / CAST(COUNT(*) AS FLOAT) AS prozent_kein_erneurerbare_energie_2017
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2017;

-- Wie viel erneuerbare Energie wird in den 5 grössten Thurgauer Gemeinden im Jahr 2021 produziert?
SELECT S.name AS gemeinde, T.total_gwh
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2021
ORDER BY T.einwohner DESC
LIMIT 5;

-- Welche 3 Thurgauer Gemeinden weisen zwischen 2018 und 2021 den grössten Zuwachs an erneuerbarer Energieproduktion auf? Geben Sie auch den prozentualen Anstieg an.
SELECT
    S.name AS gemeinde,
    (
        100.0 * SUM( CASE WHEN T.jahr = 2021 THEN T.total_gwh ELSE 0 END) /
        SUM( CASE WHEN T.jahr = 2018 THEN T.total_gwh ELSE 0 END
    )) AS prozent_anstieg
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr IN (2018, 2021)
GROUP BY S.name
ORDER BY prozent_anstieg DESC
LIMIT 3;

-- Wie viele MWh an erneuerbarer Energie hat Amriswil im Kanton Thurgau von 2016 bis 2020 insgesamt produziert?
SELECT SUM(T.total_gwh) * 1000 AS total_mwh
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Amriswil', 'Amriswil (TG)')
    AND T.jahr >= 2016
    AND T.jahr <= 2020;

-- Zeigen Sie mir 2 Aargauer Gemeinden, die im Jahr 2019 der wichtigste Produzent von Energie aus Holzbiomasse waren.
SELECT S.name AS gemeinde
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2019
ORDER BY T.biomasse_holz_gwh DESC
LIMIT 2;

-- Wie hoch ist die Gesamtmenge an erneuerbarer Energie aus der Kehrichtverbrennung im Kanton Thurgau im Jahr 2020?
SELECT S.name AS gemeinde
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2019
ORDER BY T.biomasse_holz_gwh DESC
LIMIT 2;

-- Wie viele GWh Energie wurden im Jahr 2015 im Kanton Thurgau aus den einzelnen Biogasanlagentypen produziert?
SELECT
    SUM(biogasanlagen_abwasser_gwh) AS biogasanlagen_abwasser_gwh_kanton_thurgau,
    SUM(biogasanlagen_industrie_gwh) AS biogasanlagen_industrie_gwh_kanton_thurgau,
    SUM(biogasanlagen_landwirtschaft_gwh) AS biogasanlagen_landwirtschaft_gwh_kanton_thurgau
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2015;

-- Welche war die kleinste Gemeinde (in Einwohnern), die im Jahr 2021 im Kanton Thurgau Energie aus der Kehrichtverbrennung produzierte?
SELECT S.name AS gemeinde
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2021
    AND T.kehricht_gwh > 0
ORDER BY T.einwohner ASC
LIMIT 1;

-- Zeigen Sie mir die Produktion von Energie aus Sonne und Wind in Berg, TG im Jahr 2018.
SELECT T.photovoltaik_gwh, T.wind_gwh
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Berg', 'Berg (TG)')
    AND T.jahr = 2018;

-- Welche 3 Thurgauer Gemeinden hatten im Jahr 2019 den höchsten Anteil an Wasserkraft an der gesamten erneuerbaren Energieproduktion und wie hoch war dieser?
SELECT
    S.name AS gemeinde,
    100.0 * T.wasserkraft_gwh / T.total_gwh AS prozent_wasserkraft
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2019
ORDER BY prozent_wasserkraft DESC
LIMIT 3;

-- Wie hoch ist der Anteil der Gemeinden im Kanton Thurgau, die zwischen 2015 und 2021 einen Rückgang der Produktion von erneuerbaren Energien zu verzeichnen haben?
SELECT 100 * SUM(CASE WHEN T.total_gwh_2015 > T.total_gwh_2021 THEN 1 ELSE 0 END) / CAST(COUNT(*) AS FLOAT) AS prozent_abnahme
FROM (
    SELECT
        S.name,
        SUM(CASE WHEN T.jahr = 2015 THEN T.total_gwh ELSE 0 END) AS total_gwh_2015,
        SUM(CASE WHEN T.jahr = 2021 THEN T.total_gwh ELSE 0 END) AS total_gwh_2021
    FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal = TRUE
        AND T.jahr IN (2015, 2021)
    GROUP BY S.name
) AS T;

-- Zeigen Sie mir die Produktion von Energie aus landwirtschaftlichem Biogas in Fischingen, Kanton Thurgau, im Jahr 2018.
SELECT T.biogasanlagen_landwirtschaft_gwh
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE T.jahr = 2018
    AND S.name IN ('Fischingen', 'Fischingen (TG)');

-- Wie viel erneuerbare Energie hat der Kanton Thurgau im Zeitraum 2017-2021 insgesamt produziert?
SELECT SUM(T.total_gwh) AS total_gwh_2017_2021
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
WHERE T.jahr >= 2017
    AND T.jahr <= 2021;

-- Wie hoch war die Produktion von Solarstrom in Roggwil und Langrickenbach TG in den Jahren 2019 und 2020?
SELECT S.name AS gemeinde, T.jahr, T.photovoltaik_gwh
FROM thurgau_erneuerbare_elektrizitatsproduktion_gemeinde AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name IN ('Roggwil', 'Roggwil (TG)', 'Langrickenbach', 'Langrickenbach (TG)')
    AND T.jahr IN (2019, 2020)
ORDER BY S.name, T.jahr;