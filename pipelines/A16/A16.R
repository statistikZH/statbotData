library(magrittr)
# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A16")
ds <- download_data(ds)

# data cleaning -----------------------------------------------------------

### Filter specific dimensions

# To reduce the dataset size, we will not include sex and citizenship category
ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::filter(
    sex == "Sex - total"
  ) %>%
  dplyr::select(
    -sex,
  )
colnames(ds$postgres_export)

# Pivot indicators into 1 indicator per column and cleanup names
ds$postgres_export %<>%
  tidyr::pivot_wider(
    names_from = demographic_component,
    values_from = demographic_balance_by_canton
  ) %>%
  janitor::clean_names() %>%
  dplyr::rename(
    "total_population" = population_on_1_january,
    "births" = live_birth,
    "deaths" = death,
    "net_migration" = net_migration_incl_change_of_population_type,
    "immigration" = immigration_incl_change_of_population_type
  )
# Remove redundant or constant columns
# + acquisition of swiss citizenship is always 0
# + The 'change of population type' component is
#   always included in the demographic components of
#   'immigration' and 'net migration'.
ds$postgres_export %<>%
  dplyr::select(
    -change_of_population_type,
    -population_on_31_december,
    -natural_change,
    -gender_change_in_the_civil_register_entry,
    -gender_change_in_the_civil_register_exit
  )

# Remove rows with no canton and 0 values
# Excluding years 1971 - 1980 where there is only
# information about net migration
ds$postgres_export %<>%
  dplyr::filter(year >= 1981) %>%
  dplyr::filter(canton != "No indication")

# join the cleaned data to the postgres spatial units table ---------------

spatial_map <- ds$postgres_export %>%
  dplyr::select(canton) %>%
  dplyr::distinct(canton) %>%
  map_ds_spatial_units()

ds$postgres_export %<>%
  dplyr::left_join(spatial_map, by = "canton") %>%
  dplyr::select(-canton)
ds$postgres_export
## check that each spatial unit could be matched -> this has to be TRUE

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package stabotData
# to upload the dataset to postgres, testrun the queries, generate a sample
# upload the metadata, etc
# -------------------------------------------------------------------------

# testrun queries
statbotData::testrun_queries(ds)

# create the table in postgres
statbotData::create_postgres_table(ds)

# add the metadata to postgres
statbotData::update_metadata_in_postgres(ds)

# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)
