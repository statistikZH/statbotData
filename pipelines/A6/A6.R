# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds as dataset class
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A6")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  dplyr::mutate(
    spatialunit_uid = spatial_mapping_country()
  ) %>%
  janitor::clean_names(
  ) %>%
  dplyr::filter(
    startsWith(periode, "Jahr:")
  ) %>%
  dplyr::rename(
    jahr = periode
  ) %>%
  dplyr::rename(
    "anzahl_abstimmungsvorlagen" = volksabstimmungen_anzahl_vorlagen_nach_thema_seit_1971,
    "thema" = abstimmungsvorlage_thema
  ) %>%
  dplyr::mutate(
    jahr = as.numeric(stringr::str_extract(jahr, "\\d+"))
  )
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
