library(shiny)
library(dplyr)
library(stringr)
library(tools)

# Define UI for Shiny app
ui <- fluidPage(
  titlePanel("HUGO Gene Name Search"),
  sidebarLayout(
    sidebarPanel(
      textInput("gene_name", label = "Enter gene name:", placeholder = "Type and press Enter"),
      actionButton("search_button", "Search")
    ),
    mainPanel(
      tableOutput("search_results")
    )
  )
)

# Define server logic for Shiny app
server <- function(input, output, session) {
  # Original directory path
  dir_path <- "/Users/winhide/Library/CloudStorage/OneDrive-BethIsraelLaheyHealth/Hide_ncLab/BIDMC.lab/Projects/Genedex/GenedexGeneLists/KeyGeneSets"
  
  # Additional directory path
 #dir_path <- "/Users/winhide/Library/CloudStorage/OneDrive-BethIsraelLaheyHealth/Hide_ncLab/BIDMC.lab/Projects/Resilience/singleCellResilience/MultiregionSCDataCIRCUITS/Results/DEGs"
  
  observeEvent(input$search_button, {
    req(input$gene_name)
    output$search_results <- renderTable({
      tryCatch({
        search_files(input$gene_name, dir_path)
      }, error = function(e) {
        data.frame(file_path = paste("Error: ", e$message))
      })
    })
  })
  
  search_files <- function(gene_name, dir_path) {
    print(paste("Searching for gene:", gene_name))
    
    file_list <- list.files(path = dir_path, pattern = "\\.(txt|csv|tab)$", recursive = TRUE, full.names = TRUE)
    if (length(file_list) == 0) {
      print("No files found in the directory.")
      return(data.frame(file_path = "No files found in the directory."))
    }
    
    results <- c()
    
    for (file_path in file_list) {
      tryCatch({
        con <- file(file_path, open = "r")
        while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0) {
          # Remove problematic characters from the line
          cleaned_line <- iconv(line, from = "UTF-8", to = "ASCII", sub = "")
          if (grepl(gene_name, cleaned_line, ignore.case = TRUE)) {
            # Extract and format the desired result
            formatted_result <- format_file_path(file_path, dir_path)
            results <- c(results, formatted_result)
            break
          }
        }
        close(con)  # Close the file connection
      }, error = function(e) {
        print(paste("Error reading file:", file_path, "Error:", e$message))
      })
    }
    
    if (length(results) == 0) {
      return(data.frame(file_path = "This gene is not in Genedex."))
    }
    
    data.frame(file_path = results)
  }
  
  # Function to format the file path
  format_file_path <- function(file_path, base_path) {
    # Remove the base path
    relative_path <- sub(base_path, "", file_path)
    # Remove the file extension
    file_name <- tools::file_path_sans_ext(basename(relative_path))
    # Combine the directory and filename
    formatted_path <- file.path(dirname(relative_path), file_name)
    return(formatted_path)
  }
}

shinyApp(ui = ui, server = server)
