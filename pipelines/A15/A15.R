# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A15")


# download the data -------------------------------------------------------

ds <- download_data(ds)

# data cleaning -----------------------------------------------------------

# Filter relevant factors and cleanup
ds$data <- ds$data %>%
  janitor::clean_names() %>%
  tibble::as_tibble() %>%
  dplyr::filter(...) %>%

# Pivot 
ds$data <- ds$data %>%
  tidyr::pivot_wider(names_from = ..., values_from = ...) %>%
  dplyr::rename(
                ...
  )


# Ensure clear column names
ds$data <- ds$data %>%
  dplyr::rename(
    ...
  )

# join the cleaned data to the postgres spatial units table ---------------

spatial_map <- ds$data %>%
  dplyr::select(canton) %>%
  dplyr::distinct(canton) %>%
  map_ds_spatial_units()

ds$data %>%
  dplyr::left_join(spatial_map, by = "canton") %>%
  dplyr::select(-canton) -> ds$data

## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)


# ingest into postgres ----------------------------------------------------

### important: name the table as energiebilanz_schweiz_in_tera_joule
