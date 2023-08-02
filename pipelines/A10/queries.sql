-- In welchem Jahr gab es die meisten Straftaten in der Schweiz?
SELECT T.jahr as jahr_mit_meisten_straftaten
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE AND T.ausfuhrungsgrad = 'Ausführungsgrad - Total'
AND T.aufklarungsgrad  = 'Aufklärungsgrad - Total' AND T.straftat = 'Straftat - Total'
GROUP BY jahr ORDER BY anzahl_straftaten DESC LIMIT 1;

-- Welches ist die meist begangene Straftat in der Schweiz?
SELECT T.straftat as hauefigste_straftat
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE AND T.ausfuhrungsgrad = 'Ausführungsgrad - Total'
AND T.aufklarungsgrad  = 'Aufklärungsgrad - Total' AND T.straftat <> 'Straftat - Total'
GROUP BY straftat ORDER BY anzahl_straftaten DESC LIMIT 1;

-- Wieviele ausgeführte und aufgeklärte Straftaten gab es 2022 in Zürich?
SELECT SUM(T.anzahl_straftaten) as anzahl_aufgeklaerte_straftaten_2022
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE
AND T.ausfuhrungsgrad = 'Vollendet'
AND T.jahr = 2022
AND T.aufklarungsgrad  = 'Aufgeklärt';

-- Welches war die am meisten begangene Straftat 2020 im Kanton Zürich?
SELECT T.straftat as haufigste_straftat_2020_kanton_zurich
FROM straftaten_aufklaerung as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE
AND T.ausfuhrungsgrad = 'Vollendet'
AND T.aufklarungsgrad  = 'Aufklärungsgrad - Total'
GROUP BY straftat
ORDER BY anzahl_straftaten LIMIT 1;
