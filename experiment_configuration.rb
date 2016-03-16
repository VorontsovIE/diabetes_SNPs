require_relative 'lib/genome_reader'

ONE_BASED_INCLUSIVE = GenomeReader::CoordinateSystem::ONE_BASED_INCLUSIVE
ZERO_BASED_EXCLUSIVE = GenomeReader::CoordinateSystem::ZERO_BASED_EXCLUSIVE

GENOME_READER = {
  'human' => GenomeReader::DiskReader.new(
    './source_data/genomes/hg19',
    chromosome_file_by_name: ->(chr){ "#{chr}.plain" },
    chromosome_name_matcher: /^(?<chromosome>\w+)\.plain$/
  ),
  'mouse' => GenomeReader::DiskReader.new(
    './source_data/genomes/mm9',
    chromosome_file_by_name: ->(chr){ "#{chr}.plain" },
    chromosome_name_matcher: /^(?<chromosome>\w+)\.plain$/
  )
}

PVALUE_CUTOFF = 0.001
FLANK_LENGTH = 50 # size of SNP flanks to extract, not additional flanks
