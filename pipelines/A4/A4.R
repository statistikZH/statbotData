# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A4")
ds <- download_data(ds)
ds$data

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  tibble::as_tibble() %>%
  dplyr::filter(
    !stringr::str_starts(Rubrik, "Energieumwandlung")
  ) %>%
  dplyr::filter(
    !stringr::str_starts(Rubrik, "Statistische Differenz")
  ) %>%
  janitor::clean_names() %>%
  dplyr::mutate(
    spatialunit_uid = spatial_mapping_country()
  ) %>%
  dplyr::rename(
    "verbrauchsart" = rubrik,
    "anzahl" = tj
  ) %>% tidyr::pivot_wider(
    names_from = c("verbrauchsart"),
    values_from = anzahl,
    names_prefix = "terajoule_"
  ) %>%
  janitor::clean_names() %>%
  dplyr::rename(
    terajoule_verbrauch_energiesektor_netzverluste_speicherungen = terajoule_eigenverbrauch_des_energiesektors_netzverluste_verbrauch_der_speicherungen,
    terajoule_endverbrauch_statistische_differenz_landwirtschaft = terajoule_endverbrauch_statistische_differenz_inkl_landwirtschaft
  )
ds$postgres_export

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package
# stabotData to upload the dataset to postgres, testrun the queries,
# generate a sample upload the metadata, etc
# -------------------------------------------------------------------------

# create the table in postgres
statbotData::create_postgres_table(ds)
# add metadata to postgres
statbotData::update_metadata_in_postgres(ds)
# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)
# testrun queries
statbotData::testrun_queries(ds)
