# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds as dataset class
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A8")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: ds$cleaned_data: separate data by units
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::rename(
    "anzahl" = nationalratswahlen_parteistimmen_fiktive_wahlende_und_parteistarke_seit_1971_schweiz_und_kantone
  ) %>%
  tidyr::pivot_wider(
    names_from = c("ergebnisse"),
    values_from = anzahl
  ) %>%
  janitor::clean_names(
  ) %>%
  dplyr::rename(
    "parteistarke_in_prozent" = parteistarke_in_percent,
    "anzahl_parteistimmen" = parteistimmen,
    "anzahl_fiktive_wahlende" = fiktive_wahlende,
  )

# -------------------------------------------------------------------------
# Step: Spatial unit mapping
#   input:  ds$cleaned_data
#.  output: ds$postgres_export
# --------------------------------------------------------------------------

spatial_mapping <- ds$cleaned_data %>%
  dplyr::select(kanton) %>%
  dplyr::distinct(kanton) %>%
  statbotData::::map_ds_spatial_units(c("Country", "Canton"))

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_mapping, by = "kanton") %>%
  dplyr::select(-c(kanton))
