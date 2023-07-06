#' Title
#'
#' @return
#' @export
#'
#' @examples
#' creates a dataset object for the statbot datasets
#'
#' A dataset object needs to be created for the download, the computation
#' as well as the publishing process
#'
#' A dataset object inherits the following classes:
#' - data_organization -> needed for the download process
#' - dataset_id -> needed for the download as well as the publishing process
#' - download_format -> needed for the download process
#'
#' @param dataset_id id of the dataset
#'
#'
#' @return list containing dataset-objects
#'
#' @family Datensatz erstellen
#'
#' @export
create_dataset <- function(id) {

  googlesheets4::gs4_deauth()

  googlesheets4::read_sheet(ss = "https://docs.google.com/spreadsheets/d/11V8Qj4v21MleMk_W9ZnP_mc4kmp0CNvsmd9w4A9sTyo/edit?usp=sharing",
                            sheet = "tables") %>%
    dplyr::filter(id = id) %>%
    as.list() -> ds_list

  # create S3 dataset-object with the needed classes
  ds_list <- structure(
    data,
    data = NULL,
    class = c(ds_list$organization, data$format, data$id)
  )


  return(ds_list)
}

