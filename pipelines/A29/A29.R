# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A29")

# The dataset is split into 1 csv file per year, the URL remains the same
# with only the year changing

agg_month <- function(df) {
  # TODO: Pivot on Parameter
  # TODO: Convert timestamp to datetime -> group by month
  # TODO: summarize for each parameter
  agg <- df
  return(agg)
}

ds
for (year in 1983:2023) {
  ds$download_url <- stringr::str_replace(ds$download_url, "[0-9]{4}", as.character(year))
  temp <- statbotData::download_data(ds)
}

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

# Missing values are denoted as ".", here we can discard them
ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::select(-bfs_nr_gemeinde) %>%
  dplyr::rename(beschaftigte_personen = beschaeftigte_personen) %>%
  dplyr::mutate(beschaftigte_personen = as.numeric(beschaftigte_personen)) %>%
  dplyr::filter(!is.na(beschaftigte_personen))
# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Merge with spatialunits to get a uid for each municipality
spatial_mapping <- ds$postgres_export %>%
  dplyr::select(gemeinde, jahr) %>%
  dplyr::distinct(gemeinde, jahr) %>%
  dplyr::mutate(canton = "TG") %>%
  statbotData::map_ds_municipalities(
    year = jahr,
    canton_abbr = canton,
    municipality_name = gemeinde
  ) %>%
  dplyr::select(gemeinde, jahr, spatialunit_uid) %>%
  dplyr::mutate(jahr = lubridate::year(jahr))


ds$postgres_export <- ds$postgres_export %>%
  dplyr::left_join(spatial_mapping, by = c("gemeinde", "jahr")) %>%
  dplyr::filter(!is.na(spatialunit_uid)) %>%
  dplyr::select(-gemeinde) %>%
  janitor::clean_names()

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
