require 'bioinform'
require_relative 'sarus'
require_relative 'genome_region'

def revcomp(seq)
  seq.tr('acgtACGT','tgcaTGCA').reverse
end

def read_multifasta(filename)
  sequence_pairs = File.readlines(filename).slice_before{|line|
    line.start_with?('>')
  }.map{|header, *sequences|
    [header[1..-1].strip, sequences.map(&:chomp).join]
  }
  non_uniq_keys = sequence_pairs.map(&:first).each_with_object(Hash.new(0)){|k, hsh| hsh[k] += 1}.select{|k,v| v > 1}.map(&:first)
  $stderr.puts "Non-unique keys of sequences: #{non_uniq_keys.join(', ')}"  unless non_uniq_keys.empty?
  sequence_pairs.to_h
end

SiteRegion = Struct.new(:region, :strand, :score, :oriented_sequence) do
  def self.from_string(str)
    region, strand, score, sequence = str.chomp.split("\t")
    self.new(GenomeRegion.from_joint_string(region), strand.to_sym, score.to_f, sequence)
  end
  def self.each_in_file(filename, &block)
    File.readlines(filename).map{|line| self.from_string(line) }.each(&block)
  end
  def to_s
    [region.to_joint_string, strand, score, oriented_sequence].join("\t")
  end

  def self.occurence_in_regions(sequences_filename:, motif_filename:, threshold:)
    motif_length = Bioinform::MotifModel::PWM.from_file(motif_filename).length

    sequences = read_multifasta(sequences_filename)
    Sarus.run_occurence_search(sequences_filename: sequences_filename,
                              motif_filename: motif_filename,
                              threshold: threshold).map{|occurence|
      region = GenomeRegion.from_joint_string(occurence.sequence_name)
      # from: 0-based; to: 1-based
      site_region = GenomeRegion.new(region.chromosome,
                                    region.from + occurence.offset,
                                    region.from + occurence.offset + motif_length)
      seq = sequences[occurence.sequence_name][occurence.offset, motif_length]
      SiteRegion.new(site_region, occurence.strand, occurence.score, (occurence.strand == :+) ? seq : revcomp(seq))
    }
  end

  def self.from_file_by_chromosome(filename)
    self.each_in_file(filename)
      .map(&:region)
      .group_by(&:chromosome).map{|chromosome, regions|
        [ chromosome, IntervalNotation::Operations.union(regions.map(&:to_interval_set)) ]
      }.to_h
  end
end
