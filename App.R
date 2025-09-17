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
library(shinyjs)
library(RColorBrewer)
library(htmlwidgets)
library(webshot2)
library(igraph)


# -----------------------------------------------------------
# UI
# -----------------------------------------------------------

info_i <- function(html) {
  tags$span(
    icon("info-circle"),
    `data-toggle`   = "tooltip",
    `data-html`     = "true",
    `data-placement`= "right",
    title = html,
    style = "cursor:help; color:#777; margin-left:8px;"
  )
}

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
      menuItem("Saved Lists", tabName = "saved_lists", icon = icon("list")),
      menuItem("Search", tabName = "gene_search", icon = icon("search")),  # Menu item for Search functionality
      menuItem("Similarity Matrix", tabName = "similarity_matrix", icon = icon("th")),  # Menu item for Similarity Matrix
      menuItem("Facet Interactions", tabName = "facet_interactions", icon = icon("sitemap"))  # Menu item for Facet Interactions
    )
  ),
  
  # Define the body of the dashboard
  dashboardBody(
    useShinyjs(),
    
    # ─── Initialize all Bootstrap tooltips ────────────────────────────────────────
    tags$script(HTML("
    $(function(){
      $('[data-toggle=\"tooltip\"]').tooltip();
    });
  ")),
    # ──────────────────────────────────────────────────────────────────────────────
    
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
                  width = 12, status = "primary", solidHeader = TRUE,
                  h4("Search Your Genes", style = "margin-bottom:20px;"),
                  
                  # Step 1 with tooltip on the info icon
                  radioButtons(
                    "input_mode",
                    label = tagList(
                      "Step 1: Choose Input Method:",
                      tags$span(
                        icon("info-circle"),
                        `data-toggle` = "tooltip",
                        `data-html`   = "true",
                        `data-placement` = "right",
                        title = "
                        <ul style='margin:0; padding-left:16px;'>
                        <li><b>Manual</b>: Type one HUGO ID per line.</li>
                        <li><b>File</b>: Upload a .txt (one ID per line) or .csv (one column).</li>
                        <li><b>Saved</b>: Pick one of your saved gene lists.</li>
                        </ul>
                        ",
                        style = "cursor:help; color:#777; margin-left:8px;"
                      )
                    ),
                    choices = c(
                      "Type genes"    = "manual",
                      "Upload file"   = "file",
                      "Saved list"    = "saved"
                    )
                  ),
                  
                  uiOutput("gene_input_ui"),
                  actionButton("search_genes", "Step 2: Search", class="btn-custom", disabled=TRUE),
                  actionButton("reset_search", "Reset", class="btn-danger", style="margin-left:10px;"),
                  br(), br(),
                  DTOutput("gene_results"),
                  uiOutput("download_results_ui")
                )
              )
      ),
      
      # SAVED LISTS TAB
      tabItem(
        tabName = "saved_lists",
        fluidRow(
          box(
            title = "Saved Lists Overview", status = "primary", solidHeader = TRUE, width = 12,
            fluidRow(
              column(3,
                     selectizeInput("saved_tag_filter", "Filter by Facets (tags)",
                                    choices = NULL, multiple = TRUE,
                                    options = list(placeholder = "Select facets…"))
              ),
              column(3,
                     radioButtons("saved_source", "Source",
                                  choices = c("All", "Preloaded", "User"),
                                  selected = "All", inline = TRUE)
              ),
              column(3,
                     sliderInput("saved_top_n", "Show top N (by size)",
                                 min = 5, max = 100, value = 30, step = 5)
              ),
              column(3,
                     textInput("saved_search", "Search by list name", placeholder = "e.g. GL0001234 or My_Gene_List")
              )
            ),
            plotlyOutput("saved_lists_bar", height = "600px")
          )
        ),
        fluidRow(
          box(
            title = "Saved Lists Table", status = "primary", solidHeader = TRUE, width = 12,
            DTOutput("saved_lists_table")
          )
        ),
        fluidRow(
          box(
            title = "List Preview", status = "primary", solidHeader = TRUE, width = 12,
            uiOutput("saved_list_meta"),
            DTOutput("single_list_preview"),
            downloadButton("download_saved_list", "Download Selected List", class = "btn-custom")
          )
        )
      ),

      
      # Tab for Similarity Matrix functionality
      tabItem(tabName = "similarity_matrix",
              fluidRow(
                box(
                  title = "Similarity Matrix", status = "primary", solidHeader = TRUE, width = 12,
                  radioButtons(
                    "matrix_type",
                    label = tagList(
                      "Perform Similarity Matrix on:",
                      info_i("
                      <b>Gene Lists</b>: choose specific lists (and optional search hits).<br>
                      <b>Facets</b>: group and compare lists by Facet tags.
                     ")
                    ),
                    choices = c("Gene Lists" = "genes", "Facets" = "facets")
                  ),
                  conditionalPanel(
                    condition = "input.matrix_type == 'genes'",
                   fluidRow(
                      column(4, actionButton("calculate_similarity_matrix_genes", "Calculate", class = "btn-custom"),
                             `data-toggle`="tooltip", title="Compute and display the similarity matrix."),
                      column(4, actionButton("reset_plot_genes", "Reset Plot", class = "btn-danger"),
                             `data-toggle`="tooltip")
                    ),
                    selectizeInput("tag_selector_similarity", "Select Tags", choices = NULL, multiple = TRUE),  # Tag selector for similarity matrix
                    selectizeInput("selected_gene_lists_matrix", "Select Gene Lists", choices = NULL, multiple = TRUE),  # Dropdown to select gene lists for analysis
                    selectizeInput("input_gene_lists_for_matrix", "Select Input Gene Lists", choices = NULL, multiple = TRUE),  # Dropdown to select user-added gene lists
                    hr(),
                    checkboxInput("use_search_hits_matrix", "Add gene lists from Search hits", value = FALSE),
                    fluidRow(
                      column(6,
                             selectInput("pval_column_matrix", "Use p-value column:",
                                         choices = c("FDR (BH)" = "Adjusted_p_value",
                                                     "Raw p-value" = "Hypergeometric_p_value"),
                                         selected = "Adjusted_p_value")
                      ),
                      column(6,
                             numericInput("pval_threshold_matrix", "Max threshold", value = 0.05, min = 0, max = 1, step = 0.001)
                      )
                    )
                  ),
                  conditionalPanel(
                    condition = "input.matrix_type == 'facets'",
                    fluidRow(
                      column(6, actionButton("select_all_facets", "Select All Facets", class = "btn-custom")),  # Button to select all facets
                      column(6, actionButton("deselect_all_facets", "Deselect All Facets", class = "btn-danger"))  # Button to deselect all facets
                    ),
                    selectizeInput("selected_facets", "Select Facets", choices = NULL, multiple = TRUE),  # Dropdown to select facets for analysis
                    fluidRow(
                      column(4, actionButton("calculate_similarity_matrix_facets", "Calculate", class = "btn-custom")),
                      column(4, actionButton("reset_plot_facets", "Reset Plot", class = "btn-danger"))
                    )
                  ),
                  uiOutput("download_similarity_ui"),
                  div(style = "width: 100%; height: 1000px; overflow: auto;", 
                      plotlyOutput("similarityMatrixHeatmap", width = "1800px", height = "1800px")  # Plot output for similarity matrix heatmap
                  )
                )
              )
      ),
      
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
                    actionButton("reset_interaction_genes", "Reset Plot", class = "btn-danger"),  # Button to reset plot for interactions
                    checkboxInput("use_search_hits_interactions", "Add gene lists from Search hits", value = FALSE),
                    fluidRow(
                      column(6,
                             selectInput("pval_column_interactions", "Use p-value column:",
                                         choices = c("FDR (BH)" = "Adjusted_p_value",
                                                     "Raw p-value" = "Hypergeometric_p_value"),
                                         selected = "Adjusted_p_value")
                      ),
                      column(6,
                             numericInput("pval_threshold_interactions", "Max threshold", value = 0.05, min = 0, max = 1, step = 0.001)
                      )
                    )
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
      tabItem(
        tabName = "input_gene_lists",
        fluidRow(
          box(
            title = "Input Gene Lists", status = "primary", solidHeader = TRUE, width = 12,
            radioButtons(
              "input_list_mode", "Add Gene Lists by:",
              choices = c("Upload Files" = "file", "Manual Entry" = "manual"),
              inline = TRUE
            ),
            conditionalPanel(
              condition = "input.input_list_mode == 'file'",
              fileInput(
                "gene_list_files",
                "Upload gene list files (.txt, .csv)",
                multiple = TRUE,
                accept = c(".txt", ".csv")
              )
            ),
            conditionalPanel(
              condition = "input.input_list_mode == 'manual'",
              textInput("manual_list_name", "List Name", value = "My_Gene_List"),
              textAreaInput(
                "manual_list_genes",
                "Enter genes (one per line)",
                rows = 6,
                placeholder = "e.g. TP53\nBRCA1\nEGFR"
              ),
              actionButton("add_manual_list", "Add List", class = "btn-custom")
            ),
            hr(),
            actionButton("clear_lists", "Clear All Lists", class = "btn-danger"),
            br(), br(),
            DTOutput("gene_lists_preview")
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
  
  
  search_genes <- function(gene_names) {
    results <- data.frame(
      Gene_list_name = character(),
      Facets = character(),
      Number_of_Input_Genes = integer(),
      Number_of_Genes_in_List = integer(),
      Number_of_Overlaps = integer(),
      Percentage_of_Overlap = numeric(),
      Overlapping_Genes = character(),
      Hypergeometric_p_value = numeric(),
      stringsAsFactors = FALSE
    )
    
    gene_names <- toupper(gene_names)
    num_input_genes <- length(unique(gene_names))
    
    universe_genes <- unique(unlist(lapply(files, function(file) {
      gene_data <- read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
      if ("Genes" %in% colnames(gene_data)) {
        colnames(gene_data)[which(colnames(gene_data) == "Genes")] <- "GENE_SYMBOL"
      }
      toupper(gene_data$GENE_SYMBOL)
    })))
    N <- length(universe_genes)
    n <- num_input_genes
    
    for (file in files) {
      gene_data <- read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
      if ("Genes" %in% colnames(gene_data)) {
        colnames(gene_data)[which(colnames(gene_data) == "Genes")] <- "GENE_SYMBOL"
      }
      gene_list <- toupper(unique(gene_data$GENE_SYMBOL))
      M <- length(gene_list)
      
      overlapping_genes <- intersect(gene_names, gene_list)
      k <- length(overlapping_genes)
      
      if (k >= 1) {
        percentage_overlap <- (k / num_input_genes) * 100
        pval <- phyper(k - 1, M, N - M, n, lower.tail = FALSE)
        
        file_base <- sub("\\.txt$", "", basename(file))
        metadata_row <- metadata[which(metadata$Gene_list_name == file_base), ]
        
        if (nrow(metadata_row) > 0) {
          results <- rbind(
            results,
            data.frame(
              Gene_list_name = metadata_row$Gene_list_name,
              Facets = metadata_row$Facets,
              Number_of_Input_Genes = n,
              Number_of_Genes_in_List = M,
              Number_of_Overlaps = k,
              Percentage_of_Overlap = round(percentage_overlap, 2),
              Overlapping_Genes = paste(overlapping_genes, collapse = ", "),
              Hypergeometric_p_value = pval,
              Reference = metadata_row$Title,
              Description = metadata_row$Notes,
              stringsAsFactors = FALSE
            )
          )
        }
      }
    }
    
    if (nrow(results) == 0) return(results)
    
    #adjust for multiple testing 
    results$Adjusted_p_value <- p.adjust(results$Hypergeometric_p_value, method = "BH")
    results$minus_log10_q <- -log10(pmax(results$Adjusted_p_value, .Machine$double.xmin))
    
    # Sort by FDR then by overlap size
    results <- results[order(results$Adjusted_p_value, -results$Number_of_Overlaps), ]
    
    # Ensure uniqueness
    unique(results)
  }
  
  search_hit_list_names <- function(res, pcol, thr) {
    if (is.null(res) || nrow(res) == 0) return(character(0))
    if (!pcol %in% names(res)) return(character(0))
    idx <- is.finite(res[[pcol]]) & !is.na(res[[pcol]]) & res[[pcol]] <= thr
    unique(res$Gene_list_name[idx])
  }
  
  # Returns a *named list* of character vectors (genes) for the given list names
  gene_lists_from_names <- function(list_names) {
    if (length(list_names) == 0) return(list())
    combine_gene_symbols(list_names)
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
  read_preloaded_genes <- function(list_name) {
    file_path <- file.path(local_folder, paste0(list_name, ".txt"))
    if (!file.exists(file_path)) return(character(0))
    gene_data <- tryCatch({
      read.table(file_path, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
    }, error = function(e) NULL)
    if (is.null(gene_data)) return(character(0))
    if ("Genes" %in% colnames(gene_data)) {
      colnames(gene_data)[colnames(gene_data) == "Genes"] <- "GENE_SYMBOL"
    }
    if (!"GENE_SYMBOL" %in% colnames(gene_data)) return(character(0))
    unique(toupper(trimws(gene_data$GENE_SYMBOL)))
  }
  
  # Build a one-row summary for a preloaded list
  summarize_preloaded <- function(fpath) {
    list_name <- sub("\\.txt$", "", basename(fpath))
    genes <- read_preloaded_genes(list_name)
    meta_row <- metadata[metadata$Gene_list_name == list_name, , drop = FALSE]
    data.frame(
      ListName  = list_name,
      Source    = "Preloaded",
      Size      = length(genes),
      Facets    = if (nrow(meta_row)) meta_row$Facets else NA_character_,
      Reference = if (nrow(meta_row)) meta_row$Title  else NA_character_,
      Notes     = if (nrow(meta_row)) meta_row$Notes  else NA_character_,
      stringsAsFactors = FALSE
    )
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
    
    p <- heatmaply::heatmaply(
      similarity_matrix,            # or `sim` in the facets version
      xlab = NA, ylab = NA,
      main = "Similarity Matrix (Facets)",
      plot_method = "plotly",
      dendrogram = "none",
      hide_colorbar = FALSE,
      na.value = "transparent",
      fontsize_row = 16,
      fontsize_col = 16,
      colors = colorRampPalette(c("blue", "red"))(256)
    ) %>%
      plotly::layout(
        margin = list(l = 320, r = 180, b = 220, t = 60),
        xaxis  = list(automargin = TRUE, tickfont = list(size = 14)),
        yaxis  = list(automargin = TRUE, tickfont = list(size = 14))
      )
    return(p)
  }
  
  # Function to calculate and plot similarity matrix based on facets
  plot_similarity_matrix_facets <- function(selected_facets) {
    sel <- get_gene_lists_by_facets(selected_facets, local_folder, filtered_metadata)
    gene_lists <- sel$gene_lists
    map        <- sel$map
    
    if (length(gene_lists) == 0) {
      showNotification("No gene lists found for the selected facets.", type = "warning")
      return(NULL)
    }
    
    # order by facet, then list name
    ord <- order(factor(map$PrimaryFacet, levels = selected_facets), map$List)
    gene_lists <- gene_lists[ord]
    map        <- map[ord, , drop = FALSE]
    
    # Jaccard similarity
    n <- length(gene_lists)
    sim <- matrix(NA_real_, n, n, dimnames = list(names(gene_lists), names(gene_lists)))
    for (i in seq_len(n)) {
      for (j in i:n) {
        u <- union(gene_lists[[i]], gene_lists[[j]])
        val <- if (length(u) == 0) NA_real_ else length(intersect(gene_lists[[i]], gene_lists[[j]])) / length(u)
        sim[i, j] <- val
        sim[j, i] <- val
      }
    }
    sim[upper.tri(sim)] <- NA
    
    # ---- SINGLE facet side bar (columns only) with proper labels ----
    facet_levels <- unique(map$PrimaryFacet)
    facet_factor <- factor(map$PrimaryFacet, levels = facet_levels)
    
    # stable palette for facets
    pal <- colorRampPalette(brewer.pal(min(8, max(3, length(facet_levels))), "Set2"))(length(facet_levels))
    facet_cols <- setNames(pal, facet_levels)
    
    # build column side colors as a one-column data.frame of factors
    col_side <- data.frame(Facet = facet_factor, row.names = map$List, check.names = FALSE)
    
    p <- heatmaply::heatmaply(
      sim,
      row_side_colors     = data.frame(Facet = facet_factor, row.names = map$List),
      column_side_colors  = data.frame(Facet = facet_factor, row.names = map$List),
      xlab = NA, ylab = NA,
      main = "Similarity Matrix (Facets)",
      plot_method = "plotly",
      dendrogram = "none",
      hide_colorbar = FALSE,
      na.value = "transparent",
      fontsize_row = 16,
      fontsize_col = 16,
      colors = colorRampPalette(c("blue", "red"))(256)
    ) %>%
      plotly::layout(
        margin = list(l = 320, r = 180, b = 220, t = 60),
        xaxis  = list(automargin = TRUE, tickfont = list(size = 14)),
        yaxis  = list(automargin = TRUE, tickfont = list(size = 14))
      )
    return(p)
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
  
  read_preloaded_genes <- function(list_name) {
    file_path <- file.path(local_folder, paste0(list_name, ".txt"))
    if (!file.exists(file_path)) return(character(0))
    gene_data <- tryCatch(read.table(file_path, header = TRUE, sep = "\t", stringsAsFactors = FALSE),
                          error = function(e) NULL)
    if (is.null(gene_data)) return(character(0))
    if ("Genes" %in% colnames(gene_data)) {
      colnames(gene_data)[colnames(gene_data) == "Genes"] <- "GENE_SYMBOL"
    }
    if (!"GENE_SYMBOL" %in% colnames(gene_data)) return(character(0))
    unique(toupper(trimws(gene_data$GENE_SYMBOL)))
  }
  
  # ensure unique list names (avoid collisions)
  unique_list_name <- function(base, existing) {
    nm <- base
    i <- 1
    while (nm %in% existing) {
      i <- i + 1
      nm <- paste0(base, "_", i)
    }
    nm
  }
  
  facet_tokens <- function(x) {
    if (is.na(x) || !nzchar(x)) return(character(0))
    trimws(unlist(strsplit(x, ",", fixed = TRUE)))
  }
  
  # Return a named list: list_name -> character vector of genes
  # Only include lists whose metadata Facets contain ANY of selected_facets.
  # Also return a data.frame mapping each list to a "primary facet" used for grouping/annotation.
  get_gene_lists_by_facets <- function(selected_facets, local_folder, filtered_metadata) {
    if (length(selected_facets) == 0) return(list(gene_lists = list(), map = data.frame()))
    
    md <- filtered_metadata
    # keep rows where any selected facet matches the tokenized facets
    keep <- vapply(seq_len(nrow(md)), function(i) {
      fs <- facet_tokens(md$Facets[i])
      any(fs %in% selected_facets)
    }, logical(1))
    md_keep <- md[keep, , drop = FALSE]
    
    if (nrow(md_keep) == 0) {
      return(list(gene_lists = list(), map = data.frame()))
    }
    
    # primary facet = first selected facet appearing in the list's facets (for grouping/color)
    primary_facet_for <- function(facets_str) {
      fs <- facet_tokens(facets_str)
      hit <- selected_facets[selected_facets %in% fs]
      if (length(hit)) hit[1] else if (length(fs)) fs[1] else NA_character_
    }
    
    list_names <- md_keep$Gene_list_name
    # read genes per list
    read_one <- function(list_name) {
      file_path <- file.path(local_folder, paste0(list_name, ".txt"))
      if (!file.exists(file_path)) return(character(0))
      gene_data <- tryCatch(read.table(file_path, header = TRUE, sep = "\t", stringsAsFactors = FALSE),
                            error = function(e) NULL)
      if (is.null(gene_data)) return(character(0))
      if ("Genes" %in% colnames(gene_data)) {
        colnames(gene_data)[colnames(gene_data) == "Genes"] <- "GENE_SYMBOL"
      }
      if (!"GENE_SYMBOL" %in% colnames(gene_data)) return(character(0))
      unique(toupper(trimws(gene_data$GENE_SYMBOL)))
    }
    
    genes_list <- lapply(list_names, read_one)
    names(genes_list) <- list_names
    # drop empties
    non_empty <- vapply(genes_list, function(x) length(x) > 0, logical(1))
    genes_list <- genes_list[non_empty]
    md_keep    <- md_keep[match(names(genes_list), md_keep$Gene_list_name), , drop = FALSE]
    
    # map list -> primary facet
    map <- data.frame(
      List = names(genes_list),
      PrimaryFacet = vapply(md_keep$Facets, primary_facet_for, character(1)),
      stringsAsFactors = FALSE
    )
    # keep only those with a facet label
    keep2 <- nzchar(map$PrimaryFacet)
    list(
      gene_lists = genes_list[keep2],
      map        = map[keep2, , drop = FALSE]
    )
  }
  
  facet_palette <- function(facets) {
    facets <- unique(facets[nzchar(facets)])
    k <- length(facets)
    # Use Set2 → Set3 fallback for larger k
    if (k <= 8) {
      cols <- brewer.pal(max(3, k), "Set2")[seq_len(k)]
    } else {
      cols <- colorRampPalette(brewer.pal(12, "Set3"))(k)
    }
    setNames(cols, facets)
  }
  
  # -----------------------------------------------------------
  # Data loading and preprocessing
  # -----------------------------------------------------------
  
  #CHANGE IF YOUR FOLDER PATH IS DIFFERENT
  #setwd("C:/Users/gp487/OneDrive - University of Exeter/Genedex/")
  # Load metadata from the Excel file
  local_folder <- "Genes_lists"
  facet_palette <- function(facets) {
  facets <- unique(facets[nzchar(facets)])
  k <- length(facets)
  # Use Set2 → Set3 fallback for larger k
  if (k <= 8) {
    cols <- brewer.pal(max(3, k), "Set2")[seq_len(k)]
  } else {
    cols <- colorRampPalette(brewer.pal(12, "Set3"))(k)
  }
  setNames(cols, facets)
}
  metadata_path <- "Gene_list_collection.xlsx"
  metadata <- read_excel(metadata_path, sheet = 2)
  
  # Filter the data to include only rows where Status = 1 and remove NA values in the Facets column
  filtered_metadata <- metadata[metadata$Status == 1 & !is.na(metadata$Facets), ]
  
  # Extract tags from the "Facets" column, split by commas, and create a unique list
  facet_tags <- unique(unlist(strsplit(filtered_metadata$Facets, ",\\s*")))
  
  # Build facet choices from the metadata Facets column (tokenized by commas)
  all_tokens  <- unique(unlist(lapply(filtered_metadata$Facets, facet_tokens)))
  facets_list <- sort(all_tokens)
  
  # Update the selectizeInput with the processed facets list
  updateSelectizeInput(session, "clustering_selected_facets", choices = facets_list)
  updateSelectizeInput(session, "selected_facets",            choices = facets_list)
  updateSelectizeInput(session, "facet_select",               choices = facets_list)
  updateSelectizeInput(session, "selected_facets_plot",       choices = facets_list)
  
  # List files in the local folder
  files <- list_local_files(local_folder)
  
  # Extract gene list names from file names (remove folder path and file extension)
  gene_list_names <- basename(files)
  gene_list_names <- sub("\\.txt$", "", gene_list_names)
  
  
  # -----------------------------------------------------------
  # Reactive values
  # -----------------------------------------------------------
  
  # Reactive value to store search results
  search_results_rv <- reactiveVal()
  
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
  
  # Reactive data.frame to store all gene lists
  gene_lists_df <- reactiveVal(
    data.frame(ListName = character(), Gene = character(), stringsAsFactors = FALSE)
  )
  
  # Reactive value to track if genes are searched
  genes_searched <- reactiveVal(FALSE)
  
  # Reactive value to track if calculation is running
  calculate_running <- reactiveVal(FALSE)
  
  # Reactive value to store clicked gene sets
  clicked_set <- reactiveVal(NULL)
  
  # Reactive value to store clicked genes
  clicked_genes <- reactiveVal(NULL)
  
  # ---- at top of server() with your other reactives ----
  similarity_plot_rv <- reactiveVal(NULL)
  
  output$download_similarity_ui <- renderUI({
    # Show the button once the plot exists; you can drop req() if you want it always visible
    req(similarity_plot_rv())
    downloadButton("download_similarity_png", "Download PNG", class = "btn-custom")
  })
  
  # -----------------------------------------------------------
  # Tab: Input gene lists
  # -----------------------------------------------------------
  
  # Handle file uploads
  observeEvent(input$gene_list_files, {
    req(input$gene_list_files)
    df_list <- lapply(seq_len(nrow(input$gene_list_files)), function(i) {
      path <- input$gene_list_files$datapath[i]
      ext  <- tools::file_ext(input$gene_list_files$name[i])
      genes <- if (tolower(ext) == "txt") {
        readLines(path)
      } else {
        read.csv(path, header=TRUE, stringsAsFactors=FALSE)[[1]]
      }
      data.frame(
        ListName = tools::file_path_sans_ext(input$gene_list_files$name[i]),
        Gene     = toupper(trimws(genes)),
        stringsAsFactors = FALSE
      )
    })
    all_lists <- do.call(rbind, df_list)
    gene_lists_df(rbind(gene_lists_df(), all_lists))
  })
  
  # Handle manual entry
  observeEvent(input$add_manual_list, {
    req(input$manual_list_name)
    genes <- strsplit(input$manual_list_genes, "[\r\n]+")[[1]]
    genes <- toupper(trimws(genes))
    new_df <- data.frame(
      ListName = input$manual_list_name,
      Gene     = genes,
      stringsAsFactors = FALSE
    )
    gene_lists_df(rbind(gene_lists_df(), new_df))
    
    # Clear manual entry fields
    updateTextInput(session, "manual_list_name", value = "")
    updateTextAreaInput(session, "manual_list_genes", value = "")
  })
  
  # Clear all lists
  observeEvent(input$clear_lists, {
    gene_lists_df(
      data.frame(ListName = character(), Gene = character(), stringsAsFactors = FALSE)
    )
  })
  
  # Preview gene lists
  output$gene_lists_preview <- renderDT({
    datatable(
      gene_lists_df(),
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })
  
  observeEvent(input$save_hits_btn, {
    res <- search_results_rv()
    if (is.null(res) || nrow(res) == 0) {
      showNotification("No search results to save.", type = "warning"); return()
    }
    sel <- input$gene_results_rows_selected
    if (length(sel) == 0) {
      showNotification("Select one or more rows in the results table.", type = "warning"); return()
    }
    
    mode    <- input$save_hits_mode %||% "overlap"
    prefix  <- gsub("[^A-Za-z0-9_\\-]", "_", input$save_hits_prefix %||% "SearchHit")
    combine <- isTRUE(input$save_hits_combine)
    
    # Build a named list: name -> gene vector
    pieces <- lapply(sel, function(i) {
      row <- res[i, ]
      if (mode == "overlap") {
        genes <- unlist(strsplit(row$Overlapping_Genes %||% "", "\\s*,\\s*"))
        genes <- unique(toupper(trimws(genes)))
        genes <- genes[nzchar(genes)]
      } else { # "full"
        genes <- read_preloaded_genes(row$Gene_list_name)
      }
      genes
    })
    
    # Determine names
    existing_names <- unique(gene_lists_df()$ListName)
    new_lists <- list()
    
    if (combine) {
      # union of all selected rows
      all_genes <- unique(unlist(pieces))
      new_name  <- unique_list_name(prefix, existing_names)
      new_lists[[new_name]] <- all_genes
    } else {
      for (k in seq_along(sel)) {
        src <- res$Gene_list_name[sel[k]]
        base <- if (mode == "overlap") paste0(prefix, "_", src, "_OVERLAP")
        else                     paste0(prefix, "_", src, "_FULL")
        nm <- unique_list_name(base, existing_names)
        new_lists[[nm]] <- pieces[[k]]
        existing_names <- c(existing_names, nm)
      }
    }
    
    # Append to gene_lists_df() (user lists store)
    df <- gene_lists_df()
    for (nm in names(new_lists)) {
      if (length(new_lists[[nm]]) == 0) next
      add <- data.frame(
        ListName = nm,
        Gene     = sort(new_lists[[nm]]),
        stringsAsFactors = FALSE
      )
      df <- rbind(df, add)
    }
    gene_lists_df(df)
    
    showNotification(sprintf("Saved %d list(s) from Search.", length(new_lists)), type = "message")
  })

  # -----------------------------------------------------------
  # Tab: Saved lists
  # -----------------------------------------------------------
  
  observe({
    updateSelectizeInput(session, "saved_tag_filter", choices = sort(facet_tags))
  })
  
  # Build preloaded list summaries (from files)
  preloaded_lists_df <- reactive({
    if (length(files) == 0) {
      return(data.frame(ListName=character(), Source=character(), Size=integer(),
                        Facets=character(), Reference=character(), Notes=character(),
                        stringsAsFactors = FALSE))
    }
    rows <- lapply(files, summarize_preloaded)
    do.call(rbind, rows)
  })
  
  
  # Build user-added list summaries (from gene_lists_df())
  user_lists_df <- reactive({
    df <- gene_lists_df()
    if (nrow(df) == 0) {
      return(data.frame(ListName=character(), Source=character(), Size=integer(),
                        Facets=character(), Reference=character(), Notes=character(),
                        stringsAsFactors = FALSE))
    }
    # collapse to sizes
    agg <- aggregate(Gene ~ ListName, data = df, FUN = function(x) length(unique(na.omit(toupper(trimws(x))))))
    data.frame(
      ListName  = agg$ListName,
      Source    = "User",
      Size      = agg$Gene,
      Facets    = NA_character_,
      Reference = NA_character_,
      Notes     = NA_character_,
      stringsAsFactors = FALSE
    )
  })
  
  user_lists_as_list <- reactive({
    df <- gene_lists_df()
    if (nrow(df) == 0) return(list())
    split(
      x = toupper(trimws(df$Gene)),
      f = df$ListName
    ) |> lapply(function(v) unique(v[nzchar(v)]))
  })
  
  # Combined + filtered table
  saved_lists_all <- reactive({
    rbind(preloaded_lists_df(), user_lists_df())
  })
  
  saved_lists_filtered <- reactive({
    tbl <- saved_lists_all()
    
    # Source filter
    if (!is.null(input$saved_source) && input$saved_source != "All") {
      tbl <- tbl[tbl$Source == input$saved_source, , drop = FALSE]
    }
    
    # Facet (tag) filter: keep rows that contain ANY selected tag in Facets
    if (!is.null(input$saved_tag_filter) && length(input$saved_tag_filter) > 0) {
      keep <- sapply(seq_len(nrow(tbl)), function(i) {
        f <- tbl$Facets[i]
        if (is.na(f) || !nzchar(f)) return(FALSE)
        any(grepl(paste(input$saved_tag_filter, collapse = "|"), f, ignore.case = TRUE))
      })
      tbl <- tbl[keep, , drop = FALSE]
    }
    
    # Search in list name
    if (!is.null(input$saved_search) && nzchar(input$saved_search)) {
      patt <- input$saved_search
      tbl <- tbl[grepl(patt, tbl$ListName, ignore.case = TRUE), , drop = FALSE]
    }
    
    # Order by size desc
    tbl[order(-tbl$Size, tbl$ListName), , drop = FALSE]
  })
  
  # Chart: top N by size (horizontal bar)
 output$saved_lists_bar <- renderPlotly({
  tbl <- saved_lists_filtered()
  if (nrow(tbl) == 0) return(NULL)
  n <- max(1, min(input$saved_top_n %||% 30, nrow(tbl)))
  top_tbl <- head(tbl, n)
  top_tbl$ListName <- factor(top_tbl$ListName, levels = rev(top_tbl$ListName))

  p <- plot_ly(
    data = top_tbl,
    x = ~Size,
    y = ~ListName,
    type = "bar",
    orientation = "h",
    source = "saved_lists_bar",   # <<< add this
    hovertemplate = paste(
      "<b>%{y}</b><br>",
      "Size: %{x}<br>",
      "Source: %{customdata[1]}<br>",
      "Facets: %{customdata[2]}<extra></extra>"
    ),
    customdata = cbind(top_tbl$Source, ifelse(is.na(top_tbl$Facets), "", top_tbl$Facets))
  ) %>%
    layout(
      xaxis = list(title = "Number of Genes"),
      yaxis = list(title = ""),
      margin = list(l = 200)
    ) %>%
    event_register("plotly_click")   # <<< and this

  p
})

  
  # Table
  output$saved_lists_table <- renderDT({
    datatable(
      saved_lists_filtered()[, c("ListName","Source","Size","Facets","Reference","Notes")],
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE,
      selection = "single"
    )
  })
  
  # Keep selected list name (from table or chart click)
  selected_saved_list <- reactiveVal(NULL)
  
  # From table click
  observeEvent(input$saved_lists_table_rows_selected, {
    idx <- input$saved_lists_table_rows_selected
    if (length(idx) == 1) {
      nm <- saved_lists_filtered()$ListName[idx]
      selected_saved_list(nm)
    }
  })
  
  # From bar click (click on a bar selects that list)
  observeEvent(plotly::event_data("plotly_click", source = "saved_lists_bar"), {
    ed <- plotly::event_data("plotly_click", source = "saved_lists_bar")  # <<< match source
    if (!is.null(ed$y)) selected_saved_list(as.character(ed$y))
  }, ignoreInit = TRUE)
  
  # Preview + download
  output$single_list_preview <- renderDT({
    nm <- selected_saved_list()
    if (is.null(nm) || !nzchar(nm)) return(NULL)
    
    # Check if it's user or preloaded
    src <- saved_lists_all()$Source[match(nm, saved_lists_all()$ListName)]
    genes <- character(0)
    if (identical(src, "Preloaded")) {
      genes <- read_preloaded_genes(nm)
    } else if (identical(src, "User")) {
      df <- gene_lists_df()
      genes <- unique(toupper(trimws(df$Gene[df$ListName == nm])))
    }
    if (length(genes) == 0) return(NULL)
    
    datatable(
      data.frame(Gene = sort(genes), stringsAsFactors = FALSE),
      options = list(pageLength = 15, scrollX = TRUE),
      rownames = FALSE
    )
  })
  
  output$saved_list_meta <- renderUI({
    nm <- selected_saved_list()
    if (is.null(nm) || !nzchar(nm)) return(NULL)
    row <- saved_lists_all()[match(nm, saved_lists_all()$ListName), , drop = FALSE]
    tags$div(
      tags$p(HTML(paste0("<b>List:</b> ", nm))),
      tags$p(HTML(paste0("<b>Source:</b> ", row$Source))),
      tags$p(HTML(paste0("<b>Size:</b> ", row$Size))),
      if (!is.na(row$Facets)) tags$p(HTML(paste0("<b>Facets:</b> ", row$Facets))) else NULL,
      if (!is.na(row$Reference)) tags$p(HTML(paste0("<b>Reference:</b> ", row$Reference))) else NULL
    )
  })
  
  output$download_saved_list <- downloadHandler(
    filename = function() {
      nm <- selected_saved_list() %||% "saved_list"
      paste0(nm, "_", Sys.Date(), ".txt")
    },
    content = function(file) {
      nm <- selected_saved_list()
      if (is.null(nm) || !nzchar(nm)) {
        writeLines(character(0), file)
        return()
      }
      src <- saved_lists_all()$Source[match(nm, saved_lists_all()$ListName)]
      genes <- character(0)
      if (identical(src, "Preloaded")) {
        genes <- read_preloaded_genes(nm)
      } else if (identical(src, "User")) {
        df <- gene_lists_df()
        genes <- unique(toupper(trimws(df$Gene[df$ListName == nm])))
      }
      write.table(data.frame(Gene = sort(genes)),
                  file, row.names = FALSE, col.names = TRUE, quote = FALSE)
    }
  )
  
  # -----------------------------------------------------------
  # Tab: Gene search
  # -----------------------------------------------------------
  
  # Observe event for gene search
  # Step 2: render the appropriate input control
  
  disable("search_genes")  # start with the Search button disabled!
  
  output$gene_input_ui <- renderUI({
    # don’t even attempt switch() until the user has picked exactly one mode
    if (is.null(input$input_mode) || length(input$input_mode) != 1) {
      return(NULL)
    }
    
    switch(input$input_mode,
           manual = tagList(
             textAreaInput("manual_genes",
                           "Enter HUGO IDs (one per line)",
                           placeholder = "e.g. TP53\nBRCA1\nEGFR", rows = 5
             ),
             helpText("Blank lines are ignored.")
           ),
           
           file = fileInput("gene_file",
                            "Upload .txt (one per line) or .csv (one column of IDs)",
                            accept = c(".txt", ".csv")
           ),
           
           saved = selectizeInput(
             "select_saved",
             "Choose from saved lists",
             choices = unique(gene_lists_df()$ListName),
             multiple = TRUE,
             options = list(placeholder = "start typing…")
           )
    )
  })
  
  observe({
    valid <- FALSE
    if (input$input_mode == "manual" && nzchar(input$manual_genes  %||% "")) valid <- TRUE
    if (input$input_mode == "file"   && !is.null(input$gene_file))            valid <- TRUE
    if (input$input_mode == "saved"  && length(input$select_saved)  > 0)      valid <- TRUE
    toggleState("search_genes", valid)
  })
  
  # Step 3: consolidate & search when they click “Search”
  observeEvent(input$search_genes, {
    # build a unified vector of gene names
    gene_names <- switch(input$input_mode,
                         manual = {
                           lines <- strsplit(input$manual_genes %||% "", "[\r\n]+")[[1]]
                           toupper(trimws(lines))
                         },
                         file = {
                           req(input$gene_file)
                           ext <- tools::file_ext(input$gene_file$name)
                           if (ext == "txt") {
                             toupper(trimws(readLines(input$gene_file$datapath)))
                           } else {
                             df <- read.csv(input$gene_file$datapath, stringsAsFactors = FALSE, header = TRUE)
                             toupper(trimws(df[[1]]))
                           }
                         },
                         saved = {
                           req(input$select_saved)
                           df <- gene_lists_df()
                           # filter rows where ListName matches any selected
                           genes <- df$Gene[df$ListName %in% input$select_saved]
                           unique(genes)
                         }
    )
    
    # clean up, validate
    gene_names <- unique(Filter(nzchar, gene_names))
    if (length(gene_names) == 0) {
      showNotification("Please provide at least one gene symbol.", type = "error")
      return()
    }
    input_genes(gene_names)
    
    # your existing search function
    results <- search_genes(gene_names)
    
    search_results_rv(results)
    # render table
    # <<< MOD: enable multi-row selection in results table >>>
    output$gene_results <- renderDT({
      datatable(
        results[, c(
          "Gene_list_name","Facets","Number_of_Overlaps",
          "Overlapping_Genes","Hypergeometric_p_value","Adjusted_p_value",
          "Reference","Description"
        )],
        colnames = c(
          "Gene List","Facets","Matches",
          "Matching Genes","p-value","FDR (BH)",
          "Reference","Description"
        ),
        options = list(pageLength = 10, scrollX = TRUE),
        rownames = FALSE,
        selection = "multiple"    # <<< MOD
      )
    })
    
    
    # Render the download button UI
    output$download_results_ui <- renderUI({
      downloadButton("download_search_results", "Download Results", class = "btn-custom")
    })
  })
  
  # Download handler for the search results
  output$download_search_results <- downloadHandler(
    filename = function() {
      paste0("gene_search_results_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(search_results_rv(), file, row.names = FALSE)
    }
  )
  
  # Reset handler
  observeEvent(input$reset_search, {
    # 1) Clear the mode selection
    updateRadioButtons(session, "input_mode", selected = character(0))
    
    # 2) Clear each of the three input widgets
    updateTextAreaInput(session, "manual_genes", value = "")
    reset("gene_file")           # from shinyjs: clears the fileInput
    updateSelectizeInput(session, "select_saved", selected = NULL)
    updateCheckboxInput(session, "use_search_hits_matrix", value = FALSE)
    updateCheckboxInput(session, "use_search_hits_interactions", value = FALSE)
    updateSelectInput(session, "pval_column_matrix", selected = "Adjusted_p_value")
    updateSelectInput(session, "pval_column_interactions", selected = "Adjusted_p_value")
    updateNumericInput(session, "pval_threshold_matrix", value = 0.05)
    updateNumericInput(session, "pval_threshold_interactions", value = 0.05)
    # 3) Hide any existing results
    output$gene_results       <- renderDT(NULL)
    output$download_results_ui <- renderUI(NULL)
    
    # 4) Disable the Search button again
    disable("search_genes")
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
  
  # Observe event for resetting the gene search
  observeEvent(input$reset_search, {
    updateTextInput(session, "genes", value = "")
    
    updateSelectizeInput(session, "select_input_gene_list_search", selected = NULL)
    
    output$gene_results <- renderDT(NULL)
    output$download_results_ui <- renderUI(NULL)
    
    input_genes(NULL)
    uploaded_genes(NULL)
    
    output$input_gene_list_ui <- renderUI(NULL)
    
    showNotification("Gene search has been reset.", type = "message")
  })
  
  observe({
    if (isTRUE(input$use_search_hits_matrix)) {
      hits <- search_hit_list_names(search_results_rv(),
                                    input$pval_column_matrix %||% "Adjusted_p_value",
                                    input$pval_threshold_matrix %||% 0.05)
      # Merge with existing list names (from files) and pre-select hits for convenience
      merged <- sort(unique(c(gene_list_names, hits)))
      updateSelectizeInput(session, "selected_gene_lists_matrix",
                           choices = merged,
                           selected = hits)
    }
  })
  
  # push Search hits into Interactions choices 
  observe({
    if (isTRUE(input$use_search_hits_interactions)) {
      hits <- search_hit_list_names(search_results_rv(),
                                    input$pval_column_interactions %||% "Adjusted_p_value",
                                    input$pval_threshold_interactions %||% 0.05)
      merged <- sort(unique(c(gene_list_names, hits)))
      updateSelectizeInput(session, "gene_lists_for_interaction",
                           choices = merged,
                           selected = hits)
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
        p <- plot_similarity_matrix_facets(selected_facets)
        similarity_plot_rv(p)   # store for download
        p
      })
    } else {
      showNotification("Please select at least one facet for similarity matrix calculation.", type = "warning")
    }
  })
  
  # Observe event for calculating similarity matrix for gene lists
  observeEvent(input$calculate_similarity_matrix_genes, {
    selected_gene_lists <- input$selected_gene_lists_matrix
    selected_input_gene_lists <- input$input_gene_lists_for_matrix
    
    search_list_names <- character(0)
    if (isTRUE(input$use_search_hits_matrix)) {
      search_list_names <- search_hit_list_names(search_results_rv(),
                                                 input$pval_column_matrix %||% "Adjusted_p_value",
                                                 input$pval_threshold_matrix %||% 0.05)
      if (length(search_list_names) == 0) {
        showNotification("No Search hits under the chosen threshold for Similarity Matrix.", type = "warning")
      }
    }

    # Combine the predefined selections + Search hits
    combined_names <- unique(c(selected_gene_lists, search_list_names))
    
    # Load predefined gene lists from files
    gene_lists_data <- list()
    if (length(combined_names) > 0) {
      gene_lists_data <- c(gene_lists_data, gene_lists_from_names(combined_names))
    }
    
    # Include user-added gene lists in the analysis
    if (length(selected_input_gene_lists) > 0) {
      input_genes_list <- user_lists_as_list()[selected_input_gene_lists]      
      gene_lists_data <- c(gene_lists_data, input_genes_list)
    }
    
    if (length(gene_lists_data) > 0 && all(sapply(gene_lists_data, length) > 0)) {
      output$similarityMatrixHeatmap <- renderPlotly({
        p <- plot_similarity_matrix_gene_lists(gene_lists_data)
        similarity_plot_rv(p)   # store for download
        p
      })
    } else {
      showNotification("No valid gene lists found. Please check the input.", type = "warning")
    }
  })
  
  
# Observe event for resetting the plot for gene lists
  observeEvent(input$reset_plot_genes, {
    similarity_plot_rv(NULL);
    output$similarityMatrixHeatmap <- renderPlotly({
      plotly::plot_ly() # Renders an empty plot
    })
  })
  
  # Observe event for resetting the plot for facets
  observeEvent(input$reset_plot_facets, {
    similarity_plot_rv(NULL);
    output$similarityMatrixHeatmap <- renderPlotly({
      plotly::plot_ly() # Renders an empty plot
    })
  })
  
  # Observe event for resetting the plot for facet interactions
  observeEvent(input$reset_interaction_genes, {
    # 1) Clear plots to true “empty” states
    output$force_directed_graph <- renderVisNetwork({
      visNetwork(
        data.frame(id = integer(0), label = character(0)),
        data.frame(from = integer(0), to = integer(0), value = numeric(0))
      )
    })
    output$upsetjs_plot <- renderUpsetjs({
      upsetjs() %>% upsetjs::fromList(list()) %>% interactiveChart()
    })
    
    # 2) Clear clicked/intersection state and table
    clicked_set(NULL)
    clicked_genes(NULL)
    output$clicked_genes_table <- renderDT(NULL)
    
    # 3) Reset inputs depending on the active interaction mode
    if (identical(input$interaction_type, "genes")) {
      updateSelectizeInput(session, "tag_selector",                      selected = character(0))
      updateSelectizeInput(session, "gene_lists_for_interaction",        selected = character(0))
      updateSelectizeInput(session, "input_gene_lists_for_interaction",  selected = character(0))
      updateCheckboxInput(session, "use_search_hits_interactions",       value = FALSE)
      updateSelectInput(session,   "pval_column_interactions",           selected = "Adjusted_p_value")
      updateNumericInput(session,  "pval_threshold_interactions",        value = 0.05)
    } else if (identical(input$interaction_type, "facets")) {
      updateSelectizeInput(session, "clustering_selected_facets",        selected = character(0))
      updateSelectizeInput(session, "input_gene_lists_for_facets",       selected = character(0))
    }
    
    # 4) Optional: normalize the viz selector back to Graph (or your preferred default)
    updateRadioButtons(session, "visualization_type", selected = "Graph")
    
    showNotification("Facet Interactions have been reset.", type = "message")
  })
  
  
  # Observe changes in the available gene lists and update the selectize input choices for the similarity matrix tab accordingly
  observe({
    updateSelectizeInput(session, "input_gene_lists_for_matrix", choices = names(gene_lists()))
  })
  
  observe({
    ch <- sort(names(user_lists_as_list()))
    updateSelectizeInput(session, "input_gene_lists_for_matrix",      choices = ch)
    updateSelectizeInput(session, "input_gene_lists_for_facets",      choices = ch)
    updateSelectizeInput(session, "input_gene_lists_for_interaction", choices = ch)
  })
  
  # Download PNG for current similarity matrix
  output$download_similarity_png <- downloadHandler(
    filename = function() paste0("similarity_matrix_", Sys.Date(), ".png"),
    content = function(file) {
      p <- similarity_plot_rv()
      if (is.null(p)) {
        png(file); plot.new(); text(0.5, 0.5, "No similarity matrix available"); dev.off()
        return()
      }
      
      # ensure margins are applied even if p was created earlier
      p <- p %>% plotly::layout(margin = list(l = 320, r = 180, b = 220, t = 60),
                                xaxis  = list(automargin = TRUE),
                                yaxis  = list(automargin = TRUE))
      
      ok <- FALSE
      try({
        # bigger size + scale so labels are crisp and not clipped
        plotly::save_image(p, file, width = 2400, height = 2400, scale = 2)
        ok <- TRUE
      }, silent = TRUE)
      
      if (!ok) {
        tmp_html <- tempfile(fileext = ".html")
        htmlwidgets::saveWidget(plotly::as_widget(p), tmp_html, selfcontained = TRUE)
        # larger viewport and higher zoom; expand adds a few extra pixels of padding
        webshot2::webshot(tmp_html, file = file,
                          vwidth = 2600, vheight = 2600, zoom = 2, expand = 10)
      }
    }
  )

  # -----------------------
  # Tab: Facet Interactions
  # -----------------------
  
  # Observe event for calculating clustering based on selected facets
  observeEvent(input$calculate_clustering, {
    calculate_running(TRUE)
    
    selected_facets <- input$clustering_selected_facets %||% character(0)
    selected_input_gene_lists <- input$input_gene_lists_for_facets %||% character(0)
    
    # 1) Grab user lists (if any)
    input_lists_full <- user_lists_as_list()
    user_gene_lists <- if (length(selected_input_gene_lists) > 0) {
      input_lists_full[selected_input_gene_lists]
    } else list()
    
    # 2) From metadata/files: lists that match ANY of the selected facets
    #    Returns: $gene_lists (named by list), $map (List, PrimaryFacet)
    sel <- get_gene_lists_by_facets(selected_facets, local_folder, filtered_metadata)
    gl_meta <- sel$gene_lists                    # named list: ListName -> character genes
    map     <- sel$map                           # data.frame(List, PrimaryFacet)
    
    # 3) Bind user input lists; tag them with facet "Input"
    if (length(user_gene_lists) > 0) {
      # keep only non-empty
      user_gene_lists <- user_gene_lists[vapply(user_gene_lists, length, integer(1)) > 0]
      if (length(user_gene_lists) > 0) {
        gl_meta <- c(gl_meta, user_gene_lists)
        add_map <- data.frame(
          List = names(user_gene_lists),
          PrimaryFacet = rep("Input", length(user_gene_lists)),
          stringsAsFactors = FALSE
        )
        map <- rbind(map, add_map)
      }
    }
    
    # 4) If nothing to show
    if (length(gl_meta) == 0) {
      calculate_running(FALSE)
      showNotification("No gene lists found for the selected facets (and inputs).", type = "warning")
      # clear plots
      output$force_directed_graph <- renderVisNetwork({
        visNetwork(data.frame(id=integer(0), label=character(0)),
                   data.frame(from=integer(0), to=integer(0), value=numeric(0)))
      })
      output$upsetjs_plot <- renderUpsetjs({
        upsetjs() %>% upsetjs::fromList(list()) %>% interactiveChart()
      })
      return(invisible(NULL))
    }
    
    # 5) Ensure map matches lists actually present
    map <- map[match(names(gl_meta), map$List), , drop = FALSE]
    
    # 6) Build overlap matrix
    n <- length(gl_meta)
    overlap_matrix <- matrix(0L, nrow = n, ncol = n, dimnames = list(names(gl_meta), names(gl_meta)))
    for (i in seq_len(n)) {
      gi <- gl_meta[[i]]
      for (j in i:n) {
        gj <- gl_meta[[j]]
        val <- length(intersect(gi, gj))
        overlap_matrix[i, j] <- val
        overlap_matrix[j, i] <- val
      }
    }
    
    # 7) Build nodes/edges
    #    IDs are row indices (1..n); labels are list names; nodes carry facet in 'group'
    nodes <- data.frame(
      id    = seq_len(n),
      label = names(gl_meta),
      group = map$PrimaryFacet,
      stringsAsFactors = FALSE
    )
    
    # drop self-loops and zero edges
    idx <- which(overlap_matrix > 0, arr.ind = TRUE)
    idx <- idx[idx[,1] != idx[,2], , drop = FALSE]
    edges <- data.frame(
      from  = idx[,1],
      to    = idx[,2],
      value = overlap_matrix[idx],
      title = paste0("Overlapping genes: ", overlap_matrix[idx]),
      stringsAsFactors = FALSE
    )
    
    # Optional: de-duplicate undirected edges (keep i<j)
    edges <- edges[edges$from < edges$to, , drop = FALSE]
    
    # 8) Colors per facet (group)
    groups <- sort(unique(nodes$group[nzchar(nodes$group)]))
    pal    <- facet_palette(groups)
    # Hub / centrality metrics 
    g_undir <- igraph::graph_from_data_frame(
      d = edges[, c("from", "to", "value")],
      directed = FALSE,
      vertices = nodes
    )
    
    deg  <- igraph::degree(g_undir, mode = "all")
    strw <- igraph::strength(g_undir, mode = "all", weights = igraph::E(g_undir)$value)
    inv_w <- 1 / pmax(igraph::E(g_undir)$value, 1e-9)
    btw   <- igraph::betweenness(g_undir, directed = FALSE, weights = inv_w, normalized = TRUE)
    
    .scale01 <- function(x) if (length(unique(x)) == 1) rep(0.5, length(x)) else {
      (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
    }
    
    nodes$degree      <- as.numeric(deg)
    nodes$strength    <- as.numeric(strw)
    nodes$betweenness <- as.numeric(btw)
    nodes$size        <- 14 + 22 * .scale01(nodes$strength)
    
    nodes$title <- paste0(
      "<b>", nodes$label, "</b><br/>",
      "Facet: ", nodes$group, "<br/>",
      "Degree: ", nodes$degree, "<br/>",
      "Weighted degree: ", nodes$strength, "<br/>",
      "Betweenness: ", sprintf("%.3f", nodes$betweenness)
    )
    # 9) Render based on viz type
    if (identical(input$visualization_type, "Graph")) {
      output$upsetjs_plot <- renderUpsetjs(NULL)
      
      legend_nodes <- data.frame(
        label       = names(pal),
        shape       = "box",
        color       = unname(pal),
        borderWidth = 1,
        font.size   = 16,
        stringsAsFactors = FALSE
      )
      
      output$force_directed_graph <- renderVisNetwork({
        legend_nodes <- data.frame(
          label       = names(pal),
          shape       = "box",
          color       = unname(pal),
          borderWidth = 1,
          font.size   = 16,
          stringsAsFactors = FALSE
        )
        
        visNetwork(nodes, edges) %>%
          visEdges(smooth = FALSE, color = "lightblue", width = 2) %>%
          # your visGroups loop stays the same here...
          visNodes(
            shape = "dot",
            # no fixed size, use nodes$size instead
            font  = list(size = 18, background = "rgba(255,255,255,0.85)", color = "#000000")
          ) %>%
          visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
          visLegend(
            useGroups = FALSE,
            addNodes  = legend_nodes,
            width     = 0.2,
            position  = "right",
            ncol      = 1
          ) %>%
          visIgraphLayout()
      })
      
    } else {
      # UpSet: just sets by list (grouping is communicated by color in the graph view)
      output$force_directed_graph <- renderVisNetwork(NULL)
      output$upsetjs_plot <- renderUpsetjs({
        upsetjs() %>% upsetjs::fromList(gl_meta) %>% interactiveChart()
      })
    }
    
    calculate_running(FALSE)
  })
  
  # Observe event for calculating interaction analysis based on selected gene lists
  observeEvent(input$calculate_interaction_genes, {
    selected_gene_lists <- input$gene_lists_for_interaction
    selected_input_gene_lists <- input$input_gene_lists_for_interaction
    
    #  Search hits if requested 
    search_list_names <- character(0)
    if (isTRUE(input$use_search_hits_matrix)) {
      search_list_names <- search_hit_list_names(search_results_rv(),
                                                 input$pval_column_matrix %||% "Adjusted_p_value",
                                                 input$pval_threshold_matrix %||% 0.05)
      if (length(search_list_names) == 0) {
        showNotification("No Search hits under the chosen threshold for Similarity Matrix.", type = "warning")
      }
    }
    combined_names <- unique(c(selected_gene_lists, search_list_names))
    
    combined_gene_lists <- list()
    if (length(combined_names) > 0) {
      combined_gene_lists <- c(combined_gene_lists, gene_lists_from_names(combined_names))
    }
    
    # Include the user-added gene lists
    if (length(selected_input_gene_lists) > 0) {
      user_gene_lists <- user_lists_as_list()[selected_input_gene_lists]      
      combined_gene_lists <- c(combined_gene_lists, user_gene_lists)
    }
    
    if (length(combined_gene_lists) > 0) {
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
        to   = which(overlap_matrix > 0, arr.ind = TRUE)[, 2],
        value = overlap_matrix[overlap_matrix > 0],
        title = paste0("Overlapping genes: ", overlap_matrix[overlap_matrix > 0])
      )
      edges <- edges[edges$from != edges$to, ]
      nodes <- data.frame(id = 1:length(combined_gene_lists), label = names(combined_gene_lists))
      g_undir <- igraph::graph_from_data_frame(
        d = edges[, c("from", "to", "value")],
        directed = FALSE,
        vertices = nodes
      )
      
      deg  <- igraph::degree(g_undir, mode = "all")
      strw <- igraph::strength(g_undir, mode = "all", weights = igraph::E(g_undir)$value)
      
      # Betweenness with inverse weights so big overlaps = short distances
      inv_w <- 1 / pmax(igraph::E(g_undir)$value, 1e-9)
      btw   <- igraph::betweenness(g_undir, directed = FALSE, weights = inv_w, normalized = TRUE)
      
      .scale01 <- function(x) if (length(unique(x)) == 1) rep(0.5, length(x)) else {
        (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
      }
      
      nodes$degree      <- as.numeric(deg)
      nodes$strength    <- as.numeric(strw)   # weighted degree
      nodes$betweenness <- as.numeric(btw)
      nodes$size        <- 14 + 22 * .scale01(nodes$strength)
      
      # Tooltip with metrics
      nodes$title <- paste0(
        "<b>", nodes$label, "</b><br/>",
        "Degree: ", nodes$degree, "<br/>",
        "Weighted degree: ", nodes$strength, "<br/>",
        "Betweenness: ", sprintf("%.3f", nodes$betweenness)
      )
      if (input$visualization_type == "Graph") {
        output$force_directed_graph <- renderVisNetwork({
          visNetwork(nodes, edges) %>%
            visEdges(smooth = FALSE, color = "lightblue", width = 2) %>%
            visNodes(
              shape = "dot",
              # no fixed size -> uses nodes$size
              font = list(size = 18, background = "rgba(255, 255, 255, 0.8)", color = "#000000"),
              color = list(
                background = "lightcoral",
                border     = "darkcoral",
                highlight  = list(background = "lightyellow", border = "orange")
              )
            ) %>%
            visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
            visIgraphLayout()
        })
        output$upsetjs_plot <- renderUpsetjs(NULL)
      } else {
        output$upsetjs_plot <- renderUpsetjs({
          upsetjs() %>% upsetjs::fromList(combined_gene_lists) %>% interactiveChart()
        })
        output$force_directed_graph <- renderVisNetwork(NULL)
      }
    } else {
      showNotification("No gene lists available for the selected inputs.", type = "warning")
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
  
  # Update gene list choices for interaction analysis
  observe({
    updateSelectizeInput(session, "gene_lists_for_interaction", choices = gene_list_names)
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
