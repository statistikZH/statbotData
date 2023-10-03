# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds as dataset class
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A10")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Map Crminal offences to categories
#   input:  ds$data
#.  output: dsoffences
# -------------------------------------------------------------------------

df_offences_and_categories <- ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::select(
    c(straftat)
  ) %>% dplyr::distinct(
    straftat
  )

# Regular expression pattern to match the crime codes
pattern_offence <- "\\(Art\\. (\\d+)"
pattern_category_offence <- "^Total"

df_offence_mapping <- df_offences_and_categories %>%
  dplyr::filter(grepl(pattern_offence, straftat)) %>%
  dplyr::mutate(kategorie = "")

# Iterate through the crime vector to create the mapping
offence_mapping <- list()
categorie <- NULL
for (offence in rev(df_offences_and_categories$straftat)) {
  if (grepl("^Total", offence)) {
    category <- offence %>% stringr::str_remove("^Total [:digit:]*\\.[:blank:]Titel:[:blank:]")
  } else if (grepl(pattern_offence, offence)) {
    offence_mapping[[offence]] <- category
  }
}

# Fill the 'titel' column in the tibble based on the mapping
for (i in seq_along(df_offence_mapping$straftat)) {
  mapping_key <- df_offence_mapping$straftat[i]
  if (mapping_key %in% names(offence_mapping)) {
    df_offence_mapping$kategorie[i] <- offence_mapping[[mapping_key]]
  }
}
df_offence_mapping

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data, df_offence_mapping
#.  output: ds$cleaned_data
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::filter(
    !stringr::str_starts(straftat, "Total")
  ) %>%
  dplyr::rename(
    "anzahl" = polizeilich_registrierte_straftaten_gemass_strafgesetzbuch
  ) %>%
  dplyr::left_join(df_offence_mapping, by = "straftat") %>%
  tidyr::pivot_wider(
    names_from = c("ausfuhrungsgrad", "aufklarungsgrad"),
    values_from = anzahl,
    names_prefix = "anzahl_straftaten"
  ) %>%
  janitor::clean_names() %>%
  dplyr::rename(
    anzahl_straftaten = anzahl_straftaten_ausfuhrungsgrad_total_aufklarungsgrad_total,
    anzahl_straftaten_unaufgeklaert = anzahl_straftaten_ausfuhrungsgrad_total_unaufgeklart,
    anzahl_straftaten_aufgeklaert = anzahl_straftaten_ausfuhrungsgrad_total_aufgeklart,
    anzahl_straftaten_vollendet = anzahl_straftaten_vollendet_aufklarungsgrad_total,
    anzahl_straftaten_vollendet_unaufgeklart = anzahl_straftaten_vollendet_unaufgeklart,
    anzahl_straftaten_vollendet_aufgeklart = anzahl_straftaten_vollendet_aufgeklart,
    anzahl_straftaten_versucht = anzahl_straftaten_versucht_aufklarungsgrad_total,
    anzahl_straftaten_versucht_unaufgeklart = anzahl_straftaten_versucht_unaufgeklart,
    anzahl_straftaten_versucht_aufgeklart = anzahl_straftaten_versucht_aufgeklart
  )
ds$cleaned_data

# -------------------------------------------------------------------------
# Step: Spatial unit mapping
#   input:  ds$cleaned_data
#.  output: ds$postgres_export
# --------------------------------------------------------------------------

spatial_mapping <- ds$cleaned_data %>%
  dplyr::select(kanton) %>%
  dplyr::distinct(kanton) %>%
  statbotData::map_ds_spatial_units(c("Country", "Canton"))

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_mapping, by = "kanton") %>%
  dplyr::select(-c(kanton))
ds$postgres_export

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package stabotData
# to upload the dataset to postgres, testrun the queries, generate a sample
# upload the metadata, etc
# -------------------------------------------------------------------------

# testrun queries
statbotData::testrun_queries(ds)

# create the table in postgres
statbotData::create_postgres_table(ds)

# add the metadata to postgres
statbotData::update_metadata_in_postgres(ds)

# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)

