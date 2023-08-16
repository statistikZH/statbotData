# load all the possible data sets
library(shiny)
library(DT)
pipelines <- list.files("../pipelines/")
choices <- pipelines

ui <- basicPage(
  h2("Statbot pipelines"),
  selectInput(inputId = "dataset",
              label = "Choose a dataset:",
              selected = "A6",
              choices = choices),
  tabsetPanel(
    tabPanel("Table", tableOutput("metadata_table")),
    tabPanel("Columns", tableOutput("metadata_columns")),
    tabPanel("Sample", dataTableOutput("sample")),
    tabPanel("Queries", htmlOutput("query"))
  )
)

server <- function(input, output) {
  # Return metadata for the table ----
  metadataTableOutput <- reactive({
    metadata_table_path <- paste0("../pipelines/", input$dataset, "/metadata_tables.csv")
    if (file.exists(metadata_table_path)) {
      readr::read_delim(metadata_table_path, delim = ";")
    }
  })

  # Return metadata for the table columns ----
  metadataColumnsOutput <- reactive({
    metadata_columns_path <- paste0("../pipelines/", input$dataset, "/metadata_table_columns.csv")
    if (file.exists(metadata_columns_path)) {
      readr::read_delim(metadata_columns_path, delim = ";") %>%
        dplyr::select(-c(table_name))
    }
  })

  # Return dataset sample  ----
  sampleOutput <- reactive({
    sample_path <- paste0("../pipelines/", input$dataset, "/sample.csv")
    if (file.exists(sample_path)) {
      readr::read_delim(sample_path, delim = ";")
    }
  })

  # Return query log ----
  queryOutput <- reactive({
    query_log_path <- paste0("../pipelines/", input$dataset, "/queries.log")
    queries <- readr::read_file(query_log_path)
    query_count <- stringr::str_count(queries, "--")
    queries <- queries %>% stringr::str_replace_all( "SELECT", "<span style='font-family:monospace;'>SELECT") %>%
      stringr::str_replace_all(";", ";</span><br><pre>") %>%
      stringr::str_replace_all("--", "</pre><hr><strong>") %>%
      stringr::str_replace_all("\\?", "?</strong><br>") %>%
      stringr::str_remove_all("Query Nr\\. \\d+")

    if (file.exists(query_log_path)) {
      paste("Number of queries:", query_count, "\n", queries)
    }
  })

  # Show metadata for table ----
  output$metadata_table <- renderTable({
    metadataTableOutput()
  })

  # Show metadata for columns ----
  output$metadata_columns <- renderTable({
    metadataColumnsOutput()
  })

  # Show sample ----
  output$sample <- renderDataTable({
    sampleOutput()
  })

  # Show query log ----
  output$query <- renderText(
    {queryOutput()}
  )
}

shinyApp(ui, server)
