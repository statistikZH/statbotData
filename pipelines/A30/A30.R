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
  )

# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Manually add spatialunit for Kanton Zürich
ds$postgres_export$spatialunit_uid <- "1_A.ADM1"
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
