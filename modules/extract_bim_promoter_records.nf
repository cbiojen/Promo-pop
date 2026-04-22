process EXTRACT_BIM_PROMOTER_RECORDS {

    publishDir "results", mode: 'copy'

    input:
    path promoter_positions
    path bim_file

    output:
    path "bim_promoter_IBD_all.tsv"

    script:
    """
    awk 'BEGIN { OFS="\t" }
    NR==FNR {
        if (FNR == 1) next
        chr = \$2
        sub(/^chr/, "", chr)
        range[chr, ++count[chr]] = \$3 ":" \$4 ":" \$1
        next
    }
    {
        chr = \$1
        sub(/^chr/, "", chr)
        pos = \$4
        for (i=1; i<=count[chr]; i++) {
            split(range[chr, i], a, ":")
            if (pos >= a[1] && pos <= a[2]) {
                print chr, a[3], \$2, \$3, \$4, \$5, \$6
            }
        }
    }' ${promoter_positions} ${bim_file} > bim_promoter_IBD_all.tsv
    """
}
