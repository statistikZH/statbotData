# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- create_dataset(id = "A14")
ds <- download_data(ds)

# -------------------------------------------------------------------------
# Step: Clean the data and add spatial unit
#   input: ds$data
#   output: dscleaned_data
# -------------------------------------------------------------------------

### Filter specific products and indicators
# NOTE: We only look at tourism as a whole, and not sectors of tourism.

global_products <- c(
  "Share of tourism of the regional total (in %)",
  "Total of tourism of the economy"
)

indicators <- c(
  "Tourism-connected gross value added (at current prices, in million CHF)",
  "Tourism-related employment (FTE)"
)

# Filter relevant factors and cleanup
ds$cleaned_data <- ds$data %>%
  janitor::clean_names() %>%
  tibble::as_tibble() %>%
  dplyr::filter(product %in% global_products) %>%
  dplyr::filter(indicator %in% indicators) %>%
  dplyr::rename(
    "value" = regional_indicators_of_the_tourism_satellite_accounts
  )

# Pivot to separate employment from CHF values
ds$cleaned_data <- ds$cleaned_data %>%
  tidyr::pivot_wider(names_from = indicator, values_from = value) %>%
  dplyr::rename(
    gross_value_added = "Tourism-connected gross value added (at current prices, in million CHF)",
    employment = "Tourism-related employment (FTE)"
  )

# Pivot again to separate total from percentage
ds$cleaned_data <- ds$cleaned_data %>%
  tidyr::pivot_wider(
    values_from = c(gross_value_added, employment),
    names_from = product,
  ) %>%
  janitor::clean_names()

# Ensure clear column names
ds$cleaned_data <- ds$cleaned_data %>%
  dplyr::rename(
    "mio_chf_gross_value_added_of_tourism" = gross_value_added_total_of_tourism_of_the_economy,
    "total_full_time_employment_of_tourism" = employment_total_of_tourism_of_the_economy,
    "percent_share_gross_value_added_of_tourism" = gross_value_added_share_of_tourism_of_the_regional_total_in_percent,
    "percent_share_full_time_employment_of_tourism" = employment_share_of_tourism_of_the_regional_total_in_percent
  )

# -------------------------------------------------------------------------
# Step: Derive the spatial units mapping
#   input: ds$cleaned_data
#.  output: ds$postgres_export
# --------------------------------------------------------------------------

spatial_map <- ds$cleaned_data %>%
  dplyr::select(canton) %>%
  dplyr::distinct(canton) %>%
  map_ds_spatial_units()

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_map, by = "canton") %>%
  dplyr::select(-canton)
ds$postgres_export

# -------------------------------------------------------------------------
# Step: After the dataset has been build use functions of package
# stabotData to upload the dataset to postgres, testrun the queries,
#  generate a sample, upload the metadata, etc
# -------------------------------------------------------------------------

# generate sample data for the dataset from the local tibble
statbotData::dataset_sample(ds)

# create the table in postgres
statbotData::create_postgres_table(ds)

# add metadata to postgres
statbotData::update_metadata_in_postgres(ds)

# run test queries
statbotData::testrun_queries(ds)
