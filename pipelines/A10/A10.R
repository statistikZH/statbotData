# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A10")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step: Map Crminal offences to categories
#   input:  ds$data
#.  output: dsoffences
# -------------------------------------------------------------------------

df_offences_and_categories <- ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::select(
    c(straftat)
  ) %>% dplyr::distinct(
    straftat
  )

# Regular expression pattern to match the crime codes
pattern_offence <- "\\(Art\\. (\\d+)"
pattern_category_offence <- "^Total"

df_offence_mapping <- df_offences_and_categories %>%
  dplyr::filter(grepl(pattern_offence, straftat)) %>%
  dplyr::mutate(kategorie = "")

# Iterate through the crime vector to create the mapping
offence_mapping <- list()
categorie <- NULL
for (offence in rev(ds_offences_and_categories$straftat)) {
  if (grepl("^Total", offence)) {
    category <- offence %>% stringr::str_remove("^Total [:digit:]*\\.[:blank:]Titel:[:blank:]")
  } else if (grepl(pattern_offence, offence)) {
    offence_mapping[[offence]] <- category
  }
}

# Fill the 'titel' column in the tibble based on the mapping
for (i in seq_along(df_offence_mapping$straftat)) {
  mapping_key <- df_offence_mapping$straftat[i]
  if (mapping_key %in% names(offence_mapping)) {
    df_offence_mapping$kategorie[i] <- offence_mapping[[mapping_key]]
  }
}
df_offence_mapping

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data, df_offence_mapping
#.  output: ds$cleaned_data
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::filter(
    !stringr::str_starts(straftat, "Total")
  ) %>%
  dplyr::rename(
    "anzahl_straftaten" = polizeilich_registrierte_straftaten_gemass_strafgesetzbuch
  ) %>%
  dplyr::left_join(df_offence_mapping, by = "straftat")
ds$cleaned_data

# -------------------------------------------------------------------------
# Step: Spatial unit mapping
#   input:  ds$cleaned_data
#.  output: ds$postgres_export
# --------------------------------------------------------------------------

spatial_mapping <- ds$cleaned_data %>%
  dplyr::select(kanton) %>%
  dplyr::distinct(kanton) %>%
  statbotData::map_ds_spatial_units(c("Country", "Canton"))

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_mapping, by = "kanton") %>%
  dplyr::select(-c(kanton))
ds$postgres_export

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
#           ds$dir/sample.csv
# -------------------------------------------------------------------------

read_write_metadata_tables(ds)
dataset_sample(ds)
