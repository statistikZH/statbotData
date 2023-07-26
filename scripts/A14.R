# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A14")


# download the data -------------------------------------------------------

ds <- download_data(ds)

# data cleaning -----------------------------------------------------------

global_products <- c(
  "Share of tourism of the regional total (in %)",
  "Total of tourism of the economy"
)

indicators <- c(
  "Tourism-connected gross value added (at current prices, in million CHF)",
  "Tourism-related employment (FTE)"
)

# Filter relevant factors and cleanup
ds$data <- ds$data %>%
  janitor::clean_names() %>%
  tibble::as_tibble() %>%
  dplyr::filter(product %in% global_products) %>%
  dplyr::filter(indicator %in% indicators) %>%
  dplyr::rename(
    "value" = regional_indicators_of_the_tourism_satellite_accounts
  )

# Pivot to separate employment from CHF values
ds$data <- ds$data %>%
  tidyr::pivot_wider(names_from = indicator, values_from = value) %>%
  dplyr::rename(
    gross_value_added = "Tourism-connected gross value added (at current prices, in million CHF)",
    employment = "Tourism-related employment (FTE)"
  )

# Pivot again to separate total from percentage
ds$data <- ds$data %>%
  tidyr::pivot_wider(
    values_from = c(gross_value_added, employment),
    names_from = product,
  ) %>%
  janitor::clean_names()

# Ensure clear column names
ds$data <- ds$data %>%
  dplyr::rename(
    "mio_chf_gross_value_added_of_tourism" = gross_value_added_total_of_tourism_of_the_economy,
    "total_full_time_employment_of_tourism" = employment_total_of_tourism_of_the_economy,
    "percent_share_gross_value_added_of_tourism" = gross_value_added_share_of_tourism_of_the_regional_total_in_percent,
    "percent_share_full_time_employment_of_tourism" = employment_share_of_tourism_of_the_regional_total_in_percent
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
