-- In welchem Jahr gab es die meisten Straftaten in der Schweiz?
SELECT T.jahr, S.name_de, T.anzahl_straftaten
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid=S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.straftat='Straftat - Total'
GROUP BY T.jahr, T.anzahl_straftaten, S.name_de
ORDER BY T.anzahl_straftaten DESC LIMIT 1;

-- Welches ist die meist begangene Straftat in der Schweiz?
SELECT T.straftat, S.name_de, SUM(T.anzahl_straftaten) AS straftaten_summe
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.straftat<>'Straftat - Total'
GROUP BY T.straftat, S.name_de
ORDER BY straftaten_summe DESC LIMIT 1;

-- Wieviele aufgeklärte Straftaten gab es 2022 in Zürich?
SELECT T.anzahl_straftaten_aufgeklaert, T.jahr, S.name_de
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Zürich%' AND S.canton=TRUE
AND T.straftat='Straftat - Total'
AND T.jahr=2022;

-- Welches war die am meisten begangene Straftat 2020 im Kanton Bern?
SELECT T.straftat, S.name_de, T.jahr, T.anzahl_straftaten
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Bern%'
AND S.canton = TRUE AND T.jahr=2020
AND T.straftat<>'Straftat - Total' AND T.anzahl_straftaten IS NOT NULL
GROUP BY T.straftat, S.name_de, T.jahr, T.anzahl_straftaten
ORDER BY T.anzahl_straftaten DESC LIMIT 1;

-- Welches ist die Kategorie der hauefigst begangenen Verbrechen in der Schweiz?
SELECT T.kategorie, S.name_de, SUM(T.anzahl_straftaten) AS straftaten_summe
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.straftat<>'Straftat - Total'
GROUP BY T.kategorie, S.name_de
ORDER BY straftaten_summe DESC LIMIT 1;


