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

  googlesheets4::read_sheet(ss = "https://docs.google.com/spreadsheets/d/1Ouxavyw-WD2g9GgngIH7x8sEg06XxlfJtJNZFs_Goqg/edit?usp=sharing",
                            sheet = "tables") -> sheet
  sheet %>%
    dplyr::filter(data_indicator == id) %>%
    as.list() -> ds_list
  ds_list$dir <- here::here("pipelines", ds_list$data_indicator, "")

  ds_list <- structure(
    ds_list,
    data = NULL,
    class = c(ds_list$organization,
              ds_list$format,
              ds_list$id)
  )


  return(ds_list)
}

