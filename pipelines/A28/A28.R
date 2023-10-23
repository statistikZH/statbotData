# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::::create_dataset("A28")
ds <- statbotData::::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

# Missing values are denoted as ".", here we can discard them
ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::select(-bfs_nr_gemeinde) %>%
  dplyr::rename(beschaftigte_personen = beschaeftigte_personen) %>%
  dplyr::mutate(beschaftigte_personen = as.numeric(beschaftigte_personen)) %>%
  dplyr::filter(!is.na(beschaftigte_personen)) %>%
  mutate(sektor = case_when(
    sektor == 1 ~ "Primär",
    sektor == 2 ~ "Sekundär",
    sektor == 3 ~ "Tertiär",
  ))

# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Merge with spatialunits to get a uid for each municipality
spatial_mapping <- ds$postgres_export %>%
  dplyr::select(gemeinde, jahr) %>%
  dplyr::distinct(gemeinde, jahr) %>%
  dplyr::mutate(canton = "TG") %>%
  statbotData::map_ds_municipalities(
    year = jahr,
    canton_abbr = canton,
    municipality_name = gemeinde
  ) %>%
  dplyr::select(gemeinde, jahr, spatialunit_uid) %>%
  dplyr::mutate(jahr = lubridate::year(jahr))


ds$postgres_export <- ds$postgres_export %>%
  dplyr::left_join(spatial_mapping, by = c("gemeinde", "jahr")) %>%
  dplyr::filter(!is.na(spatialunit_uid)) %>%
  dplyr::select(-gemeinde) %>%
  janitor::clean_names()
