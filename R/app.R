# load all the possible data sets
library(shiny)
pipelines <- list.files("../pipelines/")
choices <- pipelines

# Define UI for dataset viewer app ----
ui <- fluidPage(

  # App title ----
  titlePanel("Statbot Pipelines"),

  # Sidebar layout with a input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Selector for choosing dataset ----
      selectInput(inputId = "dataset",
                  label = "Choose a dataset:",
                  selected = "A6",
                  choices = choices),

      sliderInput(inputId = "sample_size", "Sample",
                  value=5, min=0, max=40, step=5),
    ),

    # Main panel for displaying outputs ----
    mainPanel(
      mainPanel(
        tabsetPanel(
          tabPanel("Table", tableOutput("metadata_table")),
          tabPanel("Columns", tableOutput("metadata_columns")),
          tabPanel("Sample", tableOutput("export_sample")),
          tabPanel("Queries", tableOutput("query_log"))
        )
      )
    )
  )
)

# Define server logic to summarize and view selected dataset ----
server <- function(input, output) {

  # Return metadata for the table ----
  metadataTableInput <- reactive({
    metadata_table_path <- paste0("../pipelines/", input$dataset, "/metadata_tables.csv")
    if (file.exists(metadata_table_path)) {
      readr::read_csv(metadata_table_path)
    }
  })

  # Return metadata for the table columns ----
  metadataColumnsInput <- reactive({
    metadata_columns_path <- paste0("../pipelines/", input$dataset, "/metadata_table_columns.csv")
    if (file.exists(metadata_columns_path)) {
      readr::read_csv(metadata_columns_path) %>%
        dplyr::select(-c(table_name))
    }
  })

  # Return dataset sample  ----
  exportSampleInput <- reactive({
    sample_path <- paste0("../pipelines/", input$dataset, "/export_sample.csv")
    if (file.exists(sample_path)) {
      readr::read_csv(sample_path)
    }
  })

  # Return query log ----
  queryLogInput <- reactive({
    query_log_path <- paste0("../pipelines/", input$dataset, "/queries.log")
    if (file.exists(query_log_path)) {
      read.table(query_log_path, sep = '\n')
    }
  })

  # Show metadata for table ----
  output$metadata_table <- renderTable({
    metadataTableInput()
  })

  # Show metadata for columns ----
  output$metadata_columns <- renderTable({
    metadataColumnsInput()
  })

  # Show selected number of samples ----
  output$export_sample <- renderTable({
    head(exportSampleInput(), n = input$sample_size)
  })

  # Show query log ----
  output$query_log <- renderTable(
    colnames = FALSE,
    striped = TRUE,
    {queryLogInput()}
  )

}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
