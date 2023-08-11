-- What farm animals were bred in the canton of Bern in 2020?
SELECT livestock_beef_cattle_and_cows, livestock_sheep, livestock_goats, livestock_pigs, livestock_poultry, livestock_other_animals
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name="Canton of Bern"
    AND S.canton=TRUE
    AND T.year=2020
    AND T.farmholding_system == "Farmholding system - total";

-- How many farms were there in all of Switzerland between 2012 and 2018?
SELECT year, farmholding_system, farmholdings
FROM employees_farmholdings_agricultural_area_livestock_per_canton as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name="Switzerland"
    AND S.country=TRUE
    AND year BETWEEN 2012 AND 2018
    AND T.farmholding_system == "Farmholding system - total";

-- What is the total agricultural surface area in the canton of Geneva?

-- What canton has the most pigs in its farms?

-- What is the average number of cows per farm in the canton of Vaud?

-- What canton has the highest percentage of organic farms?

-- How many employees does the largest farm in Switzerland have?

-- Does the average organic farm have less employees than the average non-organic farm?