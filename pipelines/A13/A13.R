# -------------------------------------------------------------------------
# Steps: Get the data
# input:  google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A13")
ds <- statbotData::download_data(ds)
ds$data

# -------------------------------------------------------------------------
# Step: Clean the data
#   input:  ds$data
#.  output: ds$cleaned_data: data has been cleaned
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::select(
    -c("beobachtungseinheit")
  )%>%
  dplyr::rename(
    "anzahl_pflanzungen" = anzahl_pflanzungen_in_der_schweiz,
    "eigentumertyp" = eigentumertyp
  )
ds$cleaned_data

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping and map the spatial units
#   input:  ds$cleaned_data
#.  output: ds$postgres_export
# -------------------------------------------------------------------------

spatial_map <- ds$cleaned_data %>%
  dplyr::select(kanton) %>%
  dplyr::distinct(kanton) %>%
  map_ds_spatial_units()

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_map, by = "kanton") %>%
  dplyr::select(-kanton)
colnames(ds$postgres_export)
unique(ds$postgres_export$holzartengruppe)

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
