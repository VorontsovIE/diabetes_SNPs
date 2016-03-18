require_relative 'lib/statistics/fisher_table'
require_relative 'lib/statistics/statistical_significance'

def read_motif_counts(filename)
  File.readlines(filename).map{|l| motif_name, count = l.chomp.split("\t"); [motif_name, count.to_i] }.to_h
end

motif_list = Dir.glob('source_data/motif_collections/human/*.pwm').map{|fn| File.basename(fn,'.pwm') }.select{|motif| motif.match(/\.[ABC]$/) }.sort

t2d_hap_affected_counts = read_motif_counts('results/affected_sites/human_T2D_variants_25k_haplotype.txt')
t2d_hap_all_counts = read_motif_counts('results/nonaffected_sites/human_T2D_variants_25k_haplotype.txt')

t2d_25k_affected_counts = read_motif_counts('results/affected_sites/human_T2D_variants_25k.txt')
t2d_25k_all_counts = read_motif_counts('results/nonaffected_sites/human_T2D_variants_25k.txt')

random_25k_affected_counts = read_motif_counts('results/affected_sites/random_snps_100_25k.txt')
random_25k_all_counts = read_motif_counts('results/nonaffected_sites/random_snps_100_25k.txt')

fisher_tables = motif_list.map{|motif|
  ft = FisherTable.by_class_and_total(
    class_a_total: t2d_25k_all_counts[motif], class_a_positive: t2d_25k_affected_counts[motif],
    class_b_total: random_25k_all_counts[motif], class_b_positive: random_25k_affected_counts[motif]
  )
  [motif, ft]
}.to_h

significances = fisher_tables.map{|motif, ft| [motif, ft.significance] }.to_h
corrected_significances = PvalueCorrector.new('fdr').correct_hash( significances )

puts ['Motif', 'Ratio of T2D to random affection rates', 'Significance'].join("\t")
motif_list.select{|motif| corrected_significances[motif] <= 0.05 }.map{|motif|
  [motif, fisher_tables[motif].a_to_b_positive_rate_ratio&.round(3), corrected_significances[motif]&.round(5)].join("\t")
}.each{|line| puts line }
