-- Welche Gemeinde in Basel-Landschaft hatte 2022 das teuerste Bauland?
SELECT S.name
FROM basel_land_quadratmeterpreis_wohnbauland_nach_gemeinde_und_jahr AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2022
ORDER BY T.quadratmeterpreis_chf DESC
LIMIT 1;

-- Wie viel kostete ein Quadratmeter Wohnbauland in den fünf teuersten Gemeinden von Basel-Landschaft im Jahr 2005?
SELECT S.name, T.quadratmeterpreis_chf
FROM basel_land_quadratmeterpreis_wohnbauland_nach_gemeinde_und_jahr AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2005
ORDER BY T.quadratmeterpreis_chf DESC
LIMIT 5;

-- In welcher Gemeinde des Kantons Basel-Landschaft ist der Preis für Wohnbauland zwischen 2010 und 2020 am stärksten gestiegen, und um wie viel ist er gestiegen?
SELECT
    S.name,
    (
        SUM(CASE WHEN T.jahr=2020 THEN T.quadratmeterpreis_chf ELSE 0 END) -
        SUM(CASE WHEN T.jahr=2010 THEN T.quadratmeterpreis_chf ELSE 0 END)
    ) AS preisanderung_chf
FROM basel_land_quadratmeterpreis_wohnbauland_nach_gemeinde_und_jahr AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr IN (2010, 2020)
GROUP BY S.name
ORDER BY preisanderung_chf DESC
LIMIT 1;

-- Welche Gemeinden in Basel-Landschaft hatten zwischen 2015 und 2019 einen Rückgang der Wohnbaulandpreise? Zeigen Sie auch die Preisänderungen an.
SELECT T1.name, T1.preisanderung_chf
FROM (
    SELECT
        S.name,
        (
            SUM(CASE WHEN T.jahr=2019 THEN T.quadratmeterpreis_chf ELSE 0 END) -
            SUM(CASE WHEN T.jahr=2015 THEN T.quadratmeterpreis_chf ELSE 0 END)
        ) AS preisanderung_chf
    FROM basel_land_quadratmeterpreis_wohnbauland_nach_gemeinde_und_jahr AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal=TRUE
        AND T.jahr<=2015
        AND T.jahr<=2019
    GROUP BY S.name
) as T1
WHERE T1.preisanderung_chf < 0
ORDER BY T1.preisanderung_chf ASC ;

-- Wie viele Wohnbauländer wurden 2018 in Basel-Landschaft gekauft?
SELECT SUM(T.falle)
FROM basel_land_quadratmeterpreis_wohnbauland_nach_gemeinde_und_jahr AS T
WHERE T.jahr=2018;

-- In welchem Jahr wurde die meiste Wohnfläche im Kanton Basel-Landschaft gekauft?
SELECT T.jahr
FROM basel_land_quadratmeterpreis_wohnbauland_nach_gemeinde_und_jahr AS T
GROUP BY T.jahr
ORDER BY SUM(T.flache_in_m2) DESC
LIMIT 1;

-- Wie viel Wohnbauland wurde zwischen 2010 und 2012 in Pratteln, BL, gekauft?
SELECT SUM(T.flache_in_m2) as gesamt_flache_in_m2
FROM basel_land_quadratmeterpreis_wohnbauland_nach_gemeinde_und_jahr AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Pratteln'
    AND T.jahr>=2010
    AND T.jahr<=2012;