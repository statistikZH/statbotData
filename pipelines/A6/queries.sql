-- Wieviele Abstimmungsvorlagen gab es im Jahr 2000?
SELECT COUNT(*) as anzahl_vorlagen_in_2000
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE AND T.jahr=2000;

-- Wieviele Abstimmungsvorlagen gab es seit dem Jahr 1971?
SELECT COUNT(*) as anzahl_vorlagen_in_2000
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE;
