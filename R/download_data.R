#' Function for streaming the data.
#'
#' We are only streaming the data, meaning we do not store local files of the
#' data. Data streamed is held temporarily and deleted afterwards.
#'
#' The function first runs the get_read_path() method corresponding to the dataset ID,
#' with which the read path for the download URL is created.
#' Next the function uses the appropriate read_data() method to stream and append
#' the data to the dataset (ds) in the $data object.
#'
#' @inheritParams download_data
#'
#' @export
download_data <- function(ds) {
  ds <- get_read_path(ds)

  # streams the data and appends it to the ds in $data
  ds <- read_data(ds)

  # Only return the initial ds object
  return(ds)
}

#' Function to stream data
#'
#' For PXWEB data we need to define its own method, because we are working with
#' the PXWEB package for streaming data. Every other use case can be handled by
#' the default method.
#'
read_data <- function(ds) UseMethod("read_data")
#' Default method
#'
#' The method is used in all cases where the input data is a csv, xlsx or
#' one of both packaged in a zipped folder
#'
#' Working with import() from the rio package: https://cran.r-project.org/web/packages/rio/vignettes/rio.html
#' rio uses the file extension of a file name to determine what kind of file it is
#' and thus rio allows almost all common data formats to be read with the same function
#' !Attention: package seems to be stable. Nevertheless, keep an eye out for potential issues.
#'
read_data.default <- function(ds) {
  # Get the file extension from the URL or the given info from the excel sheet
  if (!is.na(ds$format)) {
    file_ext <- ds$format
  } else {
    file_ext <- tools::file_ext(ds$read_path)
  }

  temp_file <- paste0("temp.", file_ext)

  # check which system is used to set the download method
  if (Sys.info()["sysname"] == "Windows") {
    download_method <- "wininet"
  } else {
    download_method <- "auto"
  }

  # Download the file


  withr::with_envvar(
    new = c("no_proxy" = "dam-api.bfs.admin.ch"),
    code = download.file(url = ds$read_path, destfile = temp_file, method = download_method, mode = "wb")
  )
  # Import the data
  ds$data <- rio::import(temp_file, which = ds$sheet, header = TRUE)

  # Remove the temporary file
  file.remove(temp_file)

  return(ds)
}



#' Method to stream data from pxweb data cubes which is unique to the BFS
#' Downloads the data from a data cube based on a query list and converts it to a data.frame
#'
#' We are using the PXWEB package to stream BFS data:
#' https://ropengov.github.io/pxweb/articles/pxweb.html
#'
#' !!! Important Limits: 10 calls per 10 sec., 5000  values per call
#'
#' the name of the data cube, e.g. "px-x-0103010000_102", is taken from ds$data_id
#' the download url is constructed with the "get_read_path.bfs" method and added dto the ds as 'read_path'
#' the query list, a list element containing all query parameters, gets constructed with "get_px_query_list()"
#'
#' To set up a PXWEB query list manually, start with a specific path and walk thorough each step
#' d <- pxweb::pxweb_interactive("https://www.pxweb.bfs.admin.ch/api/v1/de/px-x-0103010000_102")
#'
read_data.px <- function(ds) {
  if (is.na(ds$size) || ds$size != "large") {
    ds$data <- BFS::bfs_get_data(
      number_bfs = ds$read_path,
      language = ds$lang
    )
  } else {
    tmp <- tempfile(fileext = ".px")
    options(timeout = 300)
    download.file(ds$read_path, tmp)
    df <- pxRRead::scan_px_file(
      tmp,
      locale = ds$lang,
      encoding = ds$encoding,
      reverse_stub = !is.null(ds$reversed)
    )
    ds$data <- df$dataframe
  }
  return(ds)
}


#' Method to retrieve an RDF dataset using an input SELECT query
#' Execute a SPARQL query and return the result as a tibble.
#'
read_data.rdf <- function(ds) {
  response <- httr::POST(
    ds$base_url,
    body = list(query = ds$query),
    encode = "form",
    httr::add_headers(.headers = c("Accept" = "text/csv"))
  )
  ds$data <- readr::read_csv(httr::content(response, "text"))
  return(ds)
}
