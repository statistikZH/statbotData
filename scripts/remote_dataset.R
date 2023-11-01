# =======================================================================
# Example Script to upload metadata for a remote datasets
# -----------------------------------------------------------------------
# This script assumes you have entered the dataset that has no pipeline
# but exists only in postgres
# `data/const/statbot_data_input.csv
# Goal:
# - upload the metadata to postgres
# =======================================================================

# setup dataset class: (change `data_indicator` to the data_indicator
# of your dataset

data_indicator <- "B2"
ds <- statbotData::create_dataset(data_indicator)

# -----------------------------------------------------------------------
# STEP 1: Update the metadata to postgres
# -----------------------------------------------------------------------
# get path to the build script for the dataset
pipeline_build_path <- here::here(ds$dir, paste0(data_indicator, ".R"))
pipeline_build_path
# first try whether the metadata are readable form their files
statbotData::read_metadata_tables_from_file(ds)

statbotData::update_metadata_in_postgres(ds)

# -----------------------------------------------------------------------
# STEP 2: Testrun the queries on the updated postgres table
# -----------------------------------------------------------------------
statbotData::testrun_queries(ds)
