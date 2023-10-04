#' Establish db connection
#'
#' @return db: connection to postgres schema
#' @export
#'
#' @examples
#' \dontrun{
#' postgres_db_connect()
#' }
postgres_db_connect <- function() {
  env_file_path <- here::here(".env")
  dotenv::load_dot_env(env_file_path)
  db <- RPostgres::dbConnect(
    RPostgres::Postgres(),
    dbname = Sys.getenv("DB_NAME"),
    host = Sys.getenv("DB_HOSTADDR"),
    port = Sys.getenv("DB_PORT"),
    user = Sys.getenv("DB_USER"),
    password = Sys.getenv("DB_PASSWORD")
  )
  schema <- Sys.getenv("DB_SCHEMA")
  sql_set_path <-  paste0("SET SEARCH_PATH TO ", schema, ";")
  RPostgres::dbExecute(db, sql_set_path)
  return(db)
}

#' List Postgres table in Statbot DB
#'
#' @export
#'
#' @examples
#' \dontrun{
#' list_tables_in_statbot_db()
#' }
list_tables_in_statbot_db <- function() {
  db <- statbotData::postgres_db_connect()
  tables <- RPostgres::dbListTables(db)
  RPostgres::dbDisconnect(conn = db)
  return(tables)
}

#' Create Postgres table
#'
#' @param ds dataset pipeline class
#' @param dry_run bool: whether this is a dry run or the actual DB operation
#'
#' @export
#'
#' @examples
#' \dontrun{
#' create_postgres_table(ds, dry_run = TRUE)
#' }
create_postgres_table <- function(ds, dry_run = FALSE) {
  if (is.null(ds$postgres_export)) {
    stop("ds$postgres_export is null therefore is can not be imported to postgres")
  }
  table <- ds$name
  if (dry_run) {
    db <- DBI::ANSI()
  } else {
    # connect to postgres instance
    db <- statbotData::postgres_db_connect()
  }

  field_types <- get_postgres_data_types(db, ds$postgres_export)
  print(paste("Field type for dataset", table, ":"))
  print(field_types)

  # only if this is not a dry run: create the table:
  # overwrite if it already exists
  if (dry_run) {
    print(paste("Dryrun for table:", table, "Table was not created by this run. Please check the field types."))
  } else {
    # turn field types into a list
    field_type_list <- field_types %>%
      tibble::deframe()

    # add uid as a column
    df <- ds$postgres_export %>%
      tibble::rowid_to_column("uid")

    # create table with the field types
    RPostgres::dbWriteTable(
      conn = db,
      name = table,
      value = df,
      overwrite = TRUE,
      field.types = field_type_list
    )
    print(paste("Table", table, "was created."))
    RPostgres::dbDisconnect(conn = db)
  }
}

#' Run postgres query on table in schema
#'
#' Add schema to query
#'
#' @param table_name table_name in the query
#' @param query query on the table
#'
#' @export
#'
#' @examples
#' \dontrun{
#' run_postgres_query("SELECT count(*) FROM metadata.tables")
#' }
run_postgres_query <- function(table_name, query) {
  tryCatch(
    {
      db <- statbotData::postgres_db_connect()
      RPostgres::dbGetQuery(db, query)
    }, error = function(e) {
      stop(e)
    }, finally = {
      RPostgres::dbDisconnect(db)
    }
  )
}

#' Delete table from postgres
#'
#' @param table_name name of the table to delete
#'
#' @export
#'
#' @examples
#' \dontrun{
#' delete_metadata_from_postgres(ds)
#' }
delete_table_in_postgres <- function(table_name) {
  tryCatch(
    {
      # delete metadata entries in postgres`
      db <- statbotData::postgres_db_connect()
      RPostgres::dbRemoveTable(db, table_name)
    }, error = function(e) {
      stop(e)
    }, finally = {
      RPostgres::dbDisconnect(db)
    }
  )
}

#' Get data types for postgres table from metadata
#'
#' Returns a tibble with 2 columns: the name of the column and the
#' data_type of the column
#' This includes also the common columns such as 'uid': the primary key
#' `spatialunit_uid`: the spatial unit foreign key and the `year` column
#' The data_types are postgres data_types that can be used in the postgres
#' create table statement
#'
#' @param con: db connection
#' @param tbl: dataset table to export (ds$postgres_export)
#'
#' @return data_types: a tibble with 2 columns: name and data_type
#'
#' @examples
#' \dontrun{
#' get_data_types_from_metadata(DBI::ANSI(), ds$postgres_export)
#' }
get_postgres_data_types <- function(db, tbl) {
  # get name of the year column which can differ per language
  year_names <- c("year", "jahr", "annee")
  year_col <- intersect(colnames(tbl), year_names)
  data_types <- DBI::dbDataType(db, tbl) %>%
    tibble::enframe(
      name = "name", value = "data_type"
    ) %>%
    dplyr::filter(
      name != "spatialunit_uid"
    ) %>%
    dplyr::mutate(
      data_type = case_when(
        name == year_col ~ 'INTEGER',
        data_type == 'TEXT' ~ 'TEXT',
        .default = 'NUMERIC',
      )
    ) %>%
    tibble::add_row(
      name = "spatialunit_uid",
      data_type = "varchar REFERENCES experiment.spatial_unit (spatialunit_uid)",
      .before = 1
    ) %>%
    tibble::add_row(
      name = "uid",
      data_type = "serial4 PRIMARY KEY",
      .before = 1
    )
  return(data_types)
}
