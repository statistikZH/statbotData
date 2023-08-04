# -------------------------------------------------------------------------
# Step: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A6")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: ds$postgres_export: spatial unit uid added
# -------------------------------------------------------------------------

ds$data %>%
  dplyr::mutate(
    spatialunit_uid = spatial_mapping_country()
  ) %>%
  janitor::clean_names(
  ) %>%
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
  ) -> ds$postgres_export
ds$postgres_export

# -------------------------------------------------------------------------
# Step: Testrun queries on sqllite
#   input: ds$postgres_export, A6/queries.sql
#   output: A6/queries.log
# -------------------------------------------------------------------------

statbotData::testrun_queries(
  ds$postgres_export,
  ds$dir,
  ds$name
)
