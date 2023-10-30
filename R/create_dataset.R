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
  datasets <- load_dataset_list()
  # turn the pipeline row into a list
  dataset <- datasets %>%
    dplyr::filter(data_indicator == id)
  ds_as_list <- as.list(dataset[1, ])
  ds_as_list$dir <- here::here("pipelines", ds_as_list$data_indicator)
  if (ds_as_list$status %in% c("remote", "uploaded")) {
    ds_as_list$db_instance <- "postgres"
  } else {
    ds_as_list$db_instance <- "test"
  }

  # define the ds class
  ds_class <- structure(
    ds_as_list,
    data = NULL,
    class = c(
      ds_as_list$organization,
      ds_as_list$format,
      ds_as_list$id
    )
  )
  return(ds_class)
}
