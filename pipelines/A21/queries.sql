-- Welche Gemeinde verbrauchte 1995 in Basel-Landschaft am meisten Strom?
SELECT S.name, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=1995
ORDER BY endverbrauch_elektrizitaet_mwh DESC
LIMIT 1;

-- Wie hoch war der Gesamtstromverbrauch der Gemeinden im Kanton Basel-Landschaft im Jahr 2000 im Vergleich zu 2020?
SELECT T.jahr , SUM(T.endverbrauch_elektrizitaet_mwh) as gesamt_endverbrauch_elektrizitaet_mwh_2020
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr IN (2000, 2020)
GROUP BY T.jahr
ORDER BY gesamt_endverbrauch_elektrizitaet_mwh_2020 DESC;

-- Welches waren die Top 3 Gemeinden mit dem geringsten Stromverbrauch in Basel-Landschaft im Jahr 2012?
SELECT S.name, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2012
ORDER BY endverbrauch_elektrizitaet_mwh ASC
LIMIT 3;

-- Wie hoch war der durchschnittliche jährliche Stromverbrauch der Gemeinden im Kanton Basel-Landschaft in den Jahren 2000 bis 2020?
SELECT T.jahr , AVG(T.endverbrauch_elektrizitaet_mwh) as mittlerer_endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr >= 2000
    AND T.jahr <= 2020
GROUP BY T.jahr
ORDER BY T.jahr DESC;

-- Wie hoch war der jährliche Stromverbrauch von Blauen im Kanton Basel-Landschaft vor dem Jahr 2000?
SELECT T.jahr , T.endverbrauch_elektrizitaet_mwh as endverbrauch_elektrizitaet_mwh_blauen
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr < 2000
    AND S.name="Blauen"
ORDER BY T.jahr DESC;

-- Welche Gemeinde verbrauchte 2018 zwischen Bottmingen und Birsfelden (Basel Landschaft) am meisten Strom?
SELECT S.name, T.endverbrauch_elektrizitaet_mwh as endverbrauch_elektrizitaet_mwh_2018
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2018
    AND S.name IN ("Blauen", "Birsfelden")
ORDER BY T.endverbrauch_elektrizitaet_mwh DESC;

-- In welchem Jahr hat Muttenz (Basel Landschaft) am meisten Strom verbraucht?
SELECT T.jahr, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name="Muttenz"
ORDER BY T.endverbrauch_elektrizitaet_mwh DESC
LIMIT 1;

-- Wie hoch war der höchste jemals registrierte jährliche Stromverbrauch einer Gemeinde in Basel-Landschaft?
SELECT T.jahr, S.name, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
ORDER BY T.endverbrauch_elektrizitaet_mwh DESC
LIMIT 1;
