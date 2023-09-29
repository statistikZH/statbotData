#' Establish db connection
#'
#' @return db_connection: list of a running db connection and a schema
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
  db_connection <- list(db = db, schema = schema)
  return(db_connection)
}

#' Create Postgres table
#'
#' @param ds
#' @param dry_run bool: whether this is a dry run or the actual DB operation
#'
#' @export
#'
#' @examples
#' \dontrun{
#' create_postgres_table(ds, dry_run = TRUE)
#' }
create_postgres_table <- function(ds, dry_run = FALSE) {
  table <- ds$name
  if (dry_run) {
    con <- DBI::ANSI()
  } else {
    # connect to postgres instance
    con <- statbotData::postgres_db_connect()
    db <- con$db
  }

  field_types <- get_postgres_data_types(db, ds$postgres_export)
  print(paste("Field type for dataset", table, ":"))
  print(field_types)

  # only if this is not a dry run: create the table:
  # overwrite if it already exists
  if (dry_run) {
    print(paste("Dryrun for table:", table, "Table was not created by this run. Please check the field types."))
  } else {
    schema <- con$schema

    # turn field types into a list
    field_type_list <- field_types %>%
      tibble::deframe()

    # add uid as a column
    df <- ds$postgres_export %>%
      tibble::rowid_to_column("uid")

    # create table with the field types
    RPostgres::dbWriteTable(
      conn = db,
      name = RPostgres::Id(schema = schema, table = table),
      value = df,
      overwrite = TRUE,
      field.types = field_type_list
    )
    print(paste("Table", table, "was created for schema", schema))
    RPostgres::dbDisconnect(conn = db)
  }
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
get_postgres_data_types <- function(con, tbl) {
  data_types <- DBI::dbDataType(con, tbl) %>%
    tibble::enframe(name = "name", value = "data_type") %>%
    dplyr::filter(name != "spatialunit_uid") %>%
    tibble::add_row(
      name = "spatialunit_uid",
      data_type = "varchar REFERENCES experiment.spatial_unit (spatialunit_uid)",
      .before = 1
    ) %>%
    tibble::add_row(
      name = "uid",
      data_type = "serial4 PRIMARY KEY",
      .before = 1
    ) %>%
    dplyr::mutate(
      data_type = stringr::str_replace(data_type, "DOUBLE PRECISION", "NUMERIC")
    )
  return(data_types)
}
