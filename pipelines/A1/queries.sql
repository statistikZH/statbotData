-- Wieviele Angiogrphiegeräte gab es 2013 in der Schweiz?
SELECT SUM(anzahl_gerate) as anzahl_gerate_in_2013
FROM medizinisch_technische_infrastruktur as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.country=TRUE AND jahr = '2013';