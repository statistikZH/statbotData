# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::::create_dataset("A27")
ds <- statbotData::::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::select(-bfs_nr_gemeinde) %>%
  dplyr::rename_at(
    dplyr::vars(-jahr, -gemeinde_name, -einwohner),
    ~ paste0(.x, "_gwh")
  )

# Use 0 instead of NA to state that no energy was produced
ds$postgres_export <- ds$postgres_export %>%
  mutate(across(ends_with("_gwh"), ~ ifelse(is.na(.x), 0, .x)))
# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Merge with spatialunits to get a uid for each municipality
spatial_mapping <- ds$postgres_export %>%
  dplyr::select(gemeinde_name, jahr) %>%
  dplyr::distinct(gemeinde_name, jahr) %>%
  dplyr::mutate(canton = "TG") %>%
  statbotData::map_ds_municipalities(
    year = jahr,
    canton_abbr = canton,
    municipality_name = gemeinde_name
  ) %>%
  dplyr::select(gemeinde_name, jahr, spatialunit_uid) %>%
  dplyr::mutate(jahr = lubridate::year(jahr))


ds$postgres_export <- ds$postgres_export %>%
  dplyr::left_join(spatial_mapping, by = c("gemeinde_name", "jahr")) %>%
  dplyr::filter(!is.na(spatialunit_uid)) %>%
  dplyr::select(-gemeinde_name) %>%
  janitor::clean_names()
