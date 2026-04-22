process PLOT_MAF_DISTRIBUTION {

    publishDir "results", mode: 'copy'

    input:
    path merged_with_genocounts
    path maf_aa_vs_eur

    output:
    path "maf_distribution.png"
    path "maf_distribution.pdf"
    path "maf_plot_data.tsv"

    script:
    """
    Rscript - <<'RS'
    suppressPackageStartupMessages(library(ggplot2))

    merged_file <- "${merged_with_genocounts}"
    maf_file <- "${maf_aa_vs_eur}"

    merged_df <- read.table(merged_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
    maf_df <- read.table(maf_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

    merged_df[["promoterAI"]] <- as.numeric(merged_df[["promoterAI"]])
    merged_df[["variant_id"]] <- as.character(merged_df[["variant_id"]])
    maf_df[["variant_id"]] <- as.character(maf_df[["variant_id"]])
    maf_df[["MAF_AA"]] <- as.numeric(maf_df[["MAF_AA"]])
    maf_df[["MAF_EUR"]] <- as.numeric(maf_df[["MAF_EUR"]])

    df <- merge(merged_df, maf_df, by = "variant_id", all.x = TRUE)
    df <- df[!is.na(df[["MAF_AA"]]) & !is.na(df[["MAF_EUR"]]) & df[["MAF_EUR"]] != 1, ]

    df[["promoter_class"]] <- ifelse(
      df[["promoterAI"]] > 0.5,
      "Upregulation (>0.5)",
      ifelse(df[["promoterAI"]] < -0.5, "Downregulation (<-0.5)", "Neutral")
    )

    df[["MAF"]] <- df[["MAF_AA"]]

    write.table(df, file = "maf_plot_data.tsv", sep = "\t", row.names = FALSE, quote = FALSE)

    p <- ggplot() +
      geom_point(
        data = df[df[["promoter_class"]] == "Neutral", ],
        aes(x = MAF, y = MAF_EUR, color = promoter_class),
        alpha = 0.4, size = 2
      ) +
      geom_point(
        data = df[df[["promoter_class"]] != "Neutral", ],
        aes(x = MAF, y = MAF_EUR, color = promoter_class),
        alpha = 0.9, size = 2.8
      ) +
      scale_color_manual(values = c(
        "Neutral" = "lightgrey",
        "Upregulation (>0.5)" = "red",
        "Downregulation (<-0.5)" = "blue"
      )) +
      geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "black") +
      theme_bw() +
      labs(
        title = "MAF distribution for IBD_AA vs. EUR",
        x = "MAF_IBD",
        y = "MAF_EUR",
        color = "Promoter AI Class"
      ) +
      theme(
        plot.title = element_text(hjust = 0.5),
        legend.position = "right"
      )

    ggsave("maf_distribution.png", p, width = 7, height = 6, dpi = 300)
    ggsave("maf_distribution.pdf", p, width = 7, height = 6)
    RS
    """
}
