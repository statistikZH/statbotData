#' Get metadata from postgres
#'
#' Read metadata from the postgres instance and return the metadata
#' tables: the full tables are returned.
#'
#' @param ds dataset pipeline class
#'
#' @return list of metadata tables from postgres as tibbles
#' @export
#'
#' @examples
#' \dontrun{
#' get_metadata_from_postgres()
#' }
get_metadata_from_postgres <- function(ds = NULL) {
  tryCatch(
    {
      con <- statbotData::postgres_db_connect()
      metadata_tables <- RPostgres::dbReadTable(
        con$db,
        name = RPostgres::Id(schema = con$schema, table = "metadata_tables")
      ) %>%
        tibble::as_tibble()
      metadata_table_columns <- RPostgres::dbReadTable(
        con$db,
        name = RPostgres::Id(schema = con$schema, table = "metadata_table_columns")
      ) %>%
        tibble::as_tibble()
      if (!is.null(ds)) {
        metadata_tables <- metadata_tables %>% dplyr::filter(
          name == ds$name
        )
        metadata_table_columns <- metadata_table_columns %>% dplyr::filter(
          table_name == ds$name
        )
      }
    }, error = function(e) {
      stop(e)
    }, finally = {
      RPostgres::dbDisconnect(con$db)
    }
  )
  return(list(metadata_tables = metadata_tables,
              metadata_table_columns = metadata_table_columns))
}

#' Write metadata to postgres
#'
#' Read metadata from file and write them to postgres: the metadata
#' is expected in the files `metadata_tables.csv`
#' and `metadata_table_columns.csv`
#' The metadata is appended to the existing metadata tables in postgres
#'
#' @param ds dataset pipeline class
#'
#' @examples
#' \dontrun{
#' write_metadata_to_postgres(ds)
#' }
write_metadata_to_postgres <- function(ds) {
  tryCatch(
    {
      # read metadata
      metadata <- read_metadata_tables_from_file(ds)

      # append `metadata_tables`
      con <- statbotData::postgres_db_connect()
      RPostgres::dbWriteTable(
        conn = con$db,
        name = RPostgres::Id(schema = con$schema, table = "metadata_tables"),
        value = metadata$metadata_tables,
        append = TRUE
      )

      # append `metadata_table_columns`
      data_types_columns <- DBI::dbDataType(con$db, metadata$metadata_table_columns)
      RPostgres::dbWriteTable(
        conn = con$db,
        name = RPostgres::Id(schema = con$schema, table = "metadata_table_columns"),
        value =  metadata$metadata_table_columns,
        append = TRUE
      )
    }, error = function(e) {
      stop(e)
    }, finally = {
      RPostgres::dbDisconnect(con$db)
    }
  )
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
  metadata_db <- get_metadata_from_postgres(ds)
  print(nrow(metadata_db$metadata_tables))
  if (!(nrow(metadata_db$metadata_tables) == 0)) {
    delete_metadata_from_postgres(ds)
  }
  write_metadata_to_postgres(ds)
  return(metadata_db)
}

#' Delete metadata for a pipeline in postgres
#'
#' The pipeline dataset is supposed to be created when this function
#' is called. All metadata for the pipeline is deleted in the postgres
#' instance. This function can be used when the metadata should be updated
#' to remove the old entries and the readd the updated metadata
#'
#' @param ds dataset pipeline class
#'
#' @examples
#' \dontrun{
#' delete_metadata_from_postgres(ds)
#' }
delete_metadata_from_postgres <- function(ds) {
  tryCatch(
    {
      # delete metadata entries in postgres`
      con <- statbotData::postgres_db_connect()
      q_md_table <- paste0(
        "DELETE FROM ", con$schema,
        ".metadata_tables WHERE name='", ds$name, "'; "
      )
      q_md_cols <- paste0(
        "DELETE FROM ", con$schema,
        ".metadata_table_columns WHERE table_name='", ds$name, "';"
      )
      RPostgres::dbExecute(con$db, q_md_table, silent=)
      RPostgres::dbExecute(con$db, q_md_cols)
    }, error = function(e) {
      stop(e)
    }, finally = {
      RPostgres::dbDisconnect(con$db)
    }
  )
}
