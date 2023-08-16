# -------------------------------------------------------------------------
# Step: Get the data
# input: google sheet
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
  dplyr::rename(jahr = 1, anzahl = 2) %>%
  dplyr::rename("anzahl_millionen_tonnen_co2_equivalent" = anzahl) %>%
  dplyr::mutate(spatialunit_uid = spatial_mapping_country())
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
#   input:  ds$postgres_export
#   output: ds$dir/metadata_tables.csv
#           ds$dir/metadata_table_columns.csv
#           ds$dir/sample.csv
# -------------------------------------------------------------------------

read_write_metadata_tables(ds)
dataset_sample(ds)
dim(ds$postgres_export)
length(ds$postgres_export)
