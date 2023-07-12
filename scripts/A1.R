### create ds object
ds <- create_dataset(id = "A1")

ds <- download_data(ds)

### read in the spatial dataframe

spatial_unit_df <- readr::read_csv("data/const/spatial_unit_postgres.csv")

### clean data and prepare merge of spatial units
ds$data %>%
  janitor::clean_names() %>%
  dplyr::mutate(
    spatialunit_ontology = dplyr::case_when(
      stringr::str_detect(grossregion_kanton, "^-") ~ "Canton",
      grossregion_kanton == "Schweiz" ~ "Country",
      TRUE ~ grossregion_kanton
    )
  ) %>%
  dplyr::filter(!stringr::str_detect(grossregion_kanton, '<<')) %>%
  dplyr::mutate(grossregion_kanton = stringr::str_replace(grossregion_kanton, "^-", "")) %>%
  dplyr::mutate(grossregion_kanton = stringr::str_trim(grossregion_kanton)) -> ds$data


ds$data %>%
  dplyr::mutate(grossregion_kanton = dplyr::case_when(
    spatialunit_ontology == "Canton" ~ paste0("Kanton ", grossregion_kanton),
    TRUE ~ grossregion_kanton
  )) -> ds$data

### map the spatial units


spatial_unit_df %>%
  dplyr::filter(spatialunit_ontology %in% c("Canton", "Country")) %>%
  dplyr::distinct(name_de, name, name_fr, name_it) %>%
  print(n = 27)

ds$data %>%
  dplyr::distinct(grossregion_kanton) %>%
  print(n = 27)


# Define a mapping between French/Italian names and German names
name_mapping <- data.frame(
  grossregion_kanton = c("Vaud", "Ticino", "Genève", "Valais / Wallis", "Bern / Berne", "Fribourg / Freiburg", "Graubünden / Grigioni / Grischun"),
  name_de = c("Kanton Waadt", "Kanton Tessin", "Kanton Genf", "Kanton Wallis", "Kanton Bern", "Kanton Freiburg", "Kanton Graubünden")
)

# Replace the names in grossregion_kanton using the mapping
test_df <- test_df %>%
  dplyr::left_join(name_mapping, by = "grossregion_kanton") %>%
  dplyr::mutate(grossregion_kanton = ifelse(spatialunit_ontology == 'Canton' & !is.na(name_de), name_de, grossregion_kanton)) %>%
  dplyr::select(-name_de)



