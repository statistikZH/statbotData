# create ds object --------------------------------------------------------

ds <- create_dataset(id = "A5")


# download the data -------------------------------------------------------

ds <- download_data(ds)

# read in the spatial data ------------------------------------------------

spatial_unit_df <- readr::read_csv("data/const/spatial_unit_postgres.csv")

# data cleaning -----------------------------------------------------------

### add spatial unit column "Switzerland"
ds$data %>%
  janitor::clean_names() %>%
  dplyr::mutate(raeumliche_ebene = "Schweiz") -> ds$data

# join the cleaned data to the postgres spatial units table ---------------

ds$data <- ds$data %>%
  dplyr::left_join(dplyr::select(spatial_unit_df, spatialunit_uid, name_de), by = c("raeumliche_ebene" = "name_de")) %>%
  dplyr::select(-raeumliche_ebene)

## check that each spatial unit could be matched -> this has to be TRUE

assertthat::noNA(ds$data$spatialunit_uid)



# rename variables --------------------------------------------------------


ds$data %>%
  dplyr::rename(
    "anzahl" = anzahl_ahv_renten_rentensumme_und_mittelwert_im_dezember
  ) -> ds$data



# ingest into postgres ----------------------------------------------------

