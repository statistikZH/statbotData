# -------------------------------------------------------------------------
# Steps: Get the data
# input:  google sheet
# output: ds$data, ds$dir
#         - use a sparql query to download the data
# -------------------------------------------------------------------------

ds <- create_dataset(id = "S3")

# query the cube

ds$query <- '
PREFIX schema: <http://schema.org/>
PREFIX cofog: <https://environment.ld.admin.ch/foen/BFS_cofog_national/>
PREFIX cube: <https://cube.link/>


SELECT ?period ?cofog ?sector ?mio_chf_expenditure ?percent_total_expenditure
WHERE {
  cofog:1 cube:observationSet ?observationSet0 .
  ?observationSet0 cube:observation ?source0 .
  ?source0 cofog:cofog [ schema:name ?cofog ] .
  ?source0 cofog:period ?period .
  ?source0 cofog:in-pct ?percent_total_expenditure .
  ?source0 cofog:in-mio-chf ?mio_chf_expenditure .
  ?source0 cofog:sector [ schema:name ?sector ] .

  FILTER(LANG(?sector) = "de")
  FILTER(LANG(?cofog) = "de")
}
'
ds <- download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input:  ds$data
#.  output: ds$postgres_export:
#           - clean columns names
#.          - rename data columns
#.          - map spatial unit (only country exists as spatial unit)
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::rename(
    jahr = period,
    aufgabenbereich_des_staates = cofog,
    institutioneller_sektor = sector,
    ausgaben_in_mio_chf = mio_chf_expenditure,
    prozent_der_gesamtausgaben = percent_total_expenditure
  ) %>%
  # add CH as spatial unit
  dplyr::mutate(spatialunit_uid = statbotData::spatial_mapping_country())

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
#.          ds$dir/sample.csv
# -------------------------------------------------------------------------

read_write_metadata_tables(ds)
dataset_sample(ds)
