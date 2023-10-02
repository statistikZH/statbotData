# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A25")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

# The dataset has missing values represented as "" or "( )"
ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::select(
    jahr = year,
    flache_rebland_rote_europaische_reben_ha = flaeche_rot_euro,
    flache_rebland_kreuzung_rote_weisse_ha = flaeche_rot_kreuz,
    flache_total = flaeche_weiss,
    weinernte_total_hl = ernte_tot,
    weinernte_rot_europaische_hl = ernte_rot_euro,
    weinernte_rot_kreuzung_rot_hl = ernte_rot_kreuz,
    weinernte_europaische_weiss_hl = ernte_weiss,
    erntewert_rot_1000_chf = wert_rot,
    erntewert_weiss_1000_chf = wert_weiss
  )
# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Add spatial unit corresponding to Kanton AG
ds$postgres_export <- ds$postgres_export %>%
  dplyr::mutate(
    spatialunit_uid = "19_A.ADM1"
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
