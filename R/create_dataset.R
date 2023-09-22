#' Create a pipeline
#'
#' Creates a dataset object for the statbot datasets
#'
#' A dataset object needs to be created for the download, the computation
#' as well as the publishing process
#'
#' A dataset object inherits the following classes:
#' - data_organization -> needed for the download process
#' - dataset_id -> needed for the download as well as the publishing process
#' - download_format -> needed for the download process
#'
#' @param id id of the dataset
#'
#' @return ds_class class containing dataset with attributes
#'
#' @family Datensatz erstellen
#'
#' @export
create_dataset <- function(id) {

  # the sheet is expected as a list in order to turn the row of the pipeline into a list
  datasets <- load_dataset_list()

  # turn the pipeline row into a list
  ds_list <- datasets %>%
    dplyr::filter(data_indicator == id) %>%
    dplyr::mutate(sheet = as.list(sheet)) %>%
    as.list()
  ds_list$dir <- here::here("pipelines", ds_list$data_indicator, "")

  # define the ds class
  ds_class <- structure(
    ds_list,
    data = NULL,
    class = c(ds_list$organization,
              ds_list$format,
              ds_list$id)
  )
  return(ds_class)
}
