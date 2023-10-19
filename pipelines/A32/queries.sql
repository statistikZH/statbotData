-- Welches war das Wohnviertel in Basel-Stadt mit der höchsten Arbeitslosenquote im Jahr 2016? Geben Sie auch dessen Arbeitslosenquote an.
SELECT S.name, T.arbeitslosenquote
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2016
ORDER BY T.arbeitslosenquote DESC
LIMIT 1;

-- Wie hoch ist die relative Veränderung (in %) des Ausländeranteils zwischen 2018 und 2023 in den einzelnen Wohnvierteln von Basel-Stadt?
SELECT
    S.name,
    (   100.0 *
        SUM(CASE WHEN T.jahr = 2023 THEN T.anteil_auslander ELSE -T.anteil_auslander END) /
        SUM(CASE WHEN T.jahr = 2018 THEN T.anteil_auslander END)
    ) AS prozent_aenderung_anteil_auslander_2018_2023
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr IN (2018, 2023)
GROUP BY S.name ;

-- Wie hoch waren der Altersquotient und der Jugendquotient in Gundelingen, BS in den Jahren 2015, 2017 und 2019?
SELECT T.jahr, T.altersquotient_uber_64_jahr, T.jugendquotient_unter_20_jahr
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Gundeldingen'
    AND T.jahr IN (2015, 2017, 2019);

-- Wie heissen die 3 Wohngebiete in Basel-Stadt mit der kleinsten Wohnfläche pro Einwohner im Jahr 2020?
SELECT S.name
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2020
ORDER BY T.wohnflache_pro_person_m2 ASC
LIMIT 3;

-- In welchem Jahr war die höchste Arbeitslosenquote in Vorstädte (BS) zu verzeichnen?
SELECT T.jahr
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Vorstädte'
ORDER BY T.arbeitslosenquote ASC
LIMIT 1;

-- Wie hoch war der Anteil der Personen ohne Religionszugehörigkeit in den Jahren 2015 und 2018 in Bachletten und St. Alban, BS?
SELECT
    S.name,
    T.jahr,
    T.anteil_personen_ohne_religionszugehorigkeit
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr IN (2015, 2018)
    AND S.name IN ('St. Alban', 'Bachletten');

-- Welches Wohnviertel in Basel-Stadt hatte im Jahr 2023 die durchschnittlich ältesten Gebäude und welches war das durchschnittliche Baudatum?
SELECT S.name, T.baujahr_der_wohngebaude
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2023
ORDER BY T.baujahr_der_wohngebaude ASC
LIMIT 1;

-- Zeige mir beschäftigungsbezogene Statistiken über Iselin (BS)
SELECT T.jahr, T.arbeitsplatze_pro_einwohner, T.arbeitslosenquote
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Iselin'
ORDER BY T.jahr ASC;

-- Wie hat sich die Wohnfläche pro Einwohner in der Altstadt Grossbasel über den Zeitraum 2015 - 2019 entwickelt?
SELECT T.jahr, T.wohnflache_pro_person_m2
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Altstadt Grossbasel'
    AND T.jahr >= 2015
    AND T.jahr <= 2019
ORDER BY T.jahr ASC;

-- Welche 3 Basler Wohngebiete hatten 2015 den geringsten Anteil an Sozialhilfeempfängern und wie hoch waren die Anteile?
SELECT S.name, T.anteil_sozialhilfeempfanger
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr = 2015
ORDER BY T.anteil_sozialhilfeempfanger ASC
LIMIT 3;

-- Für welchen Zeitraum liegen beschäftigungsbezogene Statistiken über die Wohngebiete in Basel-Stadt vor?
SELECT MIN(T.jahr) erste_jahr, MAX(T.jahr) AS letzte_jahr
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE ;

-- Wie hat sich der Anteil an Grünflächen (in Prozent) von 2015 bis 2022 in den einzelnen Wohngebieten von Basel-Stadt verändert?
SELECT
    S.name,
    (   100.0 *
        SUM(CASE WHEN T.jahr = 2022 THEN T.anteil_grunflachen ELSE -T.anteil_grunflachen END) /
        SUM(CASE WHEN T.jahr = 2015 THEN T.anteil_grunflachen END)
    ) AS prozent_aenderung_anteil_grunflachen_2018_2022
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND T.jahr IN (2015, 2022)
GROUP BY S.name
ORDER BY prozent_aenderung_anteil_grunflachen_2018_2022 DESC;

-- Wie hoch ist der Anteil der Sekundarschülerinnen und -schüler im BruderHolz in Basel-Stadt in den Jahren 2016 und 2020 in den Progymnasialklassen?
SELECT T.jahr, T.gymnasialquote_anteil_progymnasium
FROM basel_stadt_kennzahlen_zu_den_basler_wohnvierteln AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.residence_area = TRUE
    AND S.name = 'Bruderholz'
    AND T.jahr IN (2016, 2020);