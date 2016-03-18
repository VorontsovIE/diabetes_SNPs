all_SNPs_VCF = 'source_data/AllSNPs.vcf'

def filter_SNPs(filename, all_SNPs_VCF)
  awk_cmd = 'BEGIN {print "^#"}; {print "\\\\b"$1"\\\\b"}'
  %x{ cat '#{filename}' | awk '#{awk_cmd}' | egrep  -f - #{all_SNPs_VCF} }
end

raise 'Specify file with SNP names (they should be in first column)'  unless filename = ARGV[0]
all_SNPs_VCF = ARGV[1]  if ARGV[1]

puts filter_SNPs(filename, all_SNPs_VCF)
