# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A3")


# download the data -------------------------------------------------------

ds <- download_data(ds)

# read in the spatial data ------------------------------------------------

spatial_unit_df <- readr::read_csv("data/const/spatial_unit_postgres.csv")


# data cleaning -----------------------------------------------------------

## clean excel-artifacts and add "beobachtungseinheit" as well as spatialunit_id for switzerland
ds$data %>%
  tidyr::drop_na() %>%
  dplyr::rename(jahr = 1, anzahl = 2) %>%
  dplyr::mutate(spatialunit_uid = spatial_mapping_country()) -> ds$data


# ingest into postgres ----------------------------------------------------

# Important for this DS: Name the table: "treibhausgasemission_in_mio_tonnen"
