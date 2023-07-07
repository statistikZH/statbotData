#' Function to retrieve the asset number and the last year of the time series
#' for a specific BFS number
#'
#' This function scrapes the asset page of a BFS-nr
#' !important: this bfs-nr here does not correspond to the bfs-nr of the municipality
#'
#' @param bfs_nr Number of a bfs publication e.g: "ind-d-21.02.30.1202.02.01"
get_bfs_asset_info <- function(ds) {

  bfs_home <- "https://www.bfs.admin.ch"

  asset_page <- httr::GET(paste0(bfs_home, "/asset/de/", ds$data_url), config = httr::use_proxy("")) %>%
    rvest::read_html()


  #asset_page <- xml2::read_html(paste0(bfs_home, "/asset/de/", ds$data_id))

  # Retrieve asset number
  # 'asset_number' is used to construct the current read_paths for BFS assets from the DAM API.
  ds$asset_number <- asset_page %>%
    rvest::html_text(ds$data_id) %>%
    stringr::str_extract("https://.*assets/.*/") %>%
    stringr::str_extract("[0-9]+")


  # Retrieve last year of the time series
  # 'year_end' is used in the px query list
  ds$year_end <- asset_page %>%
    rvest::html_element("table") %>%
    rvest::html_table() %>%
    dplyr::filter(X1 == "Dargestellter Zeitraum") %>%
    dplyr::pull(X2) %>%
    substr(., nchar(.) - 3, nchar(.))

  ds$year_start <- asset_page %>%
    rvest::html_element("table") %>%
    rvest::html_table() %>%
    dplyr::filter(X1 == "Dargestellter Zeitraum") %>%
    dplyr::pull(X2) %>%
    substr(., 1, 4)

  return(ds)
}
