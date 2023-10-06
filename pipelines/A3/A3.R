# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A3")
ds <- download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

# clean excel-artifacts and add "beobachtungseinheit" as well as
# spatialunit_id for switzerland
ds$postgres_export <- ds$data %>%
  tidyr::drop_na() %>%
  dplyr::rename(year = 1, quantity = 2) %>%
  dplyr::rename("emissions_in_million_tons_co2_equivalent" = quantity) %>%
  dplyr::mutate(spatialunit_uid = spatial_mapping_country())
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
