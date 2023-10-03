# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A3")
ds <- download_data(ds)
ds

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

# clean excel-artifacts and add "beobachtungseinheit" as well as
# spatialunit_id for switzerland
ds$postgres_export <- ds$data %>%
  tidyr::drop_na() %>%
  dplyr::rename(jahr = 1, anzahl = 2) %>%
  dplyr::rename("anzahl_millionen_tonnen_co2_equivalent" = anzahl) %>%
  dplyr::mutate(spatialunit_uid = spatial_mapping_country())
ds$postgres_export

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package stabotData
# to upload the dataset to postgres, testrun the queries, generate a sample
# upload the metadata, etc
# -------------------------------------------------------------------------

# create the table in postgres
statbotData::create_postgres_table(ds)
# copy the metadata templates to the metadata files and then complete them
statbotData::update_pipeline_last_run_date(ds)
statbotData::update_metadata_in_postgres(ds)
# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)
