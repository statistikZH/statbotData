-- Welches Jahr hatte die meisten Volksabstimmungen und wieviele Volksabstimmungen gab es da?
SELECT T.jahr as jahr_mit_den_meisten_volksabstimmungen, COUNT(*) as anzahl_volksabstimmungen
FROM volksabstimmung_nach_kanton_seit_1861 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
GROUP BY T.jahr
ORDER BY anzahl_volksabstimmungen DESC LIMIT 1;

-- Welches waren die drei Volksabstimmung mit der höchsten Beteiligung, wann fanden sie statt und wie hoch war die Beteiligung in Prozent?
SELECT T.jahr, MAX(T.beteiligung_in_prozent) AS hoechste_beteiligung_in_prozent, T.vorlage
FROM volksabstimmung_nach_kanton_seit_1861 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.beteiligung_in_prozent IS NOT NULL
GROUP BY T.jahr, T.vorlage
ORDER BY hoechste_beteiligung_in_prozent DESC
LIMIT 3;

-- Welche Vorlagen hatten mit dem Klima zu tun, wann fanden sie statt, wie waren Beteiligung und Ergebnis?
SELECT T.vorlage, T.jahr, T.beteiligung_in_prozent, T.ja_in_prozent
FROM volksabstimmung_nach_kanton_seit_1861 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND LOWER(T.vorlage) LIKE '%klima%';

-- Wieviel Prozent der Vorlagen wurden angenommen und wieviel Prozent wurden zurückgewiesen?
SELECT
  ROUND((100 * COUNT(CASE WHEN T.ja_in_prozent > 50 THEN 1 ELSE NULL END)) /
  COUNT(*), 2) AS prozent_angenommene_vorlagen,
  ROUND((100 * COUNT(CASE WHEN T.ja_in_prozent <= 50 THEN 1 ELSE NULL END)) /
  COUNT(*), 2) AS prozent_zurueckgewiesene_vorlagen
FROM volksabstimmung_nach_kanton_seit_1861 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE;

-- Welche Kantone haben 2023 gegen das Bundesgesetz über Klimaschutz gestimmt und wieviel Prozent Ja Stimmen gab es dort jeweils?
SELECT S.name_de as kanton_gegen_klimaschutzgesetz, T.ja_in_prozent
FROM volksabstimmung_nach_kanton_seit_1861 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
AND LOWER(T.vorlage) LIKE '%bundesgesetz%klimaschutz%' AND T.jahr = 2023
AND T.ja_in_prozent <= 50
GROUP BY S.name_de, T.vorlage, T.jahr, T.ja_in_prozent;

-- Welches ist aktuellest Vorlage die schweizweit angenommen wurde, aber bei der in der Mehrheit der Kanton dagegen gestimmt wurde? Zeige auch wieviel Prozent Ja Stimmen sie Schweiz weit bekam.
SELECT T.vorlage,
  MAX(CASE WHEN T.ja_in_prozent > 50 AND S.country = TRUE THEN T.ja_in_prozent ELSE NULL END) AS angenommen_gesamt,
  COUNT(CASE WHEN T.ja_in_prozent > 50 AND S.canton = TRUE THEN 1 ELSE NULL END) AS angenommen_in,
  COUNT(CASE WHEN T.ja_in_prozent <= 50 AND S.canton = TRUE THEN 1 ELSE NULL END) AS abgelehnt_in
FROM volksabstimmung_nach_kanton_seit_1861 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
GROUP BY T.vorlage, T.jahr
HAVING MAX(CASE WHEN T.ja_in_prozent > 50 AND S.country = TRUE THEN T.ja_in_prozent ELSE NULL END) IS NOT NULL
   AND COUNT(CASE WHEN T.ja_in_prozent <= 50 AND S.canton = TRUE THEN 1 ELSE NULL END) > COUNT(CASE WHEN T.ja_in_prozent > 50 AND S.canton = TRUE THEN 1 ELSE NULL END)
ORDER BY T.jahr DESC LIMIT 1;

-- Welche Volksabstimmung und in welchem Jahr hatte die wenigsten gültigen Stimmenzettel? Wieviele waren es? Und wie hoch war die Wahlbeteiligung?
SELECT T.vorlage AS vorlage_mit_wenigsten_gueltigen_stimmenzetteln, T.jahr,
  MIN(T.anzahl_gueltige_stimmzettel) AS anzahl_gueltige_stimmzettel, T.beteiligung_in_prozent
FROM volksabstimmung_nach_kanton_seit_1861 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE AND S.name_de = 'Schweiz'
GROUP BY T.vorlage, T.jahr, T.beteiligung_in_prozent
ORDER BY anzahl_gueltige_stimmzettel ASC LIMIT 1;

-- Welche drei Kanton hatten im Jahr 2023 durchschnittlich die wenigsten Stimmberechtigten? Wieviel Stimmberechtigte waren es jeweils?
SELECT S.name_de AS kanton, AVG(T.anzahl_stimmberechtigte) AS durchschnittliche_anzahl_stimmberechtigte_2023
FROM volksabstimmung_nach_kanton_seit_1861 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
AND T.jahr = 2023
GROUP BY S.name_de
ORDER BY durchschnittliche_anzahl_stimmberechtigte_2023 ASC LIMIT 3;

-- Welcher Vorlage in welchem Jahr hatte die meisten Nein Stimmen und bei welcher Wahlbeteiligung und wievielen Ja Stimmen in Prozent?
SELECT T.vorlage, T.jahr, T.anzahl_nein_stimmen AS hoechste_anzahl_nein_stimmen, T.beteiligung_in_prozent, T.ja_in_prozent
FROM volksabstimmung_nach_kanton_seit_1861 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
ORDER BY hoechste_anzahl_nein_stimmen DESC LIMIT 1;

-- Welche Vorlage in welchem Jahr und welchem Kanton bekam jemals die höchste Annahme in Prozent und wie hoch war diese Annahme bei welcher Wahlbeteiligung?
SELECT T.vorlage, T.jahr, S.name_de AS kanton, T.ja_in_prozent as hoechste_annahme, T.beteiligung_in_prozent
FROM volksabstimmung_nach_kanton_seit_1861 AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND T.ja_in_prozent IS NOT NULL
ORDER BY hoechste_annahme DESC LIMIT 1;



