-- Welches war der am meisten importierte Energietraeger 2020 in der Schweiz?
SELECT energietraeger as meist_importierte_enrgietraeger_2020
FROM energiebilanz_schweiz_in_tera_joule AS T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE
AND jahr='2020'
ORDER BY terajoule_import DESC LIMIT 1;
