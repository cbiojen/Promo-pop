process COMPUTE_PROMOTER_POSITIONS {

    publishDir "results", mode: 'copy'

    input:
    path promoter_records

    output:
    path "IBD_promoter_pos_all.tsv"

    script:
    """
    awk -F'\\t' '{
        gene=\$5;
        chrom=\$1;
        pos=\$2;

        if(min[gene]=="" || pos<min[gene])
            min[gene]=pos;

        if(max[gene]=="" || pos>max[gene])
            max[gene]=pos;

        chrom_gene[gene]=chrom;

    }

    END {
        print "gene\\tchrom\\tmin_position\\tmax_position";

        for(g in min)
            print g"\\t"chrom_gene[g]"\\t"min[g]"\\t"max[g];

    }' ${promoter_records} \
    > IBD_promoter_pos_all.tsv
    """

}