# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A4")


# download the data -------------------------------------------------------

ds <- download_data(ds)

# read in the spatial data ------------------------------------------------

spatial_unit_df <- readr::read_csv("data/const/spatial_unit_postgres.csv")

# data cleaning -----------------------------------------------------------

### add spatial unit column "Switzerland"
ds$data %>%
  janitor::clean_names() %>%
  tibble::as_tibble() %>%
  dplyr::rename(
    "verbrauchsart" = rubrik,
    "anzahl" = tj
  ) -> ds$data

# join the cleaned data to the postgres spatial units table ---------------

ds$data <- ds$data %>%
  dplyr::mutate(spatialunit_uid = spatial_mapping_country())

## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)

### widen data

ds$data %>%
  tidyr::pivot_wider(
    names_from = c("verbrauchsart"),
    values_from = anzahl,
    names_prefix = "terajoule_"
  ) %>%
  janitor::clean_names() -> ds$data

# ingest into postgres ----------------------------------------------------

### important: name the table as energiebilanz_schweiz_in_tera_joule
