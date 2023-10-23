# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset(id = "A5")
ds <- statbotData::download_data(ds)
ds$data

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::mutate(
    spatialunit_uid = spatial_mapping_country()
  ) %>%
  dplyr::rename(
    "anzahl" = anzahl_ahv_renten_rentensumme_und_mittelwert_im_dezember
  ) %>%
  tidyr::pivot_wider(
    names_from = c("beobachtungseinheit"),
    values_from = anzahl
  ) %>%
  janitor::clean_names()
ds$postgres_export
