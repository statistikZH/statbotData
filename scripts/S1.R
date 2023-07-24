# create ds object --------------------------------------------------------

ds <- create_dataset(id = "S1")

# query the cube -------------------------------------------------------

ds$query <- '
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cube: <https://cube.link/>
PREFIX dim: <https://energy.ld.admin.ch/elcom/electricityprice/dimension/>
PREFIX schema: <http://schema.org/>

# Median elecricity price per canton

SELECT ?canton ?period ?category ?product ?total
WHERE {
  <https://energy.ld.admin.ch/elcom/electricityprice-canton> cube:observationSet ?obsSet .
  ?obsSet cube:observation ?obs .
  ?obs dim:canton [ schema:name ?canton ] ;
       dim:period ?period ;
       dim:product [ schema:name ?product ] ;
       dim:category [ schema:description ?cat_desc ; schema:name ?cat_name ] ;
       dim:total ?total  .

  BIND(CONCAT(?cat_name, ": (", ?cat_desc, ")") AS ?category)
  FILTER(LANG(?canton) = "de")
  FILTER(LANG(?product) = "de")
  FILTER(LANG(?cat_desc) = "de")
}
'
ds <- download_data(ds)

# data cleaning -----------------------------------------------------------

### clean spatial unit names from artificats
ds$data %>%
  janitor::clean_names() %>%
  dplyr::rename(
    mittlerer_preis_rappen_pro_kw_hr = total,
    kanton = canton,
    energieprodukt = product,
    verbrauchskategorien = category,
    jahr = period,
  ) -> ds$data

# map spatial units -------------------------------

spatial_map <- ds$data %>%
  dplyr::select(kanton) %>%
  dplyr::distinct(kanton) %>%
  map_ds_spatial_units()

ds$data %>%
  dplyr::left_join(spatial_map, by = "kanton") %>%
  dplyr::select(-kanton) -> ds$data


## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)

# ingest into postgres ----------------------------------------------------
