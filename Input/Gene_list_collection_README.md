# Gene List Collection — Documentation

This document explains what `Gene_list_collection.xlsx` and the individual `GL*.txt` files are, how they relate to each other, and how to read them.

---

## 1. What this collection is

This is a curated library of **gene signatures ("gene lists")** extracted from published papers and preprints on Alzheimer's disease (AD), other neurodegenerative conditions (Parkinson's disease, Lewy body dementia), and related biology (innate immunity, aging). Each gene list represents a specific, well-defined comparison from a specific paper — for example, "genes upregulated in microglia in AD vs. control in the entorhinal cortex" — annotated with a controlled vocabulary of biological facets so that gene lists can be searched, filtered, and combined across papers (e.g., "give me all gene lists tagged Microglia + Alzheimer's disease + Hippocampus").

The collection consists of three linked pieces:

| File | Role |
|---|---|
| `Gene_list_collection.xlsx` | The master tracking/metadata spreadsheet — one row per gene list |
| `Facets_definition.xlsx` | The controlled vocabulary used to annotate each gene list |
| `GL*.txt` files | The actual gene lists — one plain-text file per gene list, containing the gene symbols |

---

## 2. `Gene_list_collection.xlsx`

### Sheet: `Key`
A data dictionary describing what each column in the `Gene lists` sheet means (reproduced in §2.2 below), plus the definition of the curation `Status` flag:
- **1 (curated)** — the paper has been read, a gene list identified, annotated with facets, and all columns filled in.
- **0 (not curated)** — entry exists but curation is incomplete.

### Sheet: `Gene lists`
The main table. 

#### 2.1 Row identity
- **Gene_list_name**: the unique ID, formatted `GL` + 7-digit number + a short descriptive name (e.g., `GL0000013_AD_CTR_Microglia_up`). This ID is also the filename stem of the corresponding `GL*.txt` file.

#### 2.2 Columns
| Column | Meaning |
|---|---|
| `Gene_list_name` | Unique ID (see above) |
| `Author` | First author of the source paper |
| `Contributor` | Person who added this entry to the collection |
| `Title` | Full title of the source paper |
| `DOI` | Digital Object Identifier of the source paper |
| `PMID` | PubMed ID of the source paper (blank for preprints not yet indexed) |
| `Functional facet` | One or more tags describing the biological process/condition (controlled vocabulary — see `Functional_facets` sheet in `Facets_definition.xlsx`) |
| `Cellular facet` | Cell type the gene list applies to (controlled vocabulary — `Cellular_facets` sheet) |
| `Tissue_type` | Brain region / tissue source (controlled vocabulary — `Tissue_type` sheet) |
| `Genetic facet` | Risk-increasing vs. protective, for genetic-variant gene lists (`Genetic_facets` sheet) |
| `Directionality` | `Up` or `Down` — direction of expression change |
| `Study type` | Assay used (single-nucleus RNA-seq, bulk RNA-seq, microarray, spatial transcriptomics, etc.) |
| `Location in the paper` | Table/Figure/Supplementary reference where the gene list came from |
| `Notes` | 1–2 sentence summary of how the list was generated, plus any curator caveats |
| `Status` | 1 = curated, 0 = not yet curated |

---

## 3. `Facets_definition.xlsx`

Defines the four controlled vocabularies referenced above, each on its own sheet:

- **Functional_facets** — biological processes/conditions, e.g. `Alzheimer's disease`, `Aβ Plaques`, `Tau propagation`, `Neuroinflammation`, `Cognitive resilience`.
- **Cellular_facets** — cell types and subtypes, from broad (`Neurons`, `Microglia`) to granular microglial/astrocyte activation states (`DAM stage 1`, `Homeostatic microglia`, `A1 astrocytes`).
- **Tissue_type** — anatomical sources, from whole `Brain` down to hippocampal subfields (`CA1 Region`, `Dentate Gyrus`) and non-brain matrices (`Blood`, `Plasma`, `CSF`, `Gut`, `Retina`).
- **Genetic_facets**  — `Risk increasing` / `Protective`, for rare/common-variant gene lists.

Every value entered in the `Functional facet`, `Cellular facet`, `Tissue_type`, and `Genetic facet` columns of `Gene_list_collection.xlsx` is meant to be drawn from these lists, so that the collection stays consistently searchable across papers.

---

## 4. The `GL*.txt` files

### Format
Every `GL*.txt` file is a simple single-column text file:
```
GENE_SYMBOL
APOBEC3G
BLNK
BTK
C3
...
```
- First line is always the header `GENE_SYMBOL`.
- Every subsequent line is one HGNC-style gene symbol.
- List length varies enormously by source — from few genes (a small, tightly filtered signature) up to several thousand (broad differential-expression outputs).
- A few files use Windows-style line endings (`\r\n`) rather than Unix (`\n`); this is cosmetic and doesn't affect parsing with standard tools (`pandas.read_csv`, `readlines()`, etc. all handle both).

### Naming and linkage
The filename stem of each `GL*.txt` file is the `Gene_list_name` value from `Gene_list_collection.xlsx` — e.g. `GL0000013_AD_CTR_Microglia_up.txt` is the literal gene list for the row `GL0000013_AD_CTR_Microglia_up` in the spreadsheet. That row's other columns (facets, tissue, directionality, source paper, notes) are the metadata *about* that file's contents.

---
