-- Welcher Kanton hatte 2019 die meisten privaten Wälder?
SELECT S.name_de as kanton_mit_meisten_privaten_waeldern_2019
FROM pflanzungen_schweiz as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
AND T.Jahr=2019
AND T.forstzone='Schweiz'
AND T.holzartengruppe='Holzartengruppe - Total'
AND T.eigentumertyp='Privatwälder'
ORDER BY anzahl_pflanzungen DESC LIMIT 1;
