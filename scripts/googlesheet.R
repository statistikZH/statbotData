# Google sheet
pipeline_metadata <- googlesheets4::read_sheet(
  ss = "https://docs.google.com/spreadsheets/d/11V8Qj4v21MleMk_W9ZnP_mc4kmp0CNvsmd9w4A9sTyo/edit?usp=sharing",
  sheet = "tables")
pipelines <- list.files("pipelines/")
pipeline_metadata
choices <- pipeline_metadata %>%
  dplyr::filter(data_indicator %in% pipelines) %>%
  dplyr::select(c(data_indicator, name, publisher, lang)) %>%
  dplyr::mutate(selector = paste(data_indicator, name, publisher, lang))
choices$selector
pipeline_indicator <- stringr::str_extract(choices$selector[12], '[:upper:][:digit:]+')
pipeline_indicator
