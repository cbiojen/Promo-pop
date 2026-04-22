process EXTRACT_SNP_LIST {

    publishDir "results", mode: 'copy'

    input:
    path merged_promoter_bim

    output:
    path "snp_promoter_IBD_all"

    script:
    """
    awk -F'\t' '
    NR==1 {
        for (i=1; i<=NF; i++) {
            if (\$i == "variant_id") {
                vid_col=i
                break
            }
        }
        next
    }
    vid_col && \$vid_col != "" { print \$vid_col }
    ' ${merged_promoter_bim} | sort -u > snp_promoter_IBD_all
    """
}
