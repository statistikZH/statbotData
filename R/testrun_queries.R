#' Testrun queries
#'
#' the database will just have two table, one that is defined
#' by the provided tibble and the
#' the queries are expected to be read from a file
#' `queries.sql` in the directory `dir`
#'
#' @param df tibble to turn into an sql table
#' @param dir directory to write the output to
#' @param table_name. name of the table in sql database
#'
#' @export
#'
#' @examples
#' #' \dontrun{
#'   # command to call. this function
#'   testrun_queries(ds$data, ds$dir, ds$name)
#'   # example input file `queries.sql`
#'   -- SELECT COUNT(*) from -- Wieviele Abstimmungsvorlagen gab es seit dem Jahr 1971?
#'   SELECT COUNT(*) as anzahl_vorlagen_in_2000
#'.  FROM abstimmungsvorlagen_seit_1971 as T
#'.  JOIN spatial_unit as S on T.spatialunit_uid = S.spatialunit_uid
#'.  WHERE S.name_de='Schweiz' AND S.country=TRUE
#' }
#' #' #' \dontrun{
#'   testrun_queries(ds$data, ds$dir, ds$name)
#' }
testrun_queries <- function(df, dir, table_name) {
  statbotdb <- DBI::dbConnect(RSQLite::SQLite(), "")
  spatial_df <- readr::read_csv("data/const/spatial_unit_postgres.csv",
                                show_col_types = FALSE)
  DBI::dbWriteTable(statbotdb, "spatial_unit", spatial_df, overwrite = TRUE)
  DBI::dbWriteTable(statbotdb, table_name, df, overwrite = TRUE)
  input_path <- paste0(dir, 'queries.sql')
  output_path <- paste0(dir, 'queries.log')
  lines <- readLines(input_path)
  lines <- readr::read_lines(file = input_path, skip_empty_rows = TRUE)
  query <- question <- query_lines <- question_lines <- c()
  append <- FALSE
  divider <- "======================================================="
  for (line in lines) {
    if (startsWith(line, "--")) {
      question_lines <- c(question_lines, line)
    } else {
      query_lines <- c(query_lines, line)
      if (stringr::str_detect(line, ";\\s?$")) {
        question <- paste(question_lines, collapse = " ")
        query <- paste(query_lines, collapse = " ")
        result <- DBI::dbGetQuery(conn = statbotdb, statement = query) %>%
          tibble::as_tibble()
        sprintf(
          fmt = "\n%s\n%s\n%s\n",
          question,
          query,
          divider
        ) %>% cat(file = output_path, append = append)
        question_lines <- query_lines <- c()
        append <- TRUE
        sink(file = output_path, append = append)
        print(result, row.names=FALSE, file = output_path, append = append)
        sink()
      }
    }
  }
  DBI::dbDisconnect(statbotdb)
  if (output_path != "") {
    print(paste(
      "Testrun results have been written to",
      output_path
    ))
  }
}
