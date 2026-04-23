process COMPARE_WITH_EUR_MAF {

    publishDir "results", mode: 'copy'

    input:
    path aa_maf
    path eur_maf

    output:
    path "maf_aa_vs_eur.tsv"

    shell:
    '''
    PYTHON_BIN="\$(command -v python3 || command -v python)"
    if [[ -z "\$PYTHON_BIN" ]]; then
        echo "ERROR: Neither python3 nor python is available in PATH" >&2
        exit 127
    fi
    "\$PYTHON_BIN" - <<'PY'
import csv


def split_ws(line):
    return line.strip().split()


def normalize_chrom(value):
    s = str(value).strip()
    if s.startswith("NC_") and "." in s:
        core = s[3:].split(".", 1)[0].lstrip("0")
        if core.isdigit():
            num = int(core)
            if num == 23:
                return "X"
            if num == 24:
                return "Y"
            return str(num)
    sl = s.lower()
    if sl.startswith("chr"):
        return s[3:]
    return s


def pick_column(columns, preferred_exact, preferred_contains=None):
    for name in preferred_exact:
        if name in columns:
            return name
    if preferred_contains:
        lower_cols = {c.lower(): c for c in columns}
        for token in preferred_contains:
            t = token.lower()
            for lc, orig in lower_cols.items():
                if t in lc:
                    return orig
    return None


aa_maf_file = '!{aa_maf}'
eur_maf_file = '!{eur_maf}'
out_file = 'maf_aa_vs_eur.tsv'

with open(aa_maf_file, newline='') as f:
    aa_reader = csv.DictReader(f, delimiter='\t')
    aa_rows = list(aa_reader)

with open(eur_maf_file, 'r', encoding='utf-8', errors='replace') as f:
    lines = [line for line in f if line.strip()]

if not lines:
    raise SystemExit('European MAF file is empty')

header = split_ws(lines[0])
variant_col = pick_column(
    header,
    preferred_exact=['variant_id', 'SNP', 'ID', 'rsid'],
    preferred_contains=['variant', 'snp', 'id'],
)
chrom_col = pick_column(
    header,
    preferred_exact=['CHROM', 'chrom', 'chr'],
    preferred_contains=['chrom', 'chr'],
)
pos_col = pick_column(
    header,
    preferred_exact=['POS', 'pos', 'position'],
    preferred_contains=['pos', 'position'],
)
maf_eur_col = pick_column(
    header,
    preferred_exact=['MAF_EUR', 'MAF', 'EUR_MAF', 'AF_EUR', 'ALT_AF_EUR'],
    preferred_contains=['samn10492695', 'maf_eur', 'eur_maf', 'maf', 'af'],
)

if variant_col is None or maf_eur_col is None:
    raise SystemExit('Could not detect required columns in EUR MAF file. Found columns: ' + str(header))

idx_variant = header.index(variant_col)
idx_maf = header.index(maf_eur_col)
idx_chrom = header.index(chrom_col) if chrom_col in header else None
idx_pos = header.index(pos_col) if pos_col in header else None

eur_map = {}
eur_map_chrpos = {}

for line in lines[1:]:
    cols = split_ws(line)
    if len(cols) <= max(idx_variant, idx_maf):
        continue

    variant_id = cols[idx_variant]
    maf_val = cols[idx_maf]
    eur_map[variant_id] = maf_val

    if idx_chrom is not None and idx_pos is not None and len(cols) > max(idx_chrom, idx_pos):
        chrom = normalize_chrom(cols[idx_chrom])
        pos = cols[idx_pos]
        eur_map_chrpos[(chrom, pos)] = maf_val

with open(out_file, 'w', newline='') as out:
    fieldnames = ['variant_id', 'MAF_AA', 'MAF_EUR', 'ABS_DIFF']
    writer = csv.DictWriter(out, fieldnames=fieldnames, delimiter='\t')
    writer.writeheader()

    for row in aa_rows:
        variant_id = row.get('variant_id', '')
        maf_aa = row.get('MAF_AA', '')
        maf_eur = eur_map.get(variant_id, '')

        if maf_eur == '':
            parts = variant_id.split('_')
            if len(parts) >= 2:
                chrom_guess = normalize_chrom(parts[0])
                pos_guess = parts[1]
                maf_eur = eur_map_chrpos.get((chrom_guess, pos_guess), '')

        abs_diff = ''
        try:
            if maf_aa != '' and maf_eur != '':
                abs_diff = f"{abs(float(maf_aa) - float(maf_eur)):.6f}"
        except ValueError:
            abs_diff = ''

        writer.writerow({
            'variant_id': variant_id,
            'MAF_AA': maf_aa,
            'MAF_EUR': maf_eur,
            'ABS_DIFF': abs_diff,
        })
PY
    '''
}
