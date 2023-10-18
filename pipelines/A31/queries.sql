-- Wie hoch war das durchschnittliche steuerbare Einkommen im Kanton Basel-Stadt im Jahr 2014?
SELECT (SUM(T.anzahl_veranlagungen * T.steuerbares_einkommen_mittelwert)) / SUM(T.anzahl_veranlagungen) AS steuerbares_einkommen_mittelwert_basel_stadt_2014
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2014;

-- Wie hoch war das durchschnittliche Reineinkommen in Matthäus, BS, 2015?
SELECT T.reineinkommen_mittelwert
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2015
    AND S.name = 'Matthäus';

-- Welche Wohnviertel in Basel-Stadt hat das höchste Netto-Medianeinkommen im Jahr 2005? Geben Sie auch das Einkommen an.
SELECT S.name, T.reineinkommen_median
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2005
ORDER BY T.reineinkommen_median DESC
LIMIT 1;

-- Wie stark hat sich das durchschnittliche steuerpflichtige Vermögen in Clara (BS) zwischen 1995 und 2015 verändert? Geben Sie den relativen Unterschied in Prozent an.
SELECT
    (
        100.0 *
        SUM(CASE WHEN T.jahr = 2015 THEN T.steuerbares_vermogen_mittelwert ELSE -T.steuerbares_vermogen_mittelwert END) /
        SUM(T.steuerbares_vermogen_mittelwert)
     ) AS steuerbares_vermogen_mittelwert_prozent_aenderung_1995_2015
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Clara'
    AND T.jahr IN (1995, 2015);

-- What residential area in Basel Stadt had the most income inequality in 2020 ?
SELECT S.name
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2020
ORDER BY T.reineinkommen_gini_koeffizient DESC
LIMIT 1;

-- What were the 3 residential areas in Basel-Stadt with the highest mean taxable assets in 2010? Also report the assets.
SELECT S.name, T.steuerbares_vermogen_mittelwert
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2010
ORDER BY T.steuerbares_vermogen_mittelwert DESC
LIMIT 3;

-- How did the mean net income and mean taxable income change (in percentage) between 2000 and 2020 in Clara, BS?
SELECT
    SUM(CASE WHEN T.jahr = 2020 THEN T.reineinkommen_mittelwert ELSE -T.reineinkommen_mittelwert END) / SUM(T.reineinkommen_mittelwert) AS reineinkommen_mittelwert_prozent_aenderung_2000_2020,
    SUM(CASE WHEN T.jahr = 2020 THEN T.steuerbares_einkommen_mittelwert ELSE -T.steuerbares_einkommen_mittelwert END) / SUM(T.steuerbares_einkommen_mittelwert) AS steuerbares_einkommen_mittelwert_prozent_aenderung_2000_2020
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Clara'
    AND T.jahr IN (2000, 2020);

-- Zeigen Sie mir alle Einkommenssteuerertragsindikatoren über Breite, im Kanton Basel-Stadt, über den Zeitraum 2015-2020.
SELECT T.jahr, T.ertrag_einkommenssteuer_mittelwert, T.ertrag_einkommenssteuer_median
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Breite'
    AND T.jahr BETWEEN 2015 AND 2020;

-- Welcher Anteil der Wohnvierteln in Basel-Stadt hatte 2015 ein mittleres Einkommen von über 80'000 CHF?
SELECT 100.0 * COUNT(CASE WHEN T.reineinkommen_mittelwert > 75000 THEN 1 END) / COUNT(*) AS anteil_wohnvierteln_ueber_100000_reineinkommen_mittelwert_2015
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE T.jahr = 2015;

-- Zeigen Sie mir den Gini-Koeffizienten des Reinvermögens für Bettingen, Iselin und Bruderholz (BS) im Jahr 2012.
SELECT S.name, T.reinvermogen_gini_koeffizient
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE T.jahr = 2012
    AND S.name IN ('Bettingen', 'Iselin', 'Bruderholz');

-- Wie hoch war das mittlere Reinvermögen in den 5 Wohngebieten von Basel-Stadt mit dem niedrigsten mittleren Reineinkommen im Jahr 2015?
SELECT S.name, T.reinvermogen_mittelwert AS reinvermogen_mittelwert_2015
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
JOIN (
    SELECT T.spatialunit_uid
    FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE T.jahr = 2015
    ORDER BY T.reineinkommen_mittelwert ASC
    LIMIT 5
) AS T2 ON T.spatialunit_uid = T2.spatialunit_uid
WHERE T.jahr = 2015;

-- In welchem Jahr war das durchschnittliche steuerbare Einkommen in Basel-Stadt am höchsten?
SELECT T.jahr
FROM basel_stadt_steuerstatistik_kennzahlen_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
GROUP BY T.jahr
ORDER BY (SUM(T.anzahl_veranlagungen * T.steuerbares_einkommen_mittelwert)) / SUM(T.anzahl_veranlagungen) DESC
LIMIT 1;
