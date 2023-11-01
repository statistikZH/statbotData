# -------------------------------------------------------------------------
# Step: Get the data
# input: data/const/statbot_input_data.csv
# output: ds as dataset class
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("B2")
ds <- statbotData::download_data(ds)
ds_boys <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::mutate(gender = "boy")
ds_boys

# get additional datasets for girls
ds$px_id <- "px-x-0104050000_102"
ds$download_url <- "https://www.pxweb.bfs.admin.ch/DownloadFile.aspx?file=px-x-0104050000_102"
ds <- statbotData::download_data(ds)

ds_girls <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::mutate(gender = "girl")
ds_girls

ds$data <- ds_boys %>%
  dplyr::bind_rows(ds_girls)
ds$data

# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
# .  output: ds$cleaned_data: separate data by units
# -------------------------------------------------------------------------

ds$cleaned_data <- ds$data %>%
  dplyr::filter(unit_of_measure == "Number") %>%
  dplyr::rename(
    amount = data_person,
    canton = language_region_canton
  ) %>%
  dplyr::select(
    c(gender, year, canton, first_name, year, amount)
  ) %>%
  dplyr::filter(
    !stringr::str_detect(canton, "speaking")
  )

# Compute rank per year, gender and region
ds$cleaned_data <- ds$cleaned_data %>%
  group_by(gender, canton, year) %>%
  mutate(rank = dplyr::dense_rank(desc(amount)))

# -------------------------------------------------------------------------
# Step: Spatial unit mapping
#   input:  ds$cleaned_data
# .  output: ds$postgres_export
# --------------------------------------------------------------------------

spatial_mapping() <- ds$cleaned_data %>%
  dplyr::select(canton) %>%
  dplyr::distinct(canton) %>%
  statbotData::map_ds_spatial_units(c("Country", "Canton"))
spatial_mapping

ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_mapping, by = "canton") %>%
  dplyr::select(-c(canton))
ds$postgres_export

# testrun queries on postgres
statbotData::testrun_queries(ds)
