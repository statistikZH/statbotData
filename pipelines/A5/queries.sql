-- Was war die haeufigste Rentenart 2022 in der Schweiz?
SELECT rententyp as haufigste_rentenart_2022_schweiz
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND jahr='2022'
ORDER BY anzahl_renten DESC LIMIT 1;

-- Was waren die Gesamtausgaben für Renten 2022 in Franken, wie verteilten sie sich auf die Rentenarten, auf wieviele Renten jeweils und was kam dabei als durchschnittliche Rente heraus? Ordne das Ergebnis nach Anzahl der Renten.
SELECT rententyp,
  anzahl_renten AS renten_anzahl_2022,
  1000 * rentensumme_in_tausend_franken AS rentengesamt_ausgaben_in_CHF,
  renten_mittelwert_in_franken AS durchschnittliche_rente_in_CHF
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit
WHERE jahr = 2022
  AND staatsangehorigkeit_kategorie = 'Staatsangehörigkeit - Total'
  AND geschlecht = 'Geschlecht - Total'
  AND wohnsitzstaat_kategorie = 'Wohnsitzstaat - Total'
ORDER BY anzahl_renten DESC;

-- Wie entwickelten sich die Differenz der durchschnittliche Altersrente und der Anzahl der Renten für Frauen und Männern über die Jahre?
SELECT T1.jahr,
  (T1.renten_mittelwert_in_franken - T2.renten_mittelwert_in_franken) AS differenz_durchschnittliche_altersrente_frauen_maenner,
  (T1.anzahl_renten - T2.anzahl_renten) AS differenz_anzahl_altersrenten_frauen_maenner
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit AS T1
JOIN ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit AS T2 ON T1.jahr = T2.jahr
WHERE T1.geschlecht = 'Frau'
  AND T2.geschlecht = 'Mann'
  AND T1.rententyp = 'Altersrente' AND T2.rententyp = 'Altersrente'
  AND T1.staatsangehorigkeit_kategorie = 'Staatsangehörigkeit - Total'
  AND T2.staatsangehorigkeit_kategorie = 'Staatsangehörigkeit - Total'
  AND T1.wohnsitzstaat_kategorie = 'Wohnsitzstaat - Total'
  AND T2.wohnsitzstaat_kategorie = 'Wohnsitzstaat - Total';

-- Gab es Rentenarten bei der der Anteil der an im Ausland lebenden ausländischer Staatsangehöriger im Jahr 2022 höher war als der der Anteil der im Inland lebenden Schweizer Staatsangeörigen: was waren die Zahlen?
SELECT T1.rententyp,
  SUM(T1.anzahl_renten) AS anzahl_renten_auslaender_im_ausland_2022,
  SUM(T2.anzahl_renten) AS anzahl_renten_schweizer_im_inland_2022
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit AS T1
JOIN ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit AS T2 ON T1.rententyp = T2.rententyp
WHERE T1.jahr = 2022 and T2.jahr = 2022
  AND T1.staatsangehorigkeit_kategorie = 'Ausland' AND T1.wohnsitzstaat_kategorie = 'Ausland'
  AND T2.staatsangehorigkeit_kategorie = 'Schweiz' AND T2.wohnsitzstaat_kategorie = 'Schweiz'
  AND T2.geschlecht = 'Geschlecht - Total' AND T1.geschlecht = 'Geschlecht - Total'
  AND T1.anzahl_renten > T2.anzahl_renten
GROUP BY T1.rententyp;

-- Wieviel Prozent der Rentenausgaben floss 2015 an Schweizer, die im Ausland leben und wieviel waren ?
SELECT
  ROUND((SUM(CASE WHEN jahr = 2015
       AND staatsangehorigkeit_kategorie = 'Schweiz' AND wohnsitzstaat_kategorie = 'Ausland'
       THEN rentensumme_in_tausend_franken ELSE 0 END) /
   SUM(CASE WHEN jahr = 2015 AND staatsangehorigkeit_kategorie = 'Staatsangehörigkeit - Total'
       AND wohnsitzstaat_kategorie = 'Wohnsitzstaat - Total'
       THEN rentensumme_in_tausend_franken ELSE 0 END)) * 100, 2) AS prozent_rentenausgaben_fur_schweizer_im_ausland
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit
WHERE jahr = 2015
  AND geschlecht = 'Geschlecht - Total';

-- Wie hoch war der Frauenanteil bei den Zusatzrenten für Ehepartner?
SELECT
  ROUND(100 * SUM(CASE WHEN geschlecht = 'Frau'
       THEN anzahl_renten ELSE 0 END) /
   SUM(CASE WHEN geschlecht = 'Geschlecht - Total'
       THEN anzahl_renten ELSE 0 END)
  , 2) AS prozent_frauenanteil_bei_ehepartner_zusatzrenten
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit
WHERE rententyp = 'Zusatzrente für Ehepartner'
  AND staatsangehorigkeit_kategorie = 'Staatsangehörigkeit - Total' AND wohnsitzstaat_kategorie = 'Wohnsitzstaat - Total';

-- In welchen drei Jahren gab es die höchsten Ausgaben für die Zusatzrenten für Waise und wie hoch waren diese in CHF?
SELECT 1000 * SUM(rentensumme_in_tausend_franken) as rentenausgaben_fur_waisenrente_CHF, jahr
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit
WHERE rententyp LIKE '%Waise%'
  AND staatsangehorigkeit_kategorie = 'Staatsangehörigkeit - Total'
  AND wohnsitzstaat_kategorie = 'Wohnsitzstaat - Total'
  AND geschlecht = 'Geschlecht - Total'
GROUP BY jahr
ORDER BY rentenausgaben_fur_waisenrente_CHF DESC
LIMIT 3;

-- Für welche Rentenarten ist die durchschnittlich Rente zwischen 2001 und 2022 heruntergegangen und wenn ja um wieviele CHF?
SELECT T1.rententyp,
  (AVG(T2.renten_mittelwert_in_franken) - AVG(T1.renten_mittelwert_in_franken)) as rentenabzug_2022_genueber_2001_CHF
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit AS T1
JOIN ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit AS T2 ON T1.rententyp = T2.rententyp
WHERE T1.jahr = 2001 AND T2.jahr = 2022
  AND T1.staatsangehorigkeit_kategorie = 'Staatsangehörigkeit - Total' AND T1.wohnsitzstaat_kategorie = 'Wohnsitzstaat - Total'
  AND T2.staatsangehorigkeit_kategorie = 'Staatsangehörigkeit - Total' AND T2.wohnsitzstaat_kategorie = 'Wohnsitzstaat - Total'
  AND T2.geschlecht = 'Geschlecht - Total' AND T1.geschlecht = 'Geschlecht - Total'
  AND T2.renten_mittelwert_in_franken > T1.renten_mittelwert_in_franken
GROUP BY T1.rententyp;

-- Welche Rentenarten gibt es in der Schweiz und was sind die durchschnittliche Ausgaben dafür pro Jahr?
SELECT rententyp,
  (AVG(rentensumme_in_tausend_franken) * 1000) as durchschnittliche_ausgaben_pro_jahr_chf
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit
WHERE staatsangehorigkeit_kategorie = 'Staatsangehörigkeit - Total'
  AND wohnsitzstaat_kategorie = 'Wohnsitzstaat - Total'
  AND geschlecht = 'Geschlecht - Total'
GROUP BY rententyp
ORDER BY durchschnittliche_ausgaben_pro_jahr_chf DESC;

-- Welcher Rententyp wird von Ausländern, die im Ausland leben, am häufigsten bezogen und wieviele Renten sind es?
SELECT rententyp as haufigster_rententy_fur_auslaender_im_ausland,
  MAX(anzahl_renten) as anzahl_renten_auslaender_im_ausland
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit
WHERE staatsangehorigkeit_kategorie = 'Ausland'
  AND wohnsitzstaat_kategorie = 'Ausland'
  AND geschlecht = 'Geschlecht - Total'
GROUP BY rententyp
ORDER BY anzahl_renten_auslaender_im_ausland DESC LIMIT 1;

