#' Function that creates the download url based on dataset_id and data_type
#'
#' Methods differ according to the data-holding organisation
#'
#' @param ds dataset object
get_read_path <- function(ds) UseMethod("get_read_path")

#' Standard method for creating the path of the download URL
#' for any data-holding organisation other than the FSO.
#'
#' General path format: paste of base url and id
#'
#' @param ds dataset object
#'
#' @export
get_read_path.default <- function(ds) {

  # creating the path of the download URL
  ds$read_path <- paste0(ds$base_url, ds$data_url)

  # set which data (xlsx sheet number) to 1 (first sheet) if not specified in excel list
  if(is.na(ds$sheet)){
    ds$sheet <- 1
  }

  return(ds)
}

#' Function for creating the FSP-specific read path
#'
#' Use cases currently are XLSX via DAM API and via PXWEB data cubes
#'
#' @param ds dataset object
#'
#' @export
get_read_path.bfs <- function(ds) {

  ds <- get_read_path_bfs(ds)

  return(ds)
}

get_read_path_bfs <- function(ds) UseMethod("get_read_path_bfs")

#' Default method for creating the read path for data via the DAM API
#'
#' the asset number (BFS Nr) is required
#'
get_read_path_bfs.default <- function(ds){
  # get asset number
  ds <- get_bfs_asset_info(ds)

  # set download path
  ds$read_path <- paste0(ds$base_url, ds$asset_number, "/master")

  return(ds)
}
#' Method for creating the read path for PXWEB data cubes
#'
#' the asset number (BFS Nr) is required
get_read_path_bfs.px <- function(ds){
  print(ds$size)
  if (ds$size != "large") {
    # Create the download url
    # all required information, like the name of the data cube, are in the dataset (ds)
    # Example: name of the data cube ("px-x-0103010000_102") is taken from ds$data_id
    ds$read_path <- ds$sheet
  } else {
    ds$read_path <- paste0("https://www.pxweb.bfs.admin.ch/DownloadFile.aspx?file=",
                           ds$sheet)
  }

  return(ds)
}




