# =======================================================================
# Example script to upload a new dataset to postgres
# -----------------------------------------------------------------------
# This script assumes your dataset and metadata is already in postgres
# but you have changed the dataset locally and want to update the
# dataset and metadata in the statbot postgress db
# Goal:
# - rebuild dataset from origin by running its pipeline
# - delete old table in postgres
# - upload new dataset to postgres
# - check metadata that are on file: are they still up to data
# - delete old metadata if necessary
# - reupload metadata to postgres if necessary
# =======================================================================

# setup dataset class: (change `id` to the id of your pipeline)
id <- "A1"
ds <- statbotData::create_dataset(id)

# you might need to work in the pipeline directory first:
# - ds$dir/ds$data_indicator.R produces ds$postgres_export
# - adapt ds$dir/metadata_tables.csv and ds$dir/metadata_table_colums.csv
# - adapt ds$dir/queries.sql
# -----------------------------------------------------------------------
# STEP 1: rebuild dataset from origin to get `ds$postgres_export`
# -----------------------------------------------------------------------
# get path to the build script for the dataset
pipeline_build_path <- here::here(ds$dir, paste0(id, ".R"))

# rebuild dataset locally for origin
source(path)
# check that `ds$postgres_export` is set
ds$postgres_export

# create a new dataset sample
statbotData::dataset_sample(ds)

# -----------------------------------------------------------------------
# STEP 2: Reupload the dataset to postgres
# -----------------------------------------------------------------------
# ------------------------------------------------
statbotData::delete_table_in_postgres(ds$name)
statbotData::create_postgres_table(ds)

# -----------------------------------------------------------------------
# STEP 3: Update the metadata to postgres
# -----------------------------------------------------------------------

# first try whether the metadata are readable form their files
statbotData::read_metadata_tables_from_file(ds)

statbotData::delete_metadata_from_postgres(ds$name)
statbotData::update_pipeline_last_run_date(ds)
statbotData::update_metadata_in_postgres(ds)

# -----------------------------------------------------------------------
# STEP 4: Testrun the queries on the updated postgres db
# -----------------------------------------------------------------------
statbotData::testrun_queries(ds)
