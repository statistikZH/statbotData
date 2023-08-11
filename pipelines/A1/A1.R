# -------------------------------------------------------------------------
# Step: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A1")
ds <- download_data(ds)
ds$data

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: dscleaned_data: cleaning the data before the spatial
#.                          unit mapping can be applied (removing spatial
#                           hierarchies)
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::filter(
    !stringr::str_detect(grossregion_kanton, "<<")
  ) %>%
  dplyr::rename(
    "genutzte_infrastruktur" = infrastruktur,
    "geraet_oder_untersuchung" = gerate_und_untersuchungen,
    "anzahl" = medizinisch_technische_infrastruktur_anzahl_gerate_und_untersuchungen_in_krankenhausern
  ) %>%
  tidyr::pivot_wider(
    names_from = c("geraet_oder_untersuchung"),
    values_from = anzahl,
    names_prefix = "anzahl_"
  ) %>%
  janitor::clean_names() %>%
  dplyr::rename(
    "anzahl_gerate" = anzahl_anzahl_gerate
  )
ds$cleaned_data

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping
#   input: ds$cleaned_data
#.  output: ds$spatial_mapping
# --------------------------------------------------------------------------

ds$spatial_mapping <- ds$cleaned_data %>%
  dplyr::select(
    grossregion_kanton
  ) %>%
  dplyr::distinct(
    grossregion_kanton
  ) %>%
  statbotData::map_ds_spatial_units(
    c("Country", "Canton")
  )
ds$spatial_mapping %>% print(n = Inf)

# -------------------------------------------------------------------------
# Step: Apply spatial mapping
#   input: ds$cleaned_data, ds$spatial_mapping
#.  output: ds$postgres_export
# --------------------------------------------------------------------------

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(
    ds$spatial_mapping,
    by = "grossregion_kanton"
  ) %>%
  dplyr::select(
    -c(grossregion_kanton)
  )
ds$postgres_export

# -------------------------------------------------------------------------
# Step: Testrun queries on sqllite
#   input: ds$postgres_export, ds$dir/queries.sql
#   output: ds$dir/queries.log
# -------------------------------------------------------------------------

statbotData::testrun_queries(
  ds$postgres_export,
  ds$dir,
  ds$name
)

# -------------------------------------------------------------------------
# Step: Write metadata tables
#   input: ds$postgres_export
#   output: pipelines/A6/metadata.csv
# -------------------------------------------------------------------------

read_write_metadata_tables(ds)

