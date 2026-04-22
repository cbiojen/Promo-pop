process EXPORT_GENOTYPE_WITH_PLINK {

    publishDir "results", mode: 'copy'
  container "${params.plink_container}"

    input:
    path plink_bed
    path plink_bim
    path plink_fam
    path snp_list

    output:
    path "genotype_all.raw"

    script:
    """
    ln -sf ${plink_bed} plink_input.bed
    ln -sf ${plink_bim} plink_input.bim
    ln -sf ${plink_fam} plink_input.fam

    plink2 --bfile plink_input \
      --export A \
      --extract ${snp_list} \
      --out genotype_all
    """
}
