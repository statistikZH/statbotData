# =======================================================================
# Example Script for operations on all datasets
# Goal:
# - list all tables in postgres
# - list datasets that have metadata in postgres
# - list all statbot input datasets
# =======================================================================

# list all tables that are currently in postgres
tables_in_postgres <- statbotData::list_tables_in_statbot_db()

# list all tables that have metadata in postgres
tables_with_metadata_in_postgres <- statbotData::list_tables_with_metadata_in_statbot_db()

# load all datasets from the statbot dataset input list
dataset_input_list <- statbotData::load_dataset_list()
