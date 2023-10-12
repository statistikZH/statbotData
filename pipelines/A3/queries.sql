-- Wieviel Treibhausgase produzierte die Schweiz Im Jahr 2000?
SELECT T.emissions_in_million_tons_co2_equivalent
FROM greenhouse_gas_emissions_through_consumption as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name='Switzerland'
  AND S.country=TRUE
  AND T.year=2000;
