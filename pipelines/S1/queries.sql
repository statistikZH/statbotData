-- Welche Verbrauchkategorie hatte den höchsten mittleren Strompreis im Kanton Bern in 2017?
SELECT T.verbrauchskategorie as verbrauchskategorie_mit_maximalem_mittleren_strompreis_bern_2017
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Bern%' AND S.canton=TRUE AND T.jahr=2017
ORDER BY mittlerer_preis_rappen_pro_kwh DESC LIMIT 1;

-- Welches sind die verschiedenen Stromverbrauchskategorien in der Schweiz?
SELECT DISTINCT verbrauchskategorie, verbrauchskategorie_beschreibung
FROM median_strompreis_per_kanton
ORDER BY verbrauchskategorie;

-- How much would I pay in CHF for 1000 kWh with a 2-room appartment in the canton of Bern in 2017?
SELECT T.verbrauchskategorie, T.verbrauchskategorie_beschreibung, T.energieprodukt, T.mittlerer_preis_rappen_pro_kwh * 1000 / 100 as preis_franken_fur_1000_kwh_bern_2017_2_zimmerwohnung
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Bern%'
    AND S.canton=TRUE
    AND T.jahr=2017
    AND T.verbrauchskategorie_beschreibung LIKE '%2-zimmerwohnung%'
    AND T.verbrauchskategorie_grosse_kwh_pro_jahr >= 1000;

-- What is the canton with the highest price for 1000 kWh in 2021 for the standard electricity product in the C3 category?
SELECT S.name
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.jahr=2021
    AND T.energieprodukt="Standardprodukt"
    AND T.verbrauchskategorie="C3"
ORDER BY T.mittlerer_preis_rappen_pro_kwh DESC LIMIT 1;

-- In what year did electricity have the highest median price in canton Vaud for standard household products?
SELECT T.jahr, T.verbrauchskategorie, MAX(T.mittlerer_preis_rappen_pro_kwh)
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Waadt%'
    AND S.canton=TRUE
    AND T.energieprodukt="Standardprodukt"
    AND T.verbrauchskategorie LIKE 'H_'
GROUP BY T.verbrauchskategorie;

-- Which cantons had electricity prices below 13 cents per kwh in 2022 for the category of largest consumers?
SELECT DISTINCT(S.name)
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.jahr=2022
    AND T.verbrauchskategorie_grosse_kwh_pro_jahr = (SELECT MAX(verbrauchskategorie_grosse_kwh_pro_jahr) FROM median_strompreis_per_kanton)
    AND T.mittlerer_preis_rappen_pro_kwh < 13;

-- How did standard electricity prices for small companies evolve in canton Neuchatel between 2017 and 2023?
SELECT T.jahr, T.energieprodukt, T.verbrauchskategorie, T.mittlerer_preis_rappen_pro_kwh
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Neuenburg%'
    AND S.canton=TRUE
    AND T.jahr >= 2017
    AND T.jahr <= 2023
    AND T.energieprodukt="Standardprodukt"
    AND T.verbrauchskategorie_beschreibung LIKE '%Kleinbetrieb%'
ORDER BY T.jahr;

-- Based on the latest information, what canton can provide the cheapest electicity for the H3 category?
SELECT S.name
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.jahr=(SELECT MAX(jahr) FROM median_strompreis_per_kanton)
    AND T.verbrauchskategorie="H3"
ORDER BY T.mittlerer_preis_rappen_pro_kwh ASC LIMIT 1;

-- What were the prices for the cheapest electricity product available for all company categories in canton Geneva in 2012?
SELECT T.verbrauchskategorie, MIN(T.mittlerer_preis_rappen_pro_kwh)
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Genf%'
    AND S.canton=TRUE
    AND T.jahr=2012
    AND T.verbrauchskategorie LIKE '%C_%'
GROUP BY T.verbrauchskategorie
ORDER BY T.mittlerer_preis_rappen_pro_kwh ASC;

-- When did electricity prices reach the highest point for household categories consuming under 7500 kWh per year in canton Zurich?
SELECT T.jahr, T.verbrauchskategorie, MAX(T.mittlerer_preis_rappen_pro_kwh)
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Zürich%'
    AND S.canton=TRUE
    AND T.verbrauchskategorie LIKE 'H_%'
    AND T.verbrauchskategorie_grosse_kwh_pro_jahr < 7500
GROUP BY T.verbrauchskategorie
ORDER BY T.mittlerer_preis_rappen_pro_kwh DESC;
