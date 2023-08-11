# -------------------------------------------------------------------------
# Step: Get the data
# input: google sheet
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
colnames(ds$postgres_export)
unique(ds$postgres_export$staatsangehorigkeit_kategorie)
# -------------------------------------------------------------------------
# Step: Testrun queries on sqllite
#   input:  ds$postgres_export, ds$dir/queries.sql
#   output: ds$dir/queries.log
# -------------------------------------------------------------------------

statbotData::testrun_queries(
  ds$postgres_export,
  ds$dir,
  ds$name
)

# -------------------------------------------------------------------------
# Step: Write metadata tables
#   input:  ds$postgres_export
#   output: ds$dir/metadata_tables.csv
#           ds$dir/metadata_table_columns.csv
#           ds$dir/sample.csv
# -------------------------------------------------------------------------

read_write_metadata_tables(ds)
dataset_sample(ds)

