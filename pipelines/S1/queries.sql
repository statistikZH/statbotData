-- Welche Verbrauchkategorie hatte den höchsten mittleren Strompreis im Kanton Bern in 2017?
SELECT T.verbrauchskategorien as verbrauchskategorie_mit_maximalem_mittleren_strompreis_bern_2017
FROM median_strompreis_per_kanton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Bern%' AND S.canton=TRUE AND T.jahr=2017
ORDER BY mittlerer_preis_rappen_pro_kw_hr DESC LIMIT 1;
