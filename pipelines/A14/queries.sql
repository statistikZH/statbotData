-- Which canton has the most employees in the tourism sector in 2019?
SELECT S.name
FROM tourism_economy_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
AND T.year = 2019
ORDER BY T.total_full_time_employment_of_tourism DESC LIMIT 1;


-- What canton got the most money from tourism in 2016?
SELECT S.name
FROM tourism_economy_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
AND T.year = 2016
ORDER BY T.mio_chf_gross_value_added_of_tourism DESC LIMIT 1;


-- What canton lost the highest share of revenue from tourism between 2016 and 2019, and what percentage did it lose?
SELECT
    S.name,
    SUM(CASE WHEN T.year = 2019 THEN T.percent_share_gross_value_added_of_tourism ELSE 0 END) -
    SUM(CASE WHEN T.year = 2016 THEN T.percent_share_gross_value_added_of_tourism ELSE 0 END) AS diff_percentage_gross_value_added_of_tourism_2019_2016
FROM tourism_economy_by_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.canton=TRUE
    AND T.year IN (2016, 2019)
GROUP BY S.name
ORDER BY diff_percentage_gross_value_added_of_tourism_2019_2016 ASC
LIMIT 1;

-- How many FTE allocated to tourism were there in Switzerland 2019?

-- What percentage of full time employment was allocated in canton Zurich between 2016 and 2019?

-- How much did each canton earn from tourism in 2019?
