-- What was the municipality consuming the most electricity in 1995 in Basel-Landschaft ?
SELECT S.name, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=1995
ORDER BY endverbrauch_elektrizitaet_mwh DESC
LIMIT 1;

-- What was the total electricity consumption of municipalities in Basel-landschaft in 2000 vs 2020?
SELECT T.jahr , SUM(T.endverbrauch_elektrizitaet_mwh) as gesamt_endverbrauch_elektrizitaet_mwh_2020
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr IN (2000, 2020)
GROUP BY T.jahr
ORDER BY gesamt_endverbrauch_elektrizitaet_mwh_2020 DESC;

-- What were the top 3 municipalities consuming the least electricity in Basel-Landschaft in 2012
SELECT S.name, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2012
ORDER BY endverbrauch_elektrizitaet_mwh ASC
LIMIT 3;

-- What was the average yearly electricity consumption across Basel-landschaft municipalities over the years 2000 to 2020?
SELECT T.jahr , AVG(T.endverbrauch_elektrizitaet_mwh) as mittlerer_endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr >= 2000
    AND T.jahr <= 2020
GROUP BY T.jahr
ORDER BY T.jahr DESC;

-- What was the yearly electricity consumption of Blauen, in canton Basel-Landschaft before 2000?
SELECT T.jahr , T.endverbrauch_elektrizitaet_mwh as endverbrauch_elektrizitaet_mwh_blauen
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr < 2000
    AND S.name="Blauen"
ORDER BY T.jahr DESC;

-- Which municipality consumed the most electricity in 2018 between Bottmingen and Birsfelden (Basel Landschaft)?
SELECT S.name, T.endverbrauch_elektrizitaet_mwh as endverbrauch_elektrizitaet_mwh_2018
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2018
    AND S.name IN ("Blauen", "Birsfelden")
ORDER BY T.endverbrauch_elektrizitaet_mwh DESC;

-- In what year did Muttenz (Basel Landschaft) consume the most electricity?
SELECT T.jahr, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name="Muttenz"
ORDER BY T.endverbrauch_elektrizitaet_mwh DESC
LIMIT 1;

-- What was the highest ever recorded annual electricity consumption for a municipality in Basel Landschaft?
SELECT T.jahr, S.name, T.endverbrauch_elektrizitaet_mwh
FROM basel_land_endverbrauch_von_ektrizitat_nach_gemeinde_und_jahr_seit_1990 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
ORDER BY T.endverbrauch_elektrizitaet_mwh DESC
LIMIT 1;
