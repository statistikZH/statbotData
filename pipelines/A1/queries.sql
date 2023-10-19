-- Wieviele Angiographiegeräte gab es 2013 in der Schweiz?
SELECT SUM(anzahl_gerate) as anzahl_gerate_in_2013
FROM medizinisch_technische_infrastruktur as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country=TRUE
  AND jahr = '2013'
  AND T.genutzte_infrastruktur LIKE '%Angiographie%';

-- Welches war das medizinische Gerät 2021 in der Schweiz mit den meisten Untersuchungen und wieviele Untersuchungen gab es damit?
SELECT T.genutzte_infrastruktur as meistgenutztes_geraet_2021,
  SUM(anzahl_untersuchungen_total) as anzahl_untersuchungen
FROM medizinisch_technische_infrastruktur as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country=TRUE
  AND jahr = '2021'
GROUP BY T.genutzte_infrastruktur
ORDER BY anzahl_untersuchungen DESC LIMIT 1;

-- Welche drei Kantone haben 2021 den höchsten prozentualen Anteil an ambulanten CT Untersuchungen und wie hoch war er?
SELECT s.name_de as kanton,
  ROUND(SUM(T.anzahl_ambulante_untersuchungen) * 100 / SUM(T.anzahl_untersuchungen_total), 2) as prozent_ambulante_untersuchungen
FROM medizinisch_technische_infrastruktur as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
  AND T.jahr = '2021'
  AND T.genutzte_infrastruktur LIKE 'CT%'
  AND T.anzahl_untersuchungen_total != 0
GROUP BY S.name_de
ORDER BY prozent_ambulante_untersuchungen DESC LIMIT 3;

-- Welches fünf medizinische Geräte haben den höchsten prozentualen Anteil an ambulanten Untersuchungen und wie hoch ist er?
SELECT T.genutzte_infrastruktur,
  ROUND(SUM(T.anzahl_ambulante_untersuchungen) * 100 / SUM(T.anzahl_untersuchungen_total), 2) as prozent_ambulante_untersuchungen
FROM medizinisch_technische_infrastruktur as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country=TRUE
  AND T.anzahl_untersuchungen_total != 0
GROUP BY T.genutzte_infrastruktur
ORDER BY prozent_ambulante_untersuchungen DESC LIMIT 5;

-- Welche Kantone hatten in 2021 noch keinen CT-Scanner?
SELECT S.name_de as kanton_ohne_ct_scanner_in_2021
FROM medizinisch_technische_infrastruktur as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
  AND T.genutzte_infrastruktur LIKE 'CT%'
  AND T.anzahl_gerate = 0
  AND T.jahr = 2021;

-- Welche fünf Kantone hatte 2021 die grösste medizinische Infrastruktur mit den meisten Geräten und wieviele Geräte waren es?
SELECT S.name_de as kanton_mit_groesster_medizinischer_infrastruktur, SUM(T.anzahl_gerate) as anzahl_geraete
FROM medizinisch_technische_infrastruktur as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
  AND T.jahr = 2021
GROUP BY S.name_de
ORDER BY anzahl_geraete DESC LIMIT 5;

-- Welche fünf Kantone machte 2021 den besten Nutzen von seiner CT Scanner mit den meisten Untersuchungen pro CT Scanner und wieviele Untersuchungen gab es pro Gerät und auf wieviele Geräte verteilten sie sich?
SELECT S.name_de as kanton_mit_meisten_untersuchungen_pro_geraet,
  ROUND(SUM(T.anzahl_untersuchungen_total) / SUM(T.anzahl_gerate), 0) as untersuchungen_pro_geraet,
  SUM(T.anzahl_gerate) as anzahl_geraete
FROM medizinisch_technische_infrastruktur as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
  AND T.jahr = 2021
  AND T.genutzte_infrastruktur LIKE 'CT%'
  AND T.anzahl_gerate != 0
GROUP BY S.name_de
ORDER BY untersuchungen_pro_geraet DESC LIMIT 5;

-- Welche medizinischen Geräte zählen in der Schweiz zur medizinischen Infrastruktur und wieviele gab es davon jeweils 2020? Sortiere nach Geräteanzahl.
SELECT SUM(T.anzahl_gerate) as gerate_anzahl_2020, T.genutzte_infrastruktur
FROM medizinisch_technische_infrastruktur as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country=TRUE
  AND T.jahr = 2020
GROUP BY T.genutzte_infrastruktur
ORDER BY gerate_anzahl_2020 DESC;

-- Welches drei medizinischen Geräte hatten den meisten Zuwachs zwischen 2013 und 2021 in der Schweiz und wieviele Neuanschaffungen gab es jeweils?
WITH Infrastruktur2013 AS (
    SELECT T1.anzahl_gerate as gerate_anzahl_2013, T1.genutzte_infrastruktur
    FROM medizinisch_technische_infrastruktur as T1
    JOIN spatial_unit as S on T1.spatialunit_uid = S.spatialunit_uid
    WHERE S.country=TRUE
      AND T1.jahr = 2013
    GROUP BY T1.genutzte_infrastruktur, gerate_anzahl_2013
),
Infrastruktur2021 AS (
    SELECT T2.anzahl_gerate as gerate_anzahl_2021, T2.genutzte_infrastruktur
    FROM medizinisch_technische_infrastruktur as T2
    JOIN spatial_unit as S on T2.spatialunit_uid = S.spatialunit_uid
    WHERE S.country=TRUE
      AND T2.jahr = 2021
    GROUP BY T2.genutzte_infrastruktur, gerate_anzahl_2021
)
SELECT
    MI2013.genutzte_infrastruktur,
    MI2021.gerate_anzahl_2021 - MI2013.gerate_anzahl_2013 AS zuwachs_an_geraeten
FROM Infrastruktur2013 MI2013
JOIN Infrastruktur2021 MI2021 ON MI2013.genutzte_infrastruktur = MI2021.genutzte_infrastruktur
ORDER BY zuwachs_an_geraeten DESC
LIMIT 3;

-- Welchem drei Kantone hatte den grössten Zuwachs und Untersuchungen mit medizinischen Geräten zwischen 2013 and 2021 und wieviel hoch war der Zuwachs verteilt auf ambulante und stationäre Untersuchungen und Geräte?
WITH Untersuchungen2013 AS (
SELECT SUM(T1.anzahl_untersuchungen_total) as anzahl_untersuchungen_gesamt_2013,
  SUM(T1.anzahl_ambulante_untersuchungen) as anzahl_ambulante_untersuchungen_2013,
  SUM(T1.anzahl_stationare_untersuchungen) as anzahl_stationare_untersuchungen_2013,
  SUM(T1.anzahl_gerate) as anzahl_gerate_2013,
  S1.name_de as kanton
    FROM medizinisch_technische_infrastruktur as T1
    JOIN spatial_unit as S1 on T1.spatialunit_uid = S1.spatialunit_uid
    WHERE S1.canton=TRUE
      AND T1.jahr = 2013
    GROUP BY S1.name_de
),
Untersuchungen2021 AS (
    SELECT SUM(T2.anzahl_untersuchungen_total) as anzahl_untersuchungen_gesamt_2021,
      SUM(T2.anzahl_ambulante_untersuchungen) as anzahl_ambulante_untersuchungen_2021,
      SUM(T2.anzahl_stationare_untersuchungen) as anzahl_stationare_untersuchungen_2021,
      SUM(T2.anzahl_gerate) as anzahl_gerate_2021,
      S2.name_de as kanton2021
    FROM medizinisch_technische_infrastruktur as T2
    JOIN spatial_unit as S2 on T2.spatialunit_uid = S2.spatialunit_uid
    WHERE S2.canton=TRUE
      AND T2.jahr = 2021
    GROUP BY S2.name_de
)
SELECT
    U2013.kanton,
    U2021.anzahl_untersuchungen_gesamt_2021 - U2013.anzahl_untersuchungen_gesamt_2013 AS zuwachs_untersuchungen_gesamt,
    U2021.anzahl_ambulante_untersuchungen_2021 - U2013.anzahl_ambulante_untersuchungen_2013 AS zuwachs_ambulante_untersuchungen,
    U2021.anzahl_stationare_untersuchungen_2021 - U2013.anzahl_stationare_untersuchungen_2013 AS zuwachs_statinonäre_untersuchungen,
    U2021.anzahl_gerate_2021 - U2013.anzahl_gerate_2013 AS zuwachs_geraete
FROM Untersuchungen2013 U2013
JOIN Untersuchungen2021 U2021 ON U2013.kanton = U2021.kanton2021
ORDER BY zuwachs_untersuchungen_gesamt DESC
LIMIT 3;
