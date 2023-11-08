-- How many marriages occurred in Reiden in 1999 with a wife who held Swiss citizenship?
SELECT  T1.citizenship_category_wife, T2.name,T1.year, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.name ilike  '%Reiden%' and T1.year= 1999 and T1.citizenship_category_wife='Switzerland' and T1.citizenship_category_husband = 'Citizenship of husband - total';

-- Which canton has the highest number of marriages between Swiss women and Swiss men on 2018?
SELECT  T2.name,T1.citizenship_category_wife,T1.citizenship_category_husband,T1.year, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal=True and T1.year=2018 and T1.citizenship_category_husband='Switzerland' and T1.citizenship_category_wife='Switzerland'
ORDER BY  T1.amount DESC
LIMIT 1;

-- In which region are the fewest marriages recorded between Swiss men and foreign women?
SELECT  T2.name,T1.citizenship_category_wife,T1.citizenship_category_husband,T1.year, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal=True and T1.year=2018 and T1.citizenship_category_husband='Switzerland' and T1.citizenship_category_wife='Foreign country'
ORDER BY  T1.amount ASC
LIMIT 10;

-- What is the number of marriages in Reichenbach im Kandertal in 2020 where both the wife and husband are citizens of foreign countries?
SELECT  T2.name,T1.citizenship_category_wife,T1.citizenship_category_husband,T1.year, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.name ilike '%Reichenbach im Kandertal%' and T1.year=2020 and T1.citizenship_category_husband='Foreign country' and T1.citizenship_category_wife='Foreign country';

-- How many marriages occurred in Heitenried in the year 2008 for individuals of different nationalities?
SELECT  T2.name,T1.citizenship_category_wife,T1.citizenship_category_husband,T1.year, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.name ilike '%Heitenried%' and T1.year=2008  and T1.citizenship_category_wife !='Citizenship of wife - total' and T1.citizenship_category_husband !='Citizenship of husband - total';

-- How many marriages occurred in switzerland in the year 2010?
SELECT  T2.name,T1.citizenship_category_wife,T1.citizenship_category_husband,T1.year, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True and T1.year=2010 and T1.citizenship_category_wife ='Citizenship of wife - total' and T1.citizenship_category_husband ='Citizenship of husband - total';

-- How many marriages occurred in switzerland in the year 2010?
SELECT  T2.name,T1.citizenship_category_wife,T1.citizenship_category_husband,T1.year, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.country=True and T1.year=2010 and T1.citizenship_category_wife !='Citizenship of wife - total' and T1.citizenship_category_husband !='Citizenship of husband - total';

-- In 2000, among the municipalities, which had the highest and lowest numbers of marriages where the husbands were Swiss citizens?
(SELECT  T2.name, T2.spatialunit_ontology,T1.year, T1.amount  FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal = True AND T1.year = 2000  AND T1.citizenship_category_husband = 'Switzerland'  AND T1.citizenship_category_wife ='Citizenship of wife - total'
AND T1.amount =(SELECT Max(T1.amount) FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal = True AND T1.year = 2000  AND T1.citizenship_category_husband = 'Switzerland'  AND T1.citizenship_category_wife ='Citizenship of wife - total' )
LIMIT 1)
UNION ALL
(
SELECT  T2.name, T2.spatialunit_ontology,T1.year, T1.amount  FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal = True AND T1.year = 2000  AND T1.citizenship_category_husband = 'Switzerland'  AND T1.citizenship_category_wife ='Citizenship of wife - total'
AND T1.amount =(SELECT MIN(T1.amount) FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal = True AND T1.year = 2000  AND T1.citizenship_category_husband = 'Switzerland'  AND T1.citizenship_category_wife ='Citizenship of wife - total' )
LIMIT 1);

-- What is the highest number of marriages that occurred at the district level in 2012, where both the wife and husband were citizens of foreign countries?
SELECT  T2.name, T2.spatialunit_ontology,T1.year, T1.amount,T1.citizenship_category_husband,T1.citizenship_category_wife  FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.district = True AND T1.year = 2012  AND T1.citizenship_category_husband = 'Foreign country'  AND T1.citizenship_category_wife ='Foreign country'
ORDER BY T1.amount DESC
LIMIT 1;

-- In the year 1982, what was the average number of marriages at the municipal level, where the husbands were citizens of foreign countries?
SELECT  AVG(T1.amount)  FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal = True AND T1.year = 2012  AND T1.citizenship_category_husband = 'Foreign country' AND  T1.citizenship_category_wife ='Citizenship of wife - total';

-- In 2006, what were the top 10 cantons with the highest number of marriages where the grooms were Swiss nationals?
SELECT  T2.name, T2.spatialunit_ontology,T1.year, T1.amount   FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.canton = True AND T1.year = 2012  AND T1.citizenship_category_husband = 'Switzerland' AND  T1.citizenship_category_wife ='Citizenship of wife - total'
ORDER BY T1.amount DESC
LIMIT 10;

-- Show me the top-10 municipalities with the lowest numbers of marriages that the wives were Swiss citizens on 2016?
SELECT  T2.name, T2.spatialunit_ontology,T1.year, T1.amount   FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal = True AND T1.year = 2012  AND T1.citizenship_category_wife = 'Switzerland' AND  T1.citizenship_category_husband ='Citizenship of husband - total'
ORDER BY T1.amount ASC
LIMIT 10;

-- Give me the minimum , maximum and average number of marriages at the municipal level in 2011, where both the husband and wife are citizens of foreign countries?
SELECT  MIN(T1.amount),Max(T1.amount),AVG(T1.amount)  FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.municipal = True AND T1.year = 2011  AND T1.citizenship_category_husband = 'Foreign country' AND  T1.citizenship_category_wife ='Foreign country';

-- Give me the average number of marriages at the canton level in 2001, where both the husband and wife are citizens of Swiss?
SELECT  AVG(T1.amount)  FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.canton = True AND T1.year = 2001  AND T1.citizenship_category_husband = 'Switzerland' AND  T1.citizenship_category_wife ='Switzerland';

-- Give me the 5 highest numbers of marriages that occurred at the canton level in 2010, where both the wife and husband were citizens of foreign countries?
SELECT  T2.name, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.canton = True AND T1.year = 2010  AND T1.citizenship_category_husband = 'Foreign country' AND  T1.citizenship_category_wife ='Foreign country'
ORDER BY T1.amount DESC
LIMIT 5;

-- Show me the lowet number of marriages that occurred at the canton level in 1990, where both the wife and husband were from different nationalities?
SELECT A.*  from (SELECT T2.name, T1.citizenship_category_husband, T1.citizenship_category_wife, T1.amount
               FROM marriage_citizenship as T1
                        JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
               WHERE T2.canton = True
                 AND T1.year = 1990
                 AND T1.citizenship_category_husband = 'Foreign country'
                 and T1.citizenship_category_wife = 'Switzerland'
               UNION
               SELECT T2.name, T1.citizenship_category_husband, T1.citizenship_category_wife, T1.amount
               FROM marriage_citizenship as T1
                        JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
               WHERE T2.canton = True
                 AND T1.year = 1990
                 AND T1.citizenship_category_husband = 'Switzerland'
                 and T1.citizenship_category_wife = 'Foreign country') A
ORDER BY A.amount ASC
LIMIT 1;

-- In 2012, how many marriages took place in the District of Affoltern, categorized by the citizenships of the wives and husbands involved?
SELECT T2.name,T1.citizenship_category_husband ,T1.citizenship_category_wife , T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE T2.district = True AND T1.year = 2010  AND T2.name ilike '%Affoltern%' AND T1.citizenship_category_wife !='Citizenship of wife - total' and T1.citizenship_category_husband !='Citizenship of husband - total';

-- How many marriages occurred in Oberdorf (BL) each year?
SELECT T2.name, T1.year, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE  T2.name ilike '%Oberdorf (BL)%' AND T1.citizenship_category_wife ='Citizenship of wife - total' and T1.citizenship_category_husband ='Citizenship of husband - total'
ORDER BY T1.year ASC;

-- Please provide a summary of the number of marriages for each combination of male and female citizenships in the canton of Zurich since 2000.
SELECT T2.name, T1.year, T1.citizenship_category_husband , T1.citizenship_category_wife, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE  T2.name ilike '%z_rich%'  AND T2.canton = True AND T1.year >=2000  AND T1.citizenship_category_wife !='Citizenship of wife - total' and T1.citizenship_category_husband !='Citizenship of husband - total'
ORDER BY T1.year ASC, T1.citizenship_category_wife ASC , T1.citizenship_category_husband ASC;

-- Which five cantons have the highest number of marriages between Swiss men and foreign women on 2011?
SELECT T2.name, T1.citizenship_category_husband , T1.citizenship_category_wife, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE  T2.canton=True AND T1.year=2011 AND T1.citizenship_category_husband ='Switzerland' and T1.citizenship_category_wife ='Foreign country'
ORDER BY T1.amount DESC
LIMIT 5;

-- What are the top five municipalities with the highest number of marriages between Swiss men and foreign women in the year 2018?
SELECT T2.name, T1.citizenship_category_husband , T1.citizenship_category_wife, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE  T2.municipal = True AND T1.year=2018 AND T1.citizenship_category_husband ='Foreign country' and T1.citizenship_category_wife ='Switzerland'
ORDER BY T1.amount DESC
LIMIT 5;

-- In terms of the number of marriages between two foreigners on 2012, how does Canton Zurich compare to Canton Neuchâtel?
SELECT T2.name, T1.citizenship_category_husband , T1.citizenship_category_wife, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE  T1.year=2012 AND T2.canton = True AND (T2.name  ilike '%z_rich%' OR T2.name  ilike '%Neuch_tel%')  AND T1.citizenship_category_wife ='Foreign country' AND T1.citizenship_category_husband ='Foreign country'
ORDER BY T1.amount DESC;

-- In which year did the Canton of Bern have the highest number of marriages between Swiss citizens and foreigners?
SELECT UN.year, UN.citizenship_category_husband, UN.citizenship_category_wife, UN.amount FROM
(SELECT T2.name, T1.year, T1.citizenship_category_husband , T1.citizenship_category_wife, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE  T2.canton = True AND T2.name  ilike '%Bern%'  AND T1.citizenship_category_wife ='Switzerland' AND T1.citizenship_category_husband ='Foreign country'
UNION ALL
SELECT T2.name, T1.year, T1.citizenship_category_husband , T1.citizenship_category_wife, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE  T2.canton = True AND T2.name  ilike '%Bern%'  AND T1.citizenship_category_wife ='Foreign country' AND T1.citizenship_category_husband ='Switzerland') AS UN
ORDER BY UN.amount DESC
LIMIT 1;

-- which year has the most number of marriage between swiss man and woman from other nationalty in Switzerlan?
SELECT T1.year, T1.citizenship_category_husband , T1.citizenship_category_wife, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE  T2.country = True  AND T2.name='Switzerland'  AND T1.citizenship_category_wife ='Foreign country' AND T1.citizenship_category_husband ='Switzerland'
ORDER BY T1.amount DESC
LIMIT 1;

-- which year has the most number of marriage between swiss femal and man from other nationalty in canton Argua?
SELECT T1.year, T1.citizenship_category_husband , T1.citizenship_category_wife, T1.amount FROM marriage_citizenship as T1
JOIN spatial_unit T2 on T1.spatialunit_uid = T2.spatialunit_uid
WHERE  T2.canton=True AND T2.name ilike '%Aargau%'  AND T1.citizenship_category_wife ='Switzerland' AND T1.citizenship_category_husband ='Foreign country'
ORDER BY T1.amount DESC
LIMIT 1;