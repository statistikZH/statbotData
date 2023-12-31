# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A23")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

# The dataset has missing values represented as "" or "( )"
ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::filter(!falle %in% c("", "( )")) %>%
  dplyr::select(jahr, gemeinde, falle, flache_in_m2, quadratmeterpreis_chf) %>%
  dplyr::mutate_at(dplyr::vars(flache_in_m2, quadratmeterpreis_chf, falle), as.numeric)
# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Matching spatialunit uid to municipality/year/canton. Note that the same
# municipality can have different uid at different years (e.g. in case of
# merging/splitting municipalities).
spatial_mapping <- ds$postgres_export %>%
  dplyr::select(gemeinde, jahr) %>%
  dplyr::distinct(gemeinde, jahr) %>%
  dplyr::mutate(canton = "BL") %>%
  statbotData::map_ds_municipalities(
    year = jahr,
    canton_abbr = canton,
    municipality_name = gemeinde
  ) %>%
  dplyr::select(gemeinde, jahr, spatialunit_uid) %>%
  dplyr::mutate(jahr = lubridate::year(jahr))


# -------------------------------------------------------------------------
# Step 3 clean names and remove columns
# -------------------------------------------------------------------------

ds$postgres_export <- ds$postgres_export %>%
  dplyr::left_join(spatial_mapping, by = c("gemeinde", "jahr")) %>%
  dplyr::filter(!is.na(spatialunit_uid)) %>%
  dplyr::select(-gemeinde) %>%
  janitor::clean_names()
