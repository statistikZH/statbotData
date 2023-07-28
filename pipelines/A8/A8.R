# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A8")
ds <- statbotData::download_data(ds)
ds$dir <- here::here("pipelines", ds$data_indicator, "")

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: dscleaned_data: spatial unit uid added
# -------------------------------------------------------------------------

ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::rename(
    "anzahl" = nationalratswahlen_parteistimmen_fiktive_wahlende_und_parteistarke_seit_1971_schweiz_und_kantone
  ) %>%
  tidyr::pivot_wider(
    names_from = c("ergebnisse"),
    values_from = anzahl
  ) %>%
  janitor::clean_names(
  ) %>%
  dplyr::rename(
    "parteistarke_in_prozent" = parteistarke_in_percent,
    "anzahl_parteistimmen" = parteistimmen,
    "anzahl_fiktive_wahlende" = fiktive_wahlende,
  ) -> ds$cleaned_data
ds$cleaned_data

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping
#   input: ds$cleaned_data
#.  output: ds$spatial_mapping
# --------------------------------------------------------------------------

ds$cleaned_data %>%
  dplyr::select(
    kanton
  ) %>%
  dplyr::distinct(
    kanton
  ) %>%
  statbotData::map_ds_spatial_units(
    c("Country", "Canton")
  ) -> ds$spatial_mapping
ds$spatial_mapping %>% print(n = Inf)
colnames(ds$spatial_mapping)

# -------------------------------------------------------------------------
# Step: Apply spatial mapping
#   input: ds$cleaned_data, ds$spatial_mapping
#.  output: ds$postgres_export
# --------------------------------------------------------------------------

ds$cleaned_data %>%
  dplyr::left_join(
    ds$spatial_mapping,
    by = "kanton"
  ) %>%
  dplyr::select(
    -c(kanton)
  ) -> ds$postgres_export
ds$postgres_export

# -------------------------------------------------------------------------
# Step: Testrun queries on sqllite
#   input: ds$postgres_export, A8/queries.sql
#   output: A8/queries.log
# -------------------------------------------------------------------------

statbotData::testrun_queries(
  ds$postgres_export,
  ds$dir,
  ds$name
)
