# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A5")
ds <- download_data(ds)
ds$data

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::mutate(
    spatialunit_uid = spatial_mapping_country()
  ) %>%
  dplyr::rename(
    "anzahl" = anzahl_ahv_renten_rentensumme_und_mittelwert_im_dezember
  ) %>%
  tidyr::pivot_wider(
    names_from = c("beobachtungseinheit"),
    values_from = anzahl
  ) %>%
  janitor::clean_names()
ds$postgres_export

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package
# stabotData to upload the dataset to postgres, testrun the queries,
# generate a sample upload the metadata, etc
# -------------------------------------------------------------------------

# create the table in postgres
statbotData::create_postgres_table(ds)
# add metadata to postgres
statbotData::update_metadata_in_postgres(ds)
# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)
# testrun queries
statbotData::testrun_queries(ds)

