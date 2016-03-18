require_relative 'lib/vcf_info'

$stdin.each_line do |line|
  if line.start_with?('#')
    puts line
  else
    puts line  if VCFInfo.from_string(line).snp?
  end
end
