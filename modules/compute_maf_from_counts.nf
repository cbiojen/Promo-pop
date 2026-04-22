process COMPUTE_MAF_FROM_COUNTS {

    publishDir "results", mode: 'copy'

    input:
    path genotype_counts

    output:
    path "snp_maf_aa.tsv"

    script:
    """
    python - <<'PY'
import csv

input_file = "${genotype_counts}"
output_file = "snp_maf_aa.tsv"

with open(input_file, newline="") as f_in, open(output_file, "w", newline="") as f_out:
    reader = csv.DictReader(f_in, delimiter="\t")
    fieldnames = ["variant_id", "MAF_AA", "ALT_FREQ_AA", "N_SAMPLES"]
    writer = csv.DictWriter(f_out, fieldnames=fieldnames, delimiter="\t")
    writer.writeheader()

    for row in reader:
        variant_id = row.get("variant_id", "")
        if not variant_id:
            continue

        try:
            hom_ref = float(row.get("Hom_Ref", ""))
            het = float(row.get("Het", ""))
            hom_alt = float(row.get("Hom_Alt", ""))
        except ValueError:
            continue

        n_samples = hom_ref + het + hom_alt
        if n_samples <= 0:
            continue

        alt_freq = (2.0 * hom_alt + het) / (2.0 * n_samples)
        maf = min(alt_freq, 1.0 - alt_freq)

        writer.writerow({
            "variant_id": variant_id,
            "MAF_AA": f"{maf:.6f}",
            "ALT_FREQ_AA": f"{alt_freq:.6f}",
            "N_SAMPLES": int(n_samples),
        })
PY
    """
}
