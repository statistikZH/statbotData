# -------------------------------------------------------------------------
# Steps: Get the data
# input:  data/const/statbot_input_data.csv
# output: ds$data, ds$dir
#         - use a sparql query to download the data
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset(id = "S1")

# query the cube

ds$query <- '
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cube: <https://cube.link/>
PREFIX dim: <https://energy.ld.admin.ch/elcom/electricityprice/dimension/>
PREFIX schema: <http://schema.org/>

# Median elecricity price per canton

SELECT ?canton ?period ?cat_name ?cat_size ?cat_desc ?product ?total
WHERE {
  <https://energy.ld.admin.ch/elcom/electricityprice-canton> cube:observationSet ?obsSet .
  ?obsSet cube:observation ?obs .
  ?obs dim:canton [ schema:name ?canton ] ;
    dim:period ?period ;
    dim:product [ schema:name ?product ] ;
    dim:category [
      schema:description ?cat_desc ;
      schema:name ?cat_name ;
      schema:size ?cat_size
    ] ;
    dim:total ?total  .

  FILTER(LANG(?canton) = "de")
  FILTER(LANG(?product) = "de")
  FILTER(LANG(?cat_desc) = "de")
}
'
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input:  ds$data
# .  output: ds$cleaned_data:
#           - clean columns names
# .          - rename data columns
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::rename(
    mittlerer_preis_rappen_pro_kwh = total,
    kanton = canton,
    energieprodukt = product,
    verbrauchskategorie = cat_name,
    verbrauchskategorie_grosse_kwh_pro_jahr = cat_size,
    verbrauchskategorie_beschreibung = cat_desc,
    jahr = period,
  )

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping and map the spatial units
#   input:  ds$cleaned_data
# .  output: ds$postgres_export
# -------------------------------------------------------------------------

spatial_map <- ds$cleaned_data %>%
  dplyr::select(kanton) %>%
  dplyr::distinct(kanton) %>%
  statbotData::map_ds_spatial_units()

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_map, by = "kanton") %>%
  dplyr::select(-kanton)
colnames(ds$postgres_export)
