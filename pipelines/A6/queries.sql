-- Wie viele Abstimmungen gab es im Jahr 2000 in der Schweiz?
SELECT SUM(anzahl_vorlagen) AS gesamt_anzahl_abstimmungen FROM abstimmungsvorlagen_seit_1971 WHERE jahr = '2000' AND land = 'Schweiz';
-- Welches Thema hatte die höchste Anzahl an Abstimmungsvorlagen?
SELECT abstimmungsvorlage_thema FROM abstimmungsvorlagen_seit_1971 ORDER BY anzahl_vorlagen DESC LIMIT 1;
-- Wie viele Abstimmungen wurden insgesamt in der Schweiz durchgeführt?
SELECT SUM(anzahl_vorlagen) AS gesamt_anzahl_abstimmungen FROM abstimmungsvorlagen_seit_1971 WHERE land = 'Schweiz';
-- In welchem Jahr fand die erste Abstimmung zum Thema "Umwelt und Lebensraum" statt?
SELECT MIN(jahr) AS erstes_jahr FROM abstimmungsvorlagen_seit_1971 WHERE abstimmungsvorlage_thema = 'Umwelt und Lebensraum';
-- Wie viele Abstimmungen gab es zum Thema "Staatsordnung" in den 1980er Jahren?
SELECT SUM(anzahl_vorlagen) AS anzahl_abstimmungen_80er FROM abstimmungsvorlagen_seit_1971 WHERE abstimmungsvorlage_thema = 'Staatsordnung' AND jahr BETWEEN 1980 AND 1989;
-- Welches Thema hatte in einem einzigen Jahr die höchste Anzahl an Abstimmungsvorlagen?
SELECT abstimmungsvorlage_thema FROM abstimmungsvorlagen_seit_1971 WHERE anzahl_vorlagen = (SELECT MAX(anzahl_vorlagen) FROM abstimmungsvorlagen_seit_1971);
-- Wie viele Abstimmungen zum Thema "Sozialpolitik" wurden insgesamt durchgeführt?
SELECT SUM(anzahl_vorlagen) AS gesamt_anzahl_sozialpolitik FROM abstimmungsvorlagen_seit_1971 WHERE abstimmungsvorlage_thema = 'Sozialpolitik';
-- In welchem Jahr gab es die meisten Abstimmungen in der Schweiz?
SELECT jahr FROM abstimmungsvorlagen_seit_1971 GROUP BY jahr ORDER BY SUM(anzahl_vorlagen) DESC LIMIT 1;
-- Wie viele verschiedene Themen wurden insgesamt zur Abstimmung gebracht?
SELECT COUNT(DISTINCT abstimmungsvorlage_thema) AS anzahl_themen FROM abstimmungsvorlagen_seit_1971;
-- Wie viele Abstimmungen wurden im Durchschnitt pro Jahr durchgeführt?
SELECT AVG(anzahl_vorlagen) AS durchschnitt_abstimmungen_pro_jahr FROM abstimmungsvorlagen_seit_1971;
-- Wie viele Abstimmungen gab es zum Thema "Energie" in den 1990er Jahren?
SELECT SUM(anzahl_vorlagen) AS anzahl_abstimmungen_90er FROM abstimmungsvorlagen_seit_1971 WHERE abstimmungsvorlage_thema = 'Energie' AND jahr BETWEEN 1990 AND 1999;
-- Welches Jahr hatte die geringste Anzahl an Abstimmungen in der Schweiz?
SELECT jahr FROM abstimmungsvorlagen_seit_1971 GROUP BY jahr ORDER BY SUM(anzahl_vorlagen) ASC LIMIT 1;
-- Wie viele Abstimmungen gab es insgesamt in der Schweiz für jedes Thema?
SELECT abstimmungsvorlage_thema, SUM(anzahl_vorlagen) AS gesamt_anzahl_vorlagen FROM abstimmungsvorlagen_seit_1971 WHERE land = 'Schweiz' GROUP BY abstimmungsvorlage_thema;
-- In welchem Jahr gab es die meisten Abstimmungen zum Thema "Bildung und Forschung"?
SELECT jahr FROM abstimmungsvorlagen_seit_1971 WHERE abstimmungsvorlage_thema = 'Bildung und Forschung' ORDER BY anzahl_vorlagen DESC LIMIT 1;
-- Wie viele Abstimmungen wurden in den Jahren 2010 bis 2020 durchgeführt?
SELECT SUM(anzahl_vorlagen) AS anzahl_abstimmungen_2010_bis_2020 FROM abstimmungsvorlagen_seit_1971 WHERE jahr BETWEEN 2010 AND 2020;
-- Welches Thema wurde insgesamt am häufigsten zur Abstimmung gebracht?
SELECT abstimmungsvorlage_thema FROM abstimmungsvorlagen_seit_1971 GROUP BY abstimmungsvorlage_thema ORDER BY SUM(anzahl_vorlagen) DESC LIMIT 1;
-- Wie viele Abstimmungen wurden in jedem Jahr in der Schweiz durchgeführt?
SELECT jahr, SUM(anzahl_vorlagen) AS gesamt_anzahl_vorlagen FROM abstimmungsvorlagen_seit_1971 WHERE land = 'Schweiz' GROUP BY jahr;
-- In welchem Jahr gab es die meisten Abstimmungen zum Thema "Öffentliche Finanzen"?
SELECT jahr FROM abstimmungsvorlagen_seit_1971 WHERE abstimmungsvorlage_thema = 'Öffentliche Finanzen' ORDER BY anzahl_vorlagen DESC LIMIT 1;
-- Wie viele Abstimmungen wurden pro Jahr in der Schweiz zum Thema "Wirtschaft" durchgeführt?
SELECT jahr, SUM(anzahl_vorlagen) AS anzahl_wirtschaft_abstimmungen FROM abstimmungsvorlagen_seit_1971 WHERE abstimmungsvorlage_thema = 'Wirtschaft' AND land = 'Schweiz' GROUP BY jahr;
-- Wie viele Abstimmungen gab es insgesamt in der Schweiz?
SELECT SUM(anzahl_vorlagen) AS gesamt_anzahl_abstimmungen_schweiz FROM abstimmungsvorlagen_seit_1971;
