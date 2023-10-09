-- Welche Gemeinde in Basel-Landschaft hatte 1995 den höchsten Stromverbrauch?
SELECT S.name, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=1995
ORDER BY endverbrauch_elektrizitaet_mwh DESC
LIMIT 1;

-- Zeigen Sie mir den Gesamtstromverbrauch der Gemeinden in Basel-Landschaft im Jahr 2000 gegenüber 2020.
SELECT T.jahr , SUM(T.endverbrauch_elektrizitaet_mwh) as gesamt_endverbrauch_elektrizitaet_mwh_2020
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr IN (2000, 2020)
GROUP BY T.jahr
ORDER BY gesamt_endverbrauch_elektrizitaet_mwh_2020 DESC;

-- Welche drei Gemeinden in Basel-Landschaft hatten im Jahr 2012 den geringsten Stromverbrauch?
SELECT S.name, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2012
ORDER BY endverbrauch_elektrizitaet_mwh ASC
LIMIT 3;

-- Wie hoch war der durchschnittliche jährliche Stromverbrauch der Gemeinden im Kanton Basel-Landschaft in den Jahren 2000 bis 2020?
SELECT T.jahr , AVG(T.endverbrauch_elektrizitaet_mwh) as mittlerer_endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr >= 2000
    AND T.jahr <= 2020
GROUP BY T.jahr
ORDER BY T.jahr DESC;

-- Wie hoch war der jährliche Stromverbrauch von Blauen im Kanton Basel-Landschaft vor dem Jahr 2000?
SELECT T.jahr , T.endverbrauch_elektrizitaet_mwh as endverbrauch_elektrizitaet_mwh_blauen
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr < 2000
    AND S.name IN ('Blauen', 'Blauen (BL)')
ORDER BY T.jahr DESC;

-- Welche der Gemeinden Bottmingen und Birsfelden in Basel-Landschaft hatte 2018 den höchsten Stromverbrauch?
SELECT S.name, T.endverbrauch_elektrizitaet_mwh as endverbrauch_elektrizitaet_mwh_2018
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2018
    AND S.name IN ('Blauen', 'Blauen (BL)', 'Birsfelden', 'Birsfelden (BL)')
ORDER BY T.endverbrauch_elektrizitaet_mwh DESC;

-- In welchem Jahr hatte Muttenz in Basel-Landschaft den höchsten Stromverbrauch?
SELECT T.jahr, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name IN ('Muttenz', 'Muttenz (BL)')
ORDER BY T.endverbrauch_elektrizitaet_mwh DESC
LIMIT 1;

-- Wie hoch war der höchste jemals gemessene jährliche Stromverbrauch in einer Gemeinde in Basel-Landschaft? Geben Sie auch den Namen der Gemeinde an.
SELECT T.jahr, S.name, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
ORDER BY T.endverbrauch_elektrizitaet_mwh DESC
LIMIT 1;
