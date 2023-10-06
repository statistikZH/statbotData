# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A13")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input:  ds$data
#.  output: ds$cleaned_data: data has been cleaned
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::select(
    -c("observation_unit")
  ) %>%
  dplyr::rename(
    number_of_plantations = number_of_plantations_in_swiss_forest
  )
ds$cleaned_data

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping and map the spatial units
#   input:  ds$cleaned_data
#.  output: ds$postgres_export
# -------------------------------------------------------------------------

spatial_map <- ds$cleaned_data %>%
  dplyr::select(canton) %>%
  dplyr::distinct(canton) %>%
  map_ds_spatial_units()

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_map, by = "canton") %>%
  dplyr::select(-canton)
ds$postgres_export

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package
# stabotData to upload the dataset to postgres, testrun the queries,
#  generate a sample, upload the metadata, etc
# -------------------------------------------------------------------------

# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)

# create the table in postgres
statbotData::create_postgres_table(ds)

# add metadata to postgres
statbotData::update_metadata_in_postgres(ds)

# run test queries
statbotData::testrun_queries(ds)
