-- Wie viele Personen waren 2015 im primären Sektor in Uttwil TG beschäftigt?
SELECT T.beschaftigte_personen
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Uttwil', 'Uttwil (TG)')
    AND T.jahr = 2015
    AND T.sektor = 'Primär';

-- Wie viele Beschäftigte des tertiären Sektors waren 2011 und 2021 im Kanton Thurgau tätig?
SELECT T.jahr, SUM(T.beschaftigte_personen)
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr IN (2011, 2021)
    AND T.sektor = 'Tertiär'
GROUP BY T.jahr;

-- Welches sind die fünf Thurgauer Gemeinden mit dem höchsten Anteil an Beschäftigten im sekundären Sektor im Jahr 2020? Geben Sie auch die Anteile in Prozent an.
SELECT
    S.name AS gemeinde,
    (
        100.0 * SUM(CASE WHEN T.sektor = 'Sekundär' THEN T.beschaftigte_personen ELSE 0 END) /
        SUM(T.beschaftigte_personen)
    ) as prozent_beschaftigte_personen_sektor_2
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2020
GROUP BY S.name
ORDER BY prozent_beschaftigte_personen_sektor_2
DESC LIMIT 5;

-- Wie viele Personen waren im Jahr 2015 in der Stadt Frauenfeld im Kanton Thurgau im sekundären Sektor beschäftigt?
SELECT T.beschaftigte_personen
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Frauenfeld', 'Frauenfeld (TG)')
    AND T.jahr = 2015
    AND T.sektor = 'Sekundär';

-- Wie hoch war die Zahl der Beschäftigten pro Wirtschaftszweig im Kanton Thurgau in den Jahren 2017 bis 2020?
SELECT T.jahr, T.sektor, SUM(T.beschaftigte_personen)
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr >= 2017
    AND T.jahr <= 2020
GROUP BY T.sektor, T.jahr;

-- In welcher Thurgauer Gemeinde ist die Zahl der Beschäftigten zwischen 2015 und 2020 am stärksten gewachsen?
SELECT S.name AS gemeinde
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr IN (2015, 2020)
GROUP BY S.name
ORDER BY (
    100.0 * SUM(CASE WHEN T.jahr = 2020 THEN T.beschaftigte_personen ELSE 0 END) /
    SUM(CASE WHEN T.jahr = 2015 THEN T.beschaftigte_personen ELSE 0 END)
) DESC LIMIT 1;

-- Wie hoch ist die relative Veränderung der Beschäftigten in den einzelnen Wirtschaftssektoren im Thurgau in Prozent zwischen 2011 und 2021?
SELECT
    AGG.sektor,
    (
        100.0 *
        (AGG.beschaftigte_personen_2021 - AGG.beschaftigte_personen_2011) /
        AGG.beschaftigte_personen_2011
    ) AS relative_veranderung_beschaftigte_personen
FROM (
    SELECT
        T.sektor,
        SUM(CASE WHEN T.jahr = 2021 THEN T.beschaftigte_personen ELSE 0 END) AS beschaftigte_personen_2021,
        SUM(CASE WHEN T.jahr = 2011 THEN T.beschaftigte_personen ELSE 0 END) AS beschaftigte_personen_2011
    FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal = TRUE
        AND T.jahr IN (2011, 2021)
    GROUP BY T.sektor
) AS AGG;

-- In welchem Jahr erreichte die Zahl der Beschäftigten im primären Sektor im Thurgau ihren Höhepunkt?
SELECT T.jahr
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.sektor = 'Primär'
GROUP BY T.jahr
ORDER BY SUM(T.beschaftigte_personen) DESC LIMIT 1;

-- Wie hoch ist der Anteil (in %) der Thurgauer Gemeinden, in denen 2016 die Zahl der Beschäftigten im primären Sektor höher war als im sekundären Sektor?
SELECT (
    100.0 * COUNT(CASE WHEN T.beschaftigte_personen_sektor_1 > T.beschaftigte_personen_sektor_2 THEN 1 END) /
    COUNT(*)
) AS prozent_gemeinden_hohere_sektor_1
FROM (
    SELECT
        S.name AS gemeinde,
        SUM(CASE WHEN T.sektor = 'Primär' THEN T.beschaftigte_personen ELSE 0 END) AS beschaftigte_personen_sektor_1,
        SUM(CASE WHEN T.sektor = 'Sekundär' THEN T.beschaftigte_personen ELSE 0 END) AS beschaftigte_personen_sektor_2
    FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal = TRUE
        AND T.jahr = 2016
    GROUP BY S.name
) AS T;

-- Wie hoch ist der Anteil der Thurgauer Gemeinden, in denen die Zahl der Beschäftigten im primären Sektor zwischen 2013 und 2018 abgenommen hat?
SELECT (
    100.0 * COUNT(CASE WHEN T.beschaftigte_personen_sektor_1_2018 < T.beschaftigte_personen_sektor_1_2013 THEN 1 END) /
    COUNT(*)
) AS prozent_gemeinden_abnahme_sektor_1
FROM (
    SELECT
        S.name AS gemeinde,
        SUM(CASE WHEN T.jahr = 2013 THEN T.beschaftigte_personen ELSE 0 END) AS beschaftigte_personen_sektor_1_2013,
        SUM(CASE WHEN T.jahr = 2018 THEN T.beschaftigte_personen ELSE 0 END) AS beschaftigte_personen_sektor_1_2018
    FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal = TRUE
        AND T.jahr IN (2013, 2018)
        AND T.sektor = 'Primär'
    GROUP BY S.name
) AS T;

-- Welche Thurgauer Gemeinde hatte im Jahr 2020 die wenigsten Beschäftigten?
SELECT S.name AS gemeinde
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2020
GROUP BY S.name
ORDER BY SUM(T.beschaftigte_personen) ASC LIMIT 1;

-- Wie viele Beschäftigte aus dem ersten Sektor gab es in Arbon und Egnach, Thurgau, in den Jahren 2012 und 2019?
SELECT S.name AS gemeinde, T.jahr, SUM(T.beschaftigte_personen) AS beschaftigte_personen_sektor_1
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Arbon', 'Arbon (TG)', 'Egnach', 'Egnach (TG)')
    AND T.jahr IN (2012, 2019)
    AND T.sektor = 'Primär'
GROUP BY T.jahr, S.name
ORDER BY S.name, T.jahr;

-- Wie viele Beschäftigte hatte die Stadt Frauenfeld TG im tertiären Sektor bisher maximal und wann?
SELECT T.jahr, T.beschaftigte_personen AS beschaftigte_personen_sektor_3
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name IN ('Frauenfeld', 'Frauenfeld (TG)')
    AND T.sektor = 'Tertiär'
ORDER BY T.beschaftigte_personen DESC LIMIT 1;