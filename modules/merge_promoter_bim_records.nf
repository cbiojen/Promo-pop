process MERGE_PROMOTER_BIM_RECORDS {

    publishDir "results", mode: 'copy'

    input:
    path promoter_ai_records
    path promoter_bim_records

    output:
    path "merged_promoter_bim_all.tsv"

    script:
    """
    PYTHON_BIN="\$(command -v python3 || command -v python)"
    if [[ -z "\$PYTHON_BIN" ]]; then
        echo "ERROR: Neither python3 nor python is available in PATH" >&2
        exit 127
    fi
    "\$PYTHON_BIN" - <<'PY'
import csv

promoter_ai_file = "${promoter_ai_records}"
promoter_bim_file = "${promoter_bim_records}"
output_file = "merged_promoter_bim_all.tsv"


def normalize_chr(value: str) -> str:
    value = str(value).strip()
    if value.lower().startswith("chr"):
        value = value[3:]
    return value


# promoterAI columns (headerless):
# chrom, pos, ref, alt, gene, gene_id, transcript_id, strand, tss_pos, promoterAI
ai_rows = []
ai_index = {}
with open(promoter_ai_file, newline="") as f:
    reader = csv.reader(f, delimiter="\t")
    for row in reader:
        if len(row) < 10:
            continue
        chrom = normalize_chr(row[0])
        try:
            pos = int(float(row[1]))
        except ValueError:
            continue
        key = (chrom, pos)
        ai_rows.append(row)
        ai_index.setdefault(key, []).append(row)

# Supports multiple BIM/BIM-promoter formats:
# 6 cols (raw .bim): chrom, variant_id, genetic_distance, pos, ref, alt
# 7 cols (current filtered output): chrom, gene, variant_id, genetic_distance, pos, ref, alt
# 10 cols (older region-style output): region_chr, region_start, region_end, gene, chrom, pos, pos_end, variant_id, ref, alt
header = [
    "region_chr", "region_start", "region_end", "gene", "chrom", "pos", "pos_end",
    "variant_id", "ref_bim", "alt_bim", "ref_ai", "alt_ai", "gene_ai", "gene_id",
    "transcript_id", "strand", "tss_pos", "promoterAI"
]

merged_count = 0
bim_total = 0

with open(output_file, "w", newline="") as out_f:
    writer = csv.writer(out_f, delimiter="\t")
    writer.writerow(header)

    with open(promoter_bim_file, newline="") as f:
        for line in f:
            row = line.strip().split()
            if not row:
                continue
            bim_total += 1

            if len(row) >= 10:
                region_chr, region_start, region_end, gene, chrom, pos, pos_end, variant_id, ref_bim, alt_bim = row[:10]
            elif len(row) >= 7:
                chrom, gene, variant_id, _genetic_dist, pos, ref_bim, alt_bim = row[:7]
                region_chr = chrom
                region_start = pos
                region_end = pos
                pos_end = pos
            elif len(row) >= 6:
                chrom, variant_id, _genetic_dist, pos, ref_bim, alt_bim = row[:6]
                gene = "NA"
                region_chr = chrom
                region_start = pos
                region_end = pos
                pos_end = pos
            else:
                continue

            chrom_norm = normalize_chr(chrom)
            try:
                pos_int = int(float(pos))
            except ValueError:
                continue

            for ai in ai_index.get((chrom_norm, pos_int), []):
                writer.writerow([
                    region_chr, region_start, region_end, gene, chrom_norm, pos_int, pos_end,
                    variant_id, ref_bim, alt_bim, ai[2], ai[3], ai[4], ai[5], ai[6], ai[7], ai[8], ai[9]
                ])
                merged_count += 1

ai_total = len(ai_rows)
match_pct = (100.0 * merged_count / bim_total) if bim_total else 0.0

print(f"Merged file saved as {output_file}")
print(f"SNPs in bim_promoter file: {bim_total}")
print(f"SNPs in promoterAI file: {ai_total}")
print(f"Overlapping SNPs kept: {merged_count}")
print(f"Percentage of bim SNPs matched: {match_pct:.1f}%")
PY
    """
}
