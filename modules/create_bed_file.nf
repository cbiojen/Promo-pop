process CREATE_PROMOTER_BED {

    publishDir "results", mode: 'copy'

    input:
    path promoter_positions

    output:
    path "IBD_promoter_pos_all.bed"

    script:
    """
    awk 'NR>1 {
        print \$2"\\t"\$3"\\t"\$4"\\t"\$1
    }' ${promoter_positions} \
    > IBD_promoter_pos_all.bed
    """
}