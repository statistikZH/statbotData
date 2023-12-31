% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/postgres_db_metadata.R
\name{write_metadata_to_postgres}
\alias{write_metadata_to_postgres}
\title{Write metadata to postgres}
\usage{
write_metadata_to_postgres(metadata, table_name)
}
\arguments{
\item{metadata}{metadata as list of tibbles}

\item{table_name}{name of the table}
}
\description{
Read metadata from file and write them to postgres: the metadata
is expected in the files \code{metadata_tables.csv}
and \code{metadata_table_columns.csv}
The metadata is appended to the existing metadata tables in postgres
}
\examples{
\dontrun{
write_metadata_to_postgres(metadata, table_name)
}
}
