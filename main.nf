nextflow.enable.dsl=2

include { EXTRACT_PROMOTER_RECORDS } from './modules/extract_promoter_records.nf'
include { COMPUTE_PROMOTER_POSITIONS } from './modules/compute_promoter_positions.nf'
include { CREATE_PROMOTER_BED } from './modules/create_bed_file.nf'
include { EXTRACT_BIM_PROMOTER_RECORDS } from './modules/extract_bim_promoter_records.nf'
include { MERGE_PROMOTER_BIM_RECORDS } from './modules/merge_promoter_bim_records.nf'
include { EXTRACT_SNP_LIST } from './modules/extract_snp_list.nf'
include { EXPORT_GENOTYPE_WITH_PLINK } from './modules/export_genotype_with_plink.nf'
include { COUNT_GENOTYPES } from './modules/count_genotypes.nf'
include { MERGE_GENOTYPE_COUNTS } from './modules/merge_genotype_counts.nf'
include { COMPUTE_MAF_FROM_COUNTS } from './modules/compute_maf_from_counts.nf'
include { COMPARE_WITH_EUR_MAF } from './modules/compare_with_eur_maf.nf'
include { PLOT_MAF_DISTRIBUTION } from './modules/plot_maf_distribution.nf'
include { PLOT_PROMOTERAI_BY_CHROMOSOME } from './modules/plot_promoterai_by_chromosome.nf'

workflow {

    bim_file = params.bim_file ?: "${params.plink_prefix}.bim"

    promoter_records =
        EXTRACT_PROMOTER_RECORDS(
            file(params.genelist),
            file(params.promoter_db)
        )

    promoter_positions =
        COMPUTE_PROMOTER_POSITIONS(
            promoter_records
        )

    promoter_bed =
        CREATE_PROMOTER_BED(
            promoter_positions
        )

    bim_promoter_records =
        EXTRACT_BIM_PROMOTER_RECORDS(
            promoter_positions,
            file(bim_file)
        )

    merged_promoter_bim_records =
        MERGE_PROMOTER_BIM_RECORDS(
            promoter_records,
            bim_promoter_records
        )

    snp_promoter_list =
        EXTRACT_SNP_LIST(
            merged_promoter_bim_records
        )

    genotype_all =
        EXPORT_GENOTYPE_WITH_PLINK(
            file("${params.plink_prefix}.bed"),
            file("${params.plink_prefix}.bim"),
            file("${params.plink_prefix}.fam"),
            snp_promoter_list
        )

    genotype_counts =
        COUNT_GENOTYPES(
            genotype_all,
            snp_promoter_list
        )

    merged_with_genocounts =
        MERGE_GENOTYPE_COUNTS(
            merged_promoter_bim_records,
            genotype_counts
        )

    maf_aa =
        COMPUTE_MAF_FROM_COUNTS(
            genotype_counts
        )

    maf_aa_vs_eur =
        COMPARE_WITH_EUR_MAF(
            maf_aa,
            file(params.european_maf_file)
        )

    maf_distribution_plot =
        PLOT_MAF_DISTRIBUTION(
            merged_with_genocounts,
            maf_aa_vs_eur
        )

    promoterai_chrom_plot =
        PLOT_PROMOTERAI_BY_CHROMOSOME(
            merged_with_genocounts
        )
}