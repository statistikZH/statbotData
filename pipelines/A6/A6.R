# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds as dataset class
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A6")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  dplyr::mutate(
    spatialunit_uid = spatial_mapping_country()
  ) %>%
  janitor::clean_names(
  ) %>%
  dplyr::filter(
    startsWith(periode, "Jahr:")
  ) %>%
  dplyr::rename(
    jahr = periode
  ) %>%
  dplyr::rename(
    "anzahl_abstimmungsvorlagen" = volksabstimmungen_anzahl_vorlagen_nach_thema_seit_1971,
    "thema" = abstimmungsvorlage_thema
  ) %>%
  dplyr::mutate(
    jahr = as.numeric(stringr::str_extract(jahr, "\\d+"))
  )
ds$postgres_export
