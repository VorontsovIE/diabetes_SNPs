require 'optparse'
require_relative 'lib/ape_find_threshold'
require_relative 'lib/site_regions'

pvalue_cutoff = 0.001

OptionParser.new{|opts|
  opts.banner = "Usage: #{opts.program_name} <multi-FASTA> <PWM> [options]"
  opts.separator 'Options:'
  opts.on('--pvalue-cutoff VALUE', 'P-value of site threshold') {|val| pvalue_cutoff = Float(val) }
}.parse!(ARGV)

raise 'Specify existing sequences file'  unless (sequences_filename = ARGV[0]) && File.exist?(sequences_filename)
raise 'Specify existing PWM file'  unless (motif_filename = ARGV[1]) && File.exist?(motif_filename)

threshold = Ape.run_find_threshold(motif_filename, pvalue_cutoff)
occurences = SiteRegion.occurence_in_regions(
  sequences_filename: sequences_filename,
  motif_filename: motif_filename,
  threshold: threshold)

puts occurences.map(&:to_bed_string)
