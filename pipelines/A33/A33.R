# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A33")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::select(
    jahr,
    gemeinde_name,
    geschlecht,
    nationalitaet_bezeichnung,
    anzahl_personen
  ) %>%
  dplyr::rename(
    nationalitaet = "nationalitaet_bezeichnung",
  )

# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Merge with spatialunits to get a uid for each municipality
spatial_mapping <- ds$postgres_export %>%
  dplyr::select(gemeinde_name, jahr) %>%
  dplyr::distinct(gemeinde_name, jahr) %>%
  dplyr::mutate(canton = "BS") %>%
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
