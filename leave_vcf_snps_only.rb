require_relative 'lib/vcf_info'

$stdin.each_line do |line|
  puts line  if VCFInfo.from_string(line).snp?
end
