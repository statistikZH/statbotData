# -------------------------------------------------------------------------
# Steps: Get the data
# input:  google sheet
# output: ds$data, ds$dir
#         - use a sparql query to download the data
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset(id = "S3")

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
  FILTER(LANG(?sector) = "de")
  FILTER(LANG(?cofog_broad) = "de")
  FILTER(LANG(?cofog_narrow) = "de")
}
'
ds <- statbotData::download_data(ds)

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
    jahr = period,
    aufgabenbereich_cofog_feingliederung = cofog_narrow,
    aufgabenbereich_cofog_grobgliederung = cofog_broad,
    institutioneller_sektor = sector,
    ausgaben_in_mio_chf = mio_chf_expenditure,
    prozent_der_gesamtausgaben = percent_total_expenditure
  ) %>%
  # add CH as spatial unit
  dplyr::mutate(spatialunit_uid = statbotData::spatial_mapping_country())
