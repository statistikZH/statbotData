#' Read/Write metadata table as csv
#'
#' @param ds the dataset: it is expected to have
#'           ds$postgres_export
#'           the language is to be expected the language
#'           the ds is in (one language per pipeline)
#' @param overwrite default is FALSE, when set to TRUE
#'                  the metadata file will be overwritten
#'
#' @return metadata a tibble containing the metadata that
#'                  matches what is on file
#' @export
#'
#' @examples
#' \dontrun{
#'   # command to call when the metadata should be read or
#'   # when metadata do not exist yet
#'   rw_metadata_table(ds)
#'
#'   # command to call when the metadata should be overwritten
#'   rw_metadata_table(ds, overwrite = TRUE)
#' }
rw_metadata_table <- function(ds, overwrite = FALSE) {

  # set path for metadata storage
  path <- paste0(ds$dir, "metadata.csv")

  if (file.exists(path) && !overwrite) {
    metadata = readr::read_csv(path)
    return(metadata)
  }

  # make template for metadata file

  # items are received from the columns of the postgres export
  columns <- colnames(ds$postgres_export)
  items <- c(ds$name, columns)
  items <- items[!(items %in% c("jahr", "spatialunit_uid"))]

  # make vectors to prefill the tibble
  types <- c("table", rep("field", times = length(items) - 1))
  language <- rep(ds$lang, times = length(items))
  description <-rep("", times = length(items))

  # set the tibble
  metadata <- tibble::tibble(
    item = items,
    type = types,
    language = language,
    description = description
  )

  # write the tibble to a file
  write.csv(metadata, path, row.names = FALSE, quote = FALSE)
  print(
    paste(
      "metadata template written to\n",
      path,
      "\nPlease complete metadata for pipeline."
    )
  )
  return(metadata)
}
