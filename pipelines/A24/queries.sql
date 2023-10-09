-- Welche Gemeinde im Kanton Aargau hatte im Jahr 2020 am meisten Autos pro Einwohner?
SELECT S.name AS gemeinde
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2020
ORDER BY T.anzahl_personenwagen_pro_1000_einwohner DESC
LIMIT 1;

-- Wie viele landwirtschaftliche Fahrzeuge gab es im Kanton Aargau im Jahr 2010?
SELECT anzahl_landwirtschaftliche_motorfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name = 'Canton Aargau'
    AND T.jahr=2010;

-- Wie hoch war die Zahl der Nutzfahrzeuge 1960 und 1980 im Kanton Aargau?
SELECT T.jahr, anzahl_nutzfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name = 'Canton Aargau'
    AND T.jahr IN (1960, 1980);

-- Wie hat sich der Bestand an Motorrädern und Personenwagen im Kanton Aargau im Zeitraum zwischen 1930 und 1960 entwickelt?
SELECT T.jahr, anzahl_motorrader, anzahl_klein_motorrader, anzahl_motorfahrrader, anzahl_personenwagen
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name = 'Canton Aargau'
    AND T.jahr >= 1930
    AND T.jahr <= 1960;

-- Wie hoch ist der Anteil der Gemeinden im Kanton Aargau, in denen die Zahl der Autos pro Einwohner zwischen 2015 und 2022 zugenommen hat?
SELECT CAST(SUM(CASE WHEN T1.diff > 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(T1.diff) AS ratio_gemeinden_mit_zunahme_autos_pro_einwohner
FROM (
    SELECT
        SUM(CASE WHEN T.jahr = 2022 THEN T.anzahl_personenwagen_pro_1000_einwohner ELSE 0 END) -
        SUM(CASE WHEN T.jahr = 2015 THEN T.anzahl_personenwagen_pro_1000_einwohner ELSE 0 END) as diff
    FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
    JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
    WHERE S.municipal=TRUE
        AND T.jahr IN (2015, 2022)
    GROUP BY S.name
) as T1;

-- Wie hoch war die Zahl der Wohnwagen von 1998 bis 2001 in Aarburg, AG?
SELECT T.jahr, T.anzahl_anhaenger
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name IN ('Aarburg', 'Aargbug (AG)')
    AND T.jahr >= 1998
    AND T.jahr <= 2001;

-- Welches waren 2015 die Top-3-Gemeinden im Aargau mit dem höchsten Anteil an Motorrädern gegenüber Autos? Zeigen Sie auch die Proportionen.
SELECT
    S.name as gemeinde,
    CAST(T.anzahl_motorrader + T.anzahl_klein_motorrader + T.anzahl_motorfahrrader AS FLOAT) / T.anzahl_personenwagen AS ratio_motorrader_to_personenwagen
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND T.jahr=2015
ORDER BY ratio_motorrader_to_personenwagen DESC
LIMIT 3;

-- Wie hoch war die Zahl der Nutzfahrzeuge in Abtwil, AG im Jahr 2000 ?
SELECT T.anzahl_nutzfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name IN ('Abtwil', 'Abtwil (AG)')
    AND T.jahr=2000;

-- Wie hat sich die Zahl der Autos pro Einwohner im Aargau im Zeitraum 2010 bis 2022 entwickelt?
SELECT T.jahr, T.anzahl_personenwagen_pro_1000_einwohner
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND S.name = 'Canton Aargau'
    AND T.jahr >= 2010
    AND T.jahr <= 2022;

-- Welches waren die 5 Aargauer Gemeinden mit den wenigsten Motorrädern pro Personenwagen im Jahr 2015?
SELECT S.name AS gemeinde
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE T.jahr=2015
    AND S.municipal=TRUE
ORDER BY CAST(T.anzahl_motorrader + T.anzahl_klein_motorrader + T.anzahl_motorfahrrader AS FLOAT) / T.anzahl_personenwagen ASC
LIMIT 5;

-- Wie viele private Fahrzeuge gab es 2010 in Ueken im Kanton Aargau von jedem Typ?
SELECT
    T.anzahl_anhaenger,
    T.anzahl_arbeitsmotorfahrzeuge,
    T.anzahl_klein_motorrader,
    T.anzahl_kollektivfahrzeuge,
    T.anzahl_landwirtschaftliche_motorfahrzeuge,
    T.anzahl_motorfahrrader,
    T.anzahl_motorrader,
    T.anzahl_nutzfahrzeuge,
    T.anzahl_personenwagen,
    T.anzahl_ubrige_personen_transportfahrzeuge_kleinbusse_cars
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE T.jahr = 2010
    AND S.municipal = TRUE
    AND S.name IN ('Ueken', 'Ueken (AG)');

-- In welchem Jahr gab es in Zuzgen, AG, die meisten motorisierten Arbeitsfahrzeuge?
SELECT T.jahr
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Zuzgen', 'Zuzgen (AG)')
GROUP BY T.jahr
ORDER BY T.anzahl_arbeitsmotorfahrzeuge DESC
LIMIT 1;

-- Gab es 1930 oder 1940 im Kanton Aargau mehr Personenwagen?
SELECT T.jahr
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND T.jahr IN (1930, 1940)
GROUP BY T.jahr
ORDER BY T.anzahl_personenwagen DESC
LIMIT 1;

-- Zeigen Sie mir 3 Aargauer Gemeinden, in denen die Zahl der Personenwagen pro Einwohner zwischen 2018 und 2022 am stärksten abgenommen hat.
SELECT S.name AS gemeinde
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr IN (2018, 2022)
GROUP BY S.name
ORDER BY
    (
        SUM(CASE WHEN T.jahr = 2022 THEN T.anzahl_personenwagen_pro_1000_einwohner ELSE 0 END) -
        SUM(CASE WHEN T.jahr = 2018 THEN T.anzahl_personenwagen_pro_1000_einwohner ELSE 0 END)
    ) DESC
LIMIT 3;

-- Wie viele Aargauer Gemeinden haben im Jahr 2020 keine Personenwagen gezählt?
SELECT COUNT(*) AS anzahl_gemeinden_ohne_personenwagen
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten
WHERE jahr = 2020
    AND anzahl_personenwagen = 0;

-- Wie viele Kleinmotorräder gab es im Kanton Aargau zwischen 2000 und 2016?
SELECT T.jahr, T.anzahl_klein_motorrader
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton = TRUE
    AND T.jahr <= 2016
    AND T.jahr >= 2000;


-- Wo im Aargau hatten Zeihen und Zufikon im Jahr 2001 mehr Personenwagen pro Einwohner?
SELECT S.name AS gemeinde
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit as S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND T.jahr = 2001
    AND S.name IN ('Zeihen', 'Zeihen (AG)' , 'Zufikon', 'Zufikon (AG)')
ORDER BY T.anzahl_personenwagen_pro_1000_einwohner DESC
LIMIT 1;


-- Wie viele landwirtschaftliche Fahrzeuge gab es in Rekingen im Aargau zwischen 1998 und 2000?
SELECT T.jahr, T.anzahl_landwirtschaftliche_motorfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name IN ('Rekingen', 'Rekingen (AG)')
    AND T.jahr >= 1998
    AND T.jahr <= 2000
ORDER BY T.jahr ASC;


-- Wie viele Kollektivfahrzeuge gab es 2022 in Wettingen, AG?
SELECT T.anzahl_kollektivfahrzeuge
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Wettingen', 'Wettingen (AG)')
    AND T.jahr = 2022;

-- Wie viele Anhänger gab es im Jahr 2000 in Suhr, Aargau?
SELECT T.anzahl_anhaenger
FROM aargau_privatverkehr_bestand_nach_fahrzeugarten AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal = TRUE
    AND S.name IN ('Suhr', 'Suhr (AG)')
    AND T.jahr = 2000;
