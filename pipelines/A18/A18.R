# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A18")
ds <- statbotData::download_data(ds)
ds$data
# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: ds$cleaned_data: data has been cleaned:
#.  - factor `ergebnis` spilt into wide format
#.  - `datum_und_vorlage` split into `jahr` and `vorlage_title`
# -------------------------------------------------------------------------
dff <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::mutate(name = stringr::str_replace(.$stadt_agglomeration, ":.*", "")) %>%
  dplyr::select(-stadt_agglomeration) %>%
  na.omit()

dff_split <- split(dff, dff$resultat)

dff_wert <- dff_split[1]$Wert
dff_vi <- dff_split[2]$`Vertrauensintervall ± (in %, bzw. %-Punkten)`

dff_wer_vi_joined <- dplyr::left_join(x = dff_wert, y = dff_vi, by = c("name", "jahr", "variable"))

dff_cln <- dff_wer_vi_joined %>%
  dplyr::select(-resultat.x,
         -resultat.y) %>%
  dplyr::rename(var_name = "variable",
         value = "data_gemass_variable.x",
         ci = "data_gemass_variable.y")


dff_cln$spatialunit_ontology = "Municipality"

map_df <- readr::read_csv("data/const/spatial_unit_postgres.csv")



ds$cleaned_data <- dff_cln

######


spatial_map <- ds$cleaned_data %>%
  dplyr::select(name) %>%
  dplyr::distinct(name) %>%
  map_ds_spatial_units(., spatial_dimensions = c("Country", "Municipality"))

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_map, by = "Municipality") %>%
  dplyr::select(-Municipality)

dff_psql <- ds$postgres_export


map_df <- readr::read_csv("data/const/spatial_unit_postgres.csv")

statbotData::map_ds_spatial_units()

dff$stadt_agglomeration
  dplyr::select(
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
