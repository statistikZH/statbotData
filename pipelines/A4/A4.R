# -------------------------------------------------------------------------
# Step: Get the data
# input:  google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A4")
ds <- download_data(ds)
ds$data
ds

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  tibble::as_tibble() %>%
  dplyr::filter(
    !stringr::str_starts(Rubrik, "Energieumwandlung")
  ) %>%
  dplyr::filter(
    !stringr::str_starts(Rubrik, "Statistische Differenz")
  ) %>%
  janitor::clean_names() %>%
  dplyr::mutate(
    spatialunit_uid = spatial_mapping_country()
  ) %>%
  dplyr::rename(
    "verbrauchsart" = rubrik,
    "anzahl" = tj
  ) %>% tidyr::pivot_wider(
    names_from = c("verbrauchsart"),
    values_from = anzahl,
    names_prefix = "terajoule_"
  ) %>%
  janitor::clean_names()
colnames(ds$postgres_export)

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

