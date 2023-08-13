#' Write sample for the dataset
#'
#' The sample contains random 40 rows.
#'
#' @param ds
#'
#' @export
#'
#' @examples
dataset_sample <- function(ds) {
  ds$sample <- ds$postgres_export
  sample_rows <- sample(1:dim(ds$postgres_export)[1], 40)
  ds$sample <- ds$sample[sample_rows,] %>% dplyr::mutate_all(as.character)
  file_path <- paste0(ds$dir, "export_sample.csv")
  write.table(ds$sample, file_path,
              row.names = FALSE, sep = ",")
}
