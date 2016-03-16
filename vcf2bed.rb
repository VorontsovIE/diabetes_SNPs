require_relative 'lib/vcf_info'

raise 'Specify *.vcf file'  unless filename = ARGV[0]
raise "Specified file doesn't exist"  unless File.exist?(filename)

puts VCFInfo.each_in_file(filename).map(&:to_bed_positions)
