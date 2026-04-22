process EXTRACT_PROMOTER_RECORDS {

    publishDir "results", mode: 'copy'

    input:
    path genelist
    path promoter_db

    output:
    path "promoterAI_IBD_genes_all.tsv"

    script:
    """
    grep -w -F -f ${genelist} \
        ${promoter_db} \
        > promoterAI_IBD_genes_all.tsv
    """
}