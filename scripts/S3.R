# create ds object --------------------------------------------------------

ds <- create_dataset(id = "S3")

# query the cube -------------------------------------------------------

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

# data cleaning -----------------------------------------------------------

### clean spatial unit names from artificats
ds$data %>%
  janitor::clean_names() %>%
  dplyr::rename(
    jahr = period,
    aufgabenbereich_des_staates = cofog,
    institutioneller_sektor = sector,
    ausgaben_in_mio_chf = mio_chf_expenditure,
    prozent_der_gesamtausgaben = percent_total_expenditure
  ) -> ds$data
# add CH as spatial unit -------------------------------

ds$data %>%
  dplyr::mutate(spatialunit_uid = statbotData::spatial_mapping_country()) -> ds$data

## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)

# ingest into postgres ----------------------------------------------------
