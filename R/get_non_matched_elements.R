#' Get Non-Matched Elements for Each Spatial Unit Ontology
#'
#' This function returns a list of data frames containing the non-matched elements for each specified spatial unit ontology.
#' Non-matched elements are identified by comparing the 'grossregion_kanton' column of the 'ds_data' data frame
#' with the specified column of the 'spatial_units' data frame for each spatial unit ontology.
#'
#' @param spatial_units A data frame containing spatial unit data.
#' @param ds_data A data frame containing the data to be matched.
#' @param spatial_unit_ontologies A character vector specifying the spatial unit ontologies to be considered.
#' @param spatial_units_col A string specifying the column in the 'spatial_units' data frame to look for matches.
#'
#' @return A named list of data frames. Each list element corresponds to a spatial unit ontology and contains the non-matched elements for that ontology.
#' The names of the list elements are the spatial unit ontologies.
#'
#' @examples
#' \dontrun{
#'   # Assume spatial_units and ds_data are your data frames, you're interested in 'Country' and 'Canton', and you want to look for matches in the 'name_de' column
#'   ontologies <- c("Country", "Canton")
#'   result <- get_non_matched_elements(spatial_units, ds_data, ontologies, "name_de")
#' }
#'
#' @export
#'
get_non_matched_elements <- function(spatial_units, ds_data, spatial_unit_ontologies, spatial_units_col) {
  # Function to get non-matched elements for a specific spatial unit ontology
  get_non_matched_for_ontology <- function(spatial_unit_ontology) {
    # Get distinct elements for the specific spatial unit ontology
    distinct_ds <- ds_data %>%
      dplyr::filter(spatialunit_ontology == spatial_unit_ontology) %>%
      dplyr::distinct(grossregion_kanton)

    distinct_spatial_units <- spatial_units %>%
      dplyr::filter(spatialunit_ontology == spatial_unit_ontology) %>%
      dplyr::distinct(.data[[spatial_units_col]])

    # Get non-matched elements
    non_matched <- distinct_ds %>%
      dplyr::anti_join(distinct_spatial_units, by = c("grossregion_kanton" = spatial_units_col))

    return(non_matched)
  }

  # Use purrr::map to get non-matched elements for each spatial unit ontology
  non_matched_list <- purrr::map(spatial_unit_ontologies, get_non_matched_for_ontology)

  # Set names of the list elements as the spatial unit ontologies
  names(non_matched_list) <- spatial_unit_ontologies

  return(non_matched_list)
}
