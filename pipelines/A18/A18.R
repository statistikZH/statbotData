# -------------------------------------------------------------------------
# Steps: Get the data
# input: google sheet
# output: ds$data, ds$dir
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A18")
ds <- statbotData::download_data(ds)
ds$data
# -------------------------------------------------------------------------
# Step: Clean the data
#   input: ds$data
#.  output: ds$cleaned_data: data has been cleaned:
#.  - factor `ergebnis` spilt into wide format
#.  - `datum_und_vorlage` split into `jahr` and `vorlage_title`
# -------------------------------------------------------------------------
dff <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::mutate(stadt_name = stringr::str_replace(.$stadt_agglomeration, ":.*", "")) %>%
  dplyr::select(-stadt_agglomeration) %>%
  na.omit()

dff_split <- split(dff, dff$resultat)

dff_wert <- dff_split[1]$Wert
dff_vi <- dff_split[2]$`Vertrauensintervall ± (in %, bzw. %-Punkten)`

dff_wer_vi_joined <- dplyr::left_join(x = dff_wert, y = dff_vi, by = c("stadt_name", "jahr", "variable"))

dff_cln <- dff_wer_vi_joined %>%
  dplyr::select(-resultat.x,
         -resultat.y) %>%
  dplyr::rename(var_name = "variable",
         value = "data_gemass_variable.x",
         ci = "data_gemass_variable.y")


dff_cln$spatialunit_ontology = "Municipality"

map_df <- readr::read_csv("data/const/spatial_unit_postgres.csv")


# dff_cln_n <- dff_cln$name %>%
#   unique() %>%
#   sort()
#
# unique(dff_cln$name)
# mpdfn <- map_df$name %>%
#   unique() %>%
#   sort()
#
# dff_cln_n[2] == mpdfn[268]
#
# dff_cln$name[1]


######


# dff_cln$stadt_name %<>% as.factor()
# map_df$name %<>% as.factor()
ds$cleaned_data <- dff_cln

spatial_map <- ds$cleaned_data %>%
  dplyr::select(stadt_name) %>%
  dplyr::distinct(stadt_name) %>%
  map_ds_spatial_units(., spatial_dimensions = c("Municipality"))

# there is a bug in the pattern/match function
# the UID's for Zurich, Bern, Lugano, Lausanne have not been retrieved
# therefore, using a more straghtway approach

spatial_map <- ds$cleaned_data %>%
  dplyr::select(stadt_name) %>%
  dplyr::distinct(stadt_name) %>%
  left_join(map_df, by = c("stadt_name" = "name")) %>%
  select(stadt_name, spatialunit_uid)


ds$postgres_export <- ds$cleaned_data %>%
  dplyr::left_join(spatial_map) %>%
  dplyr::select(-stadt_name, -spatialunit_ontology)

assertthat::noNA(ds$postgres_export$spatialunit_uid)

statbotData::testrun_queries(ds$postgres_export,
                             ds$dir,
                             ds$name)

dff_psql <- ds$postgres_export
names(dff_psql)
