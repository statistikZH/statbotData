#' Establish db connection
#'
#' @return db_connection: list of a running db connection and a schema
#' @export
#'
#' @examples
#' \dontrun{
#'   postgres_db_connect()
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
  db_connection = list(db = db, schema = schema)
  return(db_connection)
}

#' Create Postgres table
#'
#' @param ds
#' @param dry_run bool: whether this
#'
#' @return field_types: vector of field types, in case it was called with dry_run
#' @export
#'
#' @examples
#' \dontrun{
#'   create_postgres_table(ds, dry_run = TRUE)
#' }
create_postgres_table <- function(ds, dry_run = FALSE) {
  # add uid as a column
  df <- ds$postgres_export %>%
    tibble::rowid_to_column("uid")

  # column names as tibble
  df_columns <- tibble::as_tibble(colnames(df)) %>%
    dplyr::rename("name" = value)

  # get name of the year column which can differ per language
  year_column <- df_columns %>%
    dplyr::filter(name %in% c("year", "jahr", "annee"))
  year_name <- year_column$name
  data_types <- get_data_types_from_metadata(ds, year_name)
  field_types <- df_columns %>%
    dplyr::left_join(data_types, by = "name") %>%
    tibble::deframe()
  if (dry_run) {
    return(field_types)
  }

  # connect to postgres instance
  connect <- statbotData::postgres_db_connect()
  connect
  db <- connect$db
  schema <- connect$schema
  table <- ds$name

  # get
  RPostgres::dbWriteTable(
    conn = db,
    name = RPostgres::Id(schema = schema, table = table),
    value = df,
    overwrite = TRUE,
    field.types = field_types
  )
  RPostgres::dbDisconnect(conn = db)
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
#' @param ds: dataset of the pipelin
#' @param year_name: name for the year column that depends on the language
#'
#' @return data_types: a tibble with 2 columns: name and data_type
#'
#' @examples
#' \dontrun{
#'   get_data_types_from_metadata(ds, "jahr")
#' }
get_data_types_from_metadata <- function(ds, year_name) {
  metadata <- read_metadata_tables(ds)
  data_types <- metadata$metadata_table_columns %>%
    dplyr::select(c("name", "data_type")) %>%
    tibble::add_row(
      name = "spatialunit_uid",
      data_type = "varchar REFERENCES experiment.spatial_unit (spatialunit_uid)",
      .before = 1
    ) %>%
    tibble::add_row(
      name = year_name,
      data_type = "integer",
      .before = 1
    ) %>%
    tibble::add_row(
      name = "uid",
      data_type = "serial4 PRIMARY KEY",
      .before = 1
    )
  return(data_types)
}
