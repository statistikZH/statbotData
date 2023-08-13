sample_path <- paste0("pipelines/", "A6", "/export_sample.csv")
x <- readr::read_csv(sample_path)
x
x %>% dplyr::mutate_all(as.character)
