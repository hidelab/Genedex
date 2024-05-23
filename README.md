Multigenematch

The output of genesearch R Shiny app code is a web application that allows users to upload a file containing gene names (one per line), and then search for these gene names in a specified directory containing gene lists. Here is a step-by-step explanation of what the app does and what the expected outputs are:

### UI Components
1. **Title Panel**: Displays the title "HUGO Gene Name Search - File Upload".
2. **Sidebar Panel**:
   - `fileInput`: Allows the user to upload a file with gene names.
   - `actionButton`: A button labeled "Search" to initiate the search process.
3. **Main Panel**:
   - `tableOutput`: A table output element to display the search results.

### Server Logic
1. **Directory Path**: The server function defines a directory path where the gene list files are stored.
2. **observeEvent(input$search_button)**:
   - When the search button is clicked, the uploaded file is read, and the gene names are extracted.
   - The `search_files` function is called to search for the gene names in the specified directory.

3. **search_files Function**:
   - Retrieves a list of files in the specified directory with `.txt`, `.csv`, or `.tab` extensions.
   - Iterates over each file, reading its contents, and processes the files to find matches with the uploaded gene names.
   - If matches are found, it creates a data frame with the results.

4. **process_file Function**:
   - Takes the gene names from a file and the uploaded gene names, finds intersections (matches), and creates a data frame with the results.

### Expected Outputs
1. **If Matches are Found**:
   - The app will display a table with the following columns:
     - `actual_file_path`: The path to the file where matches were found.
     - `parent_directory`: The parent directory of the file.
     - `num_matched`: The number of matched genes.
     - `num_total`: The total number of genes in the file.
     - `matched_genes`: A comma-separated list of matched gene names.

2. **If No Matches are Found**:
   - The app will display a table with a single row stating "No matches found."

3. **If an Error Occurs**:
   - If there's an error reading a file or processing the data, the app will include an error message in the results table.

### Example of a Successful Output

If the search finds matches in a file, the output might look something like this:

| actual_file_path               | parent_directory  | num_matched | num_total | matched_genes        |
|--------------------------------|-------------------|-------------|-----------|----------------------|
| /path/to/matching_file.txt     | /parent/directory | 5           | 20        | gene1, gene2, gene3  |

### Example of a No Matches Output

If no matches are found in any files, the output might look like this:

| file_path            |
|----------------------|
| No matches found.    |

### Example of an Error Output

If there's an error processing a file, the output might include:

| actual_file_path              | error_message                | parent_directory | num_matched | num_total | matched_genes |
|-------------------------------|------------------------------|------------------|-------------|-----------|---------------|
| /path/to/file_with_error.txt  | Error reading file: [message] | NA               | NA          | NA        | NA            |

By running this Shiny app, you can interactively upload a file, search for gene names, and view the results in the web interface.
