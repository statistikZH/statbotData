# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A24")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

# The dataset has missing values represented as "" or "( )"
ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::filter(location_type %in% c("TOWNSHIP", "CANTON")) %>%
  dplyr::select(
    location_name, location_type, year, pers_wagen, cars_klbusse, nutzfz, arb_motorfz, motorr, kl_motorr, motorfahrr, landw_motorfz, anhaenger, kollek_fz, mot_grad
  )
# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Matching spatialunit uid to municipality/year/canton. Note that the same
# municipality can have different uid at different years (e.g. in case of
# merging/splitting municipalities).
municipality_mapping <- ds$postgres_export %>%
  dplyr::filter(location_type == "TOWNSHIP") %>%
  dplyr::select(location_name, year) %>%
  dplyr::distinct(location_name, year) %>%
  dplyr::mutate(canton = "AG") %>%
  statbotData::map_ds_municipalities(
    year = year,
    canton_abbr = canton,
    municipality_name = location_name
  ) %>%
  dplyr::select(location_name, year, spatialunit_uid) %>%
  dplyr::mutate(year = lubridate::year(year))

cantonal_data <- ds$postgres_export %>%
  dplyr::filter(location_type == "CANTON") %>%
  dplyr::mutate(spatialunit_uid = "19_A.ADM1")

ds$postgres_export <- ds$postgres_export %>%
  dplyr::filter(location_type == "TOWNSHIP") %>%
  dplyr::left_join(municipality_mapping, by = c("location_name", "year")) %>%
  dplyr::bind_rows(cantonal_data) %>%
  dplyr::filter(!is.na(spatialunit_uid)) %>%
  dplyr::select(-location_name, -location_type) %>%
  janitor::clean_names()

# -------------------------------------------------------------------------
# Step 3 clean names and remove columns
# -------------------------------------------------------------------------

ds$postgres_export <- ds$postgres_export %>%
  dplyr::rename(
    jahr = year,
    anzahl_personenwagen = pers_wagen,
    anzahl_ubrige_personen_transportfahrzeuge_kleinbusse_cars = cars_klbusse,
    anzahl_nutzfahrzeuge = nutzfz,
    anzahl_arbeitsmotorfahrzeuge = arb_motorfz,
    anzahl_motorrader = motorr,
    anzahl_klein_motorrader = kl_motorr,
    anzahl_motorfahrrader = motorfahrr,
    anzahl_landwirtschaftliche_motorfahrzeuge = landw_motorfz,
    anzahl_anhaenger = anhaenger,
    anzahl_kollektivfahrzeuge = kollek_fz,
    anzahl_personenwagen_pro_1000_einwohner = mot_grad
  )
