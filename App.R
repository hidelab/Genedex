# -----------------------------------------------------------
# LIBRARY
# -----------------------------------------------------------
library(shiny)
library(shinydashboard)
library(readxl)
library(DT)
library(plotly)
library(visNetwork)
library(upsetjs)
library(heatmaply)

# -----------------------------------------------------------
# UI
# -----------------------------------------------------------
ui <- dashboardPage(
  # Define the header of the dashboard
  dashboardHeader(
    title = tags$div(
      style = "font-size: 24px; font-weight: bold;",  
      "Genedex"  # Title text
    )
  ),
  
  # Define the sidebar of the dashboard
  dashboardSidebar(
    # Custom CSS for sidebar menu styling
    tags$style(HTML("
      /* Increase font size in the sidebar menu (lateral tabs) */
      .sidebar-menu li a {
        font-size: 16px;  /* Increased font size */
      }
    ")),
    
    # Sidebar menu items
    sidebarMenu(
      menuItem("Input Gene Lists", tabName = "input_gene_lists", icon = icon("edit")),  # Menu item for Input Gene Lists
      menuItem("Search", tabName = "gene_search", icon = icon("search")),  # Menu item for Search functionality
      menuItem("Similarity Matrix", tabName = "similarity_matrix", icon = icon("th")),  # Menu item for Similarity Matrix
      menuItem("Facet Interactions", tabName = "facet_interactions", icon = icon("sitemap"))  # Menu item for Facet Interactions
    )
  ),
  
  # Define the body of the dashboard
  dashboardBody(
    tags$head(
      # Custom CSS for styling various elements
      tags$style(HTML("
        @media (max-width: 768px) {  /* Responsive design for smaller screens */
          .sidebar {
            width: 100%;
          }
          .box {
            width: 100%;
          }
          .box-header .box-title {
            font-size: 18px;  /* Increased font size */
          }
          .btn {
            width: 100%;
            margin-top: 5px;
          }
          .table {
            font-size: 14px;  /* Increased font size */
          }
        }
        .dataTables_wrapper {
          overflow-x: auto;  /* Enable horizontal scrolling for data tables */
        }
        .content-wrapper {
          padding: 10px;
          font-size: 16px;  /* Increased font size */
        }
        .box-body {
          padding: 5px;
          font-size: 16px;  /* Increased font size */
        }
        .square-button {
          width: 30px;
          height: 30px;
          padding: 0;
          border-radius: 5px;
          text-align: center;
        }
        .upset-plot {
          height: 800px;  /* Set height for UpSet plots */
        }

        /* Custom Button Styles */
        .btn-custom {
          background-color: #5A9BD5;  /* Slightly Darker Blue */
          color: white;
          border: none;
          border-radius: 8px;
          padding: 10px 20px;
          font-size: 16px;  /* Increased font size */
          transition: background-color 0.3s ease, box-shadow 0.3s ease;
          text-align: center;
          margin: 5px;
          display: inline-block;
        }

        .btn-custom:hover {
          background-color: #4a86c5;  /* Slightly darker blue */
          box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.2);
        }

        .btn-custom:active {
          background-color: #3a71b5;  /* Even darker blue */
          box-shadow: none;
        }

        .btn-danger {
          background-color: #D9534F;  /* Slightly Darker Red */
          color: white;
          border: none;
          border-radius: 8px;
          padding: 10px 20px;
          font-size: 16px;  /* Increased font size */
          transition: background-color 0.3s ease, box-shadow 0.3s ease;
          text-align: center;
          margin: 5px;
          display: inline-block;
        }

        .btn-danger:hover {
          background-color: #c94441;  /* Slightly darker red */
          box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.2);
        }

        .btn-danger:active {
          background-color: #b53533;  /* Even darker red */
          box-shadow: none;
        }

        /* Reduce font size for UpSet plot row names */
        .upsetjs-plot .upsetjs-label {
          font-size: 16px;  /* Adjust this size as needed */
        }
      "))
    ),
    
    # Define the content of each tab
    tabItems(
      # Tab for Gene Search functionality
      tabItem(tabName = "gene_search",
              fluidRow(
                box(
                  title = "Gene Search", status = "primary", solidHeader = TRUE, width = 12,
                  textInput("genes", "Enter HUGO Gene IDs (separated by spaces)", value = ""),  # Input for gene IDs
                  fileInput("gene_file", "Or upload a text file with HUGO Gene IDs"),  # File input for gene IDs
                  actionButton("use_input_gene_list", "Use Input Gene List", class = "btn-custom"),  # Button to use input gene list
                  uiOutput("input_gene_list_ui"),  # Dynamic UI for selecting gene lists
                  actionButton("search_genes", "Search Genes", class = "btn-custom"),  # Button to search genes
                  DTOutput("gene_results"),  # Data table output for gene search results
                  downloadButton("download_results", "Download", class = "btn-custom")  # Button to download search results
                )
              ),
              fluidRow(
                box(
                  title = "Facet Search", status = "primary", solidHeader = TRUE, width = 12,
                  selectInput("facet_select", "Select a Facet", choices = NULL),  # Dropdown to select a facet
                  actionButton("search_facet", "Search Facet", class = "btn-custom"),  # Button to search by facet
                  DTOutput("facet_results")  # Data table output for facet search results
                )
              )
      ),
      
      # Tab for Similarity Matrix functionality
      tabItem(tabName = "similarity_matrix",
              fluidRow(
                box(
                  title = "Similarity Matrix", status = "primary", solidHeader = TRUE, width = 12,
                  radioButtons("matrix_type", "Perform Similarity Matrix on:", choices = c("Gene Lists" = "genes", "Facets" = "facets")),  # Radio buttons to choose matrix type
                  conditionalPanel(
                    condition = "input.matrix_type == 'genes'",
                    fluidRow(
                      column(6, actionButton("calculate_similarity_matrix_genes", "Calculate", class = "btn-custom")),  # Button to calculate similarity matrix for genes
                      column(6, actionButton("reset_plot_genes", "Reset Plot", class = "btn-danger"))  # Button to reset plot for genes
                    ),
                    selectizeInput("tag_selector_similarity", "Select Tags", choices = NULL, multiple = TRUE),  # Tag selector for similarity matrix
                    selectizeInput("selected_gene_lists_matrix", "Select Gene Lists", choices = NULL, multiple = TRUE),  # Dropdown to select gene lists for analysis
                    selectizeInput("input_gene_lists_for_matrix", "Select Input Gene Lists", choices = NULL, multiple = TRUE)  # Dropdown to select user-added gene lists
                  ),
                  conditionalPanel(
                    condition = "input.matrix_type == 'facets'",
                    fluidRow(
                      column(6, actionButton("select_all_facets", "Select All Facets", class = "btn-custom")),  # Button to select all facets
                      column(6, actionButton("deselect_all_facets", "Deselect All Facets", class = "btn-danger"))  # Button to deselect all facets
                    ),
                    selectizeInput("selected_facets", "Select Facets", choices = NULL, multiple = TRUE),  # Dropdown to select facets for analysis
                    fluidRow(
                      column(6, actionButton("calculate_similarity_matrix_facets", "Calculate", class = "btn-custom")),  # Button to calculate similarity matrix for facets
                      column(6, actionButton("reset_plot_facets", "Reset Plot", class = "btn-danger"))  # Button to reset plot for facets
                    )
                  ),
                  div(style = "width: 100%; height: 1000px; overflow: auto;", 
                      plotlyOutput("similarityMatrixHeatmap", width = "1800px", height = "1800px")  # Plot output for similarity matrix heatmap
                  )
                )
              )
      )
      ,
      
      # Tab for Facet Interactions functionality
      tabItem(tabName = "facet_interactions",
              fluidRow(
                box(
                  title = "Facet Interactions", status = "primary", solidHeader = TRUE, width = 12,
                  radioButtons("interaction_type", "Perform Interaction Analysis on:", choices = c("Gene Lists" = "genes", "Facets" = "facets")),  # Radio buttons to choose interaction analysis type
                  conditionalPanel(
                    condition = "input.interaction_type == 'genes'",
                    selectizeInput("tag_selector", "Select Tags", choices = NULL, multiple = TRUE),  # Tag selector for interaction analysis
                    selectizeInput("gene_lists_for_interaction", "Select Gene List", choices = NULL, multiple = TRUE),  # Dropdown to select gene lists for interaction
                    selectizeInput("input_gene_lists_for_interaction", "Select Input Gene Lists", choices = NULL, multiple = TRUE),  # Dropdown to select input gene lists to add
                    actionButton("calculate_interaction_genes", "Calculate", class = "btn-custom"),  # Button to calculate interactions for genes
                    actionButton("reset_interaction_genes", "Reset Plot", class = "btn-danger")  # Button to reset plot for interactions
                  ),
                  conditionalPanel(
                    condition = "input.interaction_type == 'facets'",
                    fluidRow(
                      column(6, actionButton("select_all_clustering_facets", "Select All Facets", class = "btn-custom")),  # Button to select all clustering facets
                      column(6, actionButton("deselect_all_clustering_facets", "Deselect All Facets", class = "btn-danger"))  # Button to deselect all clustering facets
                    ),
                    selectizeInput("clustering_selected_facets", "Select Facets", choices = NULL, multiple = TRUE),  # Dropdown to select facets for clustering
                    selectizeInput("input_gene_lists_for_facets", "Select Input Gene Lists ", choices = NULL, multiple = TRUE),  # Dropdown to select input gene lists to add
                    actionButton("reset_interaction_genes", "Reset Plot", class = "btn-danger"),  # Button to reset plot for interactions
                    actionButton("calculate_clustering", "Calculate", class = "btn-custom")  # Button to calculate clustering
                  ),
                  radioButtons("visualization_type", "Select Visualization Type:", choices = c("Graph", "UpSet Plot"), inline = TRUE)  # Radio buttons to select visualization type
                )
              ),
              fluidRow(
                box(
                  width = 14,
                  div(
                    style = 'width:100%; height:1200px; overflow-x: auto; overflow-y: auto;',  # Adjusted height and added scrollbars
                    visNetworkOutput("force_directed_graph", width = "100%", height = "1000px"),  # Network plot output for force-directed graph
                    div(
                      style = 'width:1800px; overflow-x: auto; padding-left: 150px;',  
                      upsetjsOutput("upsetjs_plot", width = "1800px", height = "1200px")  # Plot output for UpSet plot
                    )
                  )
                )
              ),
              fluidRow(
                box(
                  title = "Selected Genes", status = "primary", solidHeader = TRUE, width = 12,
                  DTOutput("clicked_genes_table"),
                  downloadButton("download_clicked_genes", "Download", class = "btn-custom")
                )
              )
      ),
      
      # Tab for Input Gene Lists functionality
      tabItem(tabName = "input_gene_lists",
              fluidRow(
                box(
                  title = "Input Gene Lists", status = "primary", solidHeader = TRUE, width = 12,
                  actionButton("add_gene_list", "Add a Gene List", class = "btn-custom"),  # Button to add a gene list
                  uiOutput("gene_list_ui")  # Dynamic UI for managing gene lists
                )
              ),
              conditionalPanel(
                condition = "input.add_gene_list > 0",  # Show these buttons after "Add a Gene List" is clicked
                fluidRow(
                  box(
                    title = "Manage Gene Lists", status = "primary", solidHeader = TRUE, width = 12,
                    actionButton("clear_gene_lists", "Clear All Gene Lists", class = "btn-danger"),  # Button to clear all gene lists
                    actionButton("visualize_gene_lists", "Visualize Gene Lists", class = "btn-custom")  # Button to visualize gene lists
                  )
                )
              ),
              conditionalPanel(
                condition = "input.visualize_gene_lists > 0",  # Show "Visualized Gene Lists" after the button is clicked
                fluidRow(
                  box(
                    title = "Visualized Gene Lists", status = "primary", solidHeader = TRUE, width = 12,
                    DTOutput("visualized_gene_lists")  # Data table output for visualized gene lists
                  )
                )
              )
      )
    ),
    
    tags$div(id = "modal_placeholder")  
  )
)

# -----------------------------------------------------------
# SERVER
# -----------------------------------------------------------
server <- function(input, output, session) {
  # -----------------------------------------------------------
  # Function
  # -----------------------------------------------------------
  
  # Function to list files in the local folder
  list_local_files <- function(folder) {
    files <- list.files(folder, pattern = "\\.txt$", full.names = TRUE)
    return(files)
  }
  
  # Clean gene list by trimming whitespace and ensuring uppercase
  clean_gene_list <- function(gene_list) {
    gene_list <- trimws(gene_list)  # Remove whitespace
    gene_list <- toupper(gene_list) 
    return(gene_list)
  }
  
  # Extract genes from selected facets
  extract_genes_from_facets <- function(selected_facets) {
    # Match files containing any of the selected facets in their names
    selected_files <- files[grepl(paste(selected_facets, collapse = "|"), basename(files))]
    
    # Extract genes from matched files
    all_genes <- lapply(selected_files, function(file) {
      gene_data <- read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
      
      # Check column name consistency
      if ("Genes" %in% colnames(gene_data)) {
        colnames(gene_data)[which(colnames(gene_data) == "Genes")] <- "GENE_SYMBOL"
      }
      
      gene_list <- clean_gene_list(gene_data$GENE_SYMBOL) 
      return(gene_list)
    })
    names(all_genes) <- sub("\\.txt$", "", basename(selected_files))
    return(all_genes)
  }
  
  # Function to search for genes in the gene lists and return metadata
  search_genes <- function(gene_names) {
    results <- data.frame(Gene = character(), Gene_list_name = character(), Facets = character(), Reference = character(), stringsAsFactors = FALSE)
    gene_names <- tolower(gene_names)
    for (file in files) {
      gene_list <- suppressWarnings(readLines(file))
      gene_list <- gene_list[!grepl("GENE_SYMBOL", gene_list, ignore.case = TRUE)]
      gene_list <- tolower(gene_list)
      for (gene in gene_names) {
        if (gene %in% gene_list) {
          file_base <- sub("\\.txt$", "", basename(file))
          metadata_row <- metadata[which(metadata$Gene_list_name == file_base), ]
          if (nrow(metadata_row) > 0) {
            facets <- metadata_row$Facets
            gene_list <- metadata_row$Gene_list_name
            author <- metadata_row$Author
            title <- metadata_row$Title
            results <- rbind(results, data.frame(Gene = toupper(gene),Gene_list_name=gene_list, Facets = facets, Reference = title))
          }
        }
      }
    }
    results <- unique(results)
    return(results)
  }
  
  # Function to read and combine gene symbols from the selected gene list files
  combine_gene_symbols <- function(selected_gene_lists) {
    gene_symbols <- list()
    
    for (list_name in selected_gene_lists) {
      file_pattern <- paste0("^", list_name, ".*\\.txt$")
      file_path <- list.files(local_folder, pattern = file_pattern, full.names = TRUE)
      
      if (length(file_path) > 0) {
        gene_data <- read.table(file_path[1], header = TRUE, sep = "\t", stringsAsFactors = FALSE)
        
        if ("Genes" %in% colnames(gene_data)) {
          colnames(gene_data)[which(colnames(gene_data) == "Genes")] <- "GENE_SYMBOL"
        }
        
        if ("GENE_SYMBOL" %in% colnames(gene_data)) {
          gene_list <- clean_gene_list(gene_data$GENE_SYMBOL)  
          gene_symbols[[list_name]] <- gene_list
        } else {
          cat("GENE_SYMBOL column not found in:", file_path[1], "\n")
        }
      } else {
        cat("No file found for pattern:", file_pattern, "\n")
      }
    }
    
    return(gene_symbols)
  }
  
  # Function to search for facets
  search_facet <- function(selected_facet) {
    results <- filtered_metadata[grepl(selected_facet, filtered_metadata$Gene_list_name, ignore.case = TRUE), ]
    return(results)
  }
  
  # Function to group genes by facets
  group_genes_by_facets <- function(selected_facets) {
    facet_genes <- list()
    for (facet in selected_facets) {
      # Filenames that start with GL followed by 7 digits and contain the facet term immediately after, followed by .txt
      facet_files <- files[grepl(paste0("^GL[0-9]{7}_", facet, "\\.txt$"), basename(files))]
      facet_genes[[facet]] <- unique(unlist(lapply(facet_files, function(file) {
        gene_list <- suppressWarnings(readLines(file))
        gene_list <- gene_list[!grepl("GENE_SYMBOL", gene_list, ignore.case = TRUE)]
        return(gene_list)
      })))
    }
    return(facet_genes)
  }
  
  # Function to calculate and plot similarity matrix based on gene lists
  plot_similarity_matrix_gene_lists <- function(gene_lists) {
    if (length(gene_lists) == 0) {
      showNotification("No valid gene list found.", type = "warning")
      return(NULL)
    }
    
    gene_names <- unique(unlist(gene_lists))
    if (length(gene_names) == 0) {
      showNotification("No genes found in the selected lists.", type = "warning")
      return(NULL)
    }
    
    similarity_matrix <- matrix(0, nrow = length(gene_lists), ncol = length(gene_lists))
    rownames(similarity_matrix) <- names(gene_lists)
    colnames(similarity_matrix) <- names(gene_lists)
    
    for (i in 1:length(gene_lists)) {
      for (j in i:length(gene_lists)) {
        if (length(union(gene_lists[[i]], gene_lists[[j]])) == 0) {
          similarity_matrix[i, j] <- NA
          similarity_matrix[j, i] <- NA
        } else {
          similarity_matrix[i, j] <- length(intersect(gene_lists[[i]], gene_lists[[j]])) / length(union(gene_lists[[i]], gene_lists[[j]]))
          similarity_matrix[j, i] <- similarity_matrix[i, j]
        }
      }
    }
    
    # Check if the matrix contains any non-NA values
    if (all(is.na(similarity_matrix))) {
      showNotification("No overlaps found between the selected gene lists.", type = "warning")
      return(NULL)
    }
    # Display only the lower triangle of the matrix
    similarity_matrix[upper.tri(similarity_matrix)] <- NA
    
    heatmaply::heatmaply(
      similarity_matrix,
      xlab = "Gene Lists",
      ylab = "Gene Lists",
      main = "Similarity Matrix (Gene Lists)",
      plot_method = "plotly",
      dendrogram = "none",  
      hide_colorbar = TRUE, 
      na.value = "transparent",
      fontsize_row = 16,  
      fontsize_col = 16
    )
  }
  
  # Function to calculate and plot similarity matrix based on facets
  plot_similarity_matrix_facets <- function(selected_facets) {
    gene_lists <- extract_genes_from_facets(selected_facets)
    
    if (length(gene_lists) == 0) {
      showNotification("No gene lists found for the selected facets.", type = "warning")
      return(NULL)
    }
    
    # Calculate the similarity matrix
    gene_names <- unique(unlist(gene_lists))
    similarity_matrix <- matrix(0, nrow = length(selected_facets), ncol = length(selected_facets))
    rownames(similarity_matrix) <- selected_facets
    colnames(similarity_matrix) <- selected_facets
    
    for (i in 1:length(selected_facets)) {
      for (j in i:length(selected_facets)) {
        genes_i <- gene_lists[[i]]
        genes_j <- gene_lists[[j]]
        similarity_matrix[i, j] <- length(intersect(genes_i, genes_j)) / length(union(genes_i, genes_j))
        similarity_matrix[j, i] <- similarity_matrix[i, j]
      }
    }
    
    # Show only the upper triangle of the matrix
    similarity_matrix[upper.tri(similarity_matrix)] <- NA
    
    heatmaply::heatmaply(
      similarity_matrix,
      xlab = "Facets",
      ylab = "Facets",
      main = "Similarity Matrix (Facets)",
      plot_method = "plotly",
      dendrogram = "none",  # Remove the dendrogram
      hide_colorbar = TRUE, 
      na.value = "transparent" ,
      fontsize_row = 16,  
      fontsize_col = 16
    )
  }
  
  # Observe event for combining gene lists
  combine_gene_symbols <- function(selected_gene_lists) {
    gene_symbols <- list()
    
    for (list_name in selected_gene_lists) {
      file_pattern <- paste0("^", list_name, ".*\\.txt$")
      file_path <- list.files(local_folder, pattern = file_pattern, full.names = TRUE)
      
      cat("Processing file:", file_path, "\n")
      
      if (length(file_path) > 0) {
        gene_data <- read.table(file_path[1], header = TRUE, sep = "\t", stringsAsFactors = FALSE)
        
        if (is.data.frame(gene_data)) {
          if (!"GENE_SYMBOL" %in% colnames(gene_data)) {
            colnames(gene_data)[1] <- "GENE_SYMBOL"
          }
          
          gene_list <- clean_gene_list(gene_data$GENE_SYMBOL)  
          gene_symbols[[list_name]] <- gene_list
        } else {
          cat("Error: The file does not contain a data frame:", file_path, "\n")
        }
      } else {
        cat("No file found for pattern:", file_pattern, "\n")
      }
    }
    
    return(gene_symbols)
  }
  
  
  # -----------------------------------------------------------
  # Data loading and preprocessing
  # -----------------------------------------------------------
  
  #CHANGE IF YOUR FOLDER PATH IS DIFFERENT
  #setwd("/Users/gpegoraro/Documents/Genedex/")
  # Load metadata from the Excel file
  local_folder <- "Genes_lists"
  metadata_path <- "Gene_list_collection.xlsx"
  metadata <- read_excel(metadata_path, sheet = 2)
  
  # Filter the data to include only rows where Status = 1 and remove NA values in the Facets column
  filtered_metadata <- metadata[metadata$Status == 1 & !is.na(metadata$Facets), ]
  
  # Extract tags from the "Facets" column, split by commas, and create a unique list
  facet_tags <- unique(unlist(strsplit(filtered_metadata$Facets, ",\\s*")))
  
  # Extract facets from the filtered metadata, replace commas and spaces with underscores, and create a unique list
  facets_list <- sort(unique(unlist(gsub("[, ]", "_", filtered_metadata$Facets))))
  
  # Update the selectizeInput with the processed facets list
  updateSelectizeInput(session, "clustering_selected_facets", choices = facets_list)
  updateSelectizeInput(session, "selected_facets", choices = facets_list)
  updateSelectizeInput(session, "facet_select", choices = facets_list)
  updateSelectizeInput(session, "selected_facets_plot", choices = facets_list)
  
  # List files in the local folder
  files <- list_local_files(local_folder)
  
  # Extract gene list names from file names (remove folder path and file extension)
  gene_list_names <- basename(files)
  gene_list_names <- sub("\\.txt$", "", gene_list_names)
  
  
  # -----------------------------------------------------------
  # Reactive values
  # -----------------------------------------------------------
  
  # Reactive value to store facet results
  facet_results <- reactiveVal()
  
  # Reactive value to store input genes
  input_genes <- reactiveVal()
  
  # Reactive value to store uploaded genes
  uploaded_genes <- reactiveVal()
  
  # Reactive value to store manually entered genes
  manual_genes <- reactiveVal()
  
  # Reactive value to store manually entered genes for similarity matrix
  input_list_genes <- reactiveVal(list())
  
  # Reactive value to store the name of the manually entered gene list
  input_list_name <- reactiveVal(list())
  
  # Reactive value to store multiple gene lists
  gene_lists <- reactiveVal(list())
  
  # Reactive value to track if genes are searched
  genes_searched <- reactiveVal(FALSE)
  
  # Reactive value to track if calculation is running
  calculate_running <- reactiveVal(FALSE)
  
  # Reactive value to store clicked gene sets
  clicked_set <- reactiveVal(NULL)
  
  # Reactive value to store clicked genes
  clicked_genes <- reactiveVal(NULL)
  
  # -----------------------------------------------------------
  # Tab: Input gene lists
  # -----------------------------------------------------------
  
  # UI for dynamic gene list input
  output$gene_list_ui <- renderUI({
    lists <- gene_lists()
    ui_elements <- lapply(seq_along(lists), function(i) {
      list(
        textInput(paste0("gene_list_name_", i), label = paste("Insert Gene List", i, "Name"), value = names(lists)[i]),
        textAreaInput(paste0("gene_list_", i), label = paste("Gene List", i), value = paste(lists[[i]], collapse = "\n"), rows = 5),
        actionButton(paste0("remove_gene_list_", i), label = "Remove gene list", class = "btn btn-danger"), # Button to remove all gene lists
        actionButton("save_all_gene_lists", "Save", class = "btn-custom")  # Button to save all gene lists
        
      )
    })
    if (length(lists) > 0) {
      ui_elements <- append(ui_elements, list(actionButton("add_more_gene_list", label = "+", class = "btn btn-primary square-button")))
    }
    do.call(tagList, ui_elements)
  })
  
  # Observe event for adding the initial gene list
  observeEvent(input$add_gene_list, {
    lists <- gene_lists()
    if (length(lists) == 0) {
      new_list <- list("Enter genes here")
      names(new_list) <- paste0("Gene List ", length(lists) + 1)
      lists <- c(lists, new_list)
      gene_lists(lists)
    }
  })
  
  # Observe event for manually entered gene list
  observeEvent(input$add_manual_gene_list, {
    manual_list_input <- input$manual_gene_list
    if (is.null(manual_list_input)) {
      manual_list_input <- ""
    }
    genes <- unlist(strsplit(manual_list_input, split = "\n"))
    genes <- trimws(genes)  
    manual_genes(genes)  
    
    updated_genes <- input_list_genes()
    updated_names <- input_list_name()
    updated_genes <- c(updated_genes, list(genes))
    updated_names <- c(updated_names, input$manual_gene_list_name)
    input_list_genes(updated_genes)
    input_list_name(updated_names)
    
    output$manual_gene_list_contents <- renderDT({
      datatable(data.frame(Genes = genes), options = list(pageLength = 10, scrollX = TRUE))
    })
  })
  
  
  # Observe event for adding more gene lists
  observeEvent(input$add_more_gene_list, {
    lists <- gene_lists()
    new_list <- list("Enter genes here")
    names(new_list) <- paste0("Gene List ", length(lists) + 1)
    lists <- c(lists, new_list)
    gene_lists(lists)
  })
  
  # Observe event for removing gene lists
  observe({
    lapply(seq_along(gene_lists()), function(i) {
      observeEvent(input[[paste0("remove_gene_list_", i)]], {
        lists <- gene_lists()
        lists <- lists[-i]
        gene_lists(lists)
      })
    })
  })
  
  # Observe event for clearing all gene lists
  observeEvent(input$clear_gene_lists, {
    gene_lists(list())
  })
  
  # Observe event for saving all gene lists
  observeEvent(input$save_all_gene_lists, {
    lists <- gene_lists()
    updated_lists <- list()
    
    for (i in seq_along(lists)) {
      list_name <- input[[paste0("gene_list_name_", i)]]
      genes <- unlist(strsplit(input[[paste0("gene_list_", i)]], split = "\n"))
      genes <- trimws(genes)  
      
      # Standardize the column name to "GENE_SYMBOL"
      if (length(genes) > 0) {
        gene_data <- data.frame(GENE_SYMBOL = genes, stringsAsFactors = FALSE)
        updated_lists[[list_name]] <- gene_data$GENE_SYMBOL
      } else {
        print(paste("Warning: Gene list", list_name, "is empty."))
      }
      
    }
    
    gene_lists(updated_lists)
    
    output$manual_gene_list_contents <- renderDT({
      datatable(
        data.frame(GeneList = rep(names(updated_lists), sapply(updated_lists, length)), Genes = unlist(updated_lists)), 
        options = list(
          pageLength = 10, 
          scrollX = TRUE,
          columnDefs = list(list(visible = FALSE, targets = 0))  # Hide the first column
        )
      )
    })
  })
  
  # Observe event for visualizing gene lists
  observeEvent(input$visualize_gene_lists, {
    lists <- gene_lists()
    output$visualized_gene_lists <- renderDT({
      datatable(
        data.frame(GeneList = rep(names(lists), sapply(lists, length)), Genes = unlist(lists)), 
        options = list(pageLength = 10, scrollX = TRUE)
      )
    })
  })
  
  # Observe event for use input gene list button
  observeEvent(input$use_input_gene_list, {
    output$input_gene_list_ui <- renderUI({
      selectizeInput("select_input_gene_list_search", "Select Input Gene List", choices = names(gene_lists()), multiple = TRUE)
    })
    
    observe({
      selected_list <- input$select_input_gene_list_search
      if (!is.null(selected_list) && length(selected_list) > 0) {
        gene_list <- gene_lists()[[selected_list]]
        gene_list <- clean_gene_list(gene_list)
        cat("Cleaned Input Gene List:", gene_list, "\n")
      }
    })
  })
  
  # -----------------------------------------------------------
  # Tab: Gene search
  # -----------------------------------------------------------
  
  # Observe event for gene search
  observeEvent(input$search_genes, {
    gene_input <- input$genes
    if (is.null(gene_input)) {
      gene_input <- ""
    }
    gene_names <- unlist(strsplit(gene_input, split = " "))
    gene_names <- trimws(gene_names)  # Remove leading/trailing whitespace
    
    if (!is.null(input$gene_file)) {
      file_genes <- suppressWarnings(readLines(input$gene_file$datapath))
      gene_names <- unique(c(gene_names, file_genes))
      uploaded_genes(file_genes)  # Store uploaded genes
    }
    
    selected_lists <- input$select_input_gene_list_search
    if (length(selected_lists) > 0) {
      lists <- gene_lists()
      gene_names <- unique(c(gene_names, unlist(lapply(selected_lists, function(list_name) lists[[list_name]]))))
    }
    
    input_genes(gene_names)  # Store input genes
    
    search_results <- search_genes(gene_names)
    
    search_results <- search_results[, c("Gene","Gene_list_name", "Facets", "Reference")]
    
    output$gene_results <- renderDT({
      datatable(search_results, options = list(pageLength = 25, scrollX = TRUE)) 
    })
    
    output$download_results <- downloadHandler(
      filename = function() {
        paste("gene_search_results", Sys.Date(), ".txt", sep = "")
      },
      content = function(file) {
        write.table(search_results, file, row.names = FALSE)
      }
    )
    
  })
  
  # Observe event for gene search within selected facets
  observeEvent(input$search_facet, {
    selected_facet <- input$facet_select
    results <- search_facet(selected_facet)
    
    selected_columns <- c("Gene_list_name", "Facets", "Title", "Notes")
    results <- results[, selected_columns, drop = FALSE]
    
    facet_results(results)
    
    output$facet_results <- renderDT({
      datatable(facet_results(), selection = 'single', options = list(pageLength = 10, scrollX = TRUE))
    })
  })
  
  # Observe event for selecting a gene list from the facet search results
  observeEvent(input$facet_results_rows_selected, {
    selected_row <- input$facet_results_rows_selected
    if (!is.null(selected_row) && length(selected_row) > 0) {
      selected_gene_list <- facet_results()[selected_row, "Gene_list_name"]
      selected_file <- file.path(local_folder, paste0(selected_gene_list, ".txt"))
      gene_list_contents <- suppressWarnings(readLines(selected_file))
      gene_list_contents <- gene_list_contents[!grepl("GENE_SYMBOL", gene_list_contents, ignore.case = TRUE)]
      output$gene_list_contents <- renderDT({
        datatable(data.frame(Genes = gene_list_contents), options = list(pageLength = 10, scrollX = TRUE))
      })
      
      output$download_gene_list <- downloadHandler(
        filename = function() {
          paste(selected_gene_list, "gene_list", Sys.Date(), ".txt", sep = "_")
        },
        content = function(file) {
          write.table(data.frame(Genes = gene_list_contents), file, row.names = FALSE, quote = F)
        }
      )
    }
  })
  
  # ----------------------
  # Tab: Similarity Matrix
  # ----------------------
  
  # Observe event for calculating similarity matrix for facets
  observeEvent(input$calculate_similarity_matrix_facets, {
    selected_facets <- input$selected_facets
    
    if (length(selected_facets) > 0) {
      output$similarityMatrixHeatmap <- renderPlotly({
        plot_similarity_matrix_facets(selected_facets)
      })
    } else {
      showNotification("Please select at least one facet for similarity matrix calculation.", type = "warning")
    }
  })
  
  # Observe event for calculating similarity matrix for gene lists
  observeEvent(input$calculate_similarity_matrix_genes, {
    selected_gene_lists <- input$selected_gene_lists_matrix
    selected_input_gene_lists <- input$input_gene_lists_for_matrix
    
    # Combine both selected predefined and input gene lists
    gene_lists_data <- list()
    
    # Load predefined gene lists from files
    if (length(selected_gene_lists) > 0) {
      gene_lists_data <- combine_gene_symbols(selected_gene_lists)
    }
    
    # Include user-added gene lists in the analysis
    if (length(selected_input_gene_lists) > 0) {
      input_genes_list <- gene_lists()[selected_input_gene_lists]
      gene_lists_data <- c(gene_lists_data, input_genes_list)
    }
    
    # Check if any gene lists are loaded
    if (length(gene_lists_data) > 0 && all(sapply(gene_lists_data, length) > 0)) {
      output$similarityMatrixHeatmap <- renderPlotly({
        plot_similarity_matrix_gene_lists(gene_lists_data)
      })
    } else {
      showNotification("No valid gene lists found. Please check the input.", type = "warning")
    }
  })
  
# Observe event for resetting the plot for gene lists
  observeEvent(input$reset_plot_genes, {
    output$similarityMatrixHeatmap <- renderPlotly({
      plotly::plot_ly() # Renders an empty plot
    })
  })
  
  # Observe event for resetting the plot for facets
  observeEvent(input$reset_plot_facets, {
    output$similarityMatrixHeatmap <- renderPlotly({
      plotly::plot_ly() # Renders an empty plot
    })
  })
  
  # Observe event for resetting the plot for facet interactions
  observeEvent(input$reset_interaction_genes, {
    output$force_directed_graph <- renderVisNetwork(NULL) 
    output$upsetjs_plot <- renderUpsetjs(NULL)           
  })
  
  # Observe changes in the available gene lists and update the selectize input choices for the similarity matrix tab accordingly
  observe({
    updateSelectizeInput(session, "selected_gene_lists_matrix", choices = gene_list_names)
    updateSelectizeInput(session, "input_gene_lists_for_matrix", choices = names(gene_lists()))
  })
  
  # -----------------------
  # Tab: Facet Interactions
  # -----------------------
  
  # Observe event for calculating clustering based on selected facets
  observeEvent(input$calculate_clustering, {
    calculate_running(TRUE)
    
    selected_facets <- input$clustering_selected_facets
    
    # Include the user-added gene lists in the analysis
    selected_input_gene_lists <- input$input_gene_lists_for_facets
    
    input_genes_list <- gene_lists()[selected_input_gene_lists]  # Fetch the entire reactive list content
    
    # Retrieve the actual gene content for the selected input gene lists
    if (!is.null(selected_input_gene_lists) && length(selected_input_gene_lists) > 0) {
      user_gene_lists <- lapply(selected_input_gene_lists, function(list_name) {
        gene_list_content <- input_genes_list[[list_name]]  # Get content by name
        return(gene_list_content)
      })
      
      # Set the names of the retrieved gene lists
      names(user_gene_lists) <- selected_input_gene_lists
      
      # Standardize the case of the gene symbols
      user_gene_lists <- lapply(user_gene_lists, function(x) toupper(x)) 
    } else {
      user_gene_lists <- list()
    }
    
    if (length(selected_facets) > 0) {
      gene_lists <- group_genes_by_facets(selected_facets)
      gene_lists <- c(gene_lists, user_gene_lists)  # Combine with user input gene lists
      
      gene_lists <- lapply(gene_lists, function(list) {
        if (is.data.frame(list) && !"GENE_SYMBOL" %in% colnames(list)) {
          colnames(list) <- "GENE_SYMBOL"
        }
        return(list)
      })
      
      # Initialize a matrix to store the number of overlapping genes
      overlap_matrix <- matrix(0, nrow = length(gene_lists), ncol = length(gene_lists))
      rownames(overlap_matrix) <- names(gene_lists)
      colnames(overlap_matrix) <- names(gene_lists)
      
      # Calculate the number of overlapping genes for each pair of gene lists
      for (i in 1:length(gene_lists)) {
        for (j in i:length(gene_lists)) {
          intersect_genes <- length(intersect(gene_lists[[i]], gene_lists[[j]]))
          overlap_matrix[i, j] <- intersect_genes
          overlap_matrix[j, i] <- intersect_genes
        }
      }
      
      # Remove self-loops (edges that start and end on the same node)
      edges <- data.frame(
        from = which(overlap_matrix > 0, arr.ind = TRUE)[, 1],
        to = which(overlap_matrix > 0, arr.ind = TRUE)[, 2],
        value = overlap_matrix[overlap_matrix > 0],
        title = paste0("Overlapping genes: ", overlap_matrix[overlap_matrix > 0]) # Add title for hover
      )
      edges <- edges[edges$from != edges$to, ]
      
      # Create a force-directed graph using visNetwork
      nodes <- data.frame(id = 1:length(gene_lists), label = names(gene_lists))
      
      output$force_directed_graph <- renderVisNetwork({
        visNetwork(nodes, edges) %>%
          visEdges(smooth = FALSE, color = "lightblue", width = 2) %>%
          visNodes(
            shape = "dot", 
            size = 15, 
            font = list(
              size = 18,
              background = "rgba(255, 255, 255, 0.8)",  # Set the background color for labels
              color = "#000000"
            ),
            color = list(
              background = "lightcoral", 
              border = "darkcoral",
              highlight = list(background = "lightyellow", border = "orange")
            )
          ) %>%
          visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
          visIgraphLayout()
      })
      
      # Create UpSet plot 
      output$upsetjs_plot <- renderUpsetjs({
        upsetjs() %>% upsetjs::fromList(gene_lists) %>% interactiveChart()
      })
      
      # Observe click events on the UpSet plot
      observeEvent(input$upsetjs_plot_click, {
        set_name <- input$upsetjs_plot_click$name
        if (!is.null(set_name)) {
          selected_facets <- strsplit(set_name, "&")[[1]]
          # Ensure all facets return gene lists
          selected_genes <- tryCatch({
            Reduce(intersect, lapply(selected_facets, function(facet) {
              genes <- gene_lists[[facet]]
              
              if (is.character(genes)) {
                return(genes)
              } else {
                stop(paste("Facet", facet, "does not return a character vector"))
              }
            }))
          }, error = function(e) {
            print(paste("Error in Reduce operation:", e))
            return(NULL)
          })
          
          if (!is.null(selected_genes)) {
            clicked_genes(selected_genes)
          } else {
            showNotification("Error calculating intersection of selected gene lists.", type = "error")
          }
        }
      })
      
      observe({
        if (input$visualization_type == "Graph") {
          output$force_directed_graph <- renderVisNetwork({
            visNetwork(nodes, edges) %>%
              visEdges(smooth = FALSE, color = "lightblue", width = 2) %>%
              visNodes(
                shape = "dot", 
                size = 15, 
                font = list(
                  size = 18,
                  background = "rgba(255, 255, 255, 0.8)",  # Set the background color for labels
                  color = "#000000"
                ),
                color = list(
                  background = "lightcoral", 
                  border = "darkcoral",
                  highlight = list(background = "lightyellow", border = "orange")
                )
              ) %>%
              visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
              visIgraphLayout()
          })
          output$upsetjs_plot <- renderUpsetjs(NULL)
        } else if (input$visualization_type == "UpSet Plot") {
          output$force_directed_graph <- renderVisNetwork(NULL)
          output$upsetjs_plot <- renderUpsetjs({
            upsetjs() %>% upsetjs::fromList(gene_lists) %>% interactiveChart()
          })
        }
      })
      
      calculate_running(FALSE)
    } else {
      showNotification("Please select at least one facet for clustering analysis.", type = "warning")
    }
  })
  
  # Observe event for calculating interaction analysis based on selected gene lists
  observeEvent(input$calculate_interaction_genes, {
    selected_gene_lists <- input$gene_lists_for_interaction
    selected_input_gene_lists <- input$input_gene_lists_for_interaction
    
    # Combine both selected gene lists and input gene lists
    combined_gene_lists <- list()
    
    # Load the gene lists from files
    if (length(selected_gene_lists) > 0) {
      selected_files <- files[basename(files) %in% paste0(selected_gene_lists, ".txt")]
      gene_lists_from_files <- lapply(selected_files, function(file) {
        gene_data <- read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
        
        # Ensure column name consistency
        if ("Genes" %in% colnames(gene_data)) {
          colnames(gene_data)[which(colnames(gene_data) == "Genes")] <- "GENE_SYMBOL"
        }
        
        gene_list <- clean_gene_list(gene_data$GENE_SYMBOL)  # Clean gene list
        return(gene_list)
      })
      names(gene_lists_from_files) <- selected_gene_lists
      combined_gene_lists <- c(combined_gene_lists, gene_lists_from_files)
    }
    
    # Include the user-added gene lists
    if (length(selected_input_gene_lists) > 0) {
      user_gene_lists <- gene_lists()[selected_input_gene_lists]
      combined_gene_lists <- c(combined_gene_lists, user_gene_lists)
    }
    
    # Ensure nodes and edges are correctly generated
    if (length(combined_gene_lists) > 0) {  # Corrected variable name to combined_gene_lists
      overlap_matrix <- matrix(0, nrow = length(combined_gene_lists), ncol = length(combined_gene_lists))
      rownames(overlap_matrix) <- names(combined_gene_lists)
      colnames(overlap_matrix) <- names(combined_gene_lists)
      
      for (i in 1:length(combined_gene_lists)) {
        for (j in i:length(combined_gene_lists)) {
          intersect_genes <- length(intersect(combined_gene_lists[[i]], combined_gene_lists[[j]]))
          overlap_matrix[i, j] <- intersect_genes
          overlap_matrix[j, i] <- intersect_genes
        }
      }
      
      edges <- data.frame(
        from = which(overlap_matrix > 0, arr.ind = TRUE)[, 1],
        to = which(overlap_matrix > 0, arr.ind = TRUE)[, 2],
        value = overlap_matrix[overlap_matrix > 0],
        title = paste0("Overlapping genes: ", overlap_matrix[overlap_matrix > 0])  # Add title for hover
      )
      edges <- edges[edges$from != edges$to, ]
      
      nodes <- data.frame(id = 1:length(combined_gene_lists), label = names(combined_gene_lists))
      
      # Update visualizations based on the selected visualization type
      if (input$visualization_type == "Graph") {
        output$force_directed_graph <- renderVisNetwork({
          visNetwork(nodes, edges) %>%
            visEdges(smooth = FALSE, color = "lightblue", width = 2) %>%
            visNodes(
              shape = "dot", 
              size = 15, 
              font = list(
                size = 18,
                background = "rgba(255, 255, 255, 0.8)",
                color = "#000000"
              ),
              color = list(
                background = "lightcoral", 
                border = "darkcoral",
                highlight = list(background = "lightyellow", border = "orange")
              )
            ) %>%
            visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
            visIgraphLayout()
        })
        output$upsetjs_plot <- renderUpsetjs(NULL)  # Clear UpSet plot when Graph is selected
      } else if (input$visualization_type == "UpSet Plot") {
        output$upsetjs_plot <- renderUpsetjs({
          upsetjs() %>% upsetjs::fromList(combined_gene_lists) %>% interactiveChart()
        })
        output$force_directed_graph <- renderVisNetwork(NULL)  # Clear Graph when UpSet Plot is selected
      }
    } else {
      showNotification("No gene lists available for the selected tags.", type = "warning")
    }
  })
  
  
  # Observe tag selection and filter gene lists accordingly in the similarity matrix tab
  observeEvent(input$tag_selector_similarity, {
    selected_tags <- input$tag_selector_similarity
    
    # Filter the gene lists based on selected tags
    filtered_lists <- filtered_metadata$Gene_list_name[sapply(filtered_metadata$Facets, function(facets) {
      any(sapply(selected_tags, function(tag) grepl(tag, facets)))
    })]
    
    # Update the gene list selector with the filtered lists
    updateSelectizeInput(session, "selected_gene_lists_matrix", choices = sort(filtered_lists), selected = filtered_lists)
  })
  
  # Use observe to update the tag selection dropdown with the extracted tags for similarity matrix
  observe({
    updateSelectizeInput(session, "tag_selector_similarity", choices = sort(facet_tags))
  })
  
  # Handle clicked genes in the UpSet plot
  observeEvent(input$upsetjs_plot_click, {
    set_name <- input$upsetjs_plot_click$name
    print(paste("Clicked set name:", set_name))
    
    # Check if gene_lists is a list
    if (!is.list(gene_lists())) {
      print("Error: gene_lists is not a list. It might have been overwritten.")
      return(NULL)
    }
    
    if (!is.null(set_name)) {
      selected_facets <- strsplit(set_name, "&")[[1]]
      print(paste("Selected facets:", selected_facets))
      
      # Check the output of each facet
      gene_lists_results <- lapply(selected_facets, function(facet) {
        result <- gene_lists()[[facet]]
        print(paste("Facet:", facet, "Result:", result))
        
        # Check if the result is actually a character vector
        if (is.null(result)) {
          print(paste("Warning: No genes found for facet:", facet))
        } else if (!is.character(result)) {
          print(paste("Error: Expected a character vector, but got:", class(result)))
        }
        
        return(result)
      })
      
      # Ensure that no elements of the list are NULL or functions
      valid_gene_lists <- Filter(function(x) !is.null(x) && is.character(x), gene_lists_results)
      
      if (length(valid_gene_lists) > 0) {
        selected_genes <- Reduce(intersect, valid_gene_lists)
        print("Selected genes after intersection:")
        print(selected_genes)
        clicked_genes(selected_genes)
      } else {
        print("No valid gene lists to intersect.")
      }
    }
  })
  # Render the table and download button for the clicked genes
  observe({
    if (!is.null(clicked_genes())) {
      output$clicked_genes_table <- renderDT({
        datatable(data.frame(Gene = clicked_genes()), options = list(pageLength = 10, scrollX = TRUE))
      })
      
      output$download_clicked_genes <- downloadHandler(
        filename = function() {
          paste0("clicked_genes_", Sys.Date(), ".txt")
        },
        content = function(file) {
          write.table(data.frame(Gene = clicked_genes()), file, row.names = FALSE, quote = F)
        }
      )
    }
  })
  # Observe event for "Select All Facets" button
  observeEvent(input$select_all_facets, {
    updateSelectizeInput(session, "selected_facets", choices = facets_list, selected = facets_list)
  })
  
  # Observe event for "Deselect All Facets" button
  observeEvent(input$deselect_all_facets, {
    updateSelectizeInput(session, "selected_facets", selected = character(0))
  })
  
  # Observe event for "Select All Clustering Facets" button
  observeEvent(input$select_all_clustering_facets, {
    updateSelectizeInput(session, "clustering_selected_facets", choices = facets_list, selected = facets_list)
  })
  
  # Observe event for "Deselect All Clustering Facets" button
  observeEvent(input$deselect_all_clustering_facets, {
    updateSelectizeInput(session, "clustering_selected_facets", selected = character(0))
  })
  # Add the available user-added gene lists to the select input in the facet interactions tab
  observe({
    updateSelectizeInput(session, "input_gene_lists_for_facets", choices = names(gene_lists()))
  })
  
  # Update gene list choices for interaction analysis
  observe({
    updateSelectizeInput(session, "gene_lists_for_interaction", choices = gene_list_names)
    updateSelectizeInput(session, "input_gene_lists_for_interaction", choices = names(gene_lists()))
    
  })
  
  # Observe tag selection and filter gene lists accordingly
  observeEvent(input$tag_selector, {
    selected_tags <- input$tag_selector
    
    # Filter the gene lists based on selected tags
    filtered_lists <- filtered_metadata$Gene_list_name[sapply(filtered_metadata$Facets, function(facets) {
      any(sapply(selected_tags, function(tag) grepl(tag, facets)))
    })]
    
    # Update the gene list selector with the filtered lists
    updateSelectizeInput(session, "gene_lists_for_interaction", choices = sort(filtered_lists), selected = filtered_lists)
  })
  
  # Use observe to update the tag selection dropdown with the extracted tags
  observe({
    updateSelectizeInput(session, "tag_selector", choices = sort(facet_tags))
  }) 
  
}

# Run the application
shinyApp(ui = ui, server = server)
