# Genedex curation guide

This guide is to add new gene lists to the Genedex database. Every list added becomes part of the gene lists collection. Read the eligibility criteria carefully before adding a list, and use the commit checklist before pushing.

---

## 1. What is a curated gene list?

A curated gene list is a set of HGNC gene symbols extracted from a published study, annotated with one or more Genedex facets, and stored in a standardised format. Once a list has `Status = 1` in `Gene_list_collection.xlsx`, it is fully curated.

Lists with `Status = 0` are placeholders. 

---

## 2. Inclusion and exclusion criteria

Work through these questions in order before starting curation. If a list fails any of them, do not set `Status = 1`.

### 2.1 Sample origin

**Include:** Lists derived from human brain samples.

**Exclude:**
- Non-human samples
- Mixed human/non-human datasets where human-specific results cannot be separated

If the paper uses a non-human model but validates findings in a human cohort, only include the gene list derived from the human validation.

### 2.2 Genome reference

**Include:** Gene symbols based on GRCh38 / hg38.

**Action required:** If the paper used GRCh37 / hg19, convert gene symbols to GRCh38 before adding. Use a tool such as the HGNC Multi-Symbol Checker (https://www.genenames.org/tools/multi-symbol-checker/) or biomaRt. Note the conversion in the `Notes` column.

---

## 3. Finding lists to curate

Three tools are recommended:

**PubMed** : Search using terms like `"Alzheimer's disease" AND "differential expression" AND "single-cell"`. Filter by publication date to find recent studies. Look for supplementary tables listing DEGs.

**Rummagene** (https://rummagene.com) : Enter keywords (e.g. `AD neuroinflammation`, `microglia resilience`) to retrieve published gene lists directly. Particularly useful for finding lists that were not the primary focus of a paper.

**Gemma** (https://gemma.msl.ubc.ca) : Select organism: Human, disease: Alzheimer's Disease. Returns GEO studies with pre-computed quality scores. Prioritise studies with higher quality ratings.

When you find a candidate list, log it in `Gene_list_collection.xlsx` with `Status = 0` immediately, even if you have not finished curation. This prevents two people curating the same list independently.

---

## 4. The gene list file

### Format

- Plain text, `.txt` extension
- Tab-delimited (a single column is fine)
- First row must be the header: `GENE_SYMBOL`
- One gene symbol per row
- All symbols in uppercase HGNC nomenclature
- No trailing spaces, no empty rows

### Example

```
GENE_SYMBOL
APOE
CLU
BIN1
TREM2
PICALM
```

### Gene symbol standards

- Use current approved HGNC symbols. Check at https://www.genenames.org if uncertain.
- Do not use Ensembl IDs, Entrez IDs, or aliases.
- Remove any symbols that cannot be mapped to a current HGNC-approved gene (these are typically pseudogenes, retired symbols, or non-human entries that slipped through).

### Where to save it

Place the file in `data/gene_lists/`.

---

## 5. Naming convention

The file name is also the `Gene_list_name` entry in the metadata file. The format is:

```
GL{7-digit-zero-padded-number}_{short_descriptor}.txt
```

**Rules:**
- `GL` prefix, always uppercase
- Seven-digit number, zero-padded (e.g. `GL0000320`, not `GL320`)
- Number must be consecutive to the last entry in `Gene_list_collection.xlsx` — check before assigning
- Descriptor: lowercase, words separated by underscores, no spaces, no special characters
- Directional lists (up/downregulated) end with `_up` or `_down`
- Keep descriptors concise but informative — aim for 3–6 words

**Examples:**

| Name | Meaning |
|---|---|
| `GL0000001_AD_Immune_response.txt` | AD vs control, immune response genes |
| `GL0000097_AD_CTR_Microglia_up.txt` | AD vs control, microglia, upregulated |
| `GL0000296_tau_load_astrocytes_up.txt` | Tau load correlation, astrocytes, upregulated |

**What not to do:**
- `GL320_microglia.txt` — number not zero-padded
- `GL0000320_Tau Load Astrocytes UP.txt` — spaces and mixed case
- `GL0000320.txt` — no descriptor

---

## 6. Metadata columns in Gene_list_collection.xlsx

Add one row per gene list. All columns are required unless marked optional.

| Column | What to enter | Format / example |
|---|---|---|
| `Gene_list_name` | File name without `.txt` | `GL0000320_tau_load_astrocytes_up` |
| `Author` | First author of the source paper | `J Smith` (FirstInitial LastName) |
| `Contributor` | Your name — who added this list | `G Pegoraro` |
| `Title` | Full title of the source paper | As published |
| `Link` | Filename of the `.txt` file | `GL0000320_tau_load_astrocytes_up.txt` |
| `DOI` | DOI of the paper | `DOI:10.1016/j.cell.2023.08.039` |
| `PMID` | PubMed ID of the paper | `37652020` |
| `Functional facet` | Biological process or condition | `AD, Cognitive resilience` — see Section 7 |
| `Cellular facet` | Brain cell type or state (optional) | `Astrocytes` — see Section 7; leave blank for bulk tissue |
| `Tissue_type` | Brain region the samples came from (optional) | `Prefrontal Cortex`, `Hippocampus` — see Section 7 |
| `Genetic facet` | Genetic context if applicable (optional) | `APOE4`, `TREM2 variant` — leave blank if not applicable |
| `Directionality` | Direction of expression change | `up`, `down`, or blank if not directional |
| `Study type` | Sequencing approach | `bulk RNA-seq`, `single-cell RNA-seq`, `WGCNA`, `Microarray` |
| `Location in the paper` | Where the list appears in the paper | `Supplementary Table 3`, `Table 2`, `Figure 4B` |
| `Notes` | One–two sentences describing how the list was generated | `Upregulated DEGs in AD astrocytes vs controls, PFC bulk RNA-seq` |
| `Status` | Curation status | `1` (curated) or `0` (not yet curated) |

**On `Status`:** Only set `Status = 1` once you have completed all steps in this guide including the commit checklist. If you are interrupted mid-curation, leave it as `0`.

**On `Link`:** Enter just the filename (e.g. `GL0000320_tau_load_astrocytes_up.txt`), not a full path. The app resolves paths relative to `data/gene_lists/`.

**On optional columns:** `Cellular facet`, `Tissue_type`, and `Genetic facet` may be left blank when genuinely not applicable — for example, a bulk tissue study with no regional specification has no `Tissue_type`, and most lists will have no `Genetic facet`. Do not fill these with guesses.

---

## 7. Assigning facets

Facets are the controlled vocabulary that allows Genedex to group and compare lists across studies. There are four facet columns, each drawing from its own sheet in `data/Facets_definition.xlsx`. Do not invent new facet names — if you believe a new facet is needed, open a GitHub issue for discussion before adding it.

### The four facet columns

**`Functional facet`** — the biological process or pathological condition that defines the list. This column is always required.  
Reference: `Functional_facets` sheet in `Facets_definition.xlsx`.  
Examples: `AD`, `Cognitive resilience`, `Neuroinflammation`, `Tau`, `Aβ`, `Synaptic loss`

**`Cellular facet`** — the brain cell type or state the list was derived from. Leave blank for bulk tissue unless a specific cell type was isolated or explicitly deconvolved by the authors.  
Reference: `Cellular_facets` sheet in `Facets_definition.xlsx`.  
Examples: `Astrocytes`, `Microglia`, `Excitatory neurons`, `Interneurons`, `Oligodendrocytes`, `OPCs`

**`Tissue_type`** — the brain region the samples came from.  
Reference: `Tissue_type` sheet in `Facets_definition.xlsx`.  
Examples: `Prefrontal Cortex`, `Hippocampus`, `Entorhinal Cortex`

**`Genetic facet`** — the genetic context, if the list is specific to a genotype or variant. Leave blank for the majority of lists.  
Reference: `Genetic_facets` sheet in `Facets_definition.xlsx`.  
Examples: `APOE4`, `TREM2 variant`

### Format in the spreadsheet

Multiple values within a single column are entered as a comma-separated list, using exact names from `Facets_definition.xlsx`:

```
Functional facet:  AD, Cognitive resilience
Cellular facet:    Astrocytes
Tissue_type:       Prefrontal Cortex
Genetic facet:     (blank)
```

The app tokenises on commas and matches against the facet vocabulary exactly — any typo or variation will cause the list to be excluded from that facet's results.

### Worked examples

**Example 1**  
Paper: Differential expression in AD vs control, bulk cortical tissue, PFC.  
Functional facet: `AD` | Cellular facet: *(blank)* | Tissue_type: `Prefrontal Cortex` | Genetic facet: *(blank)*  
Reason: Bulk tissue — no cell type can be assigned without explicit deconvolution.

**Example 2**  
Paper: scRNA-seq comparing AD vs control, astrocyte cluster, upregulated genes, PFC.  
Functional facet: `AD` | Cellular facet: `Astrocytes` | Tissue_type: `Prefrontal Cortex` | Genetic facet: *(blank)*

**Example 3**  
Paper: Correlation of gene expression with tau pathology score in excitatory neurons, hippocampus.  
Functional facet: `Tau` | Cellular facet: `Excitatory neurons` | Tissue_type: `Hippocampus` | Genetic facet: *(blank)*

**Example 4**  
Paper: Gene expression in cognitively resilient APOE4 carriers vs AD-pathology-matched controls.  
Functional facet: `Cognitive resilience` | Cellular facet: *(blank)* | Tissue_type: *(blank)* | Genetic facet: `APOE4`

**Example 5**  
Paper: Synaptic gene loss in excitatory neurons stratified by high vs low amyloid burden, entorhinal cortex.  
Functional facet: `Synaptic loss, Aβ` | Cellular facet: `Excitatory neurons` | Tissue_type: `Entorhinal Cortex` | Genetic facet: *(blank)*

### Edge cases

- If a study uses bulk tissue, leave `Cellular facet` blank unless the authors explicitly isolate or deconvolve a cell type.
- If a list comes from a WGCNA module, assign the facet that the authors used to name or annotate the module — not your own interpretation of the hub genes.
- If you are genuinely uncertain about any facet assignment, leave `Status = 0`, add a note in `Notes`, and ask a senior lab member before proceeding.

---

## 8. Versioning Gene_list_collection.xlsx

A manual versioning system makes the history readable without the overhead of exporting to CSV or maintaining duplicate files.

### Version numbering

The file follows two-number versioning: **MAJOR.PATCH**

- **MAJOR** — increment when the column structure changes (a column or facet is added, renamed, or removed). This is rare and requires updating `Facets_definition.xlsx`, and this guide simultaneously.
- **PATCH** — increment every time gene list rows are added, edited, or deprecated. This is the normal case after every curation session.

### Where the version is recorded

The current version is stored in cell `A1` of the `Key` sheet in the format:

```
Gene_list_collection v{MAJOR}.{PATCH}
```

Example: `Gene_list_collection v1.12`

Update this cell before saving and committing. Do not leave it stale.

### When to bump the version

| Action | Version change |
|---|---|
| Adding one or more new gene list rows | PATCH +1 |
| Editing any cell in an existing row (correcting a facet, fixing a DOI, etc.) | PATCH +1 |
| Adding, renaming, or removing a column | MAJOR +1, PATCH resets to 0 |

### CHANGELOG_data.md

Every commit that modifies `Gene_list_collection.xlsx` must include a corresponding entry in `data/CHANGELOG_data.md`. This file provides the human-readable summary that git diff cannot.

**File format:**

```markdown
# Gene_list_collection changelog

## v1.13 — 2025-06-10 — G Pegoraro
- Added GL0000327_synaptic_loss_excitatory_neurons_down
- Added GL0000328_synaptic_loss_interneurons_down

## v1.12 — 2025-05-22 — I Castanho
- Corrected Tissue_type for GL0000045 (was blank, now Entorhinal Cortex)

## v1.11 — 2025-04-15 — G Pegoraro
- Added GL0000320 through GL0000326 (tau load series, six cell types)
```

Each entry needs: the version, date (YYYY-MM-DD), your name, and a one-line description per changed list. It does not need to be exhaustive prose — brief is better.

### Commit message format for metadata changes

Include the version tag in the commit message so the state of the file is findable in `git log` without opening the changelog:

```
data: add GL0000327-328 synaptic loss [v1.13]
data: correct tissue type GL0000045 [v1.12]
data: deprecate GL0000088 retracted study [v1.12]
```

### Committing

Always commit `Gene_list_collection.xlsx` and `CHANGELOG_data.md` together in the same commit. Committing them separately means the changelog is out of sync with the file it describes.

---

## 9. Contributing workflow

All additions of new gene lists (Status = 1) must go through a branch and pull request. Direct pushes to `main` are only acceptable for minor corrections such as fixing a DOI or a typo in a metadata cell.

### Step 1 — Create a branch

Create a branch from an up-to-date `main`:

```bash
git checkout main
git pull
git checkout -b curation/GL{first}-{last}_{short-descriptor}
```

Use the GL ID range and a short descriptor so the branch list is self-documenting:

```bash
git checkout -b curation/GL0000327-328_synaptic-loss
git checkout -b curation/GL0000329_tau-load-vascular
```

One branch per curation session. If you are adding several lists from the same paper, they belong in the same branch.

### Step 2 — Do the curation

Follow Sections 4–8 as normal. Commit as you go — you do not need to wait until the end of the session to commit.

```bash
git add data/gene_lists/GL0000327_synaptic_loss_excitatory_neurons_down.txt
git add data/gene_lists/GL0000328_synaptic_loss_interneurons_down.txt
git add data/Gene_list_collection.xlsx data/CHANGELOG_data.md
git commit -m "data: add GL0000327-328 synaptic loss [v1.13]"
```

### Step 3 — Open a pull request

Push the branch and open a pull request against `main` on GitHub:

```bash
git push origin curation/GL0000327-328_synaptic-loss
```

In the PR description, include:
- The GL IDs being added
- The source paper (author, title, or DOI)
- Any non-obvious facet assignment decisions

### Step 4 — Review and merge

A senior lab member reviews the PR before it is merged. The review checks:

- GL number is consecutive to the previous entry
- Facet values match the vocabulary in `Facets_definition.xlsx`
- `Status = 1` is appropriate (eligibility criteria met)
- `CHANGELOG_data.md` entry is present and the version has been bumped
- `.txt` file opens correctly and has the `GENE_SYMBOL` header

Once approved, merge into `main` and delete the branch. Deploy the app if required (see Section 11).

---

## 10. Commit checklist

Run through this before every `git push`.

- [ ] `.txt` file has `GENE_SYMBOL` as the first row header
- [ ] All gene symbols are uppercase and in current HGNC nomenclature
- [ ] Genome reference confirmed as GRCh38 (conversion noted in `Notes` if applicable)
- [ ] File saved in `data/gene_lists/`
- [ ] File name matches `Gene_list_name` in the metadata exactly (without `.txt`)
- [ ] `Link` column contains just the filename, not a full path
- [ ] GL number is consecutive — no gaps, no duplicates
- [ ] All 16 metadata columns filled (optional columns intentionally blank where appropriate)
- [ ] Facet values checked against `Facets_definition.xlsx` — exact match, no typos
- [ ] `Directionality` is `up`, `down`, or blank — nothing else
- [ ] `Status` is set to `1`
- [ ] Version number in `Key` sheet cell `A1` has been bumped
- [ ] Entry added to `CHANGELOG_data.md` with version, date, name, and description
- [ ] `Gene_list_collection.xlsx` and `CHANGELOG_data.md` staged in the same commit

---

## 11. Editing a list

If a list needs to be corrected (e.g. wrong gene symbols, updated supplementary from authors):

- Edit the `.txt` file in place
- Update any affected metadata columns
- Bump the PATCH version and describe what was corrected in `CHANGELOG_data.md`

---

## 12. Deploying changes to the live app

After merging to `main`, the Shiny.io deployment must be updated manually if:
- `Gene_list_collection.xlsx` was modified
- Any `.txt` file in `data/gene_lists/` was added or changed
- `app.R` was modified

To deploy, follow the instructions in `README.md` under *Deployment*.
