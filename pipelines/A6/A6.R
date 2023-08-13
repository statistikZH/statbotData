# -------------------------------------------------------------------------
# Step: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A6")
ds <- statbotData::download_data(ds)
ds$data

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
    jahr = as.integer(stringr::str_extract(jahr, "\\d+"))
  ) %>%
  dplyr::mutate(
    anzahl_abstimmungsvorlagen = as.integer(anzahl_abstimmungsvorlagen)
  )
ds$postgres_export

# -------------------------------------------------------------------------
# Step: Testrun queries on sqllite
#   input: ds$postgres_export, ds$dir/queries.sql
#   output: ds$dir/queries.log
# -------------------------------------------------------------------------

statbotData::testrun_queries(
  ds$postgres_export,
  ds$dir,
  ds$name
)

# -------------------------------------------------------------------------
# Step: Write metadata tables
#   input: ds$postgres_export
#   output: ds$dir/metadata_tables.csv
#           ds$dir/metadata_table_columns.csv
# -------------------------------------------------------------------------

read_write_metadata_tables(ds)
dataset_sample(ds)

