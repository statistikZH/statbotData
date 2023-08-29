#' Read/Write metadata tables as csv
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
#'                  the function watches for files:
#'                  metadata_tables.csv
#'                  metadata_table_columns.csv
#'                  If they are not there or overwrite is set
#'                  to TRUE templates for these files will be
#'                  set up. Otherwise the files will be read
#'                  and reported back
#' @export
#'
#' @examples
#' \dontrun{
#'   # command to call when the metadata should be read or
#'   # created: it will be created if it does not exist yet
#'   read_write_metadata_tables(ds)
#'
#'   # command to call when the metadata should be overwritten
#'   read_write_metadata_tables(ds, overwrite = TRUE)
#' }
read_write_metadata_tables <- function(ds, overwrite = FALSE) {

  # set path for metadata storage
  path_table <- paste0(ds$dir, "metadata_tables.csv")
  path_table_columns <- paste0(ds$dir, "metadata_table_columns.csv")

  if (file.exists(path_table) && file.exists(path_table_columns) &&!overwrite) {
    metadata_tables = readr::read_delim(path_table, delim = ";")
    metadata_table_columns = readr::read_delim(path_table_columns, delim = ";")
    return(list(metadata_tables=metadata_tables,
                metadata_table_columns=metadata_table_columns))
  }

  # make template for metadata files

  # metadata_tables entry: if possible load metadata
  table_description <- ""
  if (ds$organization == "bfs" && ds$format == "px") {
    bfs_metadata <- BFS::bfs_get_metadata(number_bfs = ds$sheet, language = ds$lang)
    table_description <- unique(bfs_metadata$title)
  }
  metadata_tables <- tibble::tibble(
    name = ds$name,
    language = ds$lang,
    data_source_url = "",
    title = table_description,
    title_en = "",
    description = "",
    description_en = "",
    temporal_coverage = "",
    update_frequency = "",
    spatial_coverage = ""
  )

  # columns are received from the columns of the postgres export
  columns <- colnames(ds$postgres_export)
  columns <- columns[!(columns %in% c("jahr", "spatialunit_uid"))]
  columns_count <- length(columns)
  metadata_table_columns <- tibble::tibble(
    name = columns,
    table_name = rep(ds$name, times = columns_count),
    data_type = rep("", times = columns_count),
    title = rep("", times = columns_count),
    title_en = rep("", times = columns_count),
    example_values = get_examples(ds, columns)
  )

  # write the tibble to a file
  write.table(metadata_tables, path_table,
              row.names = FALSE, quote = FALSE, sep = ";")
  write.table(metadata_table_columns, path_table_columns,
              row.names = FALSE, quote = FALSE, sep = ";")
  print(
    paste(
      "metadata templates written to\n",
      ds$dir,
      "\nPlease complete metadata for pipeline."
    )
  )
  return(list(metadata_tables=metadata_tables,
              metadata_table_columns=metadata_table_columns))
}

#' get example values for the columns
#'
#' @param ds the dataset: it is expected to have
#'           ds$postgres_export
#' @param columns columns of the dataset: colnames(ds$postgres)
#'
#' @return example_values array of example values
#' @export
#'
#' @examples
#' \dontrun{
#'   get_examples(ds, columns)
#'   # returns 3 values for each column from the samples
#' }
get_examples <- function(ds, columns) {
  # For each column, we get 3 example values and paste them into a single string.
  example_values <- columns %>%
    purrr::map_chr(
      \(x) unique(ds$postgres_export[, x]) %>%
        head(3) %>%
        dplyr::pull(x) %>%
        paste(sep=" ", collapse="; ")
    )
  return(example_values)
}
