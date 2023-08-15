-- Which canton has the most employees in the tourism sector in 2019?
SELECT S.name
FROM tourism_economy_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
AND T.year = 2019
ORDER BY T.total_full_time_employment_of_tourism DESC LIMIT 1;
