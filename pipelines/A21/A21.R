# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A21")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  tidyr::pivot_wider(names_from = "indikator", values_from = "wert") %>%
  dplyr::select(-bfs_nummer)

# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------


# Matching spatialunit uid to municipality/year/canton. Note that the same
# municipality can have different uid at different years (e.g. in case of
# merging/splitting municipalities).
spatial_mapping <- ds$postgres_export %>%
  dplyr::select(gemeinde, jahr) %>%
  dplyr::distinct(gemeinde, jahr) %>%
  dplyr::mutate(canton = "BL") %>%
  statbotData::map_ds_municipalities(
    year = jahr,
    canton_abbr = canton,
    municipality_name = gemeinde
  ) %>%
  dplyr::select(gemeinde, jahr, spatialunit_uid) %>%
  dplyr::mutate(jahr = lubridate::year(jahr))


# -------------------------------------------------------------------------
# Step 3 clean names and remove columns
# -------------------------------------------------------------------------

# Note: we drop records without spatialunit_uid this happens for record
# with an invalid municipality - date combination (according to spatialunits)
# It only happens for ~40 records in 1990 in municipalities whose name were valid later
# in spatialunits.
ds$postgres_export <- ds$postgres_export %>%
  dplyr::left_join(spatial_mapping, by = c("gemeinde", "jahr")) %>%
  dplyr::filter(!is.na(spatialunit_uid)) %>%
  dplyr::select(-gemeinde) %>%
  janitor::clean_names() %>%
  dplyr::rename(
    endverbrauch_elektrizitaet_mwh = endverbrauch_elektrizitaet_m_wh
  )

colnames(ds$postgres_export)

# -------------------------------------------------------------------------
# Step: Testrun queries on sqllite
#   input:  ds$postgres_export, ds$dir/queries.sql
#   output: ds$dir/queries.log
# -------------------------------------------------------------------------

statbotData::testrun_queries(
  ds$postgres_export,
  ds$dir,
  ds$name
)

# -------------------------------------------------------------------------
# Step: Write metadata tables
#   input:  ds$postgres_export
#   output: ds$dir/metadata_tables.csv
#           ds$dir/metadata_table_columns.csv
#           ds$dir/sample.csv
# -------------------------------------------------------------------------

read_write_metadata_tables(ds)
dataset_sample(ds)
