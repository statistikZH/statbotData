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

ds$postgres_export <- ds$data %>%
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
    "anzahl_abstimmungsvorlagen" = volksabstimmungen_anzahl_vorlagen_nach_thema_seit_1971,
    "thema" = abstimmungsvorlage_thema
  ) %>%
  dplyr::mutate(
    jahr = as.numeric(stringr::str_extract(jahr, "\\d+"))
  )
ds$postgres_export

# -------------------------------------------------------------------------
# Step: Upload to postgres
#   input:  ds$postgres_export
#   output: postgres upload
# -------------------------------------------------------------------------

# check for correct data_types and columns
statbotData::create_postgres_table(ds, dry_run = TRUE)

# when dry run went well: do the update
statbotData::create_postgres_table(ds)

# -------------------------------------------------------------------------
# Step: Testrun queries on sqllite
#   input:  ds$postgres_export, ds$dir/queries.sql
#   output: ds$dir/queries.log
# -------------------------------------------------------------------------

# the queries run on the postgres db if the ds$status is "uploaded"
statbotData::testrun_queries(ds)

# -------------------------------------------------------------------------
# Step: Write metadata tables
#   input:  ds$postgres_export
#   output: ds$dir/metadata_tables.csv
#           ds$dir/metadata_table_columns.csv
#           ds$dir/sample.csv
# -------------------------------------------------------------------------

# read metadata: check: some data_types are not what postgres expects:
#`categorical` -> `varchar`
#`numeric` -> `numeric` or `integer`
statbotData::read_metadata_tables(ds)

# generate metadata templates if needed
# (these don't overwrite existing metadata any more)
statbotData::generate_metadata_templates(ds)

# generate a dataset sample
# this writes a new sample if ds$status is not uploaded
# the sample does not include the postgres primary key "uid"
statbotData::dataset_sample(ds)
