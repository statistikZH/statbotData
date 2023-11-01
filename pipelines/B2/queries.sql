-- How many records are there in the database
SELECT COUNT(*) FROM baby_names_favorite_firstname;

-- How many records are there in the database
SELECT COUNT(*) FROM baby_names_favorite_firstname;

-- How many girls borned in 2014 in Switzeland is named as Lena. Return me the rank as well.
SELECT amount
FROM baby_names_favorite_firstname as bnff
JOIN spatial_unit as su ON bnff.spatialunit_uid = su.spatialunit_uid
WHERE year = 2014
    AND bnff.gender = 'girl'
    AND bnff.first_name = 'Lena'
    AND su.name = 'Switzerland'
    AND su.country = 'TRUE';


