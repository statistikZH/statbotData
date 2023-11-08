-- What are the top 5 cantons with the highest number of divorces in 1994 for Swiss couples?
SELECT su.name, SUM(div.amount) as total
FROM divorces_duration_of_marriage_citizenship_categories div
JOIN spatial_unit su on div.spatialunit_uid = su.spatialunit_uid
WHERE div.year = 1994
  AND div.duration_of_marriage = 'Duration of marriage - total'
  AND div.citizenship_category_husband = 'Switzerland'
  AND div.citizenship_category_wife = 'Switzerland'
  AND su.name LIKE '%Canton%'
GROUP BY su.name
ORDER BY total DESC
LIMIT 5;

-- What is the total number of divorces for Swiss couples where the duration of the marriage was 20 years or more in 1994?
SELECT SUM(amount)
FROM divorces_duration_of_marriage_citizenship_categories
WHERE year = 1994
  AND duration_of_marriage = '20 years or more'
  AND citizenship_category_husband = 'Switzerland'
  AND citizenship_category_wife = 'Switzerland';

-- How has the number of divorces for Swiss couples changed from 1990 to 2000?
SELECT year, SUM(amount) as total
FROM divorces_duration_of_marriage_citizenship_categories
WHERE year BETWEEN 1990 AND 2000
  AND duration_of_marriage = 'Duration of marriage - total'
  AND citizenship_category_husband = 'Switzerland'
  AND citizenship_category_wife = 'Switzerland'
GROUP BY year
ORDER BY year;

-- At what duration of marriage do most divorces occur?
SELECT duration_of_marriage, SUM(amount) AS total_divorces
FROM divorces_duration_of_marriage_citizenship_categories
WHERE duration_of_marriage != 'Duration of marriage - total'
GROUP BY duration_of_marriage
ORDER BY total_divorces DESC
LIMIT 1;

-- What is the average number of divorces per year between 1990 and 2000 in Switzerland among Swiss couples?
SELECT AVG(total) as average_divorces_per_year
FROM (
  SELECT year, SUM(amount) as total
  FROM divorces_duration_of_marriage_citizenship_categories
  JOIN spatial_unit su on divorces_duration_of_marriage_citizenship_categories.spatialunit_uid = su.spatialunit_uid
  WHERE year BETWEEN 1990 AND 2000
    AND su.spatialunit_uid = '0_CH'
    AND duration_of_marriage = 'Duration of marriage - total'
    AND citizenship_category_husband = 'Switzerland'
    AND citizenship_category_wife = 'Switzerland'
  GROUP BY year
) as subquery;

-- How many divorces occurred in Switzerland in 1995 between Swiss couples who were married for less than 5 years?
SELECT SUM(amount)
FROM divorces_duration_of_marriage_citizenship_categories
JOIN spatial_unit su on divorces_duration_of_marriage_citizenship_categories.spatialunit_uid = su.spatialunit_uid
WHERE year = 2001
  AND su.spatialunit_uid = '0_CH'
  AND duration_of_marriage = '0-4 years'
  AND citizenship_category_husband = 'Switzerland'
  AND citizenship_category_wife = 'Switzerland';

-- In which year between 1990 and 2000 did the Canton of Zurich have the highest number of divorces between Swiss couples?
SELECT year, SUM(amount) as total
FROM divorces_duration_of_marriage_citizenship_categories join spatial_unit su on divorces_duration_of_marriage_citizenship_categories.spatialunit_uid = su.spatialunit_uid
WHERE year BETWEEN 2000 AND 2010
  AND su.spatialunit_uid = '1_A.ADM1'
  AND duration_of_marriage = 'Duration of marriage - total'
  AND citizenship_category_husband = 'Switzerland'
  AND citizenship_category_wife = 'Switzerland'
GROUP BY year
ORDER BY total DESC
LIMIT 1;

-- How did the total number of divorces between Swiss couples compare between the cantons of Zurich and Geneva in the year 1995?
SELECT su.spatialunit_uid, SUM(amount) as total
FROM divorces_duration_of_marriage_citizenship_categories join spatial_unit su on divorces_duration_of_marriage_citizenship_categories.spatialunit_uid = su.spatialunit_uid
WHERE year = 1995
  AND (su.spatialunit_uid = '1_A.ADM1' OR su.spatialunit_uid = '25_A.ADM1')
  AND duration_of_marriage = 'Duration of marriage - total'
  AND citizenship_category_husband = 'Switzerland'
  AND citizenship_category_wife = 'Switzerland'
GROUP BY su.spatialunit_uid;

-- In which year between 1990 and 2000 did the canton of zurich have more divorces between Swiss couples than the canton of geneva?
WITH zurich AS (
  SELECT year, SUM(amount) as total
  FROM divorces_duration_of_marriage_citizenship_categories d
  JOIN spatial_unit su ON d.spatialunit_uid = su.spatialunit_uid
  WHERE year BETWEEN 1990 AND 2000
    AND su.spatialunit_uid = '1_A.ADM1'
    AND duration_of_marriage = 'Duration of marriage - total'
    AND citizenship_category_husband = 'Switzerland'
    AND citizenship_category_wife = 'Switzerland'
  GROUP BY year
),
geneva AS (
  SELECT year, SUM(amount) as total
  FROM divorces_duration_of_marriage_citizenship_categories d
  JOIN spatial_unit su ON d.spatialunit_uid = su.spatialunit_uid
  WHERE year BETWEEN 1990 AND 2000
    AND su.spatialunit_uid = '25_A.ADM1'
    AND duration_of_marriage = 'Duration of marriage - total'
    AND citizenship_category_husband = 'Switzerland'
    AND citizenship_category_wife = 'Switzerland'
  GROUP BY year
)
SELECT z.year
FROM zurich z
JOIN geneva g ON z.year = g.year
WHERE z.total > g.total;

-- Which municipality had the highest number of divorces in 1995 between Swiss couples?
SELECT su.name, d.year, SUM(d.amount) as total_divorces
FROM divorces_duration_of_marriage_citizenship_categories d
JOIN spatial_unit su ON d.spatialunit_uid = su.spatialunit_uid
WHERE d.year = 1995
  AND su.spatialunit_uid LIKE '%_A.ADM3'
  AND d.duration_of_marriage = 'Duration of marriage - total'
  AND d.citizenship_category_husband = 'Switzerland'
  AND d.citizenship_category_wife = 'Switzerland'
GROUP BY su.name, d.year
ORDER BY total_divorces DESC
LIMIT 1;

-- Which canton had the least divorces in 2000 between couples where at least one partner is a foreigner?
SELECT su.name, SUM(amount) AS total_divorces
FROM divorces_duration_of_marriage_citizenship_categories d
JOIN spatial_unit su ON d.spatialunit_uid = su.spatialunit_uid
WHERE year = 2000
  AND su.spatialunit_uid LIKE '%_A.ADM1'
  AND (citizenship_category_husband = 'Foreign country' OR citizenship_category_wife = 'Foreign country')
GROUP BY su.name
ORDER BY total_divorces ASC
LIMIT 1;

-- In 1995, which municipality had the highest number of divorces between Swiss couples who were married for 10-14 years?
SELECT su.name, SUM(amount) AS total_divorces
FROM divorces_duration_of_marriage_citizenship_categories d
JOIN spatial_unit su ON d.spatialunit_uid = su.spatialunit_uid
WHERE duration_of_marriage = '10-14 years'
  AND year = 1995
  AND su.spatialunit_uid LIKE '%_A.ADM3'
  AND citizenship_category_husband = 'Switzerland'
  AND citizenship_category_wife = 'Switzerland'
GROUP BY su.name
ORDER BY total_divorces DESC
LIMIT 1;

-- In 1995, which municipality had the lowest number of divorces between Swiss couples who were married for 10-14 years?
SELECT su.name, SUM(amount) AS total_divorces
FROM divorces_duration_of_marriage_citizenship_categories d
JOIN spatial_unit su ON d.spatialunit_uid = su.spatialunit_uid
WHERE duration_of_marriage = '10-14 years'
  AND year = 1995
  AND su.spatialunit_uid LIKE '%_A.ADM3'
  AND citizenship_category_husband = 'Switzerland'
  AND citizenship_category_wife = 'Switzerland'
GROUP BY su.name
ORDER BY total_divorces ASC
LIMIT 1;

-- How many municipalites had zero/the least amount of divorces between swiss couples in the year 2012?
SELECT COUNT(*) AS number_of_municipalities
FROM (
    SELECT su.name, SUM(d.amount) as total_divorces
    FROM divorces_duration_of_marriage_citizenship_categories d
    JOIN spatial_unit su ON d.spatialunit_uid = su.spatialunit_uid
    WHERE d.year = 2012
      AND d.duration_of_marriage = 'Duration of marriage - total'
      AND su.spatialunit_uid LIKE '%_A.ADM3'
      AND d.citizenship_category_husband = 'Switzerland'
      AND d.citizenship_category_wife = 'Switzerland'
    GROUP BY su.name
) AS subquery
WHERE total_divorces = (
    SELECT MIN(total_divorces)
    FROM (
        SELECT su.name, SUM(d.amount) as total_divorces
        FROM divorces_duration_of_marriage_citizenship_categories d
        JOIN spatial_unit su ON d.spatialunit_uid = su.spatialunit_uid
        WHERE d.year = 2012
          AND d.duration_of_marriage = 'Duration of marriage - total'
          AND su.spatialunit_uid LIKE '%_A.ADM3'
          AND d.citizenship_category_husband = 'Switzerland'
          AND d.citizenship_category_wife = 'Switzerland'
        GROUP BY su.name
    ) AS inner_subquery
);

-- at which duration of marriage most marriages end in divorce across the entire country for all citizenships?
SELECT duration_of_marriage, SUM(amount) AS total_divorces
FROM divorces_duration_of_marriage_citizenship_categories
WHERE spatialunit_uid = '0_CH'
  AND duration_of_marriage != 'Duration of marriage - total'
GROUP BY duration_of_marriage
ORDER BY total_divorces DESC
LIMIT 1;

-- Is there a year where the Canton of Appenzell Innerrhoden had more divorces than the canton of Appenzell Ausserrhoden (in the years 2000 between 2015)?	"
SELECT innerrhoden.year, innerrhoden.total_divorces AS innerrhoden_divorces, ausserrhoden.total_divorces AS ausserrhoden_divorces
FROM (
    SELECT year, SUM(amount) AS total_divorces
    FROM divorces_duration_of_marriage_citizenship_categories
    WHERE spatialunit_uid = '16_A.ADM1'
      AND duration_of_marriage = 'Duration of marriage - total'
      AND year BETWEEN 2000 AND 2015
    GROUP BY year
) AS innerrhoden
JOIN (
    SELECT year, SUM(amount) AS total_divorces
    FROM divorces_duration_of_marriage_citizenship_categories
    WHERE spatialunit_uid = '15_A.ADM1'
      AND duration_of_marriage = 'Duration of marriage - total'
      AND year BETWEEN 2000 AND 2015
    GROUP BY year
) AS ausserrhoden ON innerrhoden.year = ausserrhoden.year
WHERE innerrhoden.total_divorces > ausserrhoden.total_divorces;

-- What percentage of total divorces on a cantonal level between 1996 and 2017 occurred between Swiss couples, and what percentage occurred where at least one partner was not Swiss, for each canton in Switzerland?
SELECT su.name AS canton_name,
       COALESCE(swiss.swiss_divorces, 0) AS swiss_divorces,
       COALESCE(not_swiss.not_swiss_divorces, 0) AS not_swiss_divorces,
       100.0 * COALESCE(swiss.swiss_divorces, 0) / (COALESCE(swiss.swiss_divorces, 0) + COALESCE(not_swiss.not_swiss_divorces, 0)) AS percentage_swiss,
       100.0 * COALESCE(not_swiss.not_swiss_divorces, 0) / (COALESCE(swiss.swiss_divorces, 0) + COALESCE(not_swiss.not_swiss_divorces, 0)) AS percentage_not_swiss
FROM (
  SELECT spatialunit_uid AS canton_id,
         SUM(amount) AS swiss_divorces
  FROM divorces_duration_of_marriage_citizenship_categories
  WHERE duration_of_marriage = 'Duration of marriage - total'
    AND citizenship_category_husband = 'Switzerland'
    AND citizenship_category_wife = 'Switzerland'
    AND year BETWEEN 1996 AND 2017
    AND spatialunit_uid LIKE '%_ADM1'  -- Assuming this is the pattern for cantonal IDs
  GROUP BY spatialunit_uid
) AS swiss
FULL JOIN (
  SELECT spatialunit_uid AS canton_id,
         SUM(amount) AS not_swiss_divorces
  FROM divorces_duration_of_marriage_citizenship_categories
  WHERE duration_of_marriage = 'Duration of marriage - total'
    AND (citizenship_category_husband = 'Foreign country' OR citizenship_category_wife = 'Foreign country')
    AND year BETWEEN 1996 AND 2017
    AND spatialunit_uid LIKE '%_ADM1'  -- Assuming this is the pattern for cantonal IDs
  GROUP BY spatialunit_uid
) AS not_swiss ON swiss.canton_id = not_swiss.canton_id
JOIN spatial_unit su ON COALESCE(swiss.canton_id, not_swiss.canton_id) = su.spatialunit_uid;

-- In which year between 1996 and 2017 did the canton of Graubünden experience the biggest difference in the percentage of total divorces between Swiss couples and couples where at least one partner was not Swiss?
WITH swiss AS (
  SELECT year,
         SUM(amount) AS swiss_divorces
  FROM divorces_duration_of_marriage_citizenship_categories
  WHERE duration_of_marriage = 'Duration of marriage - total'
    AND citizenship_category_husband = 'Switzerland'
    AND citizenship_category_wife = 'Switzerland'
    AND year BETWEEN 1996 AND 2017
    AND spatialunit_uid = '18_A.ADM1'
  GROUP BY year
),
not_swiss AS (
  SELECT year,
         SUM(amount) AS not_swiss_divorces
  FROM divorces_duration_of_marriage_citizenship_categories
  WHERE duration_of_marriage = 'Duration of marriage - total'
    AND (citizenship_category_husband = 'Foreign country' OR citizenship_category_wife = 'Foreign country')
    AND year BETWEEN 1996 AND 2017
    AND spatialunit_uid = '18_A.ADM1'
  GROUP BY year
)
SELECT swiss.year,
       COALESCE(swiss.swiss_divorces, 0) AS swiss_divorces,
       COALESCE(not_swiss.not_swiss_divorces, 0) AS not_swiss_divorces,
       ABS(100.0 * COALESCE(swiss.swiss_divorces, 0) / (COALESCE(swiss.swiss_divorces, 0) + COALESCE(not_swiss.not_swiss_divorces, 0))
          - 100.0 * COALESCE(not_swiss.not_swiss_divorces, 0) / (COALESCE(swiss.swiss_divorces, 0) + COALESCE(not_swiss.not_swiss_divorces, 0)))
           AS percentage_difference
FROM swiss
JOIN not_swiss ON swiss.year = not_swiss.year
ORDER BY percentage_difference DESC
LIMIT 1;

-- In 2010, which municipality had the highest number of divorces between couples who were married for 5-9 years and at least one partner was not Swiss?
SELECT su.name, sum(amount) as total_divorces
FROM divorces_duration_of_marriage_citizenship_categories AS div
JOIN spatial_unit AS su ON div.spatialunit_uid = su.spatialunit_uid
WHERE year = 2010
  AND duration_of_marriage = '5-9 years'
  AND (citizenship_category_husband = 'Foreign country' OR citizenship_category_wife = 'Foreign country')
  AND su.spatialunit_uid LIKE '%_A.ADM3'
GROUP BY su.name
ORDER BY total_divorces DESC
LIMIT 1;

-- In which year did the canton of Vaud experience the highest number of divorces between Swiss couples who were married for 15-19 years?
SELECT year, sum(amount) as total_divorces
FROM divorces_duration_of_marriage_citizenship_categories AS div
JOIN spatial_unit AS su ON div.spatialunit_uid = su.spatialunit_uid
WHERE su.spatialunit_uid = '22_A.ADM1'
  AND duration_of_marriage = '15-19 years'
  AND citizenship_category_husband = 'Switzerland'
  AND citizenship_category_wife = 'Switzerland'
GROUP BY year
ORDER BY total_divorces DESC
LIMIT 1;

-- Over the years 2000 to 2020, which Swiss municipality experienced the largest increase in total divorces, regardless of citizenship status and duration of marriage?
WITH yearly_totals AS (
  SELECT year, su.name, sum(amount) as total_divorces
  FROM divorces_duration_of_marriage_citizenship_categories AS div
  JOIN spatial_unit AS su ON div.spatialunit_uid = su.spatialunit_uid
  WHERE year BETWEEN 2000 AND 2020
    AND duration_of_marriage = 'Duration of marriage - total'
    AND su.spatialunit_uid LIKE '%_A.ADM3'
  GROUP BY year, su.name
),
year_2000 AS (
  SELECT name, total_divorces
  FROM yearly_totals
  WHERE year = 2000
),
year_2020 AS (
  SELECT name, total_divorces
  FROM yearly_totals
  WHERE year = 2020
)
SELECT year_2000.name, (year_2020.total_divorces - year_2000.total_divorces) as divorce_increase
FROM year_2000
JOIN year_2020 ON year_2000.name = year_2020.name
ORDER BY divorce_increase DESC
LIMIT 1;