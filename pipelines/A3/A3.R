# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset(id = "A3")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

# clean excel-artifacts and add "beobachtungseinheit" as well as
# spatialunit_id for switzerland
ds$postgres_export <- ds$data %>%
  tidyr::drop_na() %>%
  dplyr::rename(year = 1, quantity = 2) %>%
  dplyr::rename("emissions_in_million_tons_co2_equivalent" = quantity) %>%
  dplyr::mutate(spatialunit_uid = spatial_mapping_country()) %>%
  dplyr::mutate(emissions_in_million_tons_co2_equivalent = as.numeric(emissions_in_million_tons_co2_equivalent))
ds$postgres_export
