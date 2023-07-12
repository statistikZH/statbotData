### test pipeline
test_ds <- create_dataset(id = "A1")

download_data(test_ds) -> test_ds

### clean data and merge spatial units
test_ds$data %>%
  janitor::clean_names() %>%
  dplyr::mutate(
    spatialunit_ontology = dplyr::case_when(
      stringr::str_detect(grossregion_kanton, "^-") ~ "Canton", # cantons start with "-"
      grossregion_kanton == "Schweiz" ~ "Country",     # country is "Schweiz"
      TRUE ~ grossregion_kanton                      # keep other values as they are
    )
  ) %>%
  dplyr::filter(!stringr::str_detect(grossregion_kanton, '<<')) %>%
  dplyr::mutate(grossregion_kanton = stringr::str_replace(grossregion_kanton, "^-", "")) %>%
  dplyr::mutate(grossregion_kanton = stringr::str_trim(grossregion_kanton)) -> test_ds$data


spatial_unit_df


BFS::bfs_get_metadata(number_bfs = "px-x-1404010100_101", language = "de") %>%
  str()



### some function for mapping




spatial_unit_df <- readr::read_csv("~/Documents/phillipp/spatial_unit_202307121126.csv")

spatial_unit_df %>%
  dplyr::filter(spatialunit_ontology == "Canton") %>%
  dplyr::distinct(name_de) %>%
  print(n = 27)

test_ds$data %>%
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

# Now perform the join
joined_df <- dplyr::left_join(test_df, spatial_unit_df, by = c("grossregion_kanton" = "name_de", "spatialunit_ontology" = "spatialunit_ontology"))

find_closest_match <- function(data, spatial_unit_df, level_col, name_col_data, name_col_spatial) {
  # Initialize a list to store the closest match for each level
  closest_match <- list()

  # Get unique levels
  levels <- unique(data[[level_col]])

  for (level in levels) {
    # Subset data and spatial_unit_df for the current level
    data_level <- dplyr::filter(data, !!rlang::sym(level_col) == level)
    spatial_level <- dplyr::filter(spatial_unit_df, !!rlang::sym(level_col) == level)

    # Get unique names in data_level
    unique_names <- dplyr::distinct(data_level, !!rlang::sym(name_col_data))
    browser()
    # Find the closest match for each name in unique_names
    closest <- stringdist::amatch(unique_names[[name_col_data]], spatial_level[[name_col_spatial]], maxDist = 3)

    # Create a dataframe with the original name and its closest match
    closest_df <- data.frame(original_name = unique_names[[name_col_data]], closest_match = spatial_level[[name_col_spatial]][closest])

    # Add the closest match dataframe to the closest_match list
    closest_match[[level]] <- closest_df
  }

  closest_match
}

# Example usage
closest_matches <- find_closest_match(test_ds$data, spatial_unit_df_test, "spatialunit_ontology", "grossregion_kanton", "name_de")

