#' Get metadata from postgres
#'
#' Read metadata from the postgres instance and return the metadata
#' of all or a selected table
#'
#' @param ds_table_name name of the table to get metadata for: optional
#'
#' @return list of metadata tables from postgres as tibbles
#' @export
#'
#' @examples
#' \dontrun{
#' get_metadata_from_postgres()
#' }
get_metadata_from_postgres <- function(ds_table_name = NULL) {
  tryCatch(
    {
      db <- statbotData::postgres_db_connect()
      metadata_tables <- RPostgres::dbReadTable(
        db,
        name = "metadata_tables",
      ) %>%
        tibble::as_tibble()
      metadata_table_columns <- RPostgres::dbReadTable(
        db,
        name = "metadata_table_columns",
      ) %>%
        tibble::as_tibble()
      if (!is.null(ds_table_name)) {
        metadata_tables <- metadata_tables %>% dplyr::filter(
          name == ds_table_name
        )
        metadata_table_columns <- metadata_table_columns %>% dplyr::filter(
          table_name == ds_table_name
        )
      }
    }, error = function(e) {
      stop(e)
    }, finally = {
      RPostgres::dbDisconnect(db)
    }
  )
  return(list(metadata_tables = metadata_tables,
              metadata_table_columns = metadata_table_columns))
}

#' List all tables that have metadata in postgres
#'
#' @return list of tables with metadata in postgres
#' @export
#'
#' @examples
#' \dontrun{
#' list_tables_with_metadata_in_postgres()
#' }
list_tables_with_metadata_in_statbot_db <- function() {
  metadata <- get_metadata_from_postgres()
  tables_with_table_metadata <- metadata$metadata_tables$name
  tables_with_column_metadata <- unique(metadata$metadata_table_columns$table_name)
  tables_with_metadata <- c(tables_with_table_metadata, tables_with_column_metadata) %>%
    unique()
  return(tables_with_metadata)
}

#' Update metadata for a pipeline in postgres
#'
#' Update the metadata in postgres by deleting and
#' inserting it again
#'
#' @param ds dataset pipeline class
#'
#' @return list of metadata tables from postgres as tibbles
#'
#' @export
#'
#' @examples
#' \dontrun{
#' update_metadata_in_postgres(ds)
#' }
update_metadata_in_postgres <- function(ds) {
  metadata_from_file <- read_metadata_tables_from_file(ds)
  if (is.null(metadata_from_file)) {
    msg <- paste("Generate metadata files with function",
                 "statbotData::generate_metadata_templates",
                 "then remove .template in the file name and complete the metadata.")
    stop(msg)
  }
  write_metadata_to_postgres(metadata_from_file, ds$name)
  metadata_db <- get_metadata_from_postgres(ds$name)
  return(metadata_db)
}

#' Delete metadata for a pipeline in postgres
#'
#' The pipeline dataset is supposed to be created when this function
#' is called. All metadata for the pipeline is deleted in the postgres
#' instance. This function can be used when the metadata should be updated
#' to remove the old entries and the readd the updated metadata
#'
#' @param table_name name of the table to delete metadata for
#'
#' @export
#'
#' @examples
#' \dontrun{
#' delete_metadata_from_postgres(table_name)
#' }
delete_metadata_from_postgres <- function(table_name) {
  tryCatch(
    {
      # delete metadata entries in postgres`
      db <- statbotData::postgres_db_connect()
      q_md_table <- paste0(
        "DELETE FROM metadata_tables WHERE name='", table_name, "'; "
      )
      q_md_cols <- paste0(
        "DELETE FROM metadata_table_columns WHERE table_name='",table_name, "';"
      )
      print(q_md_table)
      RPostgres::dbExecute(db, q_md_table)
      print(q_md_cols)
      RPostgres::dbExecute(db, q_md_cols)
    }, error = function(e) {
      stop(e)
    }, finally = {
      RPostgres::dbDisconnect(db)
    }
  )
}

#' Write metadata to postgres
#'
#' Read metadata from file and write them to postgres: the metadata
#' is expected in the files `metadata_tables.csv`
#' and `metadata_table_columns.csv`
#' The metadata is appended to the existing metadata tables in postgres
#'
#' @param metadata metadata as list of tibbles
#' @param table_name name of the table
#'
#' @examples
#' \dontrun{
#' write_metadata_to_postgres(metadata, table_name)
#' }
write_metadata_to_postgres <- function(metadata, table_name) {
  tryCatch(
    {
      # append `metadata_tables`
      db <- statbotData::postgres_db_connect()
      RPostgres::dbWriteTable(
        conn = db,
        name = "metadata_tables",
        value = metadata$metadata_tables,
        append = TRUE
      )

      # append `metadata_table_columns`
      data_types_columns <- DBI::dbDataType(db, metadata$metadata_table_columns)
      RPostgres::dbWriteTable(
        conn = db,
        name = "metadata_table_columns",
        value =  metadata$metadata_table_columns,
        append = TRUE
      )
    }, error = function(e) {
      stop(e)
    }, finally = {
      RPostgres::dbDisconnect(db)
    }
  )
}
