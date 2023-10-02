# load all the possible data sets
library(shiny)
library(DT)
library(statbotData)

# load all datasets
dataset_list <- load_dataset_list()

# load all pipelines that are already installed
pipelines_path <- here::here("pipelines")
pipelines <- list.files(pipelines_path)
query_counts <- c()
for (pipeline_id in pipelines) {
  query_log_path <- paste0("pipelines/", pipeline_id, "/queries.log")
  if (file.exists(query_log_path)) {
    queries <- readr::read_file(query_log_path)
    query_count <- stringr::str_count(queries, "--")
    query_counts <- c(query_counts, query_count)
  }
}
counts <- tibble::tibble(pipelines, query_counts) %>%
  dplyr::rename(data_indicator = pipelines)

# get choices for pipelines
choices_ds <- dataset_list %>%
  dplyr::filter(data_indicator %in% pipelines) %>%
  dplyr::left_join(counts, by = "data_indicator") %>%
  dplyr::mutate(
    location = dplyr::case_when(
      status == "uploaded" ~ "REMOTE",
      .default = "LOCAL"
    )) %>%
  dplyr::mutate(
    selector = paste(location, name, data_indicator, "(", publisher, lang, "): query_count =", query_counts)
  )

ui <- basicPage(
  h2("Statbot pipelines"),
  p("The environment is either 'local' from file"),
  p("or 'remote': from the remote postgres instance"),
  selectInput(inputId = "dataset",
              label = "Choose a dataset: id, environment, publisher, language, name, query counts",
              width = 800,
              choices = choices_ds$selector),
  tabsetPanel(
    tabPanel("Queries", htmlOutput("query")),
    tabPanel("Table", dataTableOutput("metadata_table")),
    tabPanel("Columns", dataTableOutput("metadata_columns")),
    tabPanel("Sample", dataTableOutput("sample"))
  )
)

server <- function(input, output) {
  pipelineOutput <- reactive({
    input_ds <- scan(text = input$dataset, what = "")
    pipeline_id <- input_ds[3]
    location <- input_ds[1]
    ds <- statbotData::create_dataset(pipeline_id)
    if (location == "LOCAL") {
      metadata <- statbotData::read_metadata_tables_from_file(ds)
      sample_path <- here::here("pipelines", pipeline_id, "sample.csv")
      if (file.exists(sample_path)) {
        sample <- readr::read_delim(sample_path, delim = ";", show_col_types = FALSE)
      }
    }
    if (location == "REMOTE") {
      metadata <- statbotData::get_metadata_from_postgres(ds)
      sample <- statbotData::run_postgres_query(
        table = ds$name,
        query = paste("SELECT * FROM", ds$name, "LIMIT 40;")
      )
    }
    metadata$metadata_tables <- tibble::as_tibble(
      cbind(key = names(metadata$metadata_tables),
            t(metadata$metadata_tables))
    ) %>%
      dplyr::rename(value = V2)
    list(metadata = metadata, sample = sample)
  })

  # Return query log
  queryOutput <- reactive({
    input_ds <- scan(text = input$dataset, what = "")
    pipeline_id <- input_ds[3]
    location <- input_ds[1]
    if (location == "REMOTE") {
      # run query again if location is remote
      ds <- statbotData::create_dataset(pipeline_id)
      statbotData::testrun_queries(ds)
    }
    query_log_path <- here::here("pipelines", pipeline_id, "queries.log")
    if (file.exists(query_log_path)) {
      queries <- readr::read_file(query_log_path)
      query_count <- stringr::str_count(queries, "--")
      queries <- queries %>%
        # stringr::str_replace_all("\\s*(?i)select\\s+", "<span style=font-family:monospace;</span><strong>SELECT</strong> ") %>%
        stringr::str_replace_all("\\s*(?i)select\\s+", "<strong>SELECT</strong> ") %>%
        stringr::str_replace_all(";", ";</span><br><pre>") %>%
        stringr::str_replace_all("--", "</pre><hr><strong>") %>%
        stringr::str_replace_all("\\?", "?</strong><br>") %>%
        stringr::str_remove_all("Query Nr\\. \\d+") %>%
        stringr::str_replace_all("\\s+(?i)insert\\s+",                "<br><strong>INSERT</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)update\\s+",                "<br><strong>UPDATE</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)delete\\s+",                "<br><strong>DELETE</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)distinct\\s+",              "<br><strong>DISTINCT</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)join\\s+",                  "<br><strong>JOIN</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)inner\\s+join\\s+",         "<br><strong>INNER JOIN</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)left\\s+join\\s+",          "<br><strong>LEFT JOIN</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)right\\s+join\\s+",         "<br><strong>RIGHT JOIN</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)full\\s+outer\\s+join\\s+", "<br><strong>FULL OUTER JOIN</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)union\\s+",                "<br><strong>UNION</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)intersect\\s+",             "<br><strong>INTERSECT</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)except\\s+",                "<br><strong>EXCEPT</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)offset\\s+",                "<br><strong>OFFSET</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)from\\s+",                  "<br><strong>FROM</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)join\\s+",                  "<br><strong>JOIN</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)where\\s+",                 "<br><strong>WHERE</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)group\\s+by\\s+",           "<br><strong>GROUP BY</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)order\\s+by\\s+",           "<br><strong>ORDER BY</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)having\\s+",                "<br><strong>HAVING</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)limit\\s+",                 "<br><strong>LIMIT</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)like\\s+",                  " <strong>LIKE</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)ilike\\s+",                 " <strong>ILIKE</strong> ") %>%
        stringr::str_replace_all("\\s*(?i)=\\s*",                     " <strong>=</strong> ") %>%
        stringr::str_replace_all("\\s*(?i)!\\s*=\\s*",                " <strong>!=</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)desc\\s*",                  " <strong>DESC</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)asc\\s*",                   " <strong>ASC</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)count\\s*",                 " <strong>COUNT</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)between\\s+",               " <strong>BETWEEN</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)as\\s+",                    " <strong>AS</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)on\\s+",                    " <strong>ON</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)and\\s+",                  " <strong>AND</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)sum\\s*",                  " <strong>SUM</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)avg\\s*",                  " <strong>AVG</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)min\\s*",                  " <strong>MIN</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)max\\s*",                  " <strong>MAX</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)row_number\\s+",           " <strong>ROW_NUMBER</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)rank\\s+",                 " <strong>RANK</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)dense_rank\\s+",           " <strong>DENSE_RANK</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)ntile\\s+",                " <strong>NTILE</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)first_value\\s+",          " <strong>FIRST_VALUE</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)last_value\\s+",           " <strong>LAST_VALUE</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)lead\\s+",                 " <strong>LEAD</strong> ") %>%
        stringr::str_replace_all("\\s+(?i)lag\\s+",                  " <strong>LAG</strong> ")
      queries
    }
  })

  # Show metadata for table
  output$metadata_table <- renderDataTable({
    pipelineOutput()$metadata$metadata_tables
  })

  # Show metadata for columns
  output$metadata_columns <- renderDataTable({
    pipelineOutput()$metadata$metadata_table_columns
  })

  # Show sample
  output$sample <- renderDataTable({
    pipelineOutput()$sample
  })

  # Show query log
  output$query <- renderText(
    {queryOutput()}
  )

}

shinyApp(ui, server)
