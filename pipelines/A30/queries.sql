-- Wie viele Verkäufe von Wohnbauland gab es im Kanton Zürich in den Jahren 2015 und 2021?
SELECT T.jahr, T.faelle
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr IN (2015, 2021);

-- In welchem Jahr ist der durchschnittliche Preis für Wohnbauland im Kanton Zürich am stärksten gestiegen (in CHF) im Vergleich zum Vorjahr?
SELECT T.jahr
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
ORDER BY T.durschnitt_preis_chf_pro_m2 - LAG(T.durschnitt_preis_chf_pro_m2) OVER (ORDER BY T.jahr) DESC
LIMIT 1;

-- Wie hoch war der durchschnittliche Quadratmeterpreis für Wohnbauland im Kanton Zürich zwischen 1980 und 2000?
SELECT AVG(T.durschnitt_preis_chf_pro_m2) AS durschnitt_preis_chf_pro_m2_1980_2000
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr >= 1980
    AND T.jahr <= 2000;

-- In welchem Jahr war der Interquartilabstand des Quadratmeterpreises für Wohnbauland im Kanton Zürich am höchsten und wie hoch war er?
SELECT T.jahr, T.quantil_75_preis_chf_pro_m2 - T.quantil_25_preis_chf_pro_m2 AS interquartilabstand_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
ORDER BY interquartilabstand_preis_chf_pro_m2 DESC
LIMIT 1;

-- Wie ist das Verhältnis zwischen den Preisen für Wohnbauland im Kanton Zürich im Jahr 2020 und 1980?
SELECT
    (
        SUM(CASE WHEN T.jahr = 2020 THEN T.durschnitt_preis_chf_pro_m2 END) /
        SUM(CASE WHEN T.jahr = 1980 THEN T.durschnitt_preis_chf_pro_m2 END)
    ) AS preis_ratio_2020_1980
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr IN (1980, 2020);

-- Wann hat der Medianpreis für Wohnbauland im Kanton Zürich seinen Höhepunkt erreicht?
SELECT T.jahr
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
ORDER BY T.median_preis_chf_pro_m2 DESC
LIMIT 1;

-- Zeigen Sie mir den Medianpreis für Wohnbauland im Kanton Zürich für jedes Jahr zwischen 2010 und 2020.
SELECT T.jahr, T.median_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr >= 2010
    AND T.jahr <= 2020;

-- Zeigen Sie mir alle verfügbaren statistischen Indikatoren für den Preis von Wohnbauland im Kanton Zürich für jedes Jahr zwischen 2017 und 2021.
SELECT
    T.jahr,
    T.quantil_25_preis_chf_pro_m2,
    T.median_preis_chf_pro_m2,
    T.quantil_75_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr >= 2017
    AND T.jahr <= 2021;

-- Wie hoch war das dritte Quartil der Preise für Wohnbauland im Kanton Zürich im Jahr 2015?
SELECT T.quantil_75_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr = 2015;

-- Wie hoch war das 50. Perzentil der Preise für Wohnbauland im Kanton Zürich in den Jahren 2012 und 2014?
SELECT T.jahr, T.median_preis_chf_pro_m2
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr IN (2012, 2014);

-- Wie viele Verkäufe von Wohnbauland gab es im Kanton Zürich im Zeitraum 1990-2010 insgesamt?
SELECT SUM(T.faelle) AS faelle_1990_2010
FROM zurich_effektive_preise_wohnbauland AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE
    S.canton = TRUE
    AND S.name LIKE "%Zurich%"
    AND T.jahr >= 1990
    AND T.jahr <= 2010;