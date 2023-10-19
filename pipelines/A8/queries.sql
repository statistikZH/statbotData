-- Welche Partei hatte 2019 am meisten Wàhler (inklusive fiktive Wähler) in der Schweiz?
SELECT T.partei AS staerkeste_partei_2019,
  T.anzahl_fiktive_wahlende
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.partei != 'Übrige'
AND T.anzahl_fiktive_wahlende IS NOT NULL AND T.jahr = 2019
ORDER BY anzahl_fiktive_wahlende DESC LIMIT 1;

-- Welche Partei war 2019 prozentual am stàrksten in der Schweiz und wie stark war sie?
SELECT T.partei AS staerkste_partei_2019, T.parteistarke_in_prozent
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.parteistarke_in_prozent IS NOT NULL AND T.jahr = 2019
ORDER BY T.parteistarke_in_prozent DESC LIMIT 1;

-- In welchem Kanton war die FDP 2019 prozentual am stàrksten und wie stark war sie dort?
SELECT S.name_de as kanton, T.parteistarke_in_prozent AS parteistaerke_fdp_2019
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE AND partei = 'FDP'
AND T.parteistarke_in_prozent IS NOT NULL AND T.jahr = 2019
ORDER BY parteistaerke_fdp_2019 DESC LIMIT 1;

-- In welchem Jahr hatte die FDP das schwàchste Ergebnis in Prozent im Kanton Appenzell Ausserrhoden? Und wie schwach war es?
SELECT T.jahr, T.parteistarke_in_prozent AS partei_staerke_fdp_appenzell_ausserhoden
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE AND S.name_de LIKE '%Appenzell Ausserrhoden'
AND T.partei = 'FDP'
AND T.parteistarke_in_prozent IS NOT NULL
ORDER BY parteistarke_in_prozent ASC LIMIT 1;

-- Wann, in welchen Kantonen und welche Partei hatten das beste Ergebnis und wie hoch war es jeweils prozentual? Liste die 5 höchsten Ergenisse auf.
SELECT S.name_de as kanton, T.parteistarke_in_prozent, T.jahr, T.partei
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
AND T.parteistarke_in_prozent IS NOT NULL
ORDER BY T.parteistarke_in_prozent DESC LIMIT 5;

-- Wann und in welchen Kantonen stand die Partei LEGA zur Wahl und welche Parteistärke hatte sie?
SELECT S.name_de AS kanton, T.jahr, T.parteistarke_in_prozent AS parteienstaerke_Lega
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND T.partei = 'Lega'
  AND T.parteistarke_in_prozent IS NOT NULL
GROUP BY kanton, T.jahr, T.partei, T.parteistarke_in_prozent
ORDER BY jahr ASC;

-- Welche Parteien standen 2019 im Kanton Glarus zur Wahl und welche prozentuale Stärke hatten sie?
SELECT T.partei, T.parteistarke_in_prozent
FROM nationalratswahlen AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE T.parteistarke_in_prozent IS NOT NULL
  AND T.jahr = 2019
  AND S.canton = TRUE AND S.name_de LIKE '%Glarus%';

-- In wievielen Kantonen waren die Parteien 2019 jeweils aktiv und bei welcher Parteistärke schweizweit?
SELECT T.partei,
  COUNT(CASE WHEN T.parteistarke_in_prozent IS NOT NULL AND S.canton = TRUE THEN 1 ELSE NULL END) AS anzahl_kantone_wo_partei_aktiv_ist,
  MAX(CASE WHEN S.country = TRUE THEN T.parteistarke_in_prozent ELSE NULL END) AS parteistarke_schweiz
FROM nationalratswahlen AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE T.jahr = 2019
  AND S.canton = TRUE OR S.country = TRUE
GROUP BY T.partei
ORDER BY anzahl_kantone_wo_partei_aktiv_ist DESC;

-- In welchen Kantonen stand die Partei SVP 2019 nicht zur Wahl?
SELECT S.name_de AS kanton_ohne_svp_2019
FROM nationalratswahlen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND T.partei = 'SVP'
  AND T.jahr = 2019
  AND T.parteistarke_in_prozent IS NULL;

-- Zeige das Verhältnis Parteistimmen zu fiktiven Wählenden für alle Kantone, Stand 2019. Sortiere nach der Grösse des Faktors.
SELECT SUM(T.anzahl_parteistimmen) / SUM(T.anzahl_fiktive_wahlende) AS faktor_nationalratswahlen, S.name_de
FROM nationalratswahlen AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE T.jahr = 2019
  AND S.canton = TRUE
GROUP BY S.name_de
ORDER BY faktor_nationalratswahlen DESC;
