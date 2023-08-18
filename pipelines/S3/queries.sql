-- Welcher Sektor hatte in 2020 die hoechsten Staatsausgaben?
SELECT T.aufgabenbereich_des_staates as ausgaben_bereich_mit_den_hoechsten_ausgaben_2020
FROM staatsausgaben_nach_aufgabenbereichen_cofog as T
JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
WHERE S.name_de='Schweiz' AND S.country=TRUE AND T.jahr=2020
ORDER BY ausgaben_in_mio_chf DESC LIMIT 1;