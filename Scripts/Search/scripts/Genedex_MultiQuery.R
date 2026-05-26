library(shiny)
library(dplyr)
library(tools)

# Define UI for Shiny app
ui <- fluidPage(
  titlePanel("HUGO Gene Name Search - File Upload"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file_upload", label = "Upload a file with gene names (one per line):"),
      actionButton("search_button", "Search"),
      downloadButton("download_results", "Download Results")
    ),
    mainPanel(
      tableOutput("search_results")
    )
  )
)

# Define server logic for Shiny app Original directory path THIS IS HARDCODED
server <- function(input, output, session) {
  dir_path <- "OneDrive-BethIsraelLaheyHealth/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Genes_lists"
  
  results_data <- reactiveVal(NULL) # Store results for downloading
  
  observeEvent(input$search_button, {
    req(input$file_upload)
    gene_names <- readLines(input$file_upload$datapath, warn = FALSE, encoding = "UTF-8")
    results <- tryCatch({
      search_files(gene_names, dir_path)
    }, error = function(e) {
      data.frame(error_message = paste("Error: ", e$message))
    })
    results_data(results) # Save results to reactive value
    output$search_results <- renderTable({
      results
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
          file_name = basename(file_path),
          containing_directory = basename(dirname(file_path)),
          parent_directory = basename(dirname(dirname(file_path))),
          num_matched = NA,
          num_total = NA,
          matched_genes = NA,
          error_message = paste("Error reading file:", e$message)
        )))
      })
    }
    
    if (length(results) == 0) {
      return(data.frame(file_name = "No matches found."))
    }
    
    results_df <- do.call(rbind, results)
    results_df <- results_df[order(-results_df$num_matched), ]
    return(results_df)
  }
  
  process_file <- function(file_genes, gene_names, file_path) {
    file_genes <- tolower(trimws(file_genes))
    gene_names_lower <- tolower(trimws(gene_names))
    
    matched_genes <- setdiff(intersect(file_genes, gene_names_lower), "gene_symbol")
    num_matched <- length(matched_genes)
    num_total <- length(file_genes)
    
    if (num_matched > 0) {
      return(data.frame(
        file_name = tools::file_path_sans_ext(basename(file_path)),
        containing_directory = basename(dirname(file_path)),
        parent_directory = basename(dirname(dirname(file_path))),
        num_matched = num_matched,
        num_total = num_total,
        matched_genes = paste(matched_genes, collapse = ", ")
      ))
    }
  }
  
  # Download handler for results
  output$download_results <- downloadHandler(
    filename = function() {
      paste("gene_search_results", Sys.Date(), ".txt", sep = "")
    },
    content = function(file) {
      results <- results_data()
      if (!is.null(results)) {
        write.table(results, file, sep = "\t", row.names = FALSE, quote = FALSE)
      }
    }
  )
}

shinyApp(ui = ui, server = server)

