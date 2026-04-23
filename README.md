<<<<<<< HEAD
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
=======
# PromoPop Nextflow Pipeline

![PromoPop Logo](logo/logo.svg)

PromoPop identifies promoter-region variants for IBD genes, extracts genotype dosage, computes genotype counts and MAF, compares against European MAF, and generates publication-ready plots.

## Why This Setup Is Reproducible

This repository now uses a hybrid runtime model that is stable across macOS and Linux:

- Python and R tasks run in a pinned Conda environment defined in [envs/runtime.yml](envs/runtime.yml).
- PLINK2 runs in a Docker image defined in [containers/plink2/Dockerfile](containers/plink2/Dockerfile).
- Nextflow version is pinned at launch using `NXF_VER`.

## Workflow Summary

The pipeline in [main.nf](main.nf) executes these modules:

1. `EXTRACT_PROMOTER_RECORDS`
2. `COMPUTE_PROMOTER_POSITIONS`
3. `CREATE_PROMOTER_BED`
4. `EXTRACT_BIM_PROMOTER_RECORDS`
5. `MERGE_PROMOTER_BIM_RECORDS`
6. `EXTRACT_SNP_LIST`
7. `EXPORT_GENOTYPE_WITH_PLINK`
8. `COUNT_GENOTYPES`
9. `MERGE_GENOTYPE_COUNTS`
10. `COMPUTE_MAF_FROM_COUNTS`
11. `COMPARE_WITH_EUR_MAF`
12. `PLOT_MAF_DISTRIBUTION`
13. `PLOT_PROMOTERAI_BY_CHROMOSOME`

## Prerequisites

- Conda (Miniconda or Anaconda)
- Docker Desktop (or Docker Engine)
- Bash shell

## Quick Start

### 1. Create a launcher environment with Nextflow

```bash
source ~/.bash_profile
conda create -y -n nextflow-env -c conda-forge -c bioconda nextflow=25.10.4
conda activate nextflow-env
nextflow -version
```

### 2. Build the PLINK2 image (first time only)

```bash
cd /path/to/Promo-pop-main
docker build --platform linux/amd64 -t promopop-plink2:latest -f containers/plink2/Dockerfile .
```

### 3. Run the pipeline

```bash
cd /path/to/Promo-pop-main
source ~/.bash_profile
conda activate nextflow-env
NXF_VER=25.10.4 nextflow run main.nf -resume -profile docker
```

## Inputs

Defaults are configured in [nextflow.config](nextflow.config):

- `params.genelist`: one gene symbol per line
- `params.promoter_db`: promoterAI input table
- `params.plink_prefix`: PLINK prefix (`.bed`, `.bim`, `.fam`)
- `params.european_maf_file`: European MAF table
- `params.bim_file`: optional explicit BIM path (defaults to `${params.plink_prefix}.bim`)

Default sample inputs are in [data](data).

### Override parameters at runtime

```bash
NXF_VER=25.10.4 nextflow run main.nf -profile docker -resume \
   --genelist data/small_IBD_GWAS_genelist.txt \
   --promoter_db data/small_promoterAI_tss500.tsv \
   --plink_prefix data/small_big_daly_v3 \
   --european_maf_file data/final_MAF_counts.txt
```

### Run with secure external data (recommended)

Keep private datasets outside the repo and pass their paths via a local params file:

1. Copy [params.example.json](params.example.json) to `params.local.json`.
2. Edit `params.local.json` with absolute paths in your secure storage location.
3. Run:

```bash
NXF_VER=25.10.4 nextflow run main.nf -profile docker -resume -params-file params.local.json
```

`params.local.json` is ignored by git so data paths stay local.

## Main Outputs
>>>>>>> chore/reproducible-pipeline-setup

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
<<<<<<< HEAD
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
=======
- `maf_distribution.png`, `maf_distribution.pdf`
- `locus_zoom_promoterAI.png`, `locus_zoom_promoterAI.pdf`

## Reproducibility Checklist

Before sharing results, confirm all of the following:

1. You ran from a committed Git revision.
2. You used `NXF_VER=25.10.4`.
3. You ran with `-profile docker`.
4. You used the repository-provided [envs/runtime.yml](envs/runtime.yml).
5. You built and used `promopop-plink2:latest` from [containers/plink2/Dockerfile](containers/plink2/Dockerfile).
6. You archived `.nextflow.log`, `work/` metadata, and final `results/` outputs.

## Troubleshooting

- `CondaError: Run 'conda init' before 'conda activate'`
   Run `conda init bash`, then reopen terminal or `source ~/.bash_profile`.

- `failed to connect to the docker API ... /var/run/docker.sock`
   Start Docker Desktop and rerun the command.

- `plink2: command not found` in `EXPORT_GENOTYPE_WITH_PLINK`
   You likely launched without Docker profile. Use `-profile docker`.

- `First argument must be a flag` from `plink2`
   Rebuild the image from current [containers/plink2/Dockerfile](containers/plink2/Dockerfile), then rerun with `-resume`.

- Empty `MAF_EUR` values in final table
   Verify the EUR file has expected CHROM/POS/ID + MAF columns and that variant keys align.

## Developer Notes

- Pipeline configuration: [nextflow.config](nextflow.config)
- Runtime environment spec: [envs/runtime.yml](envs/runtime.yml)
- PLINK container build recipe: [containers/plink2/Dockerfile](containers/plink2/Dockerfile)
>>>>>>> chore/reproducible-pipeline-setup
