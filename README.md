# Genedex 
## Overview

GeneDex is a Shiny application designed for genetic data exploration and visualization in the context of Alzheimer's Disease. It provides tools for managing gene lists, searching genes, calculating similarity matrices, analyzing facet interactions, performing pathway enrichment analysis, and conducting functional overlap analysis.

## Features

### Input Gene Lists:

- Add and visualize multiple gene lists for analysis.
  <img width="1470" alt="Screenshot 2024-08-29 at 9 53 27 PM" src="https://github.com/user-attachments/assets/78790a4c-111f-442f-90fe-541632097843">
 <img width="1470" alt="Screenshot 2024-08-30 at 1 39 47 PM" src="https://github.com/user-attachments/assets/41e6d2fd-ebf0-47e2-b1d9-08417bc2ca2a">


#### How to use Input Gene Lists
1) Navigate to the **"Input Gene Lists"** Tab:
    - Click on the **"Input Gene Lists"** option in the left sidebar menu.
2) Add a New Gene List:
    - Click the **"Add a Gene List"** button. This action will create a new entry form for a gene list.
    - In the **"Gene List Name"** field, enter a descriptive name for your gene list.
    - In the **"Gene List"** field, input the genes you wish to include, each on a new line.
3) Manage Gene Lists:
    - To remove a gene list, click the **"Remove Gene List"** button.
    - To add additional gene lists, click the **"+"** button to create more input fields.
4) Manage All Gene Lists:
    - Use the **"Clear All Gene Lists"** button to remove all gene lists you have added.
    - Click **"Save All Gene Lists"** to save the current gene lists for analysis.
    - Select **"Visualize Gene Lists"** to view a table containing the input gene list.

### Search:

- Gene search: Input a gene or a gene list to retrieve associated facets and related publications.
- Facet search: Select a facet from the drop-down menu to see the gene lists associated with that facet.

### How to use Search
<img width="1470" alt="Screenshot 2024-08-30 at 1 39 56 PM" src="https://github.com/user-attachments/assets/d674314c-f286-4e67-ba5e-606179e31f61">

 
#### How to use Gene Search

1) Enter Gene IDs:
   - In the **"Enter HUGO Gene IDs"** field, type one or more gene symbols separated by spaces. For example, you can enter ICAM1.
2) Upload a Gene List:
   - Alternatively, click the **"Browse…"** button to upload a text file containing HUGO Gene IDs. Ensure the file format is correct, with one gene per line or separated by spaces.
3) Select Input List:
   - Click the **"Use Input Gene List"** button to select from gene lists you have previously inputted or uploaded.
4) Search Genes:
   - After entering the gene IDs or uploading a file, click the **"Search Genes"** button to retrieve information about the genes.
5) Download Results:
   - Once the search is complete, click the **"Download Results"** button to download the results as a file for further analysis.
     
#### How to use Facet Search
1) Select a Facet:
   - Choose the facet of interest from the dropdown menu.
2) Search Facet:
   - After selecting a facet, click the **"Search Facet"** button to retrieve information about the selected facet.
  
### Similarity Matrix:

- Calculate and visualize a similarity matrix using the Jaccard index for selected facets or gene lists
- Display the similarity matrix as a heatmap.

### How to Use Similarity Matrix for Gene Lists:
  <img width="1470" alt="Screenshot 2024-08-29 at 9 54 07 PM" src="https://github.com/user-attachments/assets/9dd5d55c-30f0-4c94-9172-c4e5c78a9314">
  
1) Select Gene List:
   - **"Select Tags"** : Choose tags to filter gene lists containing the selected term.
   - **"Select Gene Lists"** : Choose a specific gene list by name from the dropdown menu.
   - **"Select Input Gene Lists"** : To add a gene list that you have previously inputted to the plot, select it from the dropdown menu.
2)  Generate plot:
    - Click **"Calculate"** to generate the similarity matrix.
    - Click **"Reset Plot"** to clear the current plot and start over.

 ### How to Use Similarity Matrix for Facets:
<img width="1470" alt="Screenshot 2024-08-29 at 9 54 17 PM" src="https://github.com/user-attachments/assets/db0e1ad7-3ccd-4f00-a22c-64b4c7f299c5">

1) **"Select Facets"**:
    - Use the dropdown menu to select the facets of interest or type them in manually.
    - Click **"Select All Facets"** to include all facets in the analysis.
    - Click **"Deselect All Facets"** to remove all selected facets from the analysis.
2) Generate plot:
    - Click **"Calculate"** to generate the similarity matrix.
    - Click **"Reset Plot"** to clear the current plot and start over.
    
### Facet Interactions:

- Visualize interactions between selected facets using a force-directed graph and an UpSet plot.
- Display overlapping genes between selected facets.

### How to Use Facet Interactions

#### Choose Analysis Type:
Select whether you want to perform the interaction analysis on Gene Lists or Facets.
1) Gene Lists: Analyze interactions based on the gene lists.
2) Facets: Analyze interactions based on the facets.

#### How to Use Facet Interaction for Gene Lists

<img width="1470" alt="Screenshot 2024-08-29 at 9 54 33 PM" src="https://github.com/user-attachments/assets/54ba05dc-7f92-445b-bc2c-8ec39fc89091">

1) Select Gene List:
   - **"Select Tags"** : Choose tags to filter gene lists containing the selected term.
   - **"Select Gene Lists"** : Choose a specific gene list by name from the dropdown menu.
   - **"Select Input Gene Lists"** : To add a gene list that you have previously inputted to the plot, select it from the dropdown menu.
2) Select your preferred visualization type:
  - Graph: Displays a network visualization of interactions.
  - Upset plot: Visualizes the intersections and overlaps between gene lists or facets. It allows you to visualize the genes in the overlapping sections by clicking on the bars and downloading the table.
3) Generate plot:
  - Click **"Calculate"** to generate the chosen visualization.
  - Click **"Reset Plot"** to remove the current visualization and start over.
  
  
#### How to Use Facet Interaction for Facets
 
<img width="1470" alt="Screenshot 2024-08-29 at 9 54 33 PM" src="https://github.com/user-attachments/assets/333e6c72-f3eb-4d32-a253-5cd5751ce38c">

1) **"Select Facets"**:
    - Use the dropdown menu to select the facets of interest or type them in manually.
    - Click **"Select All Facets"** to include all facets in the analysis.
    - Click **"Deselect All Facets"** to remove all selected facets from the analysis.
    - Click **"Select Input Gene Lists"** to add a gene list that you have previously inputted to the plot, select it from the dropdown menu.
2) Select your preferred visualization type:
  - Graph: Displays a network visualization of interactions.
  - Upset plot: Visualizes the intersections and overlaps between gene lists or facets. It allows you to visualize the genes in the overlapping sections by clicking on the bars and downloading the table.
3) Generate plot:
  - Click **"Calculate"** to generate the chosen visualization.
  - Click **"Reset Plot"** to remove the current visualization and start over.
  

## Requirements

R (version 4.0 or higher)

## Running the Application

Run the application:
```{r}
shiny::runApp()
```
### How to use Genedex ###
- External use: Access the version on Shiny.io at https://hidelab.shinyapps.io/genedex/
- Internal use: Use the code in the GitHub folder.
 - Download the code
 - Change the working directory in line 535 to the OneDrive folder [Genedex](https://bilh-my.sharepoint.com/:f:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex?csf=1&web=1&e=F0inEa)
```{r}
  #CHANGE IF YOUR FOLDER PATH IS DIFFERENT
  setwd("/Users/gpegoraro/Documents/Genedex/")
```
 - Update the path to the folders as follows:
```{r}
local_folder <- "Data/Genes_lists"
metadata_path <- "Data/Metadata/Gene_list_collection.xlsx"
```
## Curation
### How to upload a gene list
To upload a new gene list:
1) Go to OneDrive and navigate to the Genedex folder.
2) Open the [Gene_list_collection.xlsx](https://bilh-my.sharepoint.com/:x:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Metadata/Gene_list_collection.xlsx?d=wbae2449a15dc45cd97aa063210d18107&csf=1&web=1&e=FKkGf6.) file.
3) Add metadata about the gene list in the Gene_list_collection.xlsx file.
4) Add the gene list to the [Genedex/Data/Genes_lists/](https://bilh-my.sharepoint.com/:f:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Genes_lists?csf=1&web=1&e=O5YWqj) folder.    

#### Adding metadata in Gene_list_collection.xlsx
If you want to add a new gene list, fill in the following columns in the file. Refer to the "Key" sheet for a description of each column:
- **Gene_list_name**: Name of the gene list, composed of an alphanumeric ID starting with "GL" followed by a number, and a facet. Ensure the number is consecutive to the previous list. Specify facets in the "Facets" column. Example: ***GL0000001_AD_Immune_response***
- **Author**: Format as "FirstInitial LastName."
- **Contributor**: Name of the person who found the list.
- **Title**: Title of the paper where the list was found.
- **Link**: Link to the gene list's location on OneDrive. The list should be in the [Genes_lists](https://bilh-my.sharepoint.com/:f:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Genes_lists?csf=1&web=1&e=O5YWqj) folder.
- **DOI**: DOI of the paper. 
- **PMID**: PubMed ID of the paper. 
- **Facets**: List of one or more facets representing the gene list. Facet names should be selected from: [Facets_list.docx](https://bilh-my.sharepoint.com/:w:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Metadata/Facets/Facets_list.docx?d=wfc333940c322442e95037bd5a2601bf3&csf=1&web=1&e=bSH0Cx) <br />
- **Study type**: Type of study (e.g., bulk RNA-sequencing, single-cell RNA-sequencing).
- **Table or supplementary identifier in the paper**: Location of the gene list in the paper.
- **Notes**: Brief description of the gene list content (e.g., DEG in AD vs. controls from bulk tissue RNA-seq in PFC).
- **Status**: "Curated (1)" or "Not curated (0)." If status = 1, the gene list will not be analyzed in the Genedex app.
The curation of a gene list entails: 
 
  1) Read the paper and identify a gene list 
  2) Annotation of the gene list with one or more facets 
  3) Fill all the columns in the collective file

IMPORTANT: after you have modified the file copy it to the folder [Gene_lists_collections](https://bilh-my.sharepoint.com/:f:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Metadata/Gene_lists_collections?csf=1&web=1&e=OT4lJ5) adding the number of the version to the end of file name. You can find version number in [Log_gene_lists.xslx](https://bilh-my.sharepoint.com/:x:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Metadata/Log_gene_lists.xlsx?d=w97ac1bd7696249c8b30004b64f57b1b9&csf=1&web=1&e=XvrGzL), add +1 to the current version.

#### How to upload a gene list
To upload a gene list:
- Ensure the file is a .txt format, with each row containing a gene symbol.
- Include a header, GENE_SYMBOL, followed by gene names in HUGO nomenclature.
- Name the file according to the Gene_list_name used for its metadata.
Once these requirements are met, upload the gene lists in [Genes_lists](https://bilh-my.sharepoint.com/:f:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Genes_lists?csf=1&web=1&e=O5YWqj)

#### Resources for gene lists collection 
Tools used to search for gene lists:
- Rummagene: Enter keywords (e.g., "AD Neuroinflammation") to retrieve related publications and gene lists.
- PubMed: Input key terms to find associated publications.
- Gemma: Select the organism (Human) and disease (Alzheimer's Disease) to retrieve GEO studies with associated quality.
  
#### How to curate a gene list
- Identify genes with consistent expression changes under specific conditions (facets) such as AD or neurodegeneration, using studies like RNA-sequencing or scRNA-sequencing. For gene lists from studies like WGCNA that analyze modules of co-expressed genes, ensure the facet corresponds to the module.
- Samples must be human.
- For gene lists from differential expression studies, select genes with an adjusted p-value < 0.1.
- Ensure the genome reference is GRCh38. If the version is GRCh37, convert gene symbols to GRCh38.

#### When to deploy on Shiny.io 
Please deploy on Shiny.io if:
- The App.R code is modified.
- Changes are made to [Gene_list_collection.xlsx](https://bilh-my.sharepoint.com/:x:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Metadata/Gene_list_collection.xlsx?d=wbae2449a15dc45cd97aa063210d18107&csf=1&web=1&e=FKkGf6.)


#### How to deploy 
1) Copy the amended files in one folder
2) Ensure the folder contains:
   - app.R : code for the shiny app (comment line 535 to the OneDrive folder)
   - Genes_lists : folder containing the gene lists
   - Gene_list_collection.xlsx : file containing the gene lists metadata
4) Login to shinyapps.io
5) Go to **Account Settings** > **Tokens**
6) Click **"Show Secret"** and copy the provided token 
7) Then in R:
```{r}
setwd("path/to/app")
rsconnect::setAccountInfo(name='your_account_name')

token='your_token'
secret='your_secret'

rsconnect::deployApp()
```
## Versioning
1) MAJOR Version (1st number): Represents significant changes to the code, including:
 - Introduction of new functionalities
 - Significant updates that may not be backward compatible <br />
2) MINOR Version (2nd number): Indicates the addition of new features or enhancements to existing functionalities, such as:
 - Adding new features
 - Enhancing existing functionalities <br />
3) PATCH Version (3rd number): Represents bug fixes or minor improvements, including:
 - Fixing bugs in the code
 - Adding, removing, or modifying gene lists. Add your changes to the file [Log_gene_lists](https://bilh-my.sharepoint.com/:x:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Metadata/Log_gene_lists.xlsx?d=w97ac1bd7696249c8b30004b64f57b1b9&csf=1&web=1&e=TnA0S8) <br />

### Release notes

| Release | Description | Date |
| --- | --- | --- |
| Genedex v1.0.0 | The app contains 3 functionalities: Input Gene Lists, Search, Similarity Matrix and Facets Interactions | 08/29/2024 |










