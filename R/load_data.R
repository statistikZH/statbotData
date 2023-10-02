#' load dataset list
#'
#' loads the list of datasets from a csv file
#'
#' @return dataset_list list of datasets in the csv file
#' @export
load_dataset_list <- function() {
  dataset_list_path <- here::here("data", "const", "statbot_input_data.csv")
  dataset_list <- readr::read_csv(dataset_list_path, show_col_types = FALSE)
  return(dataset_list)
}

#' Load spatial units from file
#'
#' @return spatial_map spatial units as a tibble
#' @export
load_spatial_map <- function() {
  spatial_unit_path <- here::here("data", "const", "spatial_unit_postgres.csv")
  spatial_map <- readr::read_csv(spatial_unit_path, show_col_types = FALSE)
  return(spatial_map)
}
