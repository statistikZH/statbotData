# Install libraries for downloading and parsing px files
# --------------------------------------------------------
# Most of these packages can directly be added with `use_package`
# The SDSC-ORD packages should be made ready to be added on CRAN
devtools::install_github("SDSC-ORD/fsopxRLoc")
devtools::install_github("SDSC-ORD/pxRRead")
library(fsopxRLoc)
library(pxRRead)

# Get the dataset from the pipeline
# --------------------------------------------------------
# only the px_id is needed to process the dataset
# directories are prepared for the processed dataset
# and for the dataset download
# The processed dataset should be in a form where
# it can be directly added to postgres: observation by
# observation: the columnnames should match the
# columnnames of the postgres table
ds_id <- "A1"
ds <- create_dataset(ds_id)
print(ds$sheet)
px_id <- ds$sheet
dir_id <- paste0("ds-", ds_id)
download_dir <- paste0(getwd(), '/DsDownloads/', dir_id, '/')
processed_dir <- paste0(getwd(), '/DsProcessed/', dir_id, '/')
dir.create(download_dir, showWarnings = FALSE)
dir.create(processed_dir, showWarnings = FALSE)


# Get Mapping of spatial data from postgres table
# ------------------------------------------------
# for now these spatial data have been added as a file
# But later these should be directly added form postgres

# a function to clean the spatial names is defined
clean_name <- function(name) {
  str_replace_all(name,"Kanton ", "") %>% make_clean_names()
}

# the spatial mapping is read from file
map_path <- paste0(getwd(), '/data/', 'spatial.csv')

spatial_unit_list <- read.csv(map_path) %>%
  as_tibble() %>%
  subset(select = -c(type)) %>%
  dplyr::rowwise() %>%
  mutate(name_de_cleaned = clean_name(name_de)) %>%
  subset(select = -c(name_de)) %>%
  relocate(name_de_cleaned) %>%
  deframe() %>%
  as.list

# Download the px cube
# ------------------------------------------------
# The package used for that should be added to Cran
# to make sure it can be easily installed
downloaded_ds <- fsopxRLoc::download_px_cube(px_id, download_dir)

# Parse the px cube from the downloaded file
# ------------------------------------------------
# The package used for that should be added to Cran
# to make sure it can be easily installed
parsed_ds <- scan_px_file(downloaded_ds,
                          locale = "de",
                          output_dir = processed_dir)

# The spatial mapping needs to be done
# ------------------------------------------------
# Each observation has a spatial unit that needs to
# be mapped to the spatial unit in postgres
# Also the column names are cleaned up as they will
# become the column name of the resulting postgres table
# that the dataset is mapped to

# Clean columnnames
df_clean <- parsed_ds$dataframe %>% clean_names()
df_clean

# Define a function for the mapping
# with a list: the search_string is mapped to
# a name in the list and the value for that name is returned
find_match <- function(list_obj, search_string) {
  print(search_string)
  search_terms <- str_split_1(as.character(search_string), "_")
  for (term in search_terms) {
    matching_names <- grep(term, names(list_obj), ignore.case = TRUE, value = TRUE)
    if (length(matching_names) == 1) {
      return(list_obj[[matching_names]])
    }
  }
  return("")
}
find_match(spatial_unit_list, "Schweiz")

# Define a specialized function for the spatial_unit_list
# It returns the spatial postgres key for the spacialunit table
map_spatial <- function(search_string) {
  result <- find_match(spatial_unit_list, search_string)
  return(result)
}
df_spatial <- df_clean %>% distinct(grossregion_kanton)
df_spatial
df_mapped <- df_spatial %>% dplyr::rowwise() %>% mutate(name_de = map_spatial(grossregion_kanton))


# apply spatial map
df_mapped <- df_clean %>% dplyr::rowwise() %>% mutate(name_de = map_spatial(grossregion_kanton))
