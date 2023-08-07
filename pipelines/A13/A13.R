# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A13")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: ds$cleaned_data: data has been cleaned
# -------------------------------------------------------------------------

ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::select(
    -c("beobachtungseinheit")
  )%>%
  dplyr::rename(
    "anzahl_pflanzungen" = anzahl_pflanzungen_in_der_schweiz,
    "eigentumertyp" = eigentumertyp
  ) -> ds$cleaned_data
print(ds$cleaned_data)

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
