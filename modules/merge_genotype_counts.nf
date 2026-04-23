process MERGE_GENOTYPE_COUNTS {

    publishDir "results", mode: 'copy'

    input:
    path merged_promoter_bim
    path genotype_counts

    output:
    path "merged_all_with_genocounts.tsv"

    script:
    """
<<<<<<< HEAD
    python - <<'PY'
=======
    PYTHON_BIN="\$(command -v python3 || command -v python)"
    if [[ -z "\$PYTHON_BIN" ]]; then
        echo "ERROR: Neither python3 nor python is available in PATH" >&2
        exit 127
    fi
    "\$PYTHON_BIN" - <<'PY'
>>>>>>> chore/reproducible-pipeline-setup
import csv

merged_file = "${merged_promoter_bim}"
geno_counts_file = "${genotype_counts}"
output_file = "merged_all_with_genocounts.tsv"

# Load genotype counts keyed by variant_id
counts_by_variant = {}
with open(geno_counts_file, newline="") as f:
    reader = csv.DictReader(f, delimiter="\t")
    for row in reader:
        variant_id = row.get("variant_id", "")
        if variant_id:
            counts_by_variant[variant_id] = {
                "Hom_Ref": row.get("Hom_Ref", ""),
                "Het": row.get("Het", ""),
                "Hom_Alt": row.get("Hom_Alt", ""),
                "Ref_Allele": row.get("Ref_Allele", ""),
            }

with open(merged_file, newline="") as in_f, open(output_file, "w", newline="") as out_f:
    reader = csv.DictReader(in_f, delimiter="\t")
    fieldnames = list(reader.fieldnames or []) + ["Hom_Ref", "Het", "Hom_Alt", "Ref_Allele"]

    writer = csv.DictWriter(out_f, fieldnames=fieldnames, delimiter="\t", extrasaction="ignore")
    writer.writeheader()

    for row in reader:
        variant_id = row.get("variant_id", "")
        counts = counts_by_variant.get(variant_id, {
            "Hom_Ref": "",
            "Het": "",
            "Hom_Alt": "",
            "Ref_Allele": "",
        })
        row.update(counts)
        writer.writerow(row)
PY
    """
}
