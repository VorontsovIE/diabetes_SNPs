require 'optparse'
require_relative 'lib/perfectosape/SNPScanRunner'
require_relative 'lib/perfectosape/SNPScanResults'
require_relative 'lib/perfectosape/Hocomoco10Results'

# Hocomoco10 expected
def all_sites_in_file(filename, motif_collection:,
                                precalulated_thresholds:,
                                pvalue_cutoff: 0.001,
                                additional_options: [])
  Ape.run_SNPScan(snvs_file: filename,
                  motif_collection: motif_collection,
                  precalulated_thresholds: precalulated_thresholds,
                  fold_change_cutoff: 1,
                  pvalue_cutoff: pvalue_cutoff,
                  additional_options: additional_options) do |pipe|
    PerfectosAPE::Hocomoco10Result.each_in_stream(pipe).to_a
  end
end

def count_items_by(enumerator)
  raise 'Specify block'  unless block_given?
  result = Hash.new(0)
  enumerator.each{|item|
    result[yield item] += 1
  }
  result
end

pvalue_cutoff = 0.0005
fold_change_cutoff = 4
fold_change_direction = :any # count both disruption and emergence events
filter_by_fold_change = true

should_have_site_before = nil
should_have_site_after = nil

chipseq_files_pattern = nil
# accessibility_filename = nil


OptionParser.new{|opts|
  opts.on('--pvalue-cutoff CUTOFF', 'Specify P-value cutoff for site recognition') {|value| pvalue_cutoff = Float(value) }
  opts.on('--fold-change-cutoff CUTOFF', 'Specify fold-change cutoff for affinity change') {|value| fold_change_cutoff = Float(value) }
  opts.on('--fold-change-direction MODE', 'Specify direction of fold change: disruption/emergence/any'){|value|
    fold_change_direction = value.downcase.to_sym
    raise 'Fold change direction should be one of disruption/emergence/any'  unless [:disruption, :emergence, :any].include?(fold_change_direction)
  }
  
  opts.on('--site-before', 'Oblige original allele have site') { should_have_site_before = true }
  opts.on('--site-after', 'Oblige original allele have site') { should_have_site_after = true }

  # FILE_PATTERN example "results/confident_sites/*_HUMAN.*.txt"
  opts.on('--chip-seq-intervals FILE_PATTERN', 'Specify pattern for files with intervals of ChIP-Seq sites'){|value|
    chipseq_files_pattern = value
  }

  # # FILE_PATTERN example "results/confident_sites/*_HUMAN.*.txt"
  # opts.on('--accessibility-intervals FILE', 'Specify file with profile of DNase accessibility'){|value|
  #   accessibility_filename = value
  # }
  
  opts.on('--[no-]filter-by-fold-change', 'Filter by affinity change (default). If disabled, it is possible to count all sites, independent of fold change') {|value|
    filter_by_fold_change = value
  }

}.parse!(ARGV)

raise 'Specify file with SNP sequences'  unless snp_sequences_filename = ARGV[0]

motif_list = Dir.glob('source_data/motif_collections/human/*.pwm').map{|fn| File.basename(fn, '.pwm').to_sym }.sort


all_sites = all_sites_in_file(
  snp_sequences_filename,
  motif_collection: 'source_data/motif_collections/human/',
  precalulated_thresholds: 'source_data/motif_thresholds/human/',
  pvalue_cutoff: pvalue_cutoff
)

if filter_by_fold_change
  all_affected_sites = all_sites.select{|site|
    case fold_change_direction
    when :disruption
      site.disrupted?(fold_change_cutoff: fold_change_cutoff)
    when :emergence
      site.emerged?(fold_change_cutoff: fold_change_cutoff)
    when :any
      site.disrupted?(fold_change_cutoff: fold_change_cutoff) || site.emerged?(fold_change_cutoff: fold_change_cutoff)
    end
  }
else
  all_affected_sites = all_sites
end

if should_have_site_before
  all_affected_sites = all_affected_sites.select{|site| site.site_before_substitution?(pvalue_cutoff: pvalue_cutoff) }
end

if should_have_site_after
  all_affected_sites = all_affected_sites.select{|site| site.site_after_substitution?(pvalue_cutoff: pvalue_cutoff) }
end

sites = all_affected_sites

# IT'S REASONABLE TO FILTER SNPs BY ACCESSIBILITY, NOT SITES!
# if accessibility_filename
#   confident_regions = SiteRegion.from_file_by_chromosome(accessibility_filename)
#   sites = sites.select{|site|
#     variant_id, genome_pos = site.variant_id.split('@')
#     chromosome, pos = genome_pos.split(':')
#     pos = pos.to_i
#     confident_regions[chromosome].include_position?(pos)
#   }
# end

if chipseq_files_pattern
  confident_regions = Dir.glob(chipseq_files_pattern).map{|fn|
    motif_name = File.basename(confident_sites_filename, '.txt').to_sym
    [motif_name, SiteRegion.from_file_by_chromosome(fn)]
  }.to_h

  sites = all_affected_sites.select{|site|
    confident_regions.has_key?(site.motif_name)
  }.select{|site|
    variant_id, genome_pos = site.variant_id.split('@')
    chromosome, pos = genome_pos.split(':')
    pos = pos.to_i
    confident_regions[site.motif_name][chromosome].include_position?(pos)
  }
end

site_counts = count_items_by(sites, &:motif_name)

motif_list.each{|motif|
  puts [motif, site_counts[motif]].join("\t")
}
