# -------------------------------------------------------------------------
# Step: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset(id = "A1")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: dscleaned_data: cleaning the data before the spatial
#.                          unit mapping can be applied (removing spatial
#                           hierarchies)
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::filter(
    !stringr::str_detect(grossregion_kanton, "<<")
  ) %>%
  dplyr::rename(
    "genutzte_infrastruktur" = infrastruktur,
    "geraet_oder_untersuchung" = gerate_und_untersuchungen,
    "anzahl" = medizinisch_technische_infrastruktur_anzahl_gerate_und_untersuchungen_in_krankenhausern
  ) %>%
  tidyr::pivot_wider(
    names_from = c("geraet_oder_untersuchung"),
    values_from = anzahl,
    names_prefix = "anzahl_"
  ) %>%
  janitor::clean_names() %>%
  dplyr::rename(
    "anzahl_gerate" = anzahl_anzahl_gerate
  )

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping and map the spatial units
#   input:  ds$cleaned_data
#.  output: ds$postgres_export
# -------------------------------------------------------------------------

spatial_map <- ds$cleaned_data %>%
  dplyr::select(grossregion_kanton) %>%
  dplyr::distinct(grossregion_kanton) %>%
  statbotData::map_ds_spatial_units()

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_map, by = "grossregion_kanton") %>%
  dplyr::select(-grossregion_kanton)
