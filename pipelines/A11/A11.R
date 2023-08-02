# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A11")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: ds$cleaned_data: data has been cleaned
# -------------------------------------------------------------------------

ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::rename(
    "anzahl_auslaendische_grenzganger_innen" = auslandische_grenzganger_innen
  ) %>%
  dplyr::mutate(
    jahr = stringr::str_replace(quartal, 'Q\\d{1}$', '')
  ) %>%
  dplyr::select(
    -c("quartal")
  ) -> df
df

df %>%
  dplyr::group_by(
    jahr,
    geschlecht,
    arbeitsgemeinde
  ) %>%
  dplyr::summarise(
    anzahl_auslaendische_grenzganger_innen=sum(anzahl_auslaendische_grenzganger_innen),
  ) -> df
df
df %>%
  dplyr::filter(
    stringr::str_detect(arbeitsgemeinde, '^\\.{6}')
  ) -> ds$cleaned_data
ds$cleaned_data

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping
#   input: ds$cleaned_data
#.  output: ds$spatial_mapping
# --------------------------------------------------------------------------
ds$cleaned <- df
ds$cleaned_data %>%
  dplyr::select(
    arbeitsgemeinde
  ) %>%
  dplyr::distinct(
    arbeitsgemeinde
  ) -> sp
sp
  statbotData::map_ds_spatial_units(
    c("Municipality")
  ) -> ds$spatial_mapping
ds$spatial_mapping %>% print(n = Inf)

# -------------------------------------------------------------------------
# Step: Apply spatial mapping
#   input: ds$cleaned_data, ds$spatial_mapping
#.  output: ds$postgres_export
# --------------------------------------------------------------------------
ds$cleaned <- df
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
