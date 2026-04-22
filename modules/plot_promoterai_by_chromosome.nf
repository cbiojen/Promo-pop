process PLOT_PROMOTERAI_BY_CHROMOSOME {

    publishDir "results", mode: 'copy'

    input:
    path merged_with_genocounts

    output:
    path "locus_zoom_promoterAI.png"
    path "locus_zoom_promoterAI.pdf"
    path "promoterAI_plot_data.tsv"

    shell:
    '''
    cat > plot_promoterai_by_chromosome.R <<'RS'
    suppressPackageStartupMessages(library(ggplot2))
    suppressPackageStartupMessages(library(dplyr))

    input_file <- '!{merged_with_genocounts}'
    df <- read.delim(input_file, sep = '\t', header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)

    df[['promoterAI']] <- as.numeric(df[['promoterAI']])
    df[['chrom']] <- as.character(df[['chrom']])

    df <- df %>%
      mutate(
        significant = ifelse(df[['promoterAI']] >= 0.5 | df[['promoterAI']] <= -0.5, 'Significant', 'Not Significant'),
        chrom = factor(df[['chrom']], levels = sort(unique(df[['chrom']])))
      )

    write.table(df, file = 'promoterAI_plot_data.tsv', sep = '\t', row.names = FALSE, quote = FALSE)

    p <- ggplot(df, aes(x = chrom, y = promoterAI)) +
      annotate('rect', xmin = -Inf, xmax = Inf, ymin = 0.5, ymax = Inf, fill = 'lightblue', alpha = 0.3) +
      annotate('rect', xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = -0.5, fill = 'lightblue', alpha = 0.3) +
      geom_hline(yintercept = 0.5, linetype = 'dashed', color = 'blue', alpha = 0.5) +
      geom_hline(yintercept = -0.5, linetype = 'dashed', color = 'blue', alpha = 0.5) +
      geom_hline(yintercept = 0, linetype = 'solid', color = 'gray50', alpha = 0.5) +
      geom_point(aes(color = significant), size = 2, alpha = 0.7, position = position_jitter(width = 0.2, height = 0)) +
      scale_color_manual(values = c('Significant' = 'blue', 'Not Significant' = 'gray60')) +
      labs(title = 'PromoterAI Scores Across Chromosomes', x = 'Chromosome', y = 'PromoterAI Score', color = 'Significance') +
      theme_classic() +
      theme(legend.position = 'top', plot.title = element_text(hjust = 0.5, face = 'bold'), axis.text = element_text(size = 10), axis.title = element_text(size = 12, face = 'bold'))

    ggsave('locus_zoom_promoterAI.png', plot = p, width = 12, height = 6, dpi = 300)
    ggsave('locus_zoom_promoterAI.pdf', plot = p, width = 12, height = 6)

    cat('Summary:\n')
    cat('Total variants:', nrow(df), '\n')
    cat('Significant variants (|promoterAI| >= 0.5):', sum(df[['promoterAI']] >= 0.5 | df[['promoterAI']] <= -0.5, na.rm = TRUE), '\n')
RS

    Rscript plot_promoterai_by_chromosome.R
    '''
}
