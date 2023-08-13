-- Welche Partei hatte 2019 am meisten fiktive Wàhler in der Schweiz?
SELECT partei as partei_mit_meisten_fiktiven_waehler_schweiz_2019
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.partei!='Übrige'
AND T.anzahl_fiktive_wahlende IS NOT NULL AND T.jahr = 2019
ORDER BY anzahl_fiktive_wahlende DESC LIMIT 1;

-- Welche Partei war 2019 prozentual and stàrksten in der Schweiz?
SELECT partei as staerkste_partei_2019_schweiz
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.parteistarke_in_prozent IS NOT NULL AND T.jahr = 2019
ORDER BY T.parteistarke_in_prozent DESC LIMIT 1;

-- In welchem Kanton war die FDP 2019 prozentual am stàrksten?
SELECT S.name_de as kanton_wo_die_fdp_2019_am_starksten_war
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE AND partei = 'FDP'
AND T.parteistarke_in_prozent IS NOT NULL AND T.jahr = 2019
ORDER BY parteistarke_in_prozent DESC LIMIT 1;

-- In welchem Jahr hatte die FDP das schwàchste Ergebnis in Prozent im Kanton Appenzell Ausserrhoden?
SELECT T.jahr as jahr_wo_die_fdp_schwaechstes_ergebnis_in_appenzell_ausserhoden_hatte
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE AND S.name_de LIKE '%Appenzell Ausserrhoden'
AND T.partei = 'FDP'
AND T.parteistarke_in_prozent IS NOT NULL
ORDER BY parteistarke_in_prozent ASC LIMIT 1;
