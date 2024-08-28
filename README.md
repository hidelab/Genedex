# Genedex 1.0.0

## Overview

Genedex is a Shiny application designed for genetic data exploration and visualization in the context of Alzheimer's Disease. It provides tools for managing gene lists, searching genes, calculating similarity matrices, analyzing facet interactions, performing pathway enrichment analysis, and conducting functional overlap analysis.

## Features

### Input Gene Lists:

- Add and visualize multiple gene lists for analysis.

### Search:

- Gene search: Input a gene or a gene list to retrieve associated facets and related publications.
- Facet search: Select a facet from the drop-down menu to see the gene lists associated with that facet.

### Similarity Matrix:

- Calculate and visualize a similarity matrix using the Jaccard index for selected facets or gene lists
- Display the similarity matrix as a heatmap.

### Facet Interactions:

- Visualize interactions between selected facets using a force-directed graph and an UpSet plot.
- Display overlapping genes between selected facets.

## Requirements

R (version 4.0 or higher)

## Running the Application

Run the application:
```{r}
shiny::runApp()
```
## How to upload a gene list
To upload a new gene list:
1) Go to OneDrive and navigate to the Genedex folder.
2) Open the [Gene_list_collection.xlsx](https://bilh-my.sharepoint.com/:x:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Metadata/Gene_list_collection.xlsx?d=wbae2449a15dc45cd97aa063210d18107&csf=1&web=1&e=FKkGf6.) file.
3) Add metadata about the gene list in the Gene_list_collection.xlsx file.
4) Add the gene list to the [Genedex/Data/Genes_lists/](https://bilh-my.sharepoint.com/:f:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Genes_lists?csf=1&web=1&e=O5YWqj) folder.    

### Adding metadata in Gene_list_collection.xlsx
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

### How to upload a gene list
To upload a gene list:
- Ensure the file is a .txt format, with each row containing a gene symbol.
- Include a header, GENE_SYMBOL, followed by gene names in HUGO nomenclature.
- Name the file according to the Gene_list_name used for its metadata.
Once these requirements are met, upload the gene lists in [Genes_lists](https://bilh-my.sharepoint.com/:f:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Genes_lists?csf=1&web=1&e=O5YWqj)

### Resources for gene lists collection ###
Tools used to search for gene lists:
- Rummagene: Enter keywords (e.g., "AD Neuroinflammation") to retrieve related publications and gene lists.
- PubMed: Input key terms to find associated publications.
- Gemma: Select the organism (Human) and disease (Alzheimer's Disease) to retrieve GEO studies with associated quality.
  
### How to curate a gene list ###
- Identify genes with consistent expression changes under specific conditions (facets) such as AD or neurodegeneration, using studies like RNA-sequencing or scRNA-sequencing. For gene lists from studies like WGCNA that analyze modules of co-expressed genes, ensure the facet corresponds to the module.
- Samples must be human.
- For gene lists from differential expression studies, select genes with an adjusted p-value < 0.1.
- Ensure the genome reference is GRCh38. If the version is GRCh37, convert gene symbols to GRCh38.

### How to use Genedex ###
- External use: Access the version on Shiny.io.
- Internal use: Use the code in the GitHub folder. Ensure to update paths to the Genes_lists folder and the [Gene_list_collection.xlsx](https://bilh-my.sharepoint.com/:x:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Metadata/Gene_list_collection.xlsx?d=wbae2449a15dc45cd97aa063210d18107&csf=1&web=1&e=FKkGf6.) file.

### When to deploy on Shiny.io ###
Please deploy on Shiny.io if:
- The App.R code is modified.
- Changes are made to [Gene_list_collection.xlsx](https://bilh-my.sharepoint.com/:x:/r/personal/whide_bidmc_harvard_edu/Documents/Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Data/Metadata/Gene_list_collection.xlsx?d=wbae2449a15dc45cd97aa063210d18107&csf=1&web=1&e=FKkGf6.)

### How to deploy ###
1) Copy the amended files in one folder
2) Ensure the folder contains:
   - app.R : code for the shiny app
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













