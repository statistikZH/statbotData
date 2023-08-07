# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
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

ds$data %>%
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
   ) -> ds$cleaned_data
print(ds$cleaned_data)

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping
#   input: ds$cleaned_data
#.  output: ds$spatial_mapping
# --------------------------------------------------------------------------

ds$cleaned_data %>%
  dplyr::select(
    kanton
  ) %>%
  dplyr::distinct(
    kanton
  ) %>%
  statbotData::map_ds_spatial_units(
    c("Country", "Canton")
  ) -> ds$spatial_mapping
ds$spatial_mapping %>% print(n = Inf)

# -------------------------------------------------------------------------
# Step: Apply spatial mapping
#   input: ds$cleaned_data, ds$spatial_mapping
#.  output: ds$postgres_export
# --------------------------------------------------------------------------

ds$cleaned_data %>%
  dplyr::left_join(
    ds$spatial_mapping,
    by = "kanton"
  ) %>%
  dplyr::select(
    -c(kanton)
  ) -> ds$postgres_export
ds$postgres_export

# -------------------------------------------------------------------------
# Step: Testrun queries on sqllite
#   input: ds$postgres_export, A8/queries.sql
#   output: A8/queries.log
# -------------------------------------------------------------------------

statbotData::testrun_queries(
  ds$postgres_export,
  ds$dir,
  ds$name
)