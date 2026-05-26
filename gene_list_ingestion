## Contributing workflow

All additions of new gene lists (Status = 1) must go through a branch and pull request. Direct pushes to `main` are only acceptable for minor corrections such as fixing a DOI or a typo in a metadata cell.

### Step 1 : Create a branch

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

### Step 2 : Do the curation

Follow Sections 4–8 as normal. Commit as you go : you do not need to wait until the end of the session to commit.

```bash
git add data/gene_lists/GL0000327_synaptic_loss_excitatory_neurons_down.txt
git add data/gene_lists/GL0000328_synaptic_loss_interneurons_down.txt
git add data/Gene_list_collection.xlsx data/CHANGELOG_data.md
git commit -m "data: add GL0000327-328 synaptic loss [v1.13]"
```

### Step 3 : Open a pull request

Push the branch and open a pull request against `main` on GitHub:

```bash
git push origin curation/GL0000327-328_synaptic-loss
```

In the PR description, include:
- The GL IDs being added
- The source paper (author, title, or DOI)
- Any non-obvious facet assignment decisions

### Step 4 : Review and merge

A senior lab member reviews the PR before it is merged. The review checks:

- GL number is consecutive to the previous entry
- Facet values match the vocabulary in `Facets_definition.xlsx`
- `Status = 1` is appropriate (eligibility criteria met)
- `CHANGELOG_data.md` entry is present and the version has been bumped
- `.txt` file opens correctly and has the `GENE_SYMBOL` header

Once approved, merge into `main` and delete the branch. Deploy the app if required (see Section 11).

---
## Versioning Gene_list_collection.xlsx

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
| Adding, renaming, or removing a column or a facet | MAJOR +1, PATCH resets to 0 |

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

Each entry needs: the version, date (YYYY-MM-DD), your name, and a one-line description per changed list. It does not need to be exhaustive prose, brief is better.

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
##  Commit checklist

Run through this before every `git push`.

- [ ] `.txt` file has `GENE_SYMBOL` as the first row header
- [ ] All gene symbols are uppercase and in current HGNC nomenclature
- [ ] Genome reference confirmed as GRCh38 (conversion noted in `Notes` if applicable)
- [ ] File saved in `data/gene_lists/`
- [ ] File name matches `Gene_list_name` in the metadata exactly (without `.txt`)
- [ ] `Link` column contains just the filename, not a full path
- [ ] GL number is consecutive : no gaps, no duplicates
- [ ] All 16 metadata columns filled (optional columns intentionally blank where appropriate)
- [ ] Facet values checked against `Facets_definition.xlsx` : exact match, no typos
- [ ] `Directionality` is `up`, `down`, or blank , nothing else
- [ ] `Status` is set to `1`
- [ ] Version number in `Key` sheet cell `A1` has been bumped
- [ ] Entry added to `CHANGELOG_data.md` with version, date, name, and description
- [ ] `Gene_list_collection.xlsx` and `CHANGELOG_data.md` staged in the same commit

---

## Editing a list

If a list needs to be corrected (e.g. wrong gene symbols, updated supplementary from authors):

- Edit the `.txt` file in place
- Update any affected metadata columns
- Bump the PATCH version and describe what was corrected in `CHANGELOG_data.md`

---
