# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::::create_dataset("A31")
ds <- statbotData::::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::select(-wohnviertel) %>%
  dplyr::rename(jahr = "steuerjahr")

# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Add Basel-Stadt ID explicitely
spatial_mapping <- ds$postgres_export %>%
  dplyr::select(wohnviertel_name, jahr) %>%
  dplyr::distinct(wohnviertel_name, jahr) %>%
  dplyr::mutate(canton_hist_id = 12) %>%
  statbotData::map_ds_residential_areas(
    year = jahr,
    canton_hist_id = canton_hist_id,
    residential_area_name = wohnviertel_name
  ) %>%
  dplyr::select(wohnviertel_name, jahr, spatialunit_uid) %>%
  dplyr::mutate(jahr = lubridate::year(jahr))

ds$postgres_export <- ds$postgres_export %>%
  dplyr::left_join(spatial_mapping, by = c("wohnviertel_name", "jahr")) %>%
  dplyr::filter(!is.na(spatialunit_uid)) %>%
  dplyr::select(-wohnviertel_name) %>%
  janitor::clean_names()
