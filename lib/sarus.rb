module Sarus
  Result = Struct.new(:score, :offset, :strand, :sequence_name) do
    def self.from_string(str, sequence_name)
      score, offset, strand = str.chomp.split("\t")
      self.new(score.to_f, offset.to_i, strand.to_sym, sequence_name)
    end

    def self.each_in_stream(stream, &block)
      stream.each_line.map(&:chomp).slice_before{|line|
        line.start_with?('>')
      }.map{|header, *sarus_positions|
        [header, sarus_positions] # sarus_positions unsplatted
      }.reject{|header, sarus_positions|
        sarus_positions.empty?
      }.map{|header, sarus_positions|
        [header[1..-1].strip, sarus_positions]
      }.flat_map{|sequence_name, sarus_positions|
        sarus_positions.map{|line|
          self.from_string(line, sequence_name)
        }
      }.each(&block)
    end
  end

  def self.run_occurence_search(sequences_filename:, motif_filename:, threshold:)
    IO.popen(['java', '-jar', 'sarus.jar', sequences_filename, motif_filename, threshold.to_s]){|io|
      Sarus::Result.each_in_stream(io.read)
    }
  end
end
