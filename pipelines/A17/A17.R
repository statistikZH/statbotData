# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds as dataset class
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A17")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: ds$cleaned_data: data has been cleaned:
#.  - factor `ergebnis` spilt into wide format
#.  - `datum_und_vorlage` split into `jahr` and `vorlage_title`
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::mutate(
    "jahr" = stringr::str_extract(datum_und_vorlage, '^\\d{4}')
  ) %>%
  dplyr::mutate(
    "vorlage_title" = stringr::str_replace(datum_und_vorlage, '^\\d{4}-\\d{2}-\\d{2} ', "")
  ) %>% dplyr::select(
    -c(datum_und_vorlage)
  ) %>%
  dplyr::rename(
    "anzahl" = volksabstimmungen_ergebnisse_ebene_kanton_seit_1866
  ) %>%
  tidyr::pivot_wider(
    names_from = c("ergebnis"),
    values_from = anzahl
  ) %>%
  janitor::clean_names(
  ) %>%
  dplyr::rename(
    "anzahl_stimmberechtigte" = stimmberechtigte,
    "anzahl_abgegebene_stimmen" = abgegebene_stimmen,
    "beteiligung_in_prozent" = beteiligung_in_percent,
    "anzahl_gueltige_stimmzettel" = gultige_stimmzettel,
    "anzahl_ja_stimmen" = ja,
    "anzahl_nein_stimmen" = nein,
    "ja_in_prozent" = ja_in_percent
   )

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping and map the spatial units
#   input:  ds$cleaned_data
#.  output: ds$postgres_export
# -------------------------------------------------------------------------

spatial_map <- ds$cleaned_data %>%
  dplyr::select(kanton) %>%
  dplyr::distinct(kanton) %>%
  map_ds_spatial_units()

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_map, by = "kanton") %>%
  dplyr::select(-kanton)
ds$postgres_export

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package stabotData
# to upload the dataset to postgres, testrun the queries, generate a sample
# upload the metadata, etc
# -------------------------------------------------------------------------

# testrun queries
statbotData::testrun_queries(ds)

# create the table in postgres
statbotData::create_postgres_table(ds)

# add the metadata to postgres
statbotData::update_metadata_in_postgres(ds)

# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)
