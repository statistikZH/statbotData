-- Which canton had the most private forests in 2019?
SELECT S.name as canton
FROM number_of_plantations_in_swiss_forest as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
  AND T.year=2019
  AND T.forest_zone='Switzerland'
  AND T.wood_species='Species - total'
  AND T.type_of_owner='Private forest'
ORDER BY number_of_plantations DESC LIMIT 1;
