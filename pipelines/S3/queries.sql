-- Welche Teilung hatte im Jahr 2020 die höchsten Staatsausgaben?
SELECT aufgabenbereich_cofog_teilung as ausgaben_bereich_mit_den_hoechsten_ausgaben_2020
FROM staatsausgaben_nach_aufgabenbereichen_cofog
WHERE institutioneller_sektor="Staat" AND jahr=2020
GROUP BY aufgabenbereich_cofog_teilung
ORDER BY SUM(ausgaben_in_mio_chf) DESC LIMIT 1;

-- Welches waren die 3 grössten Ausgabenquellen des Bundes im Jahr 2021 und wie hoch waren diese?
SELECT SUM(ausgaben_in_mio_chf),aufgabenbereich_cofog_gruppen as ausgaben_bereich_mit_den_hoechsten_ausgaben_2020
FROM staatsausgaben_nach_aufgabenbereichen_cofog
WHERE institutioneller_sektor="Bund" AND jahr=2020
GROUP BY aufgabenbereich_cofog_gruppen
ORDER BY SUM(ausgaben_in_mio_chf) DESC LIMIT 3;

-- Wie viel Prozent des Staat Budgets gab im Jahr 2021 fur Bildung aus?
SELECT SUM(prozent_der_gesamtausgaben) as prozent_der_gesamtausgaben_fur_bildung
FROM staatsausgaben_nach_aufgabenbereichen_cofog
WHERE institutioneller_sektor="Staat"
    AND jahr=2021
    AND aufgabenbereich_cofog_teilung = "Bildungswesen";

-- Wie hoch waren die religionsbezogenen Ausgaben der Kantone im Jahr ihres Höchststandes?
SELECT t1.jahr, t1.aufgabenbereich_cofog_gruppen, t1.ausgaben_in_mio_chf
FROM staatsausgaben_nach_aufgabenbereichen_cofog t1
INNER JOIN (
    SELECT jahr, SUM(ausgaben_in_mio_chf) AS tot_spending
    FROM staatsausgaben_nach_aufgabenbereichen_cofog
    WHERE LOWER(aufgabenbereich_cofog_gruppen) LIKE '%religion%' AND institutioneller_sektor = 'Kantone'
    GROUP BY jahr
    ORDER BY tot_spending DESC LIMIT 1
) t2 ON t1.jahr = t2.jahr
WHERE t1.aufgabenbereich_cofog_gruppen LIKE '%religion%' AND t1.institutioneller_sektor = 'Kantone';

-- Wie viel hat jeder institutionelle Sektor im Jahr 2018 für den Umweltschutz ausgegeben?
SELECT SUM(ausgaben_in_mio_chf), institutioneller_sektor
FROM staatsausgaben_nach_aufgabenbereichen_cofog
WHERE jahr=2018 AND aufgabenbereich_cofog_teilung = "Umweltschutz"
GROUP BY institutioneller_sektor
ORDER BY SUM(ausgaben_in_mio_chf) ASC;

-- Welcher Anteil des Schweizer Budgets wird jedes Jahr in Sicherheit investiert?
SELECT jahr, SUM(prozent_der_gesamtausgaben)
FROM staatsausgaben_nach_aufgabenbereichen_cofog
WHERE LOWER(aufgabenbereich_cofog_gruppen) LIKE "%sicherheit%"
    AND institutioneller_sektor = "Staat"
GROUP BY jahr
ORDER BY jahr ASC;

-- Wie hoch waren die Mittel für die Polizei im Vergleich zu denen für die Feuerwehr im Jahr 2020?
SELECT ausgaben_in_mio_chf, aufgabenbereich_cofog_gruppen
FROM staatsausgaben_nach_aufgabenbereichen_cofog
WHERE (
    LOWER(aufgabenbereich_cofog_gruppen) LIKE "%polizei%"
    OR LOWER(aufgabenbereich_cofog_gruppen) LIKE "%feuerwehr%"
)
    AND jahr = 2020
    AND institutioneller_sektor = "Staat";

-- Wie hoch war der Anteil des Gemeinde Budgets, der seit 2011 für Kommunikation bereitgestellt wurde?
SELECT jahr, SUM(prozent_der_gesamtausgaben) as prozent_der_gesamtausgaben_fur_kommunikation_in_landgemeinden
FROM staatsausgaben_nach_aufgabenbereichen_cofog
WHERE LOWER(aufgabenbereich_cofog_gruppen) LIKE "%kommunikation%"
    AND institutioneller_sektor = "Gemeinden"
    AND jahr >= 2011
GROUP BY jahr
ORDER BY jahr ASC;

-- Wie hoch ist der Anteil des Schweizer Budgets, der 2010 und 2020 für die Gesundheit ausgegeben wird?
SELECT jahr, SUM(prozent_der_gesamtausgaben)
FROM staatsausgaben_nach_aufgabenbereichen_cofog
WHERE aufgabenbereich_cofog_teilung = "Gesundheitswesen"
    AND institutioneller_sektor = "Staat"
    AND jahr <= 2020
    AND jahr >= 2010
GROUP BY jahr
ORDER BY jahr ASC;

-- Wie verteilen sich die kantonalen Bildungsausgaben im Jahr 2010?
SELECT aufgabenbereich_cofog_gruppen, ausgaben_in_mio_chf as kantonale_ausgaben_in_mio_chf_jahr_2010
FROM staatsausgaben_nach_aufgabenbereichen_cofog
WHERE aufgabenbereich_cofog_teilung = "Bildungswesen"
    AND jahr = 2020
    AND institutioneller_sektor = "Kantone"
ORDER BY ausgaben_in_mio_chf DESC;
