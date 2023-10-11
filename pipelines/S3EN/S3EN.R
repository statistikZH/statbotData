# -------------------------------------------------------------------------
# Steps: Get the data
# input:  google sheet
# output: ds$data, ds$dir
#         - use a sparql query to download the data
# -------------------------------------------------------------------------

ds <- create_dataset(id = "S3EN")

# query the cube

ds$query <- '
PREFIX schema: <http://schema.org/>
PREFIX cofog: <https://environment.ld.admin.ch/foen/BFS_cofog_national/>
PREFIX cube: <https://cube.link/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?period ?cofog_narrow ?cofog_broad ?sector ?mio_chf_expenditure ?percent_total_expenditure
WHERE {
  cofog:1 cube:observationSet ?observationSet0 .

  ?observationSet0 cube:observation ?source0 .

  ?source0
    cofog:cofog ?cofog_narrow_uri ;
    cofog:period ?period ;
    cofog:in-pct ?percent_total_expenditure ;
    cofog:in-mio-chf ?mio_chf_expenditure ;
    cofog:sector [ schema:name ?sector ] .

  # COFOG has multiple levels of classification, here we use 2 (narrowest and one above)
  ?cofog_narrow_uri
    schema:name ?cofog_narrow ;
    skos:broader ?cofog_broad_uri .

  ?cofog_broad_uri schema:name ?cofog_broad .

  # Ensure that cofog_narrow is the most specific cofog classification available
  FILTER NOT EXISTS { ?x skos:broader ?cofog_narrow_uri } .

  # Only include german language data
  FILTER(LANG(?sector) = "en")
  FILTER(LANG(?cofog_broad) = "en")
  FILTER(LANG(?cofog_narrow) = "en")
}
'
ds <- download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input:  ds$data
# .  output: ds$postgres_export:
#           - clean columns names
# .          - rename data columns
# .          - map spatial unit (only country exists as spatial unit)
# -------------------------------------------------------------------------

# cofog_narrow and cofog_broad are known as groups and divisions, respectively
# Source: https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Glossary:Classification_of_the_functions_of_government_(COFOG)

ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::rename(
    year = period,
    function_cofog_narrow = cofog_narrow,
    function_cofog_broad = cofog_broad,
    institutional_sector = sector,
    expenses_in_million_chf = mio_chf_expenditure,
    percentage_of_total_expenses = percent_total_expenditure
  ) %>%
  dplyr::mutate(
    institutional_sector = dplyr::case_when(
      institutional_sector == "General government" ~ "Government",
      institutional_sector == "State government" ~ "Canton",
      institutional_sector == "Local government" ~ "Commune",
      institutional_sector == "Central government" ~ "Confederation",
      institutional_sector == "Social security funds" ~ "Social security funds"
    )
  ) %>%
  # add CH as spatial unit
  dplyr::mutate(spatialunit_uid = statbotData::spatial_mapping_country())

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package stabotData
# to upload the dataset to postgres, testrun the queries, generate a sample
# upload the metadata, etc
# -------------------------------------------------------------------------

# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)

# create the table in postgres
statbotData::create_postgres_table(ds)

# add metadata to postgres
statbotData::update_metadata_in_postgres(ds)

# run test queries
statbotData::testrun_queries(ds)
