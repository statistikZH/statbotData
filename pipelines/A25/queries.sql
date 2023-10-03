-- Wie viel Fläche wurde im Jahr 2017 im Aargau für den Rotweinanbau genutzt?
SELECT T.flache_rebland_rote_europaische_reben_ha, T.flache_rebland_kreuzung_rote_weisse_ha
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2017;

-- Wie viel Wein wurde im Aargau 1980 und 2010 geerntet?
SELECT T.jahr, T.weinernte_total_hl
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr IN (1980, 2010);

-- Um wie viel Franken hat sich der Gesamtwert der Weinernte im Aargau zwischen 1980 und 2016 verändert?
SELECT (
    SUM(CASE WHEN T.jahr = 2016 THEN T.erntewert_rot_1000_chf + T.erntewert_weiss_1000_chf ELSE 0 END) -
    SUM(CASE WHEN T.jahr = 1980 THEN T.erntewert_rot_1000_chf + T.erntewert_weiss_1000_chf ELSE 0 END)
) * 1000.0 AS wertanderung_1980_2016_chf
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr IN (1980, 2016);

-- Wie viel Rot- und Weisswein wurde im Jahr 2019 im Aargau geerntet?
SELECT T.weinernte_rot_europaische_hl, T.weinernte_rot_kreuzung_rot_hl, T.weinernte_europaische_weiss_hl
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2019;

-- Wie viel Prozent des im Aargau geernteten Rotweins stammte im Jahr 2000 aus Kreuzungen?
SELECT 100 * CAST(T.weinernte_rot_kreuzung_rot_hl AS FLOAT) / T.weinernte_total_hl
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2000;

-- In welchem Jahr wurde im Aargau am meisten Wein geerntet?
SELECT T.jahr
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
GROUP BY T.jahr
ORDER BY T.weinernte_total_hl DESC
LIMIT 1;

-- Wie hoch war der Wert des im Aargau produzierten Weissweins in den Jahren 2003 bis 2008?
SELECT T.jahr, T.erntewert_weiss_1000_chf
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr >= 2003
    AND T.jahr <= 2008;

-- Wie hat sich die Weinbaufläche im Aargau zwischen 1980 und 2000 relativ verändert (in prozent)?
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

-- Wie viel Prozent des Wertes des im Aargau produzierten Weines entfiel 2017 auf Rotwein?
SELECT 100.0 * T.erntewert_rot_1000_chf / (T.erntewert_rot_1000_chf + T.erntewert_weiss_1000_chf) AS prozent_rotwein_wert_2017
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2017;

-- Wie viele Quadratkilometer Rebfläche gab es im Aargau im Jahr 2018?
SELECT CAST(T.flache_total_ha AS FLOAT) / 100 AS flache_total_km2
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr = 2018;

-- Wie viele Liter Wein wurden im Aargau zwischen 2000 und 2010 insgesamt produziert?
SELECT 100 * SUM(T.weinernte_total_hl) AS weinernte_2000_2010_total_liter
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr >= 2000
    AND T.jahr <= 2010;

-- Wie hoch war die Differenz in CHF zwischen dem Wert des im Aargau produzierten Rotweins in den Jahren 1999 und 2000?
SELECT (
    SUM(CASE WHEN T.jahr = 2000 THEN T.erntewert_rot_1000_chf ELSE 0 END) -
    SUM(CASE WHEN T.jahr = 1999 THEN T.erntewert_rot_1000_chf ELSE 0 END)
) * 1000.0 AS wertanderung_1999_2000_chf
FROM aargau_obst_rebbau_rebland_wein_ernte AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND S.name LIKE "%Aargau%"
    AND T.jahr IN (1999, 2000);