# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A4")


# download the data -------------------------------------------------------

ds <- download_data(ds)

# read in the spatial data ------------------------------------------------

spatial_unit_df <- readr::read_csv("data/const/spatial_unit_postgres.csv")

# data cleaning -----------------------------------------------------------

### add spatial unit column "Switzerland"
ds$data %>%
  janitor::clean_names() %>%
  tibble::as_tibble() %>%
  dplyr::mutate(raeumliche_ebene = "Schweiz") %>%
  dplyr::rename("beobachtungseinheit" = rubrik,
                "anzahl_terajoule" = tj) -> ds$data

# join the cleaned data to the postgres spatial units table ---------------

ds$data <- ds$data %>%
  dplyr::left_join(dplyr::select(spatial_unit_df, spatialunit_uid, name_de), by = c("raeumliche_ebene" = "name_de"))

## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)


# ingest into postgres ----------------------------------------------------

