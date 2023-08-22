#' Write sample for the dataset
#'
#' The sample contains random rows
#' The number of the rows defaults to 40
#' but can be specified
#'
#' @param ds
#' @param sample_size default 40
#'
#' @export
#'
#' @examples
dataset_sample <- function(ds, sample_size=40) {
  print(ds$postgres_export)
  file_path <- paste0(ds$dir, "sample.csv")
  ds$sample <- ds$postgres_export
  row_count <- dim(ds$postgres_export)[1]
  if (row_count > sample_size) {
    sample_rows <- sample(1:row_count, sample_size)
    ds$sample <- ds$sample[sample_rows,]
  }
  ds$sample <- ds$sample %>% dplyr::mutate_all(as.character)
  write.table(ds$sample, file_path,
              row.names = FALSE, sep = ";")
}
