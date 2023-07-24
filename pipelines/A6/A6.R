# -------------------------------------------------------------------------
# Pipeline
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A6")
ds <- statbotData::download_data(ds)
a6_dir <- paste0(getwd(), '/pipelines/a6/')
a6_table_name <- 'abstimmungsvorlagen_seit_1971'
ds$data_cleaned <- a6_clean_data(ds$data)
ds$data_export <- a6_spatial_transformation(ds$data_cleaned)
a6_samples(ds$data_export, a6_dir, a6_table_name)
a6_execute_queries(ds$data_export, a6_dir, a6_table_name)

# -------------------------------------------------------------------------
# Function: clean the data
# -------------------------------------------------------------------------

a6_clean_data <- function(df) {
  df %>%
    janitor::clean_names() %>%
    dplyr::filter(
      startsWith(periode, "Jahr:")
    ) %>%
    dplyr::rename(
      jahr = periode
    ) %>%
    dplyr::rename(
      "anzahl_vorlagen" = volksabstimmungen_anzahl_vorlagen_nach_thema_seit_1971
    ) %>%
    dplyr::mutate(
      jahr = as.numeric(stringr::str_extract(jahr, "\\d+"))
    ) -> df_cleaned
  return(df_cleaned)
}


# -------------------------------------------------------------------------
# Function: spatial transformation
# -------------------------------------------------------------------------

a6_spatial_transformation <- function(df) {
  df %>%
    dplyr::mutate(
      spatialunit_uid = spatial_mapping_country()
    ) %>%
    dplyr::mutate(
      land = "Schweiz"
    )  -> df_export
  return(df_export)
}

# -------------------------------------------------------------------------
# Function: prepare sample for chatgpt
# -------------------------------------------------------------------------

a6_samples <- function(df, dir, table_name) {
  df %>%
    dplyr::select(
      -c(spatialunit_uid)
    ) -> ds$sample
  sample_rows <- sample(1:dim(ds$data_export)[1], 40)
  ds$sample <- ds$sample[sample_rows,]
  write.table(
    ds$sample,
    sep = "|",
    file = paste0(dir, table_name, ".csv"),
    row.names = FALSE,
    quote = FALSE
  )
}

# -------------------------------------------------------------------------
# Function: Load data into postgres and try queries
# -------------------------------------------------------------------------

a6_execute_queries <- function(df, dir, table_name) {
  statbotdb <- DBI::dbConnect(RSQLite::SQLite(), "statbot.sqlite")
  DBI::dbWriteTable(statbotdb, table_name, df, overwrite = TRUE)
  path <- paste0(dir, 'queries.sql')
  lines <- readLines(path)
  count = 0
  for (line in lines) {
    if (startsWith(line, "--")) {
      count <- count + 1
      print(paste(count, line))
    } else {
      print(line)
      result <- DBI::dbGetQuery(statbotdb, line)
      print(result, row.names = FALSE)
    }
  }
  DBI::dbDisconnect(statbotdb)
}
