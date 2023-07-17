#' Get Closest Matches for Non-matched Spatial Units
#'
#' This function returns the closest matches from a list of non-matched spatial units,
#' where the matches are sought across multiple name columns of a spatial units data frame.
#'
#' @param non_matched_list A named list of character vectors, where each vector contains the names
#' of non-matched spatial units for a particular spatial unit ontology.
#' The names of the list elements are the spatial unit ontologies.
#' @param spatial_units A data frame containing the spatial units information,
#' where each row is a spatial unit and there are columns for the name of the spatial unit
#' in multiple languages (name, name_de, name_fr, name_it).
#'
#' @return A named list where each element is a character vector containing the closest matches
#' for the non-matched elements in the corresponding list element of `non_matched_list`.
#' The names of the list elements are the spatial unit ontologies.
#'
#' @examples
#' \dontrun{
#' # Assume non_matched_list is the list returned by the get_non_matched_elements function
#' # and spatial_units is your spatial units data frame
#' closest_matches_list <- get_closest_matches(non_matched_list, spatial_units)
#' }
#'
#' @export
get_closest_matches <- function(non_matched_list, spatial_units) {
  # Function to find closest match from multiple columns
  find_closest_match <- function(x, columns) {
    distances <- sapply(columns, function(column) {
      stringdist::stringdistmatrix(x, column, method = "jw")
    })
    closest_match <- columns[which.min(distances)]
    return(closest_match)
  }

  # Function to get closest matches for a data frame of non-matched elements
  get_closest_matches_for_df <- function(non_matched_df) {
    closest_matches <- sapply(non_matched_df$grossregion_kanton, function(x) {
      find_closest_match(x, c(spatial_units$name, spatial_units$name_de, spatial_units$name_fr, spatial_units$name_it))
    })
    return(closest_matches)
  }

  # Use purrr::map to get closest matches for each list element
  closest_matches_list <- purrr::map(non_matched_list, get_closest_matches_for_df)

  # Set names of the list elements as the names of the non-matched list elements
  names(closest_matches_list) <- names(non_matched_list)

  return(closest_matches_list)
}
