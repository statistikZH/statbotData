#' Map spatial units in the observations
#'
#' This function expects a tibble with the distinct spatial values of the
#' dataset in this column.
#'
#' The idea is to find matches for these spatial values in a reduced dataframe
#' this dataframe is then returned with spatial matches and can be joined
#' with the dataset in order to transfer the match making to the dataset
#'
#' In order to keep that function general: the pattern_function and the
#' match_function can be provided.
#'
#' The spatial_dimensions should given in order to allow for filtering
#' of spatialunit_ontologies. The default is Canton and Country.
#'
#' WARNING:
#' For every new spatial mapping the function has to be run and the output
#' needs to be checked for a correct mapping. The function works fine for
#' BFS Stattab Canton and Country level, but has not yet been used for other
#' levels: for exmaple on the level of municipalities there might be adjustments
#' needed, as there are municipalities in different cantons that have the same
#' name.
#'
#' @param df_spatial tibble that has just one colunm with all the distinct
#'                   spatial values of the dataset
#' @param spatial_dimensions a vector of values for spatialunit_ontology
#'                           default: "Canton" and "Country"
#' @param pattern_function function to make a pattern for detecting
#'                         the spatial unit, default stattab_make_pattern
#'                         as an example
#' @param match_function function to detect the pattern in the spatial units
#'                       of the dataset, default stattab_find_match
#'                       as an example
#'
#' @return df_spatial tibble that contains a mapping of the spatial units
#'                    to spatialunit_uid and the name of the spatial unit
#' @export
#'
#' @examples map_ds_spatial_units(df_spatial)
#' \dontrun{
#'   # df_spatial should be a tibble with just one column that contains
#'   # spatial values that are all distinct
#'   df_spatial <- map_ds_spatial_units(df_spatial)
#' }
map_ds_spatial_units <- function(
    df_spatial,
    spatial_dimensions = c("Canton", "Country"),
    pattern_function = stattab_make_pattern,
    match_function = stattab_find_match
) {
  # read file with spatial units and prepare tibble
  map_df <- load_spatial_map()
  map_df <- filter_and_add_pattern(
    map_df,
    spatial_dimensions = spatial_dimensions,
    pattern_function = pattern_function
  )
  spatial_units_list <- map_df$spatialunit_uid
  names(spatial_units_list) <- map_df$spatialunit_pattern

  # remember input columns name
  colnames_input <- colnames(df_spatial)
  colnames(df_spatial) <- "spatial_value"
  # check there is just one spatial column
  assertthat::assert_that(dim(df_spatial)[2] == 1)
  assertthat::assert_that(dim(df_spatial)[1] == length(
    unique(df_spatial$spatial_value)))

  # make the matches with the input data frame
  df_spatial %>%
    dplyr::mutate(spatialunit_uid = map_spatial(
      spatial_value,
      spatial_units_list = spatial_units_list,
      match_function = match_function)) -> df_spatial
  # move stored input column name back to dataframe
  colnames(df_spatial) <- c(colnames_input, "spatialunit_uid")
  return(df_spatial)
}

#' Filter and add a pattern out of the names of the spatial unit
#'
#' Filter the spatial units by their spatial ontology values and
#' add a pattern from the name and its translations
#'
#' @param pattern_function function to make a pattern for detecting
#'                         the spatial unit, default stattab_make_pattern
#'                         as an example
#'
#' @param spatial_dimensions a vector of values for spatialunit_ontology
#'
#' @return spatial_unit_df a tibble with spatial units of the given
#'                         spacial_ontologies with a column added for the pattern
#' @export
#'
#' @examples
#' \dontrun{
#' # get a tibble with the spatial units on the levels country and canton
#' df_spatial <- filter_and_add_pattern(map_df, c("Country", "Canton"))
#' }
filter_and_add_pattern <- function(
    map_df,
    spatial_dimensions,
    pattern_function)
  {
  map_df %>%
    dplyr::select(
      spatialunit_ontology, spatialunit_uid, name, name_fr, name_it, name_de
    ) %>%
    dplyr::filter(
      spatialunit_ontology %in% spatial_dimensions
    ) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      spatialunit_pattern = pattern_function(name, name_de, name_fr, name_it)
    ) -> spatial_unit_df
  return(spatial_unit_df)
}

#' Title
#'
#' @param term term that should be matched
#' @param spatial_units_list list of spatial units: names are the pattern
#'                           used for the matching and values are the spatial
#'                           uids that the terms should be matched to
#' @param match_function function to detect the pattern in the spatial units
#'                       of the dataset, default stattab_find_match
#'                       as an example
#'
#' @return spatial_code if match was found otherwise blank
#' @export
#'
#' @examples
#' \dontrun{
#'   # df_spatial should be a tibble with just one column that contains
#'   # spatial values that are all distinct
#'   spatialunit_uid <- ("Zug",
#'                       spatial_units_list
#'                       stattab_find_match)
#' }
map_spatial <- function(
    term, spatial_units_list,
    match_function = stattab_find_match
) {
  spatial_code <- lapply(term,
                         FUN=match_function,
                         spatial_units_list = spatial_units_list) %>% unlist()
  return(spatial_code)
}


#' Stattab pattern making
#'
#' The function makes a pattern to detect a spatial unit
#' by cleaning all translations and combining them into
#' a comma separated string. This functions has to correspond to
#' the pattern detection function: stattab_find_match
#'
#' @param name name of the spatial unit
#' @param name_de german translation
#' @param name_fr french translation
#' @param name_it italian translation
#'
#' @return pattern that is used for the match making
#' @export
#'
#' @examples
#' \dontrun{
#'   # Assume non_matched_list is the list returned by the get_non_matched_elements function
#'   # and spatial_units is your spatial units data frame
#'   stattab_make_pattern("Canton of Basel-Stadt","Kanton Basel-Stadt",
#'                        "Canton de Bâle-Ville","Cantone di Basilea Città")
#'   # returns: "basel_stadt,bale_ville,basilea_citta"
#' }
#'
stattab_make_pattern <- function(name, name_de, name_fr, name_it) {
  name <- stringr::str_replace(name, "Canton (of )?", "") %>% janitor::make_clean_names()
  name_it <- stringr::str_replace(name_it, "Canton(e)? (di )?", "") %>% janitor::make_clean_names()
  name_de <- stringr::str_replace(name_de, "Kanton ", "") %>% janitor::make_clean_names()
  name_fr <- stringr::str_replace(name_fr, "Canton (du |de |d'| des )?", "") %>% janitor::make_clean_names()
  names <- unique(c(name, name_it, name_de, name_fr))
  pattern <- paste(names, collapse = ",")
  return(pattern)
}

#' Stattab find match
#'
#' The functions finds a map for a spatial term considering a given map
#' of pattern and matching targets
#'
#' @param spacial_term spatial term that should be matched
#' @param spatial_units_list list of spatialunit uid
#'                           the list is expected to be named and the names
#'                           are the pattern used for the matching
#'
#' @return match or blank if no match was found
#' @export
#'
#' @examples
#' \dontrun{
#'.  # Assume non_matched_list is the list returned by the get_non_matched_elements function
#'   # and spatial_units is your spatial units data frame
#'   match <- stattab_find_match("Basel-Stadt",
#'                               list("basel_stadt,bale_ville,basilea_citta" = "12_A.ADM1"))
#' }
stattab_find_match <- function(spacial_term, spatial_units_list) {
  spacial_patterns <- names(spatial_units_list)
  terms <- stringr::str_split_1(as.character(spacial_term), " / ") %>%
    janitor::make_clean_names()
  for (term in terms) {
    # the pattern is the term and after it either a comma or the end of the string
    pattern <- paste0(term, "(,|$){1}")
    match <- grep(pattern, spacial_patterns, value = TRUE)
    if (length(match) == 1) {
      return(spatial_units_list[[match]])
    }
  }
  return("")
}

#' Get Spatial Unit for Switzerland
#'
#' This is a very simple function to provide the spatialunit_uid for Switzerland
#' The spatial unit has to be added to tables that don't come with a spatial
#' unit
#'
#' @return spatialunit_uid_ch spatialunit_uid for Switzerland
#'
#' @export
#'
#' @examples spatial_mapping_country()
#' \dontrun{
#'   spatialunit_uid_ch <- spatial_mapping_country()
#' }
spatial_mapping_country <- function() {
  load_spatial_map() %>%
    dplyr::select(country, spatialunit_uid) %>%
    dplyr::filter(country) -> spatial_unit_df
  return(spatial_unit_df$spatialunit_uid)
}

#' Get spatialunits of municipalities.
#'
#' This function uses temporal and cantonal information to
#' unambiguously assign a uid to each municipality. It handles duplicate names in different cantons,
#' merged, renamed or split municipalities.
#'
#' @param .data A tibble containing at least columns with the year of observation, 2 letter canton abbreviations and names of municipalities.
#' @param year column containing the year of observation.
#' @param canton_abbr column containing the 2 letter abbreviation corresponding to the municipality's canton.
#' @param municipality_name column containing the names of municipalities.
#'
#' @return spatial mapping with input columns, plus valid_until, valid_from, spatialunit and name.
#' @import rlang dplyr
#' @export
#'
map_ds_municipalities <- function(.data, year, canton_abbr, municipality_name) {
  spatial_map <- load_spatial_map() %>%
    filter(municipal, !canton) %>%
    select(spatialunit_uid, name, valid_from, valid_until)
    # Fuzzy merge on date ranges
    # Municipalities with the same name in different cantons
    # are stored with (XX) where XX is the canton abbreviation
    matches <- .data %>%
      mutate(exp_name = paste0(
        {{ municipality_name }},
        paste0(" (", {{ canton_abbr }}, ")"))
      ) %>%
      mutate({{ year }} := lubridate::ymd({{ year }}, truncated=2L)) %>%
      cross_join(spatial_map) %>%
      filter(
        {{ year }} >= valid_from,
        {{ year }} <= valid_until,
        {{ municipality_name }} == name | exp_name == name
      )
  return(matches)
}

#' Get spatialunits of residential areas.
#'
#' This function uses temporal and cantonal information to
#' unambiguously assign a uid to each residential area.
#'
#' @param .data A tibble containing at least columns with the year of observation, 2 letter canton abbreviations and names of residential areas.
#' @param year column containing the year of observation.
#' @param canton_hist_id column containing the residential area canton's historical id.
#' @param residential_area_name column containing the names of residential areas.
#'
#' @return spatial mapping with input columns, plus valid_until, valid_from, spatialunit and name.
#' @import rlang dplyr
#' @export
#'
map_ds_residential_areas <- function(.data, year, canton_hist_id, residential_area_name) {
  selected_cantons <- .data %>%
    select({{ canton_hist_id }}) %>%
    distinct() %>%
    pull()
  spatial_map <- load_spatial_map() %>%
    filter(residence_area, !canton) %>%
    filter(canton_hist_id %in% selected_cantons) %>%
    select(spatialunit_uid, name, valid_from, valid_until)
    # Fuzzy merge on date ranges
    matches <- .data %>%
      mutate({{ year }} := lubridate::ymd({{ year }}, truncated=2L)) %>%
      cross_join(spatial_map) %>%
      filter(
        {{ year }} >= valid_from,
        {{ year }} <= valid_until,
        {{ residential_area_name }} == name
      )
  return(matches)
}