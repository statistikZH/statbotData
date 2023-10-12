# -------------------------------------------------------------------------
# Step 0: Get and aggregate the data
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A29")

# The dataset is split into 1 csv file per year, the URL remains the same
# with only the year changing

agg_month <- function(df) {
  # Only measurements from Stampfenbachstrasse are kept
  # (only station available for all years)
  # Exclude parameters that represent a threshold/max value
  # Widen table to have 1 column per parameter
  # Truncate timestamps to month (yyyy-mm)
  # Compute monthly mean for each parameter
  agg <- df %>%
    janitor::clean_names() %>%
    dplyr::filter(
      standort == "Zch_Stampfenbachstrasse",
      !parameter %in% c("O3_nb_h1>120", "O3_max_h1")
    ) %>%
    dplyr::select(-intervall, -status) %>%
    tidyr::pivot_wider(
      names_from = c(parameter, einheit),
      values_from = wert,
      names_glue = "{parameter}_{einheit}"
    ) %>%
    janitor::clean_names(replace = janitor:::mu_to_u) %>%
    dplyr::mutate(datum = substr(datum, 1, 7)) %>%
    dplyr::group_by(datum) %>%
    dplyr::summarise(across(is.numeric, ~ mean(.x, na.rm = T))) %>%
    dplyr::mutate(across(everything(), ~ ifelse(is.nan(.), NA, .))) %>%
    dplyr::rename(nox_ppb = "n_ox_ppb")
  return(agg)
}

# Download + aggregate data from each year
# and collect all years in a single tibble
full_data <- tibble::tibble()
for (year in 1983:2023) {
  # Year is substituted in URL
  ds$download_url <- stringr::str_replace(
    ds$download_url,
    "[0-9]{4}",
    as.character(year)
  )
  # Daily data for a single year aggregated by month
  temp <- statbotData::download_data(ds)$data
  temp <- agg_month(temp)
  # Monthly data for a single year appended to the full dataset
  full_data <- dplyr::bind_rows(full_data, temp)
}
# Overwrite ds$data with the full dataset
ds$data <- full_data

# -------------------------------------------------------------------------
# Step 1: Prepare rename columns
# -------------------------------------------------------------------------

ds$postgres_export <- ds$data %>%
  dplyr::mutate(
    jahr = as.integer(substr(datum, 1, 4)),
    monat = as.integer(substr(datum, 6, 7))
  ) %>%
  dplyr::select(-datum)

# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# All data comes from Stadt Zürich. Explicitely adding UID
ds$postgres_export <- ds$postgres_export %>%
  dplyr::mutate(spatialunit_uid = "253_A.ADM3")

# -------------------------------------------------------------------------
# Step: Upload dataset to postgres, test run queries, generate a sample and
# metadata files.
#   input:  ds$postgres_export, ds$dir/queries.sql
#   output: ds$dir/queries.log
# -------------------------------------------------------------------------

# create the table in postgres
statbotData::create_postgres_table(ds)
# copy the metadata templates to the metadata files and then complete them
statbotData::update_pipeline_last_run_date(ds)
statbotData::update_metadata_in_postgres(ds)
# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)
statbotData::testrun_queries(ds)
