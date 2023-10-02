#' Load spatial units into a spatial_unit_table
#'
#' The table has already been set up at the remote postgres
#' instance. Just the data was loaded from file.
#' This function was only used once during the setup phase.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' upload_spatial_units_to_postgres()
#' }
upload_spatial_units_to_postgres <- function() {
  tryCatch(
    {
      con <- statbotData::postgres_db_connect()
      spatial_unit_table <- "spatial_unit"
      df <- load_spatial_map()
      RPostgres::dbWriteTable(
        conn = con$db,
        name = RPostgres::Id(schema = con$schema, table = "spatial_unit"),
        value = df,
        append = TRUE
      )
      # Since no primary key was specified yet, it had to be created
      RPostgres::dbGetQuery(
        conn = db,
        "ALTER TABLE spatial_unit ADD PRIMARY KEY(spatialunit_uid);"
      )
    }, error = function(e) {
      stop(e)
    }, finally = {
      RPostgres::dbDisconnect(con$db)
    }
  )
}

#' Intitial setup of metadata tables
#'
#' This function was used only once for the inital setup of the tables
#'
#' @param example_pipeline example pipeline that is used to derive the structure
#'                         of the metadata tables from
#'
#' @export
#'
#' @examples
#' \dontrun{
#' intial_setup_of_metadata_tables()
#' }
intial_setup_of_metadata_tables <- function(example_pipeline = "A6") {
  # setup any pipeline in order to use it to determine the metadata
  ds <- statbotData::create_dataset(example_pipeline)
  metadata <- read_metadata_tables_from_file(ds)

  # create `metadata_tables
  con <- statbotData::postgres_db_connect()
  data_types_tables <- DBI::dbDataType(con$db, metadata$metadata_tables)
  data_types_tables["name"] <- "varchar PRIMARY KEY"
  RPostgres::dbWriteTable(
    conn = con$db,
    name = RPostgres::Id(schema = con$schema, table = "metadata_tables"),
    value = metadata$metadata_tables,
    overwrite = TRUE,
    field.types = data_types_tables
  )

  # create `metadata_table_columns`
  data_types_columns <- DBI::dbDataType(con$db, metadata$metadata_table_columns)
  RPostgres::dbWriteTable(
    conn = con$db,
    name = RPostgres::Id(schema = con$schema, table = "metadata_table_columns"),
    value =  metadata$metadata_table_columns,
    overwrite = TRUE,
    field.types = data_types_columns
  )
  RPostgres::dbGetQuery(
    conn = con$db,
    "ALTER TABLE experiment.metadata_table_columns ADD PRIMARY KEY(name, table_name);"
  )
  RPostgres::dbDisconnect(con$db)
}
