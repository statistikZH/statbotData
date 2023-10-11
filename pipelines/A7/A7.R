# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A7")
ds <- download_data(ds)
ds

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
ds$postgres_export

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package stabotData
# to upload the dataset to postgres, testrun the queries, generate a sample
# upload the metadata, etc
# -------------------------------------------------------------------------

# create the table in postgres
statbotData::create_postgres_table(ds)
# copy the metadata templates to the metadata files and then complete them
statbotData::read_metadata_tables_from_file(ds)

statbotData::update_metadata_in_postgres(ds)
# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)
