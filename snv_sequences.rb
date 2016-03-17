require 'optparse'
require_relative 'experiment_configuration'
require_relative 'lib/vcf_info'

species = 'human'
add_prefix_to_chromosome_name = true
skip_nonexistent_chromosomes = true
reject_multiallele_snvs = true
flank_length = 50

OptionParser.new{|opts|
  opts.on('--species SPECIES', 'Species to load genome from (human or mouse). Default - human.') {|value|
    species = value.downcase
    raise 'Species can be either human or mouse'  unless ['human', 'mouse'].include?(species)
  }
  opts.on('--[no-]chromosome-prefix', 'Add prefix to chromosome (default = true)') {|value|
    add_prefix_to_chromosome_name = value
  }
  opts.on('--[no-]skip-nonexistent-chromosomes', 'Ignore SNV or raise error if SNV is located on a chromosome with nonexistent name (e.g. MT instead of M). Skip(true) by default.') {|value|
    skip_nonexistent_chromosomes = value
  }
  opts.on('--flank-length LENGTH', 'Specify length of flanks (50bp by default)') {|value|
    flank_length = Integer(value)
  }
  opts.on('--[no-]reject-multiallele-snvs', 'Keep only di-allele SNVs (true, default) or any SNVs'){|value|
    reject_multiallele_snvs = value
  }
}.parse!(ARGV)

raise 'Specify vcf-file with SNVs'  unless filename = ARGV[0]

$genome_reader = GENOME_READER[species]

nonexistent_chromosome_checker = ->(info){
  chromosome_name = add_prefix_to_chromosome_name ? "chr#{info.chromosome}" : info.chromosome
  !$genome_reader.chromosome_exist?(chromosome_name)
}

snps = VCFInfo.snps_in_file(filename).to_a

if reject_multiallele_snvs
  snps.reject!{|info|
    info.non_reference_alleles.size > 1
  }
end


if skip_nonexistent_chromosomes
  snps.reject!(&nonexistent_chromosome_checker)
else
  wrong_snp = snps.detect(&nonexistent_chromosome_checker)
  raise "SNV on non-existent chromosome:\n`#{wrong_snp}`"  if wrong_snp
end

snp_sequences = snps.flat_map{|info|
  chromosome_name = add_prefix_to_chromosome_name ? "chr#{info.chromosome}" : info.chromosome
  seq = $genome_reader.read_sequence(chromosome_name, ONE_BASED_INCLUSIVE,
                                    info.position - flank_length,
                                    info.position + flank_length).upcase

  raise 'Bad reference allele' unless seq[flank_length] == info.reference_allele.upcase

  left_flank = seq[0,flank_length]
  right_flank = seq[flank_length + 1, flank_length]
  mid_substitution = [info.reference_allele, *info.non_reference_alleles].join('/')
  seq_w_snv = "#{left_flank}[#{mid_substitution}]#{right_flank}"

  ["#{info.variant_name}@#{chromosome_name}:#{info.position}", seq_w_snv].join("\t")
}

puts snp_sequences.join("\n")
