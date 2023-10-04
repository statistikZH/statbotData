-- Welche Verbrauchkategorie hatte den höchsten mittleren Strompreis im Kanton Bern in 2017?
SELECT T.verbrauchskategorie as verbrauchskategorie_max_mittlerer_strompreis, T.verbrauchskategorie_beschreibung,
S.name_de as kanton, T.jahr
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Bern%' AND S.canton=TRUE AND T.jahr=2017
ORDER BY mittlerer_preis_rappen_pro_kwh DESC LIMIT 1;

-- Welches sind die verschiedenen Stromverbrauchskategorien in der Schweiz?
SELECT DISTINCT verbrauchskategorie, verbrauchskategorie_beschreibung
FROM median_strompreis_per_kanton
ORDER BY verbrauchskategorie;

-- Wie viel zahle ich in CHF für 1000 kWh bei einer 2-Zimmer-Wohnung im Kanton Bern im Jahr 2017?
SELECT T.verbrauchskategorie, T.verbrauchskategorie_beschreibung,
T.energieprodukt,
T.mittlerer_preis_rappen_pro_kwh * 1000 / 100 as preis_franken_fur_1000_kwh_bern_2017_2_zimmerwohnung
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Bern%'
    AND S.canton=TRUE
    AND T.jahr=2017
    AND T.verbrauchskategorie_beschreibung LIKE '%2-Zimmerwohnung%'
    AND T.verbrauchskategorie_grosse_kwh_pro_jahr >= 1000;

-- Welches ist der Kanton mit dem höchsten Preis für 1000 kWh im Jahr 2021 für das Standardstromprodukt der Kategorie C3?
SELECT S.name_de as kanton, T.jahr, T.verbrauchskategorie, T.energieprodukt
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.jahr=2021
    AND T.energieprodukt='Standardprodukt'
    AND T.verbrauchskategorie='C3'
GROUP BY S.name_de, T.jahr, T.verbrauchskategorie, T.energieprodukt, T.mittlerer_preis_rappen_pro_kwh
ORDER BY T.mittlerer_preis_rappen_pro_kwh DESC LIMIT 1;

-- In welchem Jahr hatte der Strom im Kanton Waadt den höchsten mittleren Preis für Standardhaushaltsprodukte?
WITH WAADT AS (
    SELECT *
    FROM median_strompreis_per_kanton as T
    JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
    WHERE S.name_de LIKE '%Waadt%'
        AND S.canton=TRUE
        AND T.energieprodukt='Standardprodukt'
        AND T.verbrauchskategorie LIKE 'H_'
)
SELECT WAADT.jahr, HOCH.verbrauchskategorie, HOCH.max_mittlerer_preis_rappen_pro_kwh
FROM WAADT
JOIN (
    SELECT
        WAADT.verbrauchskategorie,
        MAX(WAADT.mittlerer_preis_rappen_pro_kwh) AS max_mittlerer_preis_rappen_pro_kwh
    FROM WAADT
    GROUP BY WAADT.verbrauchskategorie
) AS HOCH ON HOCH.verbrauchskategorie=WAADT.verbrauchskategorie AND HOCH.max_mittlerer_preis_rappen_pro_kwh=WAADT.mittlerer_preis_rappen_pro_kwh;

-- In welchen Kantonen liegen die Strompreise für die Kategorie der Grossverbraucher im Jahr 2022 unter 13 Rappen pro Kilowattstunde?
SELECT DISTINCT(S.name)
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.jahr=2022
    AND T.verbrauchskategorie_grosse_kwh_pro_jahr = (SELECT MAX(verbrauchskategorie_grosse_kwh_pro_jahr) FROM median_strompreis_per_kanton)
    AND T.mittlerer_preis_rappen_pro_kwh < 13;

-- Wie haben sich die Standardstrompreise für kleine Unternehmen im Kanton Neuenburg zwischen 2017 und 2023 entwickelt?
SELECT T.jahr, T.energieprodukt, T.verbrauchskategorie, T.mittlerer_preis_rappen_pro_kwh
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Neuenburg%'
    AND S.canton=TRUE
    AND T.jahr >= 2017
    AND T.jahr <= 2023
    AND T.energieprodukt='Standardprodukt'
    AND T.verbrauchskategorie_beschreibung LIKE '%Kleinbetrieb%'
ORDER BY T.jahr;

-- Welcher Kanton kann nach den neuesten Informationen den günstigsten Strom für die Kategorie H3 anbieten?
SELECT S.name
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.jahr=(SELECT MAX(jahr) FROM median_strompreis_per_kanton)
    AND T.verbrauchskategorie='H3'
GROUP BY T.jahr, S.name, T.mittlerer_preis_rappen_pro_kwh
ORDER BY T.mittlerer_preis_rappen_pro_kwh ASC LIMIT 1;

-- Wie hoch waren die Preise für das günstigste verfügbare Stromprodukt für alle Unternehmenskategorien im Kanton Genf im Jahr 2012?
SELECT T.verbrauchskategorie, MIN(T.mittlerer_preis_rappen_pro_kwh)
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Genf%'
    AND S.canton=TRUE
    AND T.jahr=2012
    AND T.verbrauchskategorie LIKE '%C_%'
GROUP BY T.verbrauchskategorie, T.jahr, T.mittlerer_preis_rappen_pro_kwh
ORDER BY T.mittlerer_preis_rappen_pro_kwh ASC;

-- Wann haben die Strompreise für Haushalte mit einem Verbrauch von weniger als 7500 kWh pro Jahr im Kanton Zürich ihren Höchststand erreicht?
WITH T1 AS (
    SELECT *
    FROM median_strompreis_per_kanton as T
    JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
    WHERE S.name_de LIKE '%Zürich%'
        AND S.canton=TRUE
        AND T.verbrauchskategorie LIKE 'H_%'
        AND T.verbrauchskategorie_grosse_kwh_pro_jahr < 7500
)
SELECT T1.jahr, HOCH.verbrauchskategorie, HOCH.max_mittlerer_preis_rappen_pro_kwh
FROM T1
JOIN (
    SELECT
        T1.verbrauchskategorie,
        MAX(T1.mittlerer_preis_rappen_pro_kwh) AS max_mittlerer_preis_rappen_pro_kwh
    FROM T1
    GROUP BY T1.verbrauchskategorie
) AS HOCH ON HOCH.verbrauchskategorie=T1.verbrauchskategorie AND HOCH.max_mittlerer_preis_rappen_pro_kwh=T1.mittlerer_preis_rappen_pro_kwh;