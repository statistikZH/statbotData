#' Testrun queries
#'
#' the database will just have two table:
#' - one that is defined by the provided tibble
#' - and one that contains the spatial units
#'
#' the queries are expected to be read from a file
#' `queries.sql` in the directory `dir`. The queries
#' should be formulated for `table_name` as the table
#' with spatial joins on the `spatial_unit` table
#'
#' @param df tibble to turn into an sql table
#' @param dir directory to write the output to
#' @param table_name. name of the table in sql database
#' @param ds dataset
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # command to call. this function
#'   testrun_queries(
#'     ds
#'   )
#'   # example input in file `queries.sql` in the directory ds$dir
#'   -- Wieviele Abstimmungsvorlagen gab es seit dem Jahr 1971?
#'   SELECT COUNT(*) as anzahl_vorlagen_in_2000
#'.  FROM abstimmungsvorlagen_seit_1971 as T
#'.  JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
#'.  WHERE S.name_de='Schweiz' AND S.country=TRUE
#' }
testrun_queries <- function(ds) {

  # set up variables
  df <- ds$postgres_export
  dir <- ds$dir
  table_name <- ds$name

  # prepare db connection
  if (ds$db_instance == "postgres") {
    db <- statbotData::postgres_db_connect()
  } else {
    db <- DBI::dbConnect(RSQLite::SQLite(), "")
    prepare_test_db(db, df, table_name)
  }

  # set file pathes
  input_path <- here::here(dir, 'queries.sql')
  output_path <- here::here(dir, 'queries.log')
  log_time_and_environment(ds$status, output_path)

  # read queries
  lines <- readr::read_lines(file = input_path, skip_empty_rows = TRUE)

  # reset all variables
  query <- question <- query_lines <- question_lines <- c()
  count <- 0
  end_of_query_pattern <- ";\\s?$"

  # loop over the input lines
  for (line in lines) {

    # question lines
    if (startsWith(line, "--")) {
      question_lines <- c(question_lines, line)
      next
    }

    # query lines
    query_lines <- c(query_lines, line)

    # add the end of each sql query: get and log the result
    if (stringr::str_detect(line, end_of_query_pattern)) {
      count <- count + 1
      question <- paste(question_lines, collapse = " ")
      query <- paste(query_lines, collapse = " ")
      if (ds$db_instance == "postgres") {
        result <- RPostgres::dbGetQuery(conn = db, query)
      } else {
        result <- DBI::dbGetQuery(conn = db, statement = query)
      }
      log_question_and_query(count, question, query, output_path)
      log_result(result, output_path)
      question_lines <- query_lines <- c()
    }
  }

  # close db connection and report result location
  if (ds$db_instance == "postgres") {
    RPostgres::dbDisconnect(conn = db)
  } else {
    DBI::dbDisconnect(db)
  }

  # inform the caller to where the log has been written
  print(paste(
    "Results for query run on", ds$db_instance, "db have been written to:",
    output_path
  ))
}

#' Writing the sql questinon and query to the output file
#'
#' @param count the number of the query
#'              (to keep track of how many queries there are)
#' @param question the natural language questions that belongs to the query
#' @param query the sql query
#' @param output_path the file where the query results are logged
#'
#' @examples
#' \dontrun{
#'   # command to call. this function
#'   log_question_and_query(
#'     1,
#'     "Wieviele Abstimmungsvorlagen gab es seit dem Jahr 1971?",
#'     "SELECT COUNT(*) as anzahl_vorlagen_in_2000 FROM abstimmungsvorlagen_seit_1971",
#'     output_path
#'   )
#' }
log_question_and_query <- function(count, question, query, output_path) {
  count_line <- paste("Query Nr.", toString(count))
  sprintf(
    fmt = "\n%s\n%s\n%s\n",
    count_line,
    question,
    query
  ) %>% cat(file = output_path, append = TRUE)
}

#' Writing the sql result to the output file
#'
#' Since the reslt is a tibble a different method is used for writing the
#' result.
#'
#' @param result the result of the query
#' @param output_path the file where the query results are logged
#'
#' @examples
#' \dontrun{
#'   # command to call. this function
#'   log_question_and_query(
#'     result,
#'     output_path
#'   )
#' }
log_result <- function(result, output_path) {
  sink(file = output_path, append = TRUE)
  print(result, row.names=FALSE, file = output_path, append = TRUE)
  sink()
}

#' Log environment and time to the output file
#'
#' @param pipleine_status property status of the dataset class ds
#' @param output_path the file where the query results are logged
#'
#' @examples
#' \dontrun{
#' log_question_and_query(ds$status, output_path)
#' }
log_time_and_environment <- function(pipeline_status, output_path) {
  if (pipeline_status %in% c("remote", "uploaded")) {
    env <- "REMOTE"
  } else {
    env <- "LOCAL"
  }
  sink(file = output_path, append = FALSE)
  print(paste0("Environment: ", env, ", Time: ", Sys.time()),
        row.names = FALSE,
        file = output_path,
        append = TRUE)
  sink()
}

#' Preparing the database table for the query test runs
#'
#' The spatial_unit tables is needed for the spatial joins.
#'
#' @param db sql connection
#' @param df tibble that gets loaded as a sql table
#' @param table_name name of the table
#'
#' @examples
#' \dontrun{
#'   # command to call. this function
#'   prepare_db(
#'     db,
#'     df,
#'     'abstimmungsvorlagen_seit_1971'
#'   )
#' }
prepare_test_db <- function(db, df, table_name) {
  spatial_df <- load_spatial_map()
  DBI::dbWriteTable(db, "spatial_unit", spatial_df, overwrite = TRUE)
  DBI::dbWriteTable(db, table_name, df, overwrite = TRUE)
}
