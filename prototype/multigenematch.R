library(shiny)
library(dplyr)
library(tools)

# Define UI for Shiny app
ui <- fluidPage(
  titlePanel("HUGO Gene Name Search - File Upload"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file_upload", label = "Upload a file with gene names (one per line):"),
      actionButton("search_button", "Search")
    ),
    mainPanel(
      tableOutput("search_results")
    )
  )
)

# Define server logic for Shiny app
server <- function(input, output, session) {
  dir_path <- "/Users/winhide/Library/CloudStorage/OneDrive-BethIsraelLaheyHealth/Hide_ncLab/BIDMC.lab/Projects/Genedex/GenedexGeneLists/KeyGeneSets"
  
  observeEvent(input$search_button, {
    req(input$file_upload)
    gene_names <- readLines(input$file_upload$datapath, warn = FALSE, encoding = "UTF-8")
    output$search_results <- renderTable({
      tryCatch({
        search_files(gene_names, dir_path)
      }, error = function(e) {
        data.frame(error_message = paste("Error: ", e$message))
      })
    })
  })
  
  search_files <- function(gene_names, dir_path) {
    file_list <- list.files(path = dir_path, pattern = "\\.(txt|csv|tab)$", recursive = TRUE, full.names = TRUE)
    results <- list()
    
    for (file_path in file_list) {
      tryCatch({
        file_genes <- readLines(file_path, warn = FALSE, encoding = "UTF-8")
        result <- process_file(file_genes, gene_names, file_path)
        if (!is.null(result)) {
          results <- c(results, list(result))
        }
      }, error = function(e) {
        results <- c(results, list(data.frame(
          actual_file_path = file_path,
          error_message = paste("Error reading file:", e$message),
          parent_directory = NA,
          num_matched = NA,
          num_total = NA,
          matched_genes = NA
        )))
      })
    }
    
    if (length(results) == 0) {
      return(data.frame(file_path = "No matches found."))
    }
    
    do.call(rbind, results)
  }
  
  process_file <- function(file_genes, gene_names, file_path) {
    file_genes <- tolower(trimws(file_genes))
    gene_names_lower <- tolower(trimws(gene_names))
    
    matched_genes <- intersect(file_genes, gene_names_lower)
    num_matched <- length(matched_genes)
    num_total <- length(file_genes)
    
    if (num_matched > 0) {
      return(data.frame(
        actual_file_path = file_path,
        parent_directory = dirname(dirname(file_path)),
        num_matched = num_matched,
        num_total = num_total,
        matched_genes = paste(matched_genes, collapse=", ")
      ))
    }
  }
}

shinyApp(ui = ui, server = server)
