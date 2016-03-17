require_relative 'lib/vcf_info'

if $stdin.tty?
  raise 'Specify *.vcf file'  unless filename = ARGV[0]
  raise "Specified file doesn't exist"  unless File.exist?(filename)

  puts VCFInfo.each_in_file(filename).select(&:snp?).map(&:to_bed_positions)
else
  puts VCFInfo.each_in_stream($stdin).select(&:snp?).map(&:to_bed_positions)
end
