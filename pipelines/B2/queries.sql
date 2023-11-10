-- How many girls borned in 2014 in Switzeland is named as Lena. Return me the rank as well.
SELECT amount, rank
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE year = 2014
    AND bnff.gender = 'girl'
    AND bnff.first_name = 'Lena'
    AND su.name = 'Switzerland'
    AND su.country = 'TRUE';

-- Show me the most popular names of girls in Switzerland in 2016.
SELECT first_name, gender, amount, rank
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE year = 2016 and gender = 'girl' AND su.country = 'True' AND su.name = 'Switzerland'
ORDER BY bnff.amount DESC LIMIT 1;

-- How many girls new borned with name initial L from canton Zurich in 2016?
SELECT sum(amount)
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE year = 2016 AND gender = 'girl' AND su.canton = 'True'
AND su.name ilike '%zurich%' AND bnff.first_name ilike 'l%';

-- How many boys were registered in Canton Valais in year 2011?
SELECT sum(amount)
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE year = 2011 AND gender = 'boy' AND su.name ilike '%valais%' AND su.canton = 'TRUE';

-- Which canton has the most borned boys called 'Oscar' in 2016?
SELECT su.name, bnff.amount
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE year = 2016 AND gender = 'boy' AND bnff.first_name = 'Oscar' AND su.canton = 'TRUE'
ORDER BY bnff.amount DESC LIMIT 1;

-- How many favorite babynames are registered in year 2011?
SELECT DISTINCT COUNT(bnff.first_name)
FROM baby_names_favorite_firstname as bnff
WHERE bnff.year = 2011;

-- Please list all registered baby names in Canton Zug in all years. Return me the result in order of alphabets.
SELECT DISTINCT bnff.first_name
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.name ilike '%Zug%' and su.canton = 'TRUE'
ORDER BY bnff.first_name;

-- Show me all registered gender-universal names in Switzerland.
SELECT DISTINCT bnff.first_name
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.name ilike '%Switzerland%' and su.country = 'TRUE' and gender = 'girl'
intersect
SELECT DISTINCT bnff.first_name
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.name ilike '%Switzerland%' and su.country = 'TRUE' and gender = 'boy';

-- Which canton has most borned girls registed in 2011?
SELECT sum(bnff.amount), su.name
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.canton = 'TRUE' and bnff.gender = 'girl' and bnff.year = 2011
GROUP BY su.name
ORDER BY sum(bnff.amount) DESC LIMIT 1;

-- Which canton has least borned boys registed in 2011?
SELECT sum(bnff.amount), su.name
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.canton = 'TRUE' and bnff.gender = 'boy' and bnff.year = 2011
GROUP BY su.name
ORDER BY sum(bnff.amount) LIMIT 1;

-- Show me the top one ranking girl names from year 2010 in Switzerland.
SELECT bnff.first_name, bnff.year
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.country = 'TRUE' and su.name ilike '%Switzerland%' and bnff.gender = 'girl'
and bnff.year >= 2010 and bnff.rank = 1
ORDER BY bnff.year;

-- Show me the top one ranking boy names for each year after 2012 in canton Zug. Fetch me the result in an ascending order of the year.
SELECT bnff.first_name, bnff.year
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.canton = 'TRUE' and su.name ilike '%Zug%' and bnff.gender = 'boy' and bnff.year > 2012 and bnff.rank = 1
ORDER BY bnff.year;

-- All names that have been utilized by over 50 baby girls in canton Vaud. Please order the results by year.
SELECT bnff.first_name, bnff.year, bnff.amount
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.canton = 'TRUE' and su.name ilike '%Vaud%'  and bnff.gender = 'girl' and bnff.amount > 50
ORDER BY bnff.year;

-- How many baby names were registered?
SELECT DISTINCT COUNT(bnff.first_name)
FROM baby_names_favorite_firstname as bnff;

-- Show me all registered names in records.
SELECT DISTINCT bnff.first_name
FROM baby_names_favorite_firstname as bnff;

-- Show me all top-1 ranked boy names for in each canton in year 2014.
SELECT bnff.first_name, su.name
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.canton = 'TRUE' and bnff.gender = 'boy' and bnff.year = 2014 and bnff.rank = 1;;

-- Show me all top-1 ranked girl names for in each canton in year 2016. Return me the amount and year as well.
SELECT bnff.first_name, su.name, bnff.amount, bnff.year
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.canton = 'TRUE' and bnff.gender = 'girl' and bnff.year = 2016 and bnff.rank = 1;

-- Which year has the least registered baby names for all cantons?
SELECT bnff.year, sum(bnff.amount)
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.canton = 'TRUE'
group by bnff.year
ORDER BY sum(bnff.amount) LIMIT 1;

-- Which year has the most registered baby names for all cantons?
SELECT bnff.year, sum(bnff.amount)
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.canton = 'TRUE'
group by bnff.year
ORDER BY sum(bnff.amount) DESC LIMIT 1;

-- Show me all amount of baby names in all municipalities.
SELECT bnff.first_name, bnff.amount
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE su.municipal = 'TRUE';
