# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A1")


# download the data -------------------------------------------------------

ds <- download_data(ds)

# read in the spatial data ------------------------------------------------

spatial_unit_df <- readr::read_csv("data/const/spatial_unit_postgres.csv")



# data cleaning -----------------------------------------------------------

### clean spatial unit names from artificats
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


# map the spatial units to the postgres spatial units ---------------------

## find non matching spatial units per ontology level with custom function
ontologies <- c("Country", "Canton")
result <- get_non_matched_elements(spatial_unit_df, ds$data, ontologies, "name_de")



# Assume non_matched_list is the list returned by the get_non_matched_elements function and spatial_units is your spatial units data frame
closest_matches_list <- get_closest_matches(result, spatial_unit_df)




# Define a mapping between French/Italian names and German names for the non-matches
name_mapping <- data.frame(
  grossregion_kanton = c("Kanton Vaud", "Kanton Ticino", "Kanton Genève", "Kanton Valais / Wallis", "Kanton Bern / Berne", "Kanton Fribourg / Freiburg", "Kanton Graubünden / Grigioni / Grischun", "Kanton Neuchâtel"),
  name_de = c("Kanton Waadt", "Kanton Tessin", "Kanton Genf", "Kanton Wallis", "Kanton Bern", "Kanton Freiburg", "Kanton Graubünden", "Kanton Neuenburg")
)

# Replace the names in grossregion_kanton using the mapping
ds$data <- ds$data %>%
  dplyr::left_join(name_mapping, by = "grossregion_kanton") %>%
  dplyr::mutate(grossregion_kanton = ifelse(spatialunit_ontology == 'Canton' & !is.na(name_de), name_de, grossregion_kanton)) %>%
  dplyr::select(-name_de)




# join the cleaned data to the postgres spatial units table ---------------

ds$data <- ds$data %>%
  dplyr::left_join(dplyr::select(spatial_unit_df, spatialunit_uid, name_de), by = c("grossregion_kanton" = "name_de")) %>%
  dplyr::select(-grossregion_kanton)

## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)



# rename variables --------------------------------------------------------


ds$data %>%
  dplyr::rename(
    "genutzte_infrastruktur" = infrastruktur,
    "geraet_oder_untersuchung" = gerate_und_untersuchungen,
     "anzahl" = medizinisch_technische_infrastruktur_anzahl_gerate_und_untersuchungen_in_krankenhausern
  ) -> ds$data



# ingest into postgres ----------------------------------------------------


