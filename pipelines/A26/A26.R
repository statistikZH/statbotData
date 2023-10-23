# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::::create_dataset("A26")
ds <- statbotData::::download_data(ds)

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
