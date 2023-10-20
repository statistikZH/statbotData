-- What were the names of the 3 most populous municipalities in canton Schwyz in 2015?
SELECT S.name
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2015
GROUP BY S.name
ORDER BY SUM(T.anzahl_personen) DESC
LIMIT 3;

-- How many inhabitants were there in Freienbach (SZ) during the period 2010 - 2020 ?
SELECT T.jahr, SUM(T.anzahl_personen)
FROM schwyz_standige_wohnbevolkerung_geschlecht_nationalitat AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Freienbach', 'Freienbach (SZ)')
    AND T.jahr >= 2010
    AND T.jahr <= 2020
GROUP BY T.jahr
ORDER BY T.jahr ASC;

-- Which 5 municipalities in Canton Schwyz had the highest male/female ratio in 2010? Also report the ratio.
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

-- What is the percentage of municipalities in Schwyz that had more than 10000 inhabitants in 2020?
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

-- What were the 10 municipalities in Schwyz with the lowest population growth between 2005 and 2022, and what was their percentage growth ?
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

-- Show me the number of foreign and Swiss residents for the 5 most populous municipalities in Schwyz in 2015.
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

-- What was the proportion of men among swiss and foreign residents in canton Schwyz each year between 2015 and 2020?
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

-- What was the year-on-year growth rate of the population in canton Schwyz each year during the preiod 2005-2010?
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

-- Show me the number of men and women in canton Schwyz in 2005, 2010, 2015 and 2020.
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

-- What was the swiss and foreign population in the 3 smallest Schwyz municipalities in 2020?
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

-- Show me the proportion of foreigners (foreigners/total) in canton Schwyz in each year between 2010 and 2020.
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

-- For each year in the period 2018 - 2021, show me the number of swiss residents in Einsiedeln, SZ.
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
