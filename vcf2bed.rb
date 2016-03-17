require_relative 'lib/vcf_info'

if $stdin.tty?
  raise 'Specify *.vcf file'  unless filename = ARGV[0]
  raise "Specified file doesn't exist"  unless File.exist?(filename)

  puts VCFInfo.snps_in_file(filename).map(&:to_bed_positions)
else
  puts VCFInfo.snps_in_stream($stdin).map(&:to_bed_positions)
end
