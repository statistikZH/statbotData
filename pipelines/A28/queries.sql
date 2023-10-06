-- How many people were employed in the primary sector in Uttwil, TG in 2015?
SELECT T.beschaftigte_personen
FROM thurgau_beschaftigte_nach_sektoren_und_gemeinden AS T
JOIN spatial_unit AS S ON T.spatialunit_uid = S.spatialunit_uid
WHERE S.municipal=TRUE
    AND S.name = "Uttwil"
    AND T.jahr=2015
    AND T.sektor = 1;
-- How many employees of the tertiary sector were employed in canton Thurgau in 2011 and 2021?
-- What are the five municipalities in Thurgau with the highest proportion of employees in the secondary sector in 2020?
-- How many people were employed in the secondary sector in the municipality of Frauenfeld in Canton Thurgau in 2015?
-- What was the number of employees per economic sector each year in Canton Thurgau between 2017 and 2020?
-- In which municipality in Thurgau did the proportion of employees grow the most (in percentage) between 2015 and 2020?
-- What was the growth rate of each economic sector in Thurgau in percentage between 2011 and 2021?
-- In what year did the number of employees in the primary sector in Thurgau reach its peak?
-- What is the proportion of municipalities in Thurgau where the number of employees in the primary sector was higher than in the secondary sector in 2016?
-- What is the proportion of municipalities in Thurgau where the number of employees in the primary sector decreased between 2013 and 2018?
-- What municipality in Thurgau has the fewest employees?
-- How many employees from the first sector were there in Arbon and Egnach, Thurgau in the years 2012 and 2019?
-- What is the most employees the municipality of Frauenfeld, TG has had in the tertiary sector?