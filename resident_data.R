# An attempt to process the 1_01_001_CH parquet file
# and add it manually to local database for the purpose
# of making the human-readable questions & DB queries pairs
# as the training data for the statbot project

# The DB tables to which these manually prepared tables should become a match to
# experiment.resident_population_type_citizenship_category_gender_age as rp
# experiment.spatial_unit as su ON rp.spatialunit_uid = su.spatialunit_uid

pq01 <- arrow::read_parquet("/Users/avgr/Downloads/1_01_001_CH-0.parquet")
pq01[100, ]
# data.table::fwrite(x = pq01, "/Users/avgr/Downloads/pq.csv")

su <- arrow::read_parquet("/Users/avgr/Downloads/spatialunits.parquet")

# data.table::fwrite(x = su, "/Users/avgr/Downloads/su.csv")


pq01[1:1000, ]


library(magrittr)
library(dplyr)

pq011 <- pq01 %>%
  mutate(age_group = paste(age_group_1, "years"))

pq011$age_group <- ifelse(pq011$age_group == "-111 years", "Age - total", pq011$age_group)
pq011$age_group <- ifelse(pq011$age_group == "100 years", "100 years or older", pq011$age_group)

pq011$gender <- ifelse(pq011$gender == "-111", "Sex - total", pq011$gender)
pq011$gender <- ifelse(pq011$gender == "1", "Male", pq011$gender)
pq011$gender <- ifelse(pq011$gender == "2", "Female", pq011$gender)

pq011$population_type <- ifelse(pq011$population_type == "1", "Permanent resident population", pq011$population_type)
pq011$population_type <- ifelse(pq011$population_type == "2", "Non permanent resident population", pq011$population_type)

pq011$citizenship_category <- ifelse(pq011$citizenship_category == "1", "Switzerland", pq011$citizenship_category)
pq011$citizenship_category <- ifelse(pq011$citizenship_category == "2", "Foreign country", pq011$citizenship_category)
pq011$citizenship_category <- ifelse(pq011$citizenship_category == "-111", "Citizenship (category) - total", pq011$citizenship_category)





pq011$time_value[1:100]


class(pq011$time_value)
pq011$time_value <- pq011$time_value %>%
  as.Date()
pq011$year <- pq011$time_value %>%
  lubridate::year() %>%
  as.character()



pq011 <- dplyr::select(pq011, -time_value)
pq011 <- dplyr::select(pq011, -age_group_1)
pq011 <- dplyr::select(pq011, -period_value)
pq011 <- dplyr::select(pq011, -flag)

su <- dplyr::select(su, -valid_from)
su <- dplyr::select(su, -valid_until)

pq011 <- dplyr::filter(pq011, value != 0)

pq011[1:100, ]

library(lubridate)
pq011$flag %>%
  as.character() %>%
  as.factor() %>%
  levels()


pq011[1:1000, ]



data.table::fwrite(x = pq011,
                   file = "./pq.csv")
