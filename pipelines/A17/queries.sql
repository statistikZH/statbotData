-- Welches Jahr hatte die meisten Volksabstimmungen?
SELECT T.jahr, COUNT(*) as anzahl_volksabstimmungen, S.name_de
FROM volksabstimmung_nach_kanton_seit_1861 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
GROUP BY T.jahr, S.name_de
ORDER BY anzahl_volksabstimmungen DESC LIMIT 1;
