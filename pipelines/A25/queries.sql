-- What area was dedicated to growing red wine in Aargau in 2017?
SELECT T.flache_rebland_rote_europaische_reben_ha, T.flache_rebland_kreuzung_rote_weisse_ha
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2017;
-- How much wine was harvested in Aargau in 1980 and 2010?
SELECT T.jahr, T.weinernte_total_hl
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr IN (1980, 2010);

-- By how much CHF did the total value of wine harvests in Aargau change between 1980 and 2016?
SELECT (
    SUM(CASE WHEN T.jahr = 2016 THEN T.erntewert_rot_1000_chf + T.erntewert_weiss_1000_chf ELSE 0 END) -
    SUM(CASE WHEN T.jahr = 1980 THEN T.erntewert_rot_1000_chf + T.erntewert_weiss_1000_chf ELSE 0 END)
) * 1000.0 AS wertanderung_1980_2016_chf
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr IN (1980, 2016);

-- How much red and white wine was harvested in Aargau in 2019?
SELECT T.weinernte_rot_europaische_hl, T.weinernte_rot_kreuzung_rot_hl, T.weinernte_europaische_weiss_hl
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2019;

-- What percentage of red wine harvested in Aargau was from crossings in 2000?
SELECT 100 * CAST(T.weinernte_rot_kreuzung_rot_hl AS FLOAT) / T.weinernte_total_hl
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2000;

-- In what year was the most wine harvested in Aargau?
SELECT T.jahr
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
GROUP BY T.jahr
ORDER BY T.weinernte_total_hl DESC
LIMIT 1;

-- What was the value of white wine produced in Aargau each year between 2003 and 2008?
SELECT T.jahr, T.erntewert_weiss_1000_chf
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr >= 2003
    AND T.jahr <= 2008;

-- What was the relative change in area for wine production in Aargau between 1980 and 2000?
SELECT 100 * (T1.flache_ha_2000 - T1.flache_ha_1980) / T1.flache_ha_1980 AS weinrebflache_1980_2000_change_prozent
FROM (
    SELECT
        SUM(CASE WHEN T.jahr = 1980 THEN T.flache_total_ha ELSE 0 END) AS flache_ha_1980,
        SUM(CASE WHEN T.jahr = 2000 THEN T.flache_total_ha ELSE 0 END) AS flache_ha_2000
    FROM aargau_obst_rebbau_rebland_wein_ernte AS T
    JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.canton = TRUE
        AND S.name LIKE "%Aargau%"
        AND T.jahr IN (1980, 2000)
) AS T1;

-- What percentage of the value of wine produced in Aargau that was from red wine in 2017?
SELECT 100.0 * T.erntewert_rot_1000_chf / (T.erntewert_rot_1000_chf + T.erntewert_weiss_1000_chf) AS prozent_rotwein_wert_2017
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2017;

-- How many square kilometers of vineyards were in Aargau in 2018?
SELECT CAST(T.flache_total_ha AS FLOAT) / 100 AS flache_total_km2
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2018;

-- How many liters of wine were produced in Aargau in total between 2000 and 2010?
SELECT 100 * SUM(T.weinernte_total_hl) AS weinernte_2000_2010_total_liter
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr >= 2000
    AND T.jahr <= 2010;

-- What was the difference in CHF between the value of red wine produced in Aargau in 1999 and 2000?
SELECT (
    SUM(CASE WHEN T.jahr = 2000 THEN T.erntewert_rot_1000_chf ELSE 0 END) -
    SUM(CASE WHEN T.jahr = 1999 THEN T.erntewert_rot_1000_chf ELSE 0 END)
) * 1000.0 AS wertanderung_1999_2000_chf
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr IN (1999, 2000);