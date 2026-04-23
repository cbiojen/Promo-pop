# PromoPop Nextflow Pipeline

![PromoPop Logo](logo/logo.svg)

PromoPop identifies promoter-region variants for IBD genes, extracts genotype dosage, computes genotype counts and MAF, compares against European MAF, and generates summary plots.

## Inputs

The pipeline is configured through [nextflow.config](nextflow.config). For local runs, use a params file.

### Example `params.local.json`

```json
{
  "genelist": "/ABSOLUTE/PATH/TO/secure_data/my_genelist.txt",
  "promoter_db": "/ABSOLUTE/PATH/TO/secure_data/my_promoterAI_tss500.tsv",
  "plink_prefix": "/ABSOLUTE/PATH/TO/secure_data/my_cohort",
  "european_maf_file": "/ABSOLUTE/PATH/TO/secure_data/my_eur_maf.tsv",
  "plink_container": "promopop-plink2:latest",
  "maf_plot_title": "MAF distribution for IBD_AA vs. EUR"
}
```

### Input summary

| Parameter | Description |
| --- | --- |
| `genelist` | Gene list file, one gene per line |
| `promoter_db` | promoterAI input table |
| `plink_prefix` | PLINK dataset prefix (`.bed`, `.bim`, `.fam`) |
| `european_maf_file` | European MAF table |
| `bim_file` | Optional explicit BIM path; defaults to `${plink_prefix}.bim` |

## Run

### 1. Set up Nextflow

```bash
source ~/.bash_profile
conda create -y -n nextflow-env -c conda-forge -c bioconda nextflow=25.10.4
conda activate nextflow-env
nextflow -version
```

### 2. Build the PLINK2 image

```bash
docker build --platform linux/amd64 -t promopop-plink2:latest -f containers/plink2/Dockerfile .
```

### 3. Run PromoPop

```bash
NXF_VER=25.10.4 nextflow run main.nf \
  -profile docker \
  -resume \
  -params-file params.local.json
```

## Workflow summary

The pipeline in [main.nf](main.nf) runs these modules:

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
- `maf_distribution.png`
- `maf_distribution.pdf`
- `locus_zoom_promoterAI.png`
- `locus_zoom_promoterAI.pdf`

## Reproducibility

- Python and R tasks run in a pinned Conda environment defined in [envs/runtime.yml](envs/runtime.yml).
- PLINK2 runs in a Docker image defined in [containers/plink2/Dockerfile](containers/plink2/Dockerfile).
- Nextflow is pinned at launch using `NXF_VER`.
- Keep private dataset paths in `params.local.json`.
- `params.local.json` is ignored by git.

## Troubleshooting

- `CondaError: Run 'conda init' before 'conda activate'`
  - Run `conda init bash`, then reopen the terminal or source `~/.bash_profile`.

- `failed to connect to the docker API ... /var/run/docker.sock`
  - Start Docker Desktop and rerun the command.

- `plink2: command not found` in `EXPORT_GENOTYPE_WITH_PLINK`
  - Use `-profile docker`.

- Empty `MAF_EUR` values in the final table
  - Verify the European MAF file has the expected CHROM/POS/ID + MAF columns.

## Notes

- Pipeline configuration: [nextflow.config](nextflow.config)
- Runtime environment: [envs/runtime.yml](envs/runtime.yml)
- PLINK container build recipe: [containers/plink2/Dockerfile](containers/plink2/Dockerfile)
