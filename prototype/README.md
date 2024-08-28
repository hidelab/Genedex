Multigenematch By running this Shiny app, you can interactively upload a file, search for gene names, and view the results in the web interface.

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

####

Genesearch
By running this Shiny app, you can interactively search for gene names in a specified directory and view the results in the web interface.
The provided Shiny app code allows users to enter a gene name and search for this gene name in files located within a specified directory. Here's what the app does and what the expected output is:

### UI Components

1. **Title Panel**: Displays the title "HUGO Gene Name Search".
2. **Sidebar Panel**:
   - `textInput`: Allows the user to enter a gene name.
   - `actionButton`: A button labeled "Search" to initiate the search process.
3. **Main Panel**:
   - `tableOutput`: A table output element to display the search results.

### Server Logic

1. **Directory Path**: The server function defines a directory path (`dir_path`) where the gene list files are stored.
2. **observeEvent(input$search_button)**:
   - When the search button is clicked, the `search_files` function is called with the entered gene name and directory path.
   - The function searches for the gene name in all text, CSV, and tab files within the directory.

3. **search_files Function**:
   - Retrieves a list of files in the specified directory with `.txt`, `.csv`, or `.tab` extensions.
   - Iterates over each file, reading its contents line by line.
   - Cleans each line by removing problematic characters.
   - Checks if the gene name (case insensitive) is present in any line.
   - If a match is found, the file path is formatted and added to the results.
   - If no matches are found, returns a message stating that the gene is not in Genedex.

4. **format_file_path Function**:
   - Formats the file path by removing the base path and file extension, then returns the relative path and file name.

### Expected Outputs

1. **If Matches are Found**:
   - The app will display a table with the following column:
     - `file_path`: The relative path of the file(s) where the gene name was found, formatted to remove the base path and file extension.

Example:

| file_path                          |
|------------------------------------|
| /GenedexGeneLists/KeyGeneSets/file1 |
| /GenedexGeneLists/KeyGeneSets/file2 |

2. **If No Matches are Found**:
   - The app will display a table with a single row stating "This gene is not in Genedex."

Example:

| file_path                          |
|------------------------------------|
| This gene is not in Genedex.       |

3. **If No Files are Found in the Directory**:
   - The app will display a table with a single row stating "No files found in the directory."

Example:

| file_path                          |
|------------------------------------|
| No files found in the directory.   |

4. **If an Error Occurs**:
   - If there's an error reading a file or processing the data, the app will include an error message in the console (not displayed in the table output).

### Example Usage Scenario

1. User enters "TP53" as the gene name.
2. User clicks the "Search" button.
3. The app searches through the specified directory for files containing the gene name "TP53".
4. If matches are found, the app displays a table with the relative file paths where the gene name was found.
5. If no matches are found, the app displays a message stating that the gene is not in Genedex.

By running this Shiny app, you can interactively search for gene names in a specified directory and view the results in the web interface.
