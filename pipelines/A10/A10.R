# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::::create_dataset("A10")
ds <- statbotData::::download_data(ds)

# -------------------------------------------------------------------------
# Step: Map Crminal offences to categories
#   input:  ds$data
#.  output: dsoffences
# -------------------------------------------------------------------------

df_offences_and_categories <- ds$data %>%
  janitor::clean_names(
  ) %>%
  dplyr::select(
    c(offence)
  ) %>% dplyr::distinct(
    offence
  )

# Regular expression pattern to match the crime codes
pattern_offence <- "\\(art\\.\\s?(\\d+)"
pattern_category_offence <- "^total"

df_offence_mapping <- df_offences_and_categories %>%
  dplyr::filter(grepl(pattern_offence, offence)) %>%
  dplyr::mutate(category = "")

# Iterate through the crime vector to create the mapping
offence_mapping <- list()
for (offence in rev(df_offences_and_categories$offence)) {
  if (grepl("^Total", offence)) {
    category <- offence %>% stringr::str_remove("^Total[:blank:]Title[:blank:][:alpha:]*:[:blank:]")
  } else if (grepl(pattern_offence, offence)) {
    offence_mapping[[offence]] <- category
  }
}

# Fill the 'titel' column in the tibble based on the mapping
for (i in seq_along(df_offence_mapping$offence)) {
  mapping_key <- df_offence_mapping$offence[i]
  if (mapping_key %in% names(offence_mapping)) {
    df_offence_mapping$category[i] <- offence_mapping[[mapping_key]]
  }
}

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data, df_offence_mapping
#.  output: ds$cleaned_data
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::filter(
    !stringr::str_starts(offence, "Total")
  ) %>%
  dplyr::rename(
    "number_criminal_offences" = criminal_offences_registered_by_the_police_according_to_the_swiss_criminal_code,
  ) %>%
  dplyr::left_join(df_offence_mapping, by = "offence") %>%
  tidyr::pivot_wider(
    names_from = c("level_of_completion", "level_of_detection"),
    values_from = number_criminal_offences,
    names_prefix = "number_criminal_offences"
  ) %>%
  janitor::clean_names() %>%
  dplyr::rename(
    number_criminal_offences_registered = number_criminal_offences_level_of_completion_total_level_of_detection_total,
    number_criminal_offences_unsolved = number_criminal_offences_level_of_completion_total_unsolved,
    number_criminal_offences_solved = number_criminal_offences_level_of_completion_total_solved,
    number_criminal_offences_completed = number_criminal_offences_completed_level_of_detection_total,
    number_criminal_offences_attempted = number_criminal_offences_attempted_level_of_detection_total,
    offence_category = category,
    offence_criminal_code = offence
  )

# -------------------------------------------------------------------------
# Step: Spatial unit mapping
#   input:  ds$cleaned_data
#.  output: ds$postgres_export
# --------------------------------------------------------------------------

spatial_mapping <- ds$cleaned_data %>%
  dplyr::select(canton) %>%
  dplyr::distinct(canton) %>%
  statbotData::map_ds_spatial_units(c("Country", "Canton"))

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_mapping, by = "canton") %>%
  dplyr::select(-c(canton))
