-- Which division had the highest government spending in 2020?
SELECT T.function_cofog_broad as sector_with_highest_expenses_2020
FROM government_expenditure_by_function_cofog as T
WHERE T.institutional_sector='Government' AND year=2020
GROUP BY T.function_cofog_broad, T.year
ORDER BY SUM(T.expenses_in_million_chf) DESC LIMIT 1;

-- What were the 3 largest sectors for spending of the confederation in year 2021 and how much were they?
SELECT SUM(T.expenses_in_million_chf) as expenses_in_mio_chf,
  T.function_cofog_narrow as section_with_the_highest_expenses_2020
FROM government_expenditure_by_function_cofog as T
WHERE institutional_sector='Confederation' AND year=2020
GROUP BY T.function_cofog_narrow, T.year, T.institutional_sector
ORDER BY SUM(expenses_in_million_chf) DESC LIMIT 3;

-- What percentage of the government budget was spent on education in year 2021?
SELECT SUM(T.percentage_of_total_expenses) as percentage_for_total_expenses_for_education
FROM government_expenditure_by_function_cofog as T
WHERE institutional_sector='Government'
    AND T.year=2021
    AND T.function_cofog_broad='Education'
GROUP BY T.function_cofog_broad;

-- What were the cantons' religion-related expenditures in the year of their peak?
SELECT t1.year, t1.function_cofog_narrow, t1.expenses_in_million_chf
FROM government_expenditure_by_function_cofog t1
INNER JOIN (
    SELECT year, SUM(expenses_in_million_chf) AS tot_spending
    FROM government_expenditure_by_function_cofog
    WHERE LOWER(function_cofog_narrow) LIKE '%religious%' AND institutional_sector='Canton'
    GROUP BY year
    ORDER BY tot_spending DESC LIMIT 1
) t2 ON t1.year = t2.year
WHERE LOWER(function_cofog_narrow) LIKE '%religio%' AND t1.institutional_sector='Canton';

-- How much did each institutional sector spend on environmental protection in 2018?
SELECT SUM(expenses_in_million_chf) as expenses_in_mio_chf, institutional_sector
FROM government_expenditure_by_function_cofog
WHERE year=2018 AND function_cofog_broad='Environmental protection'
GROUP BY institutional_sector
ORDER BY SUM(expenses_in_million_chf) ASC;

-- What proportion of the Swiss budget is invested in public safety each year?
SELECT year, SUM(T.percentage_of_total_expenses) as percentage_of_total_expenses_for_safety
FROM government_expenditure_by_function_cofog AS T
WHERE LOWER(function_cofog_broad) LIKE '%public%safety%'
    AND institutional_sector='Government'
GROUP BY year
ORDER BY year ASC;

-- How did police funding compare to fire funding in year 2020?
SELECT expenses_in_million_chf, function_cofog_narrow
FROM government_expenditure_by_function_cofog
WHERE (
    LOWER(function_cofog_narrow) LIKE '%police%'
    OR LOWER(function_cofog_narrow) LIKE '%fire-protection%'
)
    AND year = 2020
    AND institutional_sector='Government';

-- What percentage of the commune budget that has been allocated to communications since 2011?
SELECT year, SUM(T.percentage_of_total_expenses) as precentage_of_total_expenses_for_communication_by_communes
FROM government_expenditure_by_function_cofog as T
WHERE LOWER(function_cofog_narrow) LIKE '%communication%'
    AND institutional_sector='Commune'
    AND year >= 2011
GROUP BY year
ORDER BY year ASC;

-- What proportion of the Swiss budget will be spent on health in 2010 and 2020?
SELECT year, SUM(percentage_of_total_expenses) as precentage_of_total_expenses_for_health
FROM government_expenditure_by_function_cofog
WHERE function_cofog_broad='Health'
    AND institutional_sector='Government'
    AND year <= 2020
    AND year >= 2010
GROUP BY year
ORDER BY year ASC;

-- What is the distribution of cantonal education spending in year 2010?
SELECT function_cofog_narrow, expenses_in_million_chf as cantonal_expenses_in_mio_chf_in_2010_on_education
FROM government_expenditure_by_function_cofog as T
WHERE function_cofog_broad='Education'
    AND year = 2020
    AND institutional_sector='Canton'
ORDER BY expenses_in_million_chf DESC;
