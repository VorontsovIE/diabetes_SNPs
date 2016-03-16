require_relative 'lib/genome_reader'
require_relative 'lib/genome_region'

# Attention!!! Mitochondrial chromosome will be removed from results
ONE_BASED_INCLUSIVE = GenomeReader::CoordinateSystem::ONE_BASED_INCLUSIVE
ZERO_BASED_EXCLUSIVE = GenomeReader::CoordinateSystem::ZERO_BASED_EXCLUSIVE

GENOME_READER = {
  'human' => GenomeReader::DiskReader.new(
    File.absolute_path('./source_data/genomes/hg19', __dir__),
    chromosome_file_by_name: ->(chr){ "#{chr}.plain" },
    chromosome_name_matcher: /^(?<chromosome>\w+)\.plain$/
  ),
  'mouse' => GenomeReader::DiskReader.new(
    File.absolute_path('./source_data/genomes/mm9', __dir__),
    chromosome_file_by_name: ->(chr){ "#{chr}.plain" },
    chromosome_name_matcher: /^(?<chromosome>\w+)\.plain$/
  )
}


raise 'Specify bed-file'  unless filename = ARGV[0]
raise 'Specify species (human/mouse)'  unless species = ARGV[1]
species = species.downcase

raise 'Species should be human/mouse'  unless ['human', 'mouse'].include? species

GenomeRegion.each_in_file(filename){|region|
  next  if region.chromosome == 'chrM' || region.chromosome == 'chrMT'

  seq = GENOME_READER[species].read_sequence(region.chromosome, ZERO_BASED_EXCLUSIVE, region.from, region.to)
  puts "> #{region.to_joint_string}\n#{seq}"
}
