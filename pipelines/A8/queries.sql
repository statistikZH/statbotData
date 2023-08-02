-- Welche Partei hatte 2019 am meisten fiktive Wàhler in der Schweiz?
SELECT anzahl_fiktive_wahlende, partei, jahr
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.anzahl_fiktive_wahlende IS NOT NULL AND T.jahr = 2019
ORDER BY T.anzahl_fiktive_wahlende DESC LIMIT 1;

-- Welche Partei war 2019 prozentual and stàrksten in der Schweiz?
SELECT parteistarke_in_prozent, partei, jahr
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.parteistarke_in_prozent IS NOT NULL AND T.jahr = 2019
ORDER BY T.parteistarke_in_prozent DESC LIMIT 1;

-- In welchem Kanton war die FDP 2019 prozentual am stàrksten?
SELECT MAX(parteistarke_in_prozent) as strongest_in_percent, partei, jahr, S.name_de
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE AND partei = 'FDP'
AND T.parteistarke_in_prozent IS NOT NULL AND T.jahr = 2019;

-- In welchem Jahr hatte die FDP das schwàchste Ergebnis in Prozent im Kanton Appenzell Ausserrhoden?
SELECT MIN(parteistarke_in_prozent) as smallest_in_percent, partei, jahr, S.name_de
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE AND S.name_de LIKE '%Appenzell Ausserrhoden'
AND T.partei = 'FDP'
AND T.parteistarke_in_prozent IS NOT NULL;
