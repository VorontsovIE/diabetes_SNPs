VCFInfo = Struct.new(:chromosome, :position, :reference_allele, :non_reference_alleles, :variant_name) do
  def self.from_string(str)
    chromosome, position, variant_name, reference_allele, non_reference_alleles, *rest = str.chomp.split("\t")
    self.new(chromosome, position.to_i, reference_allele, non_reference_alleles.split(','), variant_name)
  end
  def self.each_in_file(filename, &block)
    File.readlines(filename).reject{|line| line.start_with?('#') }.map{|line| self.from_string(line) }.each(&block)
  end
  def self.each_in_stream(stream, &block)
    stream.each_line.reject{|line| line.start_with?('#') }.map{|line| self.from_string(line) }.each(&block)
  end
  def to_s
    [chromosome, position, variant_name, reference_allele, non_reference_alleles.join(',')].join("\t")
  end

  def to_bed_positions
    [chromosome, position - 1, position,  variant_name].join("\t")
  end
end
