# ---------------------------------------------------------------
# Setup Postgres db instance: a protocol
# ---------------------------------------------------------------
# Warning: don't rerun, since these steps have already been done
#          for the postgres instance that is currently in use
#
# What exactly has to be done here depends on the state of the
# postgres instance and might differ for another instance
#
# ---------------------------------------------------------------
# Establish connection to postgres db
# ---------------------------------------------------------------
connect <- statbotData::postgres_db_connect()
# connect has two variables:
# - db: the connection
# - schema: the schema to be used
db <- connect$db
schema <- connect$schema

# ---------------------------------------------------------------
# Update the spatial unit table
# ---------------------------------------------------------------
# Initially the spatial unit table was there but empty
spatial_unit_table <- "spatial_unit"
df <- load_spatial_map()
RPostgres::dbWriteTable(
  conn = db,
  name = Id(schema = schema, table = spatial_unit_table),
  value = df,
  append = TRUE
)
# Since no primary key was specified yet, it had to be created
RPostgres::dbGetQuery(
  conn = db,
  "ALTER TABLE spatial_unit ADD PRIMARY KEY(spatialunit_uid);"
)
# On the previous instance there were a lot of indexes, they
# might be created later if needed for performance reasons.

# ---------------------------------------------------------------
# Db instance is ready for the pipelines
# ---------------------------------------------------------------
