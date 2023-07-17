# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A6")

# download the data -------------------------------------------------------

ds <- download_data(ds)
# get some metadata
BFS::bfs_get_metadata(number_bfs = ds$sheet, language = ds$lang)

# data cleaning -----------------------------------------------------------

### clean names and exclude periods: only years should be kept
ds$data %>%
  janitor::clean_names() %>%
  dplyr::filter(startsWith(periode, "Jahr:")) %>%
  dplyr::rename(jahr = periode) -> ds$data

# add a spatial unit ------------------------------------------------------
ds$data %>%
  dplyr::mutate(spatialunit_uid = spatial_mapping_country())  -> ds$data

## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)

# rename variables --------------------------------------------------------

ds$data %>%
  dplyr::rename(
    "anzahl" = volksabstimmungen_anzahl_vorlagen_nach_thema_seit_1971
  ) -> ds$data
ds$data

# ingest into postgres ----------------------------------------------------
