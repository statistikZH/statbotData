# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A8")

# download the data -------------------------------------------------------

ds <- download_data(ds)
# get some metadata
BFS::bfs_get_metadata(number_bfs = ds$sheet, language = ds$lang)

# data cleaning -----------------------------------------------------------

### clean spatial unit names from artificats
ds$data %>%
  janitor::clean_names() -> ds$data
ds$data

# deriving a tibble with just the spatial units ---------------------------
df_spatial <- ds$data %>%
  dplyr::select(kanton) %>%
  dplyr::distinct(kanton)
df_spatial

# map spatial units and control the mapping -------------------------------
df_spatial <- statbotData::map_ds_spatial_units(
  df_spatial)
df_spatial %>% print(n = Inf)

# map the spatial units to the postgres spatial units ---------------------

ds$data %>%
  dplyr::left_join(df_spatial, by = "kanton") -> ds$data
ds$data
colnames(ds$data)

## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)

# rename variables --------------------------------------------------------

ds$data %>%
  dplyr::rename(
    "stimmen" = nationalratswahlen_parteistimmen_fiktive_wahlende_und_parteistarke_seit_1971_schweiz_und_kantone
  ) %>%
  dplyr::select(-c(kanton)) -> ds$data

# ingest into postgres ----------------------------------------------------


