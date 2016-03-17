require 'optparse'

All_SNPs_VCF = 'source_data/AllSNPs.vcf'
flank_length = 25000
species = 'human'

OptionParser.new{|opts|
  opts.on('--flank-length LENGTH', 'Specify flank length to search for SNPs') {|value|
    value = Integer(value)
  }

  opts.on('--species SPECIES', 'Human or mouse') {|value|
    species = value.downcase
    raise 'Specify human or mouse'  unless species
  }

  opts.on('')
}.parse!(ARGV)

genome_size_file = "source_data/genome_sizes/#{species}.genome"
cmd = "ruby vcf2bed.rb | bedtools slop -b #{flank_length} -g #{genome_size_file} | bedtools intersect -a #{All_SNPs_VCF} -b stdin"


if $stdin.tty?
  raise 'Specify input file or put data into input stream'  unless filename = ARGV[0]
  system(cmd, in: filename, out: $stdout)
else
  system(cmd, in: $stdin, out: $stdout)
end
