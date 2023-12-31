#' generate templates for metadata tables as csv file
#'
#' The function writes template files for the metadata
#' of table and column. These template can be manually
#' completed and copied into the expected metadata files
#' for the table and columns
#'
#' @param ds the dataset: it is expected to have
#'           ds$postgres_export
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   generate_metadata_templates(ds)
#' }
generate_metadata_templates <- function(ds) {

  # set path for metadata storage
  path_table <- here::here(ds$dir, "metadata_tables.template.csv")
  path_table_columns <- here::here(ds$dir, "metadata_table_columns.template.csv")

  # metadata_tables entry: if possible load metadata
  table_description <- ""
  if (ds$organization == "bfs" && ds$format == "px") {
    bfs_metadata <- BFS::bfs_get_metadata(number_bfs = ds$px_id, language = ds$lang)
    table_description <- unique(bfs_metadata$title)
  }
  metadata_tables <- tibble::tibble(
    name = ds$name,
    language = ds$lang,
    last_pipeline_run = Sys.Date(),
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
  columns <- columns[!(columns %in% c("jahr", "year", "annee", "spatialunit_uid"))]
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
    row.names = FALSE, quote = FALSE, sep = ";"
  )
  write.table(metadata_table_columns, path_table_columns,
    row.names = FALSE, quote = FALSE, sep = ";"
  )
  print(
    paste(
      "metadata templates written to",
      ds$dir,
      "Please complete metadata for pipeline and copy into:",
      "`metadata_tables.csv` and `metadata_table_columns.csv`."
    )
  )
}

#' Read metadata for a pipeline from file
#'
#' @param ds the dataset
#'
#' @return metadata as tibbles or NULL
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   read_metadata_tables_from_file(ds)
#' }
read_metadata_tables_from_file <- function(ds) {
  # set path for metadata storage
  path_table <- here::here(ds$dir, "metadata_tables.csv")
  path_table_columns <- here::here(ds$dir, "metadata_table_columns.csv")

  if (file.exists(path_table) && file.exists(path_table_columns)) {
    metadata_tables = readr::read_delim(path_table,
                                        delim = ";",
                                        show_col_types = FALSE)
    metadata_table_columns = readr::read_delim(path_table_columns,
                                               delim = ";",
                                               show_col_types = FALSE)
    return(list(metadata_tables=metadata_tables,
                metadata_table_columns=metadata_table_columns))
  } else {
    return(NULL)
  }
}

#' Update pipeline last run date in the table metadata on file
#'
#' @param ds the dataset
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   update_pipeline_last_run_date(ds)
#' }
update_pipeline_last_run_date <- function(ds) {
  if (is.null(ds$postgres_export)) {
    stop("ds$postgres_export is null therefore the metadata last run date has not been updated")
  }

  # set path for metadata storage
  path_table <- here::here(ds$dir, "metadata_tables.csv")
  if (!file.exists(path_table)) {
    stop("Metadata file `metadata_tables.csv` is missing.")
  }
  # read metadata_tables from file
  metadata_tables = readr::read_delim(path_table,
                                      delim = ";",
                                      show_col_types = FALSE)
  # update last run date
  metadata_tables$last_pipeline_run <- Sys.Date()
  write.table(metadata_tables, path_table,
              row.names = FALSE, quote = FALSE, sep = ";")
  return(metadata_tables)
}

#' get example values for the columns
#'
#' @param ds the dataset: it is expected to have
#'           ds$postgres_export
#' @param columns columns of the dataset: colnames(ds$postgres)
#'
#' @return example_values array of example values
#'
#' @examples
#' \dontrun{
#' get_examples(ds, columns)
#' # returns 3 values for each column from the samples
#' }
get_examples <- function(ds, columns) {
  # For each column, we get 3 example values and paste them into a single string.
  example_values <- columns %>%
    purrr::map_chr(
      \(x) unique(ds$postgres_export[, x, drop = F]) %>%
        head(3) %>%
        dplyr::pull(x) %>%
        paste0(collapse = ",")
    )
  return(example_values)
}
