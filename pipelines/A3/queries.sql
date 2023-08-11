-- Wieviel Treibhausgase produzierte die Schweiz Im Jahr 2000?
SELECT anzahl_millionen_tonnen_co2_equivalent as treibhausgasemission_in_mio_tonnen
FROM treibhausgasemission_in_mio_tonnen as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE AND T.jahr=2000;
