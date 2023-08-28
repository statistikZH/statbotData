-- Was war die haeufigste Rentenart 2022 in der Schweiz?
SELECT rententyp as haufigste_rentenart_2022_schweiz
FROM ahv_renten_nach_wohnsitz_und_staatsangehoerigkeit AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND jahr='2022'
ORDER BY anzahl_renten DESC LIMIT 1;