-- Welches waren die fünf am meisten importierten Energietraeger 2020 in der Schweiz und wieviel wurde importiert?
SELECT nutzungs_sektor, energietraeger, SUM(energiemenge_in_tera_joule) as tj_import_2020
FROM energiebilanz_schweiz_in_tera_joule
WHERE jahr='2020'
AND LOWER(nutzungs_sektor) LIKE '%import%'
AND energiemenge_in_tera_joule IS NOT NULL
GROUP BY energietraeger, nutzungs_sektor
ORDER BY tj_import_2020 DESC;

-- Welches war der am meisten exportierten Energietraeger 2020 in der Schweiz und wieviel wurde exportiert?
SELECT nutzungs_sektor, energietraeger, SUM(energiemenge_in_tera_joule) as tj_export_2020
FROM energiebilanz_schweiz_in_tera_joule
WHERE jahr='2020'
AND LOWER(nutzungs_sektor) LIKE '%export%'
AND energiemenge_in_tera_joule IS NOT NULL
GROUP BY energietraeger, nutzungs_sektor
ORDER BY tj_export_2020 DESC;

-- Gibt es Energieträger der niemals importiert wurden?
SELECT energietraeger
FROM energiebilanz_schweiz_in_tera_joule
WHERE LOWER(nutzungs_sektor) LIKE '%import%'
GROUP BY energietraeger
HAVING SUM(energiemenge_in_tera_joule) IS NULL OR SUM(energiemenge_in_tera_joule) = 0;

-- Gibt es Energieträger der niemals exportiert wurden?
SELECT energietraeger
FROM energiebilanz_schweiz_in_tera_joule
WHERE LOWER(nutzungs_sektor) LIKE '%export%'
GROUP BY energietraeger
HAVING SUM(energiemenge_in_tera_joule) IS NULL OR SUM(energiemenge_in_tera_joule) = 0;

-- Welche nutzungssektoren hatten 2020 mit Erneuerbarer Energie zu tun und wenn ja in welchem Umfang?
SELECT nutzungs_sektor, SUM(energiemenge_in_tera_joule) as anteil_erneuerbare_energien_2020_tj
FROM energiebilanz_schweiz_in_tera_joule
WHERE jahr='2020'
AND LOWER(energietraeger) LIKE '%erneuerbar%'
AND energiemenge_in_tera_joule IS NOT NULL
AND energiemenge_in_tera_joule !=0
GROUP BY energietraeger, nutzungs_sektor
ORDER BY anteil_erneuerbare_energien_2020_tj DESC;

-- In 2020 auf welche Energieträger hat sich der Verbrauch von Haushalten gestützt? Gib die Energieträger und Energiemengen an.
SELECT energietraeger, SUM(energiemenge_in_tera_joule) as energieverbrauch_in_tj
FROM energiebilanz_schweiz_in_tera_joule
WHERE jahr='2020'
AND LOWER(nutzungs_sektor) LIKE '%verbrauch%haushalt%'
AND energiemenge_in_tera_joule IS NOT NULL
AND energiemenge_in_tera_joule !=0
GROUP BY energietraeger, nutzungs_sektor
ORDER BY energieverbrauch_in_tj DESC;

-- In 2020 welche Endverbrauchs Sektoren haben Kohle als Energieträger benutzt und in welchem Umfang? .
SELECT nutzungs_sektor, SUM(energiemenge_in_tera_joule) as energieverbrauch_in_kohle_tj
FROM energiebilanz_schweiz_in_tera_joule
WHERE jahr='2020'
AND LOWER(nutzungs_sektor) LIKE '%verbrauch%'
AND LOWER(energietraeger) LIKE '%kohle%'
AND energiemenge_in_tera_joule IS NOT NULL
AND energiemenge_in_tera_joule !=0
GROUP BY nutzungs_sektor
ORDER BY energieverbrauch_in_kohle_tj DESC;

-- Welche Energieträger kamen 2019 bei Energieumwandlung vor und in welchem Umfang? .
SELECT nutzungs_sektor, SUM(energiemenge_in_tera_joule) as energie_umwandlung_2019_tj
FROM energiebilanz_schweiz_in_tera_joule
WHERE LOWER(nutzungs_sektor) LIKE '%umwandlung%'
AND energiemenge_in_tera_joule IS NOT NULL
AND energiemenge_in_tera_joule !=0
AND jahr = 2019
GROUP BY nutzungs_sektor
ORDER BY energie_umwandlung_2019_tj ASC;

-- Bei der Umwandlung durch Kernkraftwerke, welche Energieträger sind da mit welchen Mengen durchschnittlich im Spiel?
SELECT
    energietraeger,
    AVG(energiemenge_in_tera_joule) as durchschnittliche_umwandlung_kernkraft_in_tj
FROM energiebilanz_schweiz_in_tera_joule
WHERE LOWER(nutzungs_sektor) LIKE '%umwandlung%'
AND LOWER(nutzungs_sektor) LIKE '%kernkraftwerk%'
AND energiemenge_in_tera_joule IS NOT NULL
AND energiemenge_in_tera_joule != 0
GROUP BY energietraeger
ORDER BY durchschnittliche_umwandlung_kernkraft_in_tj ASC;

-- Hat sich der Import Mix über die Jahre veändert? Welche Energieträger wurde jeweils am meisten importiert? Zeige auch die Importmenge.
WITH RankedImports AS (
    SELECT
        energietraeger,
        jahr,
        energiemenge_in_tera_joule,
        RANK() OVER (PARTITION BY jahr ORDER BY energiemenge_in_tera_joule DESC) AS rank
    FROM energiebilanz_schweiz_in_tera_joule
    WHERE LOWER(nutzungs_sektor) LIKE '%import%'
      AND energiemenge_in_tera_joule IS NOT NULL
      AND energiemenge_in_tera_joule != 0
)
SELECT
    energietraeger,
    jahr,
    energiemenge_in_tera_joule as max_import
FROM RankedImports
WHERE rank = 1
ORDER BY jahr DESC;
