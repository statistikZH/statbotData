# -------------------------------------------------------------------------
# Steps: Get the data
# -------------------------------------------------------------------------

ds <- statbotData::create_dataset("A25")
ds <- statbotData::download_data(ds)

# -------------------------------------------------------------------------
# Step 1 rename columns + clean values
# -------------------------------------------------------------------------

# The dataset has missing values represented as "" or "( )"
ds$postgres_export <- ds$data %>%
  janitor::clean_names() %>%
  dplyr::select(
    jahr = year,
    flache_rebland_rote_europaische_reben_ha = flaeche_rot_euro,
    flache_rebland_kreuzung_rote_weisse_ha = flaeche_rot_kreuz,
    flache_rebland_weisse_reben_ha = flaeche_weiss,
    flache_total_ha = flaeche_tot,
    weinernte_total_hl = ernte_tot,
    weinernte_rot_europaische_hl = ernte_rot_euro,
    weinernte_rot_kreuzung_rot_hl = ernte_rot_kreuz,
    weinernte_europaische_weiss_hl = ernte_weiss,
    erntewert_rot_1000_chf = wert_rot,
    erntewert_weiss_1000_chf = wert_weiss
  )
# -------------------------------------------------------------------------
# Step 2 map to spatial units
# -------------------------------------------------------------------------

# Add spatial unit corresponding to Kanton AG
ds$postgres_export <- ds$postgres_export %>%
  dplyr::mutate(
    spatialunit_uid = "19_A.ADM1"
  )
