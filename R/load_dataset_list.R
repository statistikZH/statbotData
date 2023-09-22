#' load dataset list
#'
#' loads the list of datasets from a csv file
#'
#' @return dataset_list list of datasets in the csv file
#' @export
load_dataset_list <- function() {
  dataset_list_path <- here::here("data", "const", "statbot_input_data.csv")
  dataset_list <- readr::read_csv(dataset_list_path)
  return(dataset_list)
}
