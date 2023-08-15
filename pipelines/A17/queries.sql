-- Welches Jahr hatte die meisten Volksabstimmungen?
SELECT T.jahr as jahr_mit_meisten_volksabstimmungen
FROM volksabstimmung_nach_kanton_seit_1861 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
GROUP BY T.jahr
ORDER BY COUNT() DESC LIMIT 1;
