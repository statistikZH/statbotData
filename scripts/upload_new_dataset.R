# =======================================================================
# Example Script to upload a new dataset to postgres
# -----------------------------------------------------------------------
# This script assumes you have entered the dataset in
# `data/const/statbot_data_input.csv
# You have build a pipeline in `pipelines/` with a script to
# download the data and build `ds$postgres_export` as a tibble ready
# to be exported to postgres
# Goal:
# - build dataset from origin by setting up a pipeline
# - upload the new dataset to postgres
# - generate metadata templates
# - upload the metadata to postgres
# =======================================================================

# setup dataset class: (change `data_indicator` to the data_indicator
# of your dataset

data_indicator <- "A1"
ds <- statbotData::create_dataset(data_indicator)

# generate metadata template files
statbotData::generate_metadata_templates(ds)
# fill in the missing fields in the metadata files and copy the files
# to `metadata_tables.csv` and `metadata_table_columns.csv`

# -----------------------------------------------------------------------
# STEP 1: Rebuild dataset from origin to get `ds$postgres_export`
# -----------------------------------------------------------------------
# get path to the build script for the dataset
pipeline_build_path <- here::here(ds$dir, paste0(id, ".R"))

# rebuild dataset locally for origin
source(path)
# check that `ds$postgres_export` is set
ds$postgres_export

# create a dataset sample
statbotData::dataset_sample(ds)

# -----------------------------------------------------------------------
# STEP 2: Upload the dataset to postgres
# -----------------------------------------------------------------------
# uncomment the line below and run it
# ------------------------------------------------
# statbotData::create_postgres_table(ds)

# set status of dataset in `data/const/statbot_input_data` to `uploaded`
# check the dataset status
ds_input <- statbotData::load_dataset_list() %>%
  dplyr::filter(data_indicator == ds$data_indicator)
ds_input$status == 'uploaded'

# -----------------------------------------------------------------------
# STEP 3: Update the metadata to postgres
# -----------------------------------------------------------------------

# first try whether the metadata are readable form their files
statbotData::read_metadata_tables_from_file(ds)

statbotData::update_pipeline_last_run_date(ds)
statbotData::update_metadata_in_postgres(ds)

# -----------------------------------------------------------------------
# STEP 4: Testrun the queries on the updated postgres table
# -----------------------------------------------------------------------
statbotData::testrun_queries(ds)
