-- Wieviele Abstimmungsvorlagen gab es im Jahr 2000?
SELECT COUNT(*) as anzahl_abstimmungsvorlagen_im_jahr_2000
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE AND T.jahr=2000;

-- Wieviele Abstimmungsvorlagen gab es seit dem Jahr 1971?
SELECT COUNT(*) as anzahl_abstimmungsvorlagen
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE;

-- Wieviele Volksabstimmungen wurden 1995 in der Schweiz durchgeführt?
SELECT SUM(T.anzahl_abstimmungsvorlagen) AS gesamt_anzahl_abstimmungen, T.jahr
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND jahr = '1995';

-- Welches Jahr hatte die meisten Volksabstimmungen in der Schweiz?
SELECT jahr, SUM(anzahl_abstimmungsvorlagen)
FROM abstimmungsvorlagen_seit_1971
GROUP BY anzahl_abstimmungsvorlagen
ORDER BY jahr LIMIT 1;

-- Was war die 5 dominantesten Themen bei den Volksabstimmungen über die Jahre in der Schweiz?
SELECT thema, SUM(anzahl_abstimmungsvorlagen) as vorlagen_pro_thema
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
GROUP BY thema
ORDER BY vorlagen_pro_thema DESC
LIMIT 5;

-- In welchem Jahr gab es die meisten Volksabstimmungen zum Thema Religion in der Schweiz?
SELECT T.thema, T.jahr, T.anzahl_abstimmungsvorlagen
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.thema LIKE '%Religion%' AND anzahl_abstimmungsvorlagen != 0
ORDER BY anzahl_abstimmungsvorlagen DESC
LIMIT 1;

-- Welches 3 Themen hatten die wenigsten Volksabstimmungen in der Schweiz?
SELECT T.thema, SUM(T.anzahl_abstimmungsvorlagen) as abstimmungsvorlagen_pro_thema
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
GROUP BY T.thema
ORDER BY abstimmungsvorlagen_pro_thema ASC LIMIT 3;

-- In welchem Jahr gab es die grösste Diversität von Themen bei Volksabstimmungen?
SELECT COUNT(DISTINCT(thema)) as anzahl_themen_pro_jahr, jahr
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE anzahl_abstimmungsvorlagen <> 0
GROUP BY T.jahr
ORDER BY anzahl_themen_pro_jahr DESC LIMIT 1;

-- Was war die Anzahl von Volksabstimmungen der Schweiz pro Jahr in den letzten 10 Jahren?
SELECT SUM(T.anzahl_abstimmungsvorlagen) as durchschnittliche_anzahl_abstimmmungen, T.jahr
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
GROUP BY T.jahr
ORDER BY T.jahr DESC LIMIT 10;

-- In welchem Jahren gab es die Volksabstimmungen zum Thema Energie in der Schweiz?
SELECT T.jahr
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.thema LIKE '%Energie%' AND anzahl_abstimmungsvorlagen != 0
ORDER BY jahr DESC;

-- Welches waren die Themen der Volksabstimmungen in 2022?
SELECT DISTINCT(T.thema)
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.jahr = '2022' AND anzahl_abstimmungsvorlagen != 0;

-- In welchem Jahren war die Wirtschaft ein Thema in Volksabstimmungen?
SELECT T.jahr
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND T.thema LIKE '%Wirtschaft%' AND anzahl_abstimmungsvorlagen != 0
ORDER BY jahr DESC;

-- Welches Thema hatte die meisten Volksabstimmungen in den Jahren 1990 bis 2000?
SELECT thema, SUM(anzahl_abstimmungsvorlagen) as vorlagen_pro_thema
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND jahr BETWEEN 1990 AND 2000
GROUP BY thema
ORDER BY vorlagen_pro_thema DESC
LIMIT 1;

-- Welches Thema hatte die wenigsten Volksabstimmungen in den Jahren 1990 bis 2000?
SELECT thema, SUM(anzahl_abstimmungsvorlagen) as vorlagen_pro_thema
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE AND anzahl_abstimmungsvorlagen != 0
AND jahr BETWEEN 1990 AND 2000
GROUP BY thema
ORDER BY vorlagen_pro_thema ASC
LIMIT 1;

-- Wann gab es die erste Volksabstimmungen ueber Sozialpolitik?
SELECT MIN(jahr) as erstes_jahr
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND anzahl_abstimmungsvorlagen != 0 AND T.thema LIKE '%Sozialpolitik%';

-- Wann gab es die letzte Volksabstimmungen zum Thema Forschung?
SELECT MAX(jahr) as jahr_letzte_abstimmung
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND anzahl_abstimmungsvorlagen != 0 AND T.thema LIKE '%Forschung%';

-- Wieviele Abstimmung gab es insgesamt zu Bildungsthemen?
SELECT SUM(anzahl_abstimmungsvorlagen) as anzahl_abstimmungen_bildung
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND anzahl_abstimmungsvorlagen != 0 AND T.thema LIKE '%Bildung%';

-- Wieviele Volksabstimmungen gab es vor dem Jahr 2000 zum Thema Energie?
SELECT SUM(anzahl_abstimmungsvorlagen) as anzahl_abstimmungen_energie
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND anzahl_abstimmungsvorlagen != 0 AND T.thema LIKE '%Energie%'
AND jahr < 2000;

-- In wievielen Jahren gab es Volksabstimmungen zum Thema Aussenpolitik?
SELECT COUNT(jahr) as anzahl_jahre_aussenpolitik
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND anzahl_abstimmungsvorlagen != 0 AND T.thema LIKE '%Aussenpolitik%';

-- In welchen Jahren war Sicherheit ein Thema bei Volksabstimmungen?
SELECT jahr
FROM abstimmungsvorlagen_seit_1971 as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND anzahl_abstimmungsvorlagen != 0 AND T.thema LIKE '%Sicherheit%'
ORDER BY jahr DESC;

