#' Map spatial level of country and cantons
#'
#' This function expects a tibble with the distinct spatial values of the
#' dataset in this column.
#'
#' The idea is to find matches for these spatial values in a reduced dataframe
#' this dataframe is then returned with spatial matches and can be joined
#' with the dataset in order to transfer the match making to the dataset
#'
#' In order to keep that function general: the pattern_function and the
#' match_function can be provided. For now the defaults are set to
#' statab_canton_country_pattern for the pattern_function and
#' stattab_country_canton_find_match for the match_function. But you can
#' provide your own such functions, in case these do not work for your case.
#'
#' So far the function only maps on the level of country and cantons. It should
#' be not to hard to adjust this function to other spatial levels
#'
#' @param df_spatial tibble that has just one colunm with all the distinct
#'                   spatial values of the dataset
#' @param pattern_function function to make a pattern for detecting
#'                         the spatial unit, default statab_canton_country_pattern
#'                         as an example
#' @param match_function function to detect the pattern in the spatial units
#'                       of the dataset, default stattab_country_canton_find_match
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
    pattern_function = statab_canton_country_pattern,
    match_function = stattab_country_canton_find_match
) {
  map_df <- map_canton_and_country(pattern_function=pattern_function)
  spatial_units_list <- map_df$spatialunit_uid
  names(spatial_units_list) <- map_df$spatialunit_pattern
  colnames_input <- colnames(df_spatial)
  colnames(df_spatial) <- "spatial_value"
  assertthat::assert_that(dim(df_spatial)[2] == 1)
  assertthat::assert_that(dim(df_spatial)[1] == length(
    unique(df_spatial$spatial_value)))
  df_spatial %>%
    dplyr::mutate(spatialunit_uid = map_spatial(
      spatial_value,
      spatial_units_list = spatial_units_list,
      match_function = stattab_country_canton_find_match)) -> df_spatial
  colnames(df_spatial) <- c(colnames_input, "spatialunit_uid")
  return(df_spatial)
}

#' Map spatial units for the level country and canton
#'
#' Currently the function filters the spatial units for the level of countries
#' and cantons. It reads in the spatial units stored in postgres from a file.
#'
#' @param pattern_function function to make a pattern for detecting
#'                         the spatial unit, default statab_canton_country_pattern
#'                         as an example
#'
#' @return spatial_unit_df a tibble with spatial units on the level
#'                         of country and canton
#' @export
#'
#' @examples
#' \dontrun{
#' # get a tibble with the spatial units on the levels country and canton
#' df_spatial <- map_canton_and_country()
#' }
map_canton_and_country <- function(pattern_function) {
  readr::read_csv("data/const/spatial_unit_postgres.csv") %>%
    dplyr::select(
      country, canton, spatialunit_uid, name, name_fr, name_it, name_de) %>%
    dplyr::filter(country | canton) %>%
    dplyr::select(spatialunit_uid, name_de, name_fr, name_it, name)  %>%
    dplyr::rowwise() %>%
    dplyr::mutate(spatialunit_pattern = pattern_function(
      name, name_de, name_fr, name_it)) %>%
    dplyr::select(spatialunit_uid, spatialunit_pattern, name) %>%
    dplyr::relocate(spatialunit_pattern) -> spatial_unit_df
  return(spatial_unit_df)
}

#' Title
#'
#' @param term term that should be matched
#' @param spatial_units_list list of spatial units: names are the pattern
#'                           used for the matching and values are the spatial
#'                           uids that the terms should be matched to
#' @param match_function function to detect the pattern in the spatial units
#'                       of the dataset, default stattab_country_canton_find_match
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
#'                       stattab_country_canton_find_match)
#' }
map_spatial <- function(
    term, spatial_units_list,
    match_function = stattab_country_canton_find_match
) {
  spatial_code <- lapply(term,
                         FUN=match_function,
                         spatial_units_list = spatial_units_list) %>% unlist()
  return(spatial_code)
}


#' Stattab country canton pattern making
#'
#' The function makes a pattern to detect a spatial unit
#' by cleaning all translations and combining them into
#' a comma separated string. This functions has to correspond to
#' the pattern detection function: stattab_country_canton_find_match
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
#'   statab_canton_country_pattern("Canton of Basel-Stadt","Kanton Basel-Stadt",
#'                                 "Canton de Bâle-Ville","Cantone di Basilea Città")
#'   # returns: "basel_stadt,bale_ville,basilea_citta"
#' }
#'
statab_canton_country_pattern <- function(name, name_de, name_fr, name_it) {
  name <- stringr::str_replace(name, "Canton (of )?", "") %>% janitor::make_clean_names()
  name_it <- stringr::str_replace(name_it, "Canton(e)? (di )?", "") %>% janitor::make_clean_names()
  name_de <- stringr::str_replace(name_de, "Kanton ", "") %>% janitor::make_clean_names()
  name_fr <- stringr::str_replace(name_fr, "Canton (du |de |d'| des )?", "") %>% janitor::make_clean_names()
  names <- unique(c(name, name_it, name_de, name_fr))
  pattern <- paste(names, collapse = ",")
  return(pattern)
}

#' Stattab country canton find match
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
#'   match <- stattab_country_canton_find_match("Basel-Stadt",
#'                                              list("basel_stadt,bale_ville,basilea_citta" = "12_A.ADM1"))
#' }
stattab_country_canton_find_match <- function(spacial_term, spatial_units_list) {
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
