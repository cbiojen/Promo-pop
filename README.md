# PromoPop Nextflow Pipeline (`promopop_nf`)

![PromoPop Logo](logo/logo.svg)

This pipeline identifies promoter-region variants for IBD genes, extracts genotype data, computes genotype counts and MAF, compares against imported European MAF, and generates summary plots.

## Workflow overview

The pipeline in [main.nf](main.nf) runs these modules in order:

1. `EXTRACT_PROMOTER_RECORDS`  
   Filter promoterAI database to your IBD gene list.
2. `COMPUTE_PROMOTER_POSITIONS`  
   Compute min/max promoter coordinates per gene.
3. `CREATE_PROMOTER_BED`  
   Build BED-format promoter regions.
4. `EXTRACT_BIM_PROMOTER_RECORDS`  
   Keep BIM variants that fall within promoter intervals.
5. `MERGE_PROMOTER_BIM_RECORDS`  
   Merge promoterAI records with BIM promoter variants.
6. `EXTRACT_SNP_LIST`  
   Build deduplicated SNP list from `variant_id`.
7. `EXPORT_GENOTYPE_WITH_PLINK`  
   Extract genotype dosage (`.raw`) via PLINK2.
8. `COUNT_GENOTYPES`  
   Compute `Hom_Ref`, `Het`, `Hom_Alt`, and `Ref_Allele`.
9. `MERGE_GENOTYPE_COUNTS`  
   Append genotype counts to merged promoter/BIM table.
10. `COMPUTE_MAF_FROM_COUNTS`  
    Compute cohort MAF from genotype counts.
11. `COMPARE_WITH_EUR_MAF`  
    Compare cohort MAF with imported European MAF file.
12. `PLOT_MAF_DISTRIBUTION`  
    Plot IBD MAF vs EUR MAF by promoterAI class.
13. `PLOT_PROMOTERAI_BY_CHROMOSOME`  
    Plot promoterAI score distribution across chromosomes.

## Inputs

Configured in [nextflow.config](nextflow.config):

- `params.genelist` — gene list file (one gene per line)
- `params.promoter_db` — promoterAI source table
- `params.plink_prefix` — PLINK dataset prefix (`.bed/.bim/.fam`)
- `params.european_maf_file` — imported EUR MAF table
- `params.bim_file` (optional) — explicit BIM path; defaults to `${plink_prefix}.bim`

Default input files are under [data](data).

## Requirements

- Nextflow (DSL2)
- Docker (recommended profile for PLINK step)
- R with `ggplot2` and `dplyr` available to the runtime environment for plot steps

## Run

From `promopop_nf`:

```bash
nextflow run main.nf -resume -profile docker
```

### First-time container setup for PLINK step

If not already built:

```bash
docker build --platform linux/amd64 -t promopop-plink2:latest -f containers/plink2/Dockerfile .
```

## Main outputs

Published to [results](results):

- `promoterAI_IBD_genes_all.tsv`
- `IBD_promoter_pos_all.tsv`
- `IBD_promoter_pos_all.bed`
- `bim_promoter_IBD_all.tsv`
- `merged_promoter_bim_all.tsv`
- `snp_promoter_IBD_all`
- `genotype_all.raw`
- `snp_list_with_genotype_counts.tsv`
- `merged_all_with_genocounts.tsv`
- `snp_maf_aa.tsv`
- `maf_aa_vs_eur.tsv`
- `maf_distribution.png` / `maf_distribution.pdf`
- `locus_zoom_promoterAI.png` / `locus_zoom_promoterAI.pdf`

## Troubleshooting

- **`pathspec ... did not match any files`**  
  Verify path exists relative to your current working directory.
- **PLINK file not found (`.fam` missing)**  
  Confirm `params.plink_prefix` points to files that exist in `data/`.
- **Empty EUR comparison columns (`MAF_EUR`)**  
  Ensure `params.european_maf_file` is correct and has CHROM/POS/ID + EUR MAF columns.
- **Plot step errors around R script parsing**  
  Re-run with `-resume` after pulling latest module fixes.

## Notes

- Runtime/cache artifacts are in `work/` and `.nextflow/`.
- Ignore large/generated files via [`.gitignore`](.gitignore).
