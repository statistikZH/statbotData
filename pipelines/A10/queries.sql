-- In welchem Jahr gab es die meisten Straftaten in der Schweiz?
SELECT T.jahr as jahr_mit_meisten_straftaten
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE
AND T.straftat = "Straftat - Total"
GROUP BY jahr ORDER BY anzahl_straftaten DESC LIMIT 1;

-- Welches ist die meist begangene Straftat in der Schweiz?
SELECT T.straftat as hauefigste_straftat
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE
AND T.straftat != "Straftat - Total"
GROUP BY straftat ORDER BY anzahl_straftaten DESC LIMIT 1;

-- Wieviele aufgeklärte Straftaten gab es 2022 in Zürich?
SELECT T.anzahl_straftaten_aufgeklaert as anzahl_aufgeklaerte_straftaten_2022
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE
AND T.straftat = "Straftat - Total"
AND T.jahr = 2022;

-- Welches war die am meisten begangene Straftat 2020 im Kanton Bern?
SELECT T.straftat as hauefigste_straftat
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Bern%'
AND S.canton = TRUE AND T.jahr = 2020
AND T.straftat != "Straftat - Total"
GROUP BY straftat
ORDER BY anzahl_straftaten DESC LIMIT 1;

-- Welches ist die Kategorie der hauefigst begangenen Verbrechen in der Schweiz?
SELECT T.kategorie as haufigste_straftaten__kategorie_schweiz
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE
AND T.straftat != "Straftat - Total"
GROUP BY T.kategorie
ORDER BY anzahl_straftaten DESC LIMIT 1;


