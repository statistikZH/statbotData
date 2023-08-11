# -------------------------------------------------------------------------
# Step: Get the data
# input:  google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A7")
ds <- download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: dscleaned_data
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::filter(
    !stringr::str_detect(grossregion_kanton, '<<')
  ) %>%
  dplyr::rename(
    anzahl = arztpraxen_und_ambulante_zentren_anzahl_arzte
  ) %>%
  tidyr::pivot_wider(
    names_from = c("beobachtungseinheit"),
    values_from = anzahl
  ) %>%
  janitor::clean_names() %>%
  dplyr::rename(
    "anzahl_beschaeftigte" = "anzahl_personen_am_31_12"
  )
ds$cleaned_data

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping and map the spatial units
#   input:  ds$cleaned_data
#.  output: ds$postgres_export
# -------------------------------------------------------------------------

spatial_map <- ds$cleaned_data %>%
  dplyr::select(grossregion_kanton) %>%
  dplyr::distinct(grossregion_kanton) %>%
  map_ds_spatial_units()

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_map, by = "grossregion_kanton") %>%
  dplyr::select(-grossregion_kanton)

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