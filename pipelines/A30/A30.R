# -------------------------------------------------------------------------
# Steps: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A30")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

# The file has a header that needs to be removed
# First skip 17 lines, then set 1st row as header
ds$postgres_export <- ds$data %>%
  dplyr::slice(18:n()) %>%
  janitor::row_to_names(row_number = 1)

# Cleanup the column names
ds$postgres_export <- ds$postgres_export %>%
  janitor::clean_names() %>%
  dplyr::rename(
    durschnitt_preis_chf_pro_m2 = durchschnitt,
    quantil_25_preis_chf_pro_m2 = q25,
    quantil_75_preis_chf_pro_m2 = q75,
    median_preis_chf_pro_m2 = median,
  ) %>%
  dplyr::mutate(across(everything(), as.numeric))

# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Manually add spatialunit for Kanton Zürich
ds$postgres_export$spatialunit_uid <- "1_A.ADM1"
