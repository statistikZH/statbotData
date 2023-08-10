library(magrittr)
# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A15")


# download the data -------------------------------------------------------

# Might take 1 - 5 minutes
ds <- download_data(ds)

# data cleaning -----------------------------------------------------------

# Filter relevant factors and cleanup
ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  tibble::as_tibble() %>%
  dplyr::filter(
    area_of_agricultural_production == "Area - total" &
      farmholding_form == "Farmholding form - total"
  ) %>%
  dplyr::select(-area_of_agricultural_production, -farmholding_form) %>%
  dplyr::mutate(year = as.numeric(as.character(year)))

# Exclude years before 1996, as they use a different agricultural classification
# and numbers are not comparable
ds$postgres_export %<>%
  dplyr::filter(year >= 1996)


# Pivot on observation type
ds$postgres_export %<>%
  tidyr::pivot_wider(
    names_from = observation_unit,
    values_from = data_farmholding_employee_ha_animal
  ) %>%
  janitor::clean_names()

# Ensure clear column names
ds$postgres_export %<>%
  dplyr::rename(
    size_class_utilised_agricultural_area_ha = "size_class_uaa"
  )

# join the cleaned data to the postgres spatial units table ---------------

spatial_map <- ds$postgres %>%
  dplyr::select(canton) %>%
  dplyr::distinct(canton) %>%
  map_ds_spatial_units()

ds$postgres %<>%
  dplyr::left_join(spatial_map, by = "canton") %>%
  dplyr::select(-canton) -> ds$data

## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)


# ingest into postgres ----------------------------------------------------

### important: name the table as energiebilanz_schweiz_in_tera_joule
