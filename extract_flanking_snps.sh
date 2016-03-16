SNPS=$1 # source_data/snp_infos/t2d_snps_chr.vcf
ruby vcf2bed.rb $SNPS | bedtools slop -b 25000 -g source_data/genome_sizes/human.genome | bedtools intersect -a all_SNPs.vcf -b stdin
