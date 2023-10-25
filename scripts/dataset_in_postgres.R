# =======================================================================
# Example script for a dataset that is already in postgres
# Goal:
# - run queries for the dataset on postgres
# - check metadata for the dataset that are in postgres
# =======================================================================

# setup dataset class: (change `data_indicator` to the data_indicator
# of your dataset
data_indicator <- "A1"
ds <- statbotData::create_dataset(data_indicator)

# check dataset status
ds$status
# in case the status is `uploaded` the queries will run on postgres
# otherwise the queries will run locally on a db in memory

# testrun queries on postgres
statbotData::testrun_queries(ds)
# you will receive a message about the path to the output file
# the output is in the file `ds$dir/queries.log`

# show the metadata that are stored in postgres
# `ds$name` is the tablename of the dataset in postgres
statbotData::get_metadata_from_postgres(ds$name)
