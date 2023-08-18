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
    queries <- queries %>%
      stringr::str_replace_all("\\s*(?i)select\\s+", "<span style='font-family:monospace;<strong>SELECT</strong> ") %>%
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
      stringr::str_replace_all("\\s*(?i)!=\\s*",                    " <strong>!=</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)desc\\s*",                  " <strong>DESC</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)asc\\s*",                   " <strong>ASC</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)count\\s*",                 " <strong>COUNT</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)between\\s+",               " <strong>BETWEEN</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)as\\s+",                    " <strong>AS</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)on\\s+",                    " <strong>ON</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)and\\s+",                  " <strong>AND</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)sum\\s+",                  " <strong>SUM</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)avg\\s+",                  " <strong>AVG</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)min\\s+",                  " <strong>MIN</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)max\\s+",                  " <strong>MAX</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)row_number\\s+",           " <strong>ROW_NUMBER</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)rank\\s+",                 " <strong>RANK</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)dense_rank\\s+",           " <strong>DENSE_RANK</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)ntile\\s+",                " <strong>NTILE</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)first_value\\s+",          " <strong>FIRST_VALUE</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)last_value\\s+",           " <strong>LAST_VALUE</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)lead\\s+",                 " <strong>LEAD</strong> ") %>%
      stringr::str_replace_all("\\s+(?i)lag\\s+",                  " <strong>LAG</strong> ")



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
