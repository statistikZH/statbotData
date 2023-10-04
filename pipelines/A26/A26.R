# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A26")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

# Specific columns are renamed manually to make names clearer
# Append the unit to all columns names ending in schaden or anzahl
ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::select(
    jahr = year,
    total_anzahl,
    total_schaden,
    feuerzeug_rauchzeug_licht_anzahl = feuerzeug_anzahl,
    feuerzeug_rauchzeug_licht_schaden = feuerzeug_schaden,
    elektrizitaet_anzahl,
    elektrizitaet_schaden,
    vorsatzliche_brandstift_anzahl = brandstift_anzahl,
    vorsatzliche_brandstift_schaden = brandstift_schaden,
    feuerungsanlagen_anzahl = feuerungsanl_anzahl,
    feuerungsanlagen_schaden = feuerungsanl_schaden,
    explosion_anzahl,
    explosion_schaden,
    uebrige_anzahl,
    uebrige_schaden,
    unbekannt_anzahl,
    unbekannt_schaden
  ) %>%
  dplyr::rename_with(
    ~ paste0(.x, "_schadenfalle"),
    dplyr::ends_with("_anzahl")
  ) %>%
  dplyr::rename_with(
    ~ paste0(.x, "_1000_chf"),
    dplyr::ends_with("_schaden")
  )
# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Add spatial unit corresponding to Kanton AG
ds$postgres_export <- ds$postgres_export %>%
  dplyr::mutate(
    spatialunit_uid = "19_A.ADM1"
  )


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
