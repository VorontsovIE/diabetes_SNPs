VCFInfo = Struct.new(:chromosome, :position, :reference_allele, :non_reference_alleles, :variant_name) do
  def self.from_string(str)
    chromosome, position, variant_name, reference_allele, non_reference_alleles, *rest = str.chomp.split("\t")
    self.new(chromosome, position.to_i, reference_allele.upcase, non_reference_alleles.upcase.split(','), variant_name)
  end

  def self.each_in_file(filename, &block)
    File.open(filename){|f|
      self.each_in_stream(f, &block)
    }
  end

  def self.each_in_stream(stream, &block)
    stream.each_line.reject{|line| line.start_with?('#') }.map{|line| self.from_string(line) }.each(&block)
  end

  def self.snps_in_file(filename, &block)
    self.each_in_file(filename).select(&:snp?).each(&block)
  end

  def self.snps_in_stream(stream, &block)
    self.each_in_stream(stream).select(&:snp?).each(&block)
  end

  def snp?
    [reference_allele, *non_reference_alleles].all?{|allele| allele.length == 1 && ['A','C','G','T'].include?(allele) }
  end

  def to_s
    [chromosome, position, variant_name, reference_allele, non_reference_alleles.join(',')].join("\t")
  end

  def to_bed_positions
    [chromosome, position - 1, position,  variant_name].join("\t")
  end
end
