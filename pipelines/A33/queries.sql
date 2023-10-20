-- Wie hiessen die 3 bevölkerungsreichsten Gemeinden im Kanton Schwyz im Jahr 2015?
SELECT S.name
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2015
GROUP BY S.name
ORDER BY SUM(T.anzahl_personen) DESC
LIMIT 3;

-- Wie viele Einwohner gab es in Freienbach (SZ) im Zeitraum 2010 - 2020 ?
SELECT T.jahr, SUM(T.anzahl_personen)
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Freienbach', 'Freienbach (SZ)')
    AND T.jahr >= 2010
    AND T.jahr <= 2020
GROUP BY T.jahr
ORDER BY T.jahr ASC;

-- Welche 5 Gemeinden im Kanton Schwyz hatten 2010 das höchste Verhältnis zwischen Männern und Frauen? Geben Sie auch das Verhältnis an.
SELECT
    S.name,
    (
        SUM(CASE WHEN T.geschlecht = 'männlich' THEN T.anzahl_personen ELSE 0 END) /
        SUM(CASE WHEN T.geschlecht = 'weiblich' THEN T.anzahl_personen ELSE 0 END)
    ) AS weiblich_mannlich_verhaltnis_2010
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2010
GROUP BY S.name
ORDER BY weiblich_mannlich_verhaltnis_2010 DESC
LIMIT 5;

-- Wie hoch ist der Prozentsatz der Gemeinden in Schwyz, die im Jahr 2020 mehr als 10000 Einwohner haben?
SELECT
    (
        100.0 *
        COUNT(CASE WHEN T1.tot_personen > 10000 THEN 1 END) /
        COUNT(*)
    )AS prozent_gemeinden_mehr_als_10000_einwohner_2020
FROM (
    SELECT SUM(T.anzahl_personen) as tot_personen
    FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal = TRUE
        AND T.jahr = 2020
    GROUP BY S.name
) as T1;

-- Welches waren die 10 Schwyzer Gemeinden mit dem geringsten Bevölkerungswachstum zwischen 2005 und 2022, und wie hoch war ihr prozentuales Wachstum?
SELECT
    S.name,
    (
        100.0 *
        SUM(CASE WHEN T.jahr = 2022 THEN T.anzahl_personen ELSE -T.anzahl_personen END) /
        SUM(CASE WHEN T.jahr = 2005 THEN T.anzahl_personen ELSE 0 END)
    ) AS prozent_wachstum
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr IN (2005, 2022)
GROUP BY S.name
ORDER BY prozent_wachstum ASC
LIMIT 10;

-- Zeigen Sie mir die Anzahl ausländischer und schweizerischer Einwohner für die 5 bevölkerungsreichsten Gemeinden in Schwyz im Jahr 2015.
SELECT
    S.name,
    SUM(CASE WHEN T.nationalitaet = 'Schweiz' THEN T.anzahl_personen ELSE 0 END) AS schweizer,
    SUM(CASE WHEN T.nationalitaet = 'Ausland' THEN T.anzahl_personen ELSE 0 END) AS auslander
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2015
GROUP BY S.name
ORDER BY SUM(T.anzahl_personen) DESC
LIMIT 5;

-- Wie hoch war der Anteil der Männer an der schweizerischen und ausländischen Wohnbevölkerung im Kanton Schwyz in den Jahren 2015 bis 2020?
SELECT
    T.jahr,
    (
        SUM(CASE WHEN T.geschlecht = 'männlich' AND T.nationalitaet = 'Schweiz' THEN T.anzahl_personen END) /
        SUM(CASE WHEN T.nationalitaet = 'Schweiz' THEN T.anzahl_personen END)
    ) AS anteil_manner_schweizer,
    (
        SUM(CASE WHEN T.geschlecht = 'männlich' AND T.nationalitaet = 'Ausland' THEN T.anzahl_personen END) /
        SUM(CASE WHEN T.nationalitaet = 'Ausland' THEN T.anzahl_personen END)
    ) AS anteil_manner_auslander
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr >= 2015
    AND T.jahr >= 2020
GROUP BY T.jahr
ORDER BY T.jahr ASC;

-- Wie hoch war die jährliche Wachstumsrate der Bevölkerung im Kanton Schwyz in den Jahren 2005-2010?
WITH T1 AS (
    SELECT
        T.jahr,
        SUM(T.anzahl_personen) AS tot_personen
    FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal = TRUE
        AND T.jahr >= 2005
        AND T.jahr <= 2010
    GROUP BY T.jahr
    ORDER BY T.jahr ASC
)
SELECT
    T1.jahr,
    (
        100.0 *
        (T1.tot_personen - LAG(T1.tot_personen) OVER (ORDER BY T1.jahr ASC)) /
        LAG(T1.tot_personen) OVER (ORDER BY T1.jahr ASC)
    ) AS tot_personen_vorjahr
FROM T1;

-- Zeigen Sie mir die Anzahl der Männer und Frauen im Kanton Schwyz in den Jahren 2005, 2010, 2015 und 2020.
SELECT
    T.jahr,
    SUM(CASE WHEN T.geschlecht = 'männlich' THEN T.anzahl_personen END) AS anzahl_manner,
    SUM(CASE WHEN T.geschlecht = 'weiblich' THEN T.anzahl_personen END) AS anzahl_frauen
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr IN (2005, 2010, 2015, 2020)
GROUP BY T.jahr
ORDER BY T.jahr ASC;

-- Wie hoch war die schweizerische und ausländische Bevölkerung in den 3 kleinsten Schwyzer Gemeinden im Jahr 2020?
SELECT
    S.name,
    SUM(CASE WHEN T.nationalitaet = 'Schweiz' THEN T.anzahl_personen ELSE 0 END) AS anzahl_schweizer,
    SUM(CASE WHEN T.nationalitaet = 'Ausland' THEN T.anzahl_personen ELSE 0 END) AS anzahl_auslander
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2020
GROUP BY S.name
ORDER BY SUM(T.anzahl_personen) ASC
LIMIT 3;

-- Zeigen Sie mir den Anteil der ausländischen Bevölkerung (als Verhältnis) im Kanton Schwyz in jedem Jahr zwischen 2010 und 2020.
SELECT
    T.jahr,
    (
        SUM(CASE WHEN T.nationalitaet = 'Ausland' THEN T.anzahl_personen ELSE 0 END) /
        SUM(T.anzahl_personen)
    ) AS anteil_auslander
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr >= 2010
    AND T.jahr <= 2020
GROUP BY T.jahr
ORDER BY T.jahr ASC;

-- Zeigen Sie mir für jedes Jahr im Zeitraum 2018 - 2021 die Anzahl der Schweizer Einwohner in Einsiedeln, SZ.
SELECT T.jahr, SUM(T.anzahl_personen) AS anzahl_schweizer_2021_einsiedeln
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr >= 2018
    AND T.jahr <= 2021
    AND S.name IN ('Einsiedeln', 'Einsiedeln (SZ)')
    AND T.nationalitaet = 'Schweiz'
GROUP BY T.jahr
ORDER BY T.jahr ASC;
