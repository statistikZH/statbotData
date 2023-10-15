-- Wieviele Beschäftigte waren in Artpraxen, die als Einzelunternehmen im Kanton Bern registriert sind, in 2019 tätig?
SELECT SUM(anzahl_beschaeftigte) as beschaeftigte_in_einzel_praxen_in_bern_2019
FROM arztpraxen_ambulante_zentren as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Bern%' AND S.canton=TRUE
AND T.rechtsform LIKE '%Einzel%' AND T.jahr=2019;

-- Welche Rechtsform hatte einen Zuwachs an Ärzten zwischen 2017 und 2021 und wie gross war der Zuwachs?
SELECT T.rechtsform,
  (SUM(CASE WHEN jahr = 2021 THEN T.anzahl_beschaeftigte ELSE 0 END) -
   SUM(CASE WHEN jahr = 2017 THEN T.anzahl_beschaeftigte ELSE 0 END)) as zuwachs_aerzte_2017_bis_2021
FROM arztpraxen_ambulante_zentren AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de = 'Schweiz' AND S.country = TRUE
  AND LOWER(T.rechtsform) NOT LIKE '%total%'
  AND LOWER(T.altersgruppe) LIKE '%total%'
  AND LOWER(T.geschlecht) LIKE '%total%'
  AND T.jahr IN (2017, 2021)
GROUP BY T.rechtsform;

-- In welchen fünf Kantonen hatte es 2021 den grössten Prozentsatz an Ärzten in Einzelpraxen, wie gross war der Prozentsatz jeweils?
SELECT S.name_de AS kanton,
  ROUND(100 * SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%einzel%' THEN T.anzahl_beschaeftigte ELSE 0 END) /
        NULLIF(SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%total%' THEN anzahl_beschaeftigte ELSE 0 END), 0), 2) as prozent_aerzte_in_einzelpraxen_2021
FROM arztpraxen_ambulante_zentren AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND LOWER(T.altersgruppe) LIKE '%total%'
  AND LOWER(T.geschlecht) LIKE '%total%'
  AND T.jahr = 2021
GROUP BY S.name_de
ORDER BY prozent_aerzte_in_einzelpraxen_2021 DESC LIMIT 5;

-- Wieviel Prozent der Ärtze über 65 bevorzugten 2021 Einzelpraxen gegenüber anderen Rechtsformen?
SELECT
  ROUND(100 * SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%einzel%' THEN T.anzahl_beschaeftigte ELSE 0 END) /
        NULLIF(SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%total%' THEN T.anzahl_beschaeftigte ELSE 0 END), 0), 2) as prozentsatz_aerzte_ueber_65_in_einzelpraxen
FROM arztpraxen_ambulante_zentren AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
  AND T.altersgruppe LIKE '%65%'
  AND LOWER(T.geschlecht) LIKE '%total%'
  AND T.jahr = 2021;

-- Wieviel Personen arbeiteten 2021 im Durchschnitt auf einem Vollzeitaquivalent pro Rechtsform? Berechne das Ergebnis getrennt nach Geschlecht
SELECT
  SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%einzel%' AND T.geschlecht = 'Frauen' THEN T.anzahl_beschaeftigte ELSE 0 END) /
      NULLIF(SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%einzel%' AND T.geschlecht = 'Frauen' THEN T.anzahl_vollzeitaquivalente ELSE 0 END), 0)
      AS einzelpraxen_aerztinnen_pro_vollzeitequivalent,
  SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%einzel%' AND T.geschlecht = 'Frauen' THEN T.anzahl_beschaeftigte ELSE 0 END) /
      NULLIF(SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%andere%' AND T.geschlecht = 'Frauen' THEN T.anzahl_vollzeitaquivalente ELSE 0 END), 0)
      AS andere_rechtsformen_aerztinnen_pro_vollzeitequivalent,
  SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%einzel%' AND T.geschlecht = 'Männer' THEN T.anzahl_beschaeftigte ELSE 0 END) /
      NULLIF(SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%einzel%' AND T.geschlecht = 'Männer' THEN T.anzahl_vollzeitaquivalente ELSE 0 END), 0)
      AS einzelpraxen_aerzte_pro_vollzeitequivalent,
  SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%einzel%' AND T.geschlecht = 'Männer' THEN T.anzahl_beschaeftigte ELSE 0 END) /
      NULLIF(SUM(CASE WHEN LOWER(T.rechtsform) LIKE '%andere%' AND T.geschlecht = 'Männer' THEN T.anzahl_vollzeitaquivalente ELSE 0 END), 0)
      AS andere_rechtsformen_aerzte_pro_vollzeitequivalent
FROM arztpraxen_ambulante_zentren AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
  AND LOWER(T.altersgruppe) LIKE '%total%'
  AND T.jahr = 2021;

-- Welche drei Kanton hatten 2021 prozentual die meisten jungen Ärzte und Ärztinnen und wieviel Prozent waren es jeweils?
SELECT S.name_de AS kanton,
  ROUND(100 * SUM(CASE WHEN LOWER(T.altersgruppe) LIKE '%unter%' THEN T.anzahl_beschaeftigte ELSE 0 END) /
        NULLIF(SUM(CASE WHEN LOWER(T.altersgruppe) LIKE '%total%' THEN T.anzahl_beschaeftigte ELSE 0 END), 0), 2)
        AS prozent_junge_arzte_und_arztinnen
FROM arztpraxen_ambulante_zentren AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND LOWER(T.geschlecht) LIKE '%total%'
  AND LOWER(T.rechtsform) LIKE '%total%'
  AND T.jahr = 2021
GROUP BY S.name_de
ORDER BY prozent_junge_arzte_und_arztinnen DESC LIMIT 3;

-- Welcher Kanton hatte 2017 den grössten Anteil weiblicher Ärzte in Prozent?
SELECT S.name_de AS kanton,
  ROUND(100 * SUM(CASE WHEN T.geschlecht = 'Frauen' THEN T.anzahl_beschaeftigte ELSE 0 END) /
        NULLIF(SUM(CASE WHEN LOWER(T.geschlecht) LIKE '%total%' THEN T.anzahl_beschaeftigte ELSE 0 END), 0), 2)
        AS prozent_weibliche_arzte
FROM arztpraxen_ambulante_zentren AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND LOWER(T.altersgruppe) LIKE '%total%'
  AND LOWER(T.rechtsform) LIKE '%total%'
  AND T.jahr = 2021
GROUP BY S.name_de
ORDER BY prozent_weibliche_arzte DESC LIMIT 3;

-- Wieviele Ärzte arbeiteten 2019 im Kanton Zürich und wie verteilen sie sich auf Altersklassen?
SELECT SUM(T.anzahl_beschaeftigte) AS anzahl_aerzte_kanton_zurich, T.altersgruppe
FROM arztpraxen_ambulante_zentren AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE AND S.name_de LIKE '%Zürich%'
  AND LOWER(T.geschlecht) LIKE '%total%'
  AND LOWER(T.rechtsform) LIKE '%total%'
  AND T.jahr = 2019
GROUP BY S.name_de, T.altersgruppe
ORDER BY anzahl_aerzte_kanton_zurich DESC;

-- Wie hat sich das Verhàltnis Stellen zu Vollzeitàquivalenten bei den Schweizer Ärzten über die Jahre verändert?
SELECT T.jahr,
  AVG(T.anzahl_beschaeftigte) / AVG(T.anzahl_vollzeitaquivalente) AS stellenanzahl_pro_vollzeit_aequivalent
FROM arztpraxen_ambulante_zentren AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country = TRUE
  AND LOWER(T.altersgruppe) LIKE '%total%'
  AND LOWER(T.geschlecht) LIKE '%total%'
  AND LOWER(T.rechtsform) LIKE '%total%'
GROUP BY T.jahr
ORDER BY T.jahr ASC;

-- Welcher Kanton hatte 2021 die wenigsten weiblichen Ärzte und wieviele waren es?
SELECT S.name_de AS kanton,
  SUM(T.anzahl_beschaeftigte) AS anzahl_aerztinnen
FROM arztpraxen_ambulante_zentren AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
  AND LOWER(T.altersgruppe) LIKE '%total%'
  AND T.geschlecht = 'Frauen'
  AND LOWER(T.rechtsform) LIKE '%total%'
  AND T.jahr = 2021
GROUP BY S.name_de
ORDER BY anzahl_aerztinnen ASC LIMIT 1;

