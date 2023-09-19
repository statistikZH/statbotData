# load all the possible data sets
pattern_pipeline_indicator <- '[:upper:][:digit:]+'
pipeline_metadata <- googlesheets4::read_sheet(
  ss = "https://docs.google.com/spreadsheets/d/11V8Qj4v21MleMk_W9ZnP_mc4kmp0CNvsmd9w4A9sTyo/edit?usp=sharing",
  sheet = "tables")

# get all pipeline ids
pipelines <- list.files("pipelines/")

# get the query counts for the pipelines
query_counts <- c()
for (pipeline_indicator in pipelines) {
  query_log_path <- paste0("pipelines/", pipeline_indicator, "/queries.log")
  if (file.exists(query_log_path)) {
    queries <- readr::read_file(query_log_path)
    query_count <- stringr::str_count(queries, "--")
    print(paste(pipeline_indicator, query_count))
    query_counts <- c(query_counts, query_count)
  }
}

# make a tibble with query counts and pipeline indicators
counts <- tibble::tibble(pipelines, query_counts) %>%
  dplyr::rename(pipeline=pipelines)
counts

# join the two tables
choices <- pipeline_metadata %>%
  dplyr::filter(data_indicator %in% pipelines) %>%
  dplyr::select(c(publisher, lang, data_indicator, name)) %>%
  dplyr::rename(pipeline=data_indicator) %>%
  dplyr::left_join(counts, by = "pipeline")
choices

# write a csv file
write.csv(choices, row.names=FALSE, quote=FALSE, file="dataset_and_query_count.csv")
