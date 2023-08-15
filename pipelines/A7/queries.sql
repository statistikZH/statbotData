-- Wieviele Beschäftigte waren in einzelnen Artpraxen im Kanton Bern in 2019 tätig?
SELECT SUM(anzahl_beschaeftigte) as beschaeftigte_in_einzel_praxen_in_bern_2019
FROM arztpraxen_ambulante_zentren as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de LIKE '%Bern%' AND S.canton=TRUE
AND T.rechtsform LIKE '%Einzel%' AND T.jahr=2019;
