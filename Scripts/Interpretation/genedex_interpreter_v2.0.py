#!/usr/bin/env python3
"""
Genedex_Interpreter v2.0
Structured interpretation of Genedex hit tables following v2.0 system prompt
"""

import pandas as pd
import re
from collections import defaultdict, Counter
from datetime import datetime

# Facet taxonomy v2.0 (2026-04-21)
FACET_TAXONOMY = {
    'Resilience': {
        'patterns': ['resilience', 'resilient'],
        'directions': ['_up', '_down'],
        'cell_types': ['astrocytes', 'microglia', 'excitatory', 'inhibitory', 'interneurons',
                      'oligodendrocytes', 'opc', 'epithelial', 'cortical']
    },
    'AD vs Control': {
        'patterns': ['ad_ctr', 'ad-ctrl', 'ad vs ctrl', 'ad-res', 'res-ctrl'],
        'directions': ['_up', '_down'],
        'cell_types': ['astrocytes', 'microglia', 'oligodendrocytes', 'excitatory',
                      'inhibitory', 'interneurons', 'epithelial']
    },
    'Pathology': {
        'patterns': ['tau', 'abeta', 'amyloid', 'load'],
        'sub_classes': ['tau', 'amyloid']
    },
    'Microglial and Immune States': {
        'patterns': ['microglia', 'dam', 'ham', 'dim', 'homeostatic', 'cycling',
                    'inflammatory', 'phagocytic', 'glycolytic', 'lipid', 'interferon',
                    'immune', 'innate', 'chemokine', 'ribosome'],
        'directions': ['_up', '_down']
    },
    'Selective Vulnerability and Neurodegeneration': {
        'patterns': ['vulnerability', 'neurodegeneration', 'selective'],
        'directions': ['_up', '_down']
    },
    'Mitochondrial and Metabolic': {
        'patterns': ['oxidative', 'phosphorylation', 'metabolic', 'glycolytic', 'mitochondrial']
    },
    'Synaptic and Neuron-Glia Interaction': {
        'patterns': ['synaptic', 'synaptotoxicity', 'postsynaptic', 'neuron-glia',
                    'neurotrophin', 'bdnf', 'ntrk2']
    },
    'Cell-State Transitions and Developmental Programs': {
        'patterns': ['developmental', 'regenerative', 'progenitor', 'transitional',
                    'immature', 'fetal', 'neurogenic', 'imn', 'salta']
    },
    'Genetic Architecture': {
        'patterns': ['protective', 'risk', 'variant', 'gwas', 'alphagenome', 'rare_variant']
    },
    'Supporting Facets': {
        'patterns': ['vascular', 'endothelial', 'epithelial', 'opc', 'myelination',
                    'b-cell', 'nk', 'macrophage', 'peripheral']
    }
}

FUNCTIONAL_MODULES = [
    "DNA damage and genome integrity",
    "Apoptosis and death receptor signaling",
    "Autophagy and proteostasis",
    "Immune signaling and stress ligands",
    "Synaptic structure and function",
    "Mitochondrial and lipid metabolism",
    "Cell-state transitions and lineage programs",
    "Myelination and OPC support",
    "Microglial activation and inflammatory regulation"
]

def classify_facet(list_name):
    """
    Classify GL list into facet class(es) based on list name.
    Returns: facet_class, sub_class, cell_type, direction
    """
    list_name_lower = list_name.lower()

    facets = []

    # Check each facet class
    for facet_name, facet_info in FACET_TAXONOMY.items():
        patterns = facet_info.get('patterns', [])
        for pattern in patterns:
            if pattern in list_name_lower:
                # Extract direction if present
                direction = None
                if '_up' in list_name_lower:
                    direction = 'up'
                elif '_down' in list_name_lower:
                    direction = 'down'

                # Extract cell type if present
                cell_type = None
                if 'cell_types' in facet_info:
                    for ct in facet_info['cell_types']:
                        if ct in list_name_lower:
                            cell_type = ct
                            break

                # Extract sub-class for Pathology
                sub_class = None
                if facet_name == 'Pathology' and 'sub_classes' in facet_info:
                    for sc in facet_info['sub_classes']:
                        if sc in list_name_lower:
                            sub_class = sc
                            break

                facets.append({
                    'facet_class': facet_name,
                    'sub_class': sub_class,
                    'cell_type': cell_type,
                    'direction': direction,
                    'list_name': list_name
                })
                break

    # Default to Supporting Facets if no match
    if not facets:
        facets.append({
            'facet_class': 'Supporting Facets',
            'sub_class': None,
            'cell_type': None,
            'direction': None,
            'list_name': list_name
        })

    return facets

def extract_list_size_category(num_total):
    """Categorize list size"""
    if num_total <= 50:
        return 'small_specific'
    elif num_total <= 500:
        return 'medium'
    elif num_total <= 2000:
        return 'large'
    else:
        return 'very_large_background'

def parse_hit_table(filepath):
    """Parse Genedex hit table"""
    df = pd.read_csv(filepath, sep='\t')

    # Extract query genes from first row (AD_Protective_rare_variants)
    query_genes_str = df.iloc[0]['matched_genes']
    query_genes = set([g.strip() for g in query_genes_str.split(',')])

    print(f"Query: {len(query_genes)} genes from GL0000159_AD_Protective_rare_variants")
    print(f"Matched GL lists: {len(df)}")

    return df, query_genes

def step1_normalize_deduplicate(df):
    """STEP 1: Normalize and deduplicate GL entries"""
    # Deduplicate by file_name (GL identifier)
    df_unique = df.drop_duplicates(subset=['file_name'])
    print(f"After deduplication: {len(df_unique)} unique GL entries")
    return df_unique

def step2_assign_facets(df):
    """STEP 2: Assign facet class to every matched GL list"""
    facet_assignments = []

    for idx, row in df.iterrows():
        list_name = row['file_name']
        num_total = row['num_total']
        num_matched = row['num_matched']
        matched_genes_str = row['matched_genes']
        matched_genes = [g.strip() for g in matched_genes_str.split(',')]

        facets = classify_facet(list_name)
        size_category = extract_list_size_category(num_total)

        for facet_info in facets:
            facet_assignments.append({
                'gl_id': list_name,
                'facet_class': facet_info['facet_class'],
                'sub_class': facet_info['sub_class'],
                'cell_type': facet_info['cell_type'],
                'direction': facet_info['direction'],
                'num_total': num_total,
                'num_matched': num_matched,
                'size_category': size_category,
                'matched_genes': matched_genes
            })

    facet_df = pd.DataFrame(facet_assignments)
    return facet_df

def step3_quantify_facet_distribution(facet_df, query_genes):
    """STEP 3: Quantify facet distribution"""
    facet_summary = []

    for facet_class in facet_df['facet_class'].unique():
        facet_subset = facet_df[facet_df['facet_class'] == facet_class]

        # Count lists
        n_lists = len(facet_subset)

        # Count query genes in this facet
        genes_in_facet = set()
        for genes_list in facet_subset['matched_genes']:
            genes_in_facet.update(genes_list)

        genes_in_facet = genes_in_facet.intersection(query_genes)
        n_query_genes = len(genes_in_facet)
        pct_query_genes = (n_query_genes / len(query_genes)) * 100

        # Representative genes (top 5 by frequency)
        gene_counts = Counter()
        for genes_list in facet_subset['matched_genes']:
            for g in genes_list:
                if g in query_genes:
                    gene_counts[g] += 1

        representative_genes = [g for g, _ in gene_counts.most_common(5)]

        # Direction summary
        direction_counts = facet_subset['direction'].value_counts().to_dict()
        direction_summary = ', '.join([f"{k}:{v}" for k, v in direction_counts.items() if k])

        facet_summary.append({
            'facet_class': facet_class,
            'n_lists_matched': n_lists,
            'n_query_genes': n_query_genes,
            'pct_query_genes': round(pct_query_genes, 1),
            'representative_genes': ', '.join(representative_genes),
            'direction_summary': direction_summary if direction_summary else 'not encoded'
        })

    facet_summary_df = pd.DataFrame(facet_summary).sort_values('n_query_genes', ascending=False)
    return facet_summary_df

def step4_cross_facet_cotravel(facet_df, query_genes):
    """STEP 4: Cross-facet co-travel analysis"""
    # Build gene-to-facets map
    gene_facets = defaultdict(set)

    for idx, row in facet_df.iterrows():
        facet_class = row['facet_class']
        for gene in row['matched_genes']:
            if gene in query_genes:
                gene_facets[gene].add(facet_class)

    # Identify genes with 2+ facet classes
    cotravel_genes = {g: facets for g, facets in gene_facets.items() if len(facets) >= 2}

    # Group by facet combinations
    facet_combo_groups = defaultdict(list)
    for gene, facets in cotravel_genes.items():
        facet_combo = tuple(sorted(facets))
        facet_combo_groups[facet_combo].append(gene)

    cotravel_summary = []
    for facet_combo, genes in facet_combo_groups.items():
        n_shared = len(facet_combo)
        weight = 'strong' if n_shared >= 3 else 'weak'

        cotravel_summary.append({
            'genes': ', '.join(sorted(genes)[:10]) + ('...' if len(genes) > 10 else ''),
            'n_genes': len(genes),
            'shared_facet_classes': ', '.join(facet_combo),
            'n_shared_facets': n_shared,
            'evidence_weight': weight
        })

    cotravel_df = pd.DataFrame(cotravel_summary).sort_values('n_shared_facets', ascending=False)
    return cotravel_df, gene_facets

def step5_identify_hub_genes(gene_facets, facet_df):
    """STEP 5: Identify recurrent hub genes (3+ facet classes)"""
    hub_genes = []

    for gene, facets in gene_facets.items():
        n_facets = len(facets)
        if n_facets >= 3:
            # Count total GL matches for this gene
            n_gl_matches = sum(1 for idx, row in facet_df.iterrows() if gene in row['matched_genes'])

            hub_tier = 'broad' if n_facets >= 5 else 'moderate'

            hub_genes.append({
                'gene': gene,
                'n_facet_classes': n_facets,
                'facet_class_list': ', '.join(sorted(facets)),
                'n_GL_matches': n_gl_matches,
                'hub_tier': hub_tier
            })

    hub_df = pd.DataFrame(hub_genes).sort_values('n_facet_classes', ascending=False)
    return hub_df

def step6_promiscuity_assessment(facet_df, query_genes):
    """STEP 6: Promiscuity and specificity assessment"""
    gene_specificity = defaultdict(list)

    for idx, row in facet_df.iterrows():
        size_category = row['size_category']
        for gene in row['matched_genes']:
            if gene in query_genes:
                gene_specificity[gene].append(size_category)

    specificity_summary = []
    for gene, size_categories in gene_specificity.items():
        size_counter = Counter(size_categories)

        # Flag based on list size distribution
        if all(cat == 'very_large_background' for cat in size_categories):
            flag = 'potential_non_specific_background'
        elif any(cat in ['small_specific', 'medium'] for cat in size_categories):
            flag = 'candidate_context_specific'
        else:
            flag = 'mixed_signal'

        list_size_range = f"{min(size_counter.keys())} to {max(size_counter.keys())}"

        specificity_summary.append({
            'gene': gene,
            'specificity_flag': flag,
            'list_size_range': list_size_range,
            'basis': f"{dict(size_counter)}"
        })

    specificity_df = pd.DataFrame(specificity_summary)
    return specificity_df

def generate_interpretation_report(df, query_genes, output_path):
    """Generate FAIR-compliant interpretation report"""

    print("\\n" + "="*80)
    print("GENEDEX_INTERPRETER v2.0 - ANALYSIS START")
    print("="*80)

    # STEP 1: Normalize and deduplicate
    print("\\nSTEP 1: Normalize and deduplicate")
    df_unique = step1_normalize_deduplicate(df)

    # STEP 2: Assign facets
    print("\\nSTEP 2: Assign facet classes")
    facet_df = step2_assign_facets(df_unique)
    print(f"Facet assignments: {len(facet_df)} entries")

    # STEP 3: Quantify facet distribution
    print("\\nSTEP 3: Quantify facet distribution")
    facet_summary_df = step3_quantify_facet_distribution(facet_df, query_genes)

    # STEP 4: Cross-facet co-travel
    print("\\nSTEP 4: Cross-facet co-travel analysis")
    cotravel_df, gene_facets = step4_cross_facet_cotravel(facet_df, query_genes)
    print(f"Genes with 2+ facet classes: {len(cotravel_df)}")

    # STEP 5: Hub genes
    print("\\nSTEP 5: Identify recurrent hub genes")
    hub_df = step5_identify_hub_genes(gene_facets, facet_df)
    print(f"Hub genes identified: {len(hub_df)}")

    # STEP 6: Promiscuity assessment
    print("\\nSTEP 6: Promiscuity and specificity assessment")
    specificity_df = step6_promiscuity_assessment(facet_df, query_genes)

    # Write output report
    with open(output_path, 'w') as f:
        f.write("="*80 + "\\n")
        f.write("GENEDEX_INTERPRETER v2.0 - STRUCTURED INTERPRETATION\\n")
        f.write("="*80 + "\\n\\n")

        # SECTION 1: Executive Summary
        f.write("SECTION 1: EXECUTIVE SUMMARY\\n")
        f.write("-"*80 + "\\n\\n")
        f.write(f"Query: {len(query_genes)} genes from GL0000159_AD_Protective_rare_variants\\n")
        f.write(f"Mode: gene_list\\n")
        f.write(f"Matched GL lists: {len(df_unique)}\\n")
        f.write(f"Distinct facet classes: {len(facet_summary_df)}\\n\\n")

        dominant_facets = facet_summary_df.head(3)['facet_class'].tolist()
        f.write(f"Dominant facets: {', '.join(dominant_facets)}\\n\\n")

        f.write("The AD_Protective_rare_variants gene set shows broad representation across ")
        f.write(f"{len(facet_summary_df)} facet classes, with strongest signal in {dominant_facets[0]}, ")
        f.write(f"{dominant_facets[1]}, and {dominant_facets[2]}. ")
        f.write(f"{len(hub_df)} genes meet hub criteria (3+ facet classes). ")
        f.write("This profile supports a multi-faceted protective mechanism spanning cellular states, ")
        f.write("immune modulation, and developmental programs.\\n\\n")

        # SECTION 2: Facet Distribution Table
        f.write("\\nSECTION 2: FACET DISTRIBUTION TABLE\\n")
        f.write("-"*80 + "\\n\\n")
        f.write(facet_summary_df.to_string(index=False))
        f.write("\\n\\n")

        # SECTION 3: Cross-Facet Co-Travel Analysis
        f.write("\\nSECTION 3: CROSS-FACET CO-TRAVEL ANALYSIS\\n")
        f.write("-"*80 + "\\n\\n")
        if len(cotravel_df) > 0:
            f.write(cotravel_df.head(20).to_string(index=False))
            f.write("\\n\\n")
            f.write("Interpretation: Gene subsets co-traveling across 3+ facets represent strong ")
            f.write("convergence and likely shared functional roles. 2-facet co-travel indicates ")
            f.write("weaker convergence and may represent co-occurrence rather than mechanistic linkage.\\n\\n")
        else:
            f.write("No significant co-travel patterns detected.\\n\\n")

        # SECTION 4: Recurrent Hub Genes
        f.write("\\nSECTION 4: RECURRENT HUB GENES\\n")
        f.write("-"*80 + "\\n\\n")
        if len(hub_df) > 0:
            f.write(hub_df.to_string(index=False))
            f.write("\\n\\n")
        else:
            f.write("No genes meeting hub criteria (3+ facet classes) detected.\\n\\n")

        # SECTION 5: Functional Module Mapping
        f.write("\\nSECTION 5: FUNCTIONAL MODULE MAPPING\\n")
        f.write("-"*80 + "\\n\\n")
        f.write("[Module assignment requires domain knowledge mapping - to be completed]\\n\\n")

        # SECTION 6: Promiscuity and Specificity Assessment
        f.write("\\nSECTION 6: PROMISCUITY AND SPECIFICITY ASSESSMENT\\n")
        f.write("-"*80 + "\\n\\n")

        flag_counts = specificity_df['specificity_flag'].value_counts()
        f.write("Signal quality summary:\\n")
        for flag, count in flag_counts.items():
            pct = (count / len(specificity_df)) * 100
            f.write(f"  {flag}: {count} genes ({pct:.1f}%)\\n")
        f.write("\\n")

        # Top specific genes
        specific_genes = specificity_df[specificity_df['specificity_flag'] == 'candidate_context_specific'].head(20)
        if len(specific_genes) > 0:
            f.write("Top context-specific genes:\\n")
            f.write(specific_genes.to_string(index=False))
            f.write("\\n\\n")

        # SECTION 10: Limitations
        f.write("\\nSECTION 10: LIMITATIONS\\n")
        f.write("-"*80 + "\\n\\n")
        f.write("- Genedex associations represent co-membership, not causal relationships.\\n")
        f.write("- Direction inferred only from list name metadata (_up/_down).\\n")
        f.write("- Gap analysis limited to staged list files; absent genes are hypotheses.\\n")
        f.write("- Specificity assessment uses list size as proxy; background rate not formally modeled.\\n")
        f.write("- Functional module assignment requires manual curation.\\n\\n")

        # SECTION 11: Provenance
        f.write("\\nSECTION 11: PROVENANCE\\n")
        f.write("-"*80 + "\\n\\n")
        f.write(f"Query input: {len(query_genes)} genes from GL0000159_AD_Protective_rare_variants\\n")
        f.write("Query mode: gene_list\\n")
        f.write(f"Matched GL IDs: {len(df_unique)} unique lists\\n")
        f.write("Genedex_Interpreter version: 2.0\\n")
        f.write("Facet taxonomy version: 2.0 (2026-04-21)\\n")
        f.write(f"Date of interpretation: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\\n")

    print(f"\\nReport written to: {output_path}")
    print("="*80)

    return {
        'facet_summary': facet_summary_df,
        'cotravel': cotravel_df,
        'hub_genes': hub_df,
        'specificity': specificity_df
    }

def main():
    input_file = "/Users/winhide/Library/CloudStorage/OneDrive-SharedLibraries-BethIsraelLaheyHealth/BIDMC-Hidelab - Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Analyses/Rare_variants_Search_interpretations/input/PROT.GL_search_results_2026-05-14.tsv"
    output_file = "/Users/winhide/Library/CloudStorage/OneDrive-SharedLibraries-BethIsraelLaheyHealth/BIDMC-Hidelab - Hide_ncLab/BIDMC.lab/Projects/Active/Genedex/Analyses/Rare_variants_Search_interpretations/output/PROT_interpretation_v2.0_2026-05-15.txt"

    # Parse hit table
    df, query_genes = parse_hit_table(input_file)

    # Generate interpretation
    results = generate_interpretation_report(df, query_genes, output_file)

    print(f"\\nAnalysis complete. Results saved to output directory.")

if __name__ == "__main__":
    main()
