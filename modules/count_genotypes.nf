process COUNT_GENOTYPES {

    publishDir "results", mode: 'copy'

    input:
    path genotype_raw
    path snp_list

    output:
    path "snp_list_with_genotype_counts.tsv"

    script:
    """
    Rscript - <<'RS'
# Base-R implementation adapted from 6_IBD_genotype.R

snp_list <- read.table("${snp_list}", header = FALSE, stringsAsFactors = FALSE)
colnames(snp_list) <- "variant_id"

genotypes <- read.table("${genotype_raw}", header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)
original_colnames <- colnames(genotypes)

strip_ref_suffix <- function(x) {
  parts <- strsplit(x, "_", fixed = TRUE)[[1]]
  if (length(parts) >= 2) {
    last_token <- parts[length(parts)]
    if (nchar(last_token) == 1 && last_token %in% c("A", "C", "G", "T")) {
      return(paste(parts[-length(parts)], collapse = "_"))
    }
  }
  x
}

colnames(genotypes) <- vapply(colnames(genotypes), strip_ref_suffix, character(1))

get_geno_counts <- function(snp_name, geno_df) {
  if (!(snp_name %in% colnames(geno_df))) {
    warning(sprintf("SNP %s not found in genotype file", snp_name))
    return(data.frame(variant_id = snp_name, Hom_Ref = NA_integer_, Het = NA_integer_, Hom_Alt = NA_integer_))
  }

  g <- geno_df[[snp_name]]

  data.frame(
    variant_id = snp_name,
    Hom_Ref = sum(g == 0, na.rm = TRUE),
    Het     = sum(g == 1, na.rm = TRUE),
    Hom_Alt = sum(g == 2, na.rm = TRUE)
  )
}

geno_counts <- do.call(rbind, lapply(snp_list[["variant_id"]], get_geno_counts, geno_df = genotypes))

geno_counts[["Ref_Allele"]] <- sapply(geno_counts[["variant_id"]], function(snp) {
  prefix <- paste0(snp, "_")
  candidates <- original_colnames[startsWith(original_colnames, prefix)]
  if (length(candidates) == 0) {
    return(NA_character_)
  }

  suffixes <- substring(candidates, nchar(prefix) + 1)
  allele_idx <- which(nchar(suffixes) == 1 & suffixes %in% c("A", "C", "G", "T"))
  if (length(allele_idx) == 0) {
    return(NA_character_)
  }

  suffixes[allele_idx[1]]
})

geno_counts_unique <- unique(geno_counts)

write.table(
  geno_counts_unique,
  file = "snp_list_with_genotype_counts.tsv",
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)
RS
    """
}
