GenomeRegion = Struct.new(:chromosome, :from, :to) do
  def self.from_string(str)
    chromosome, from, to = str.chomp.split("\t").first(3)
    self.new(chromosome, from.to_i, to.to_i)
  end

  # chr1:23-45
  def self.from_joint_string(str)
    chromosome, coords = str.split(':')
    from, to = coords.split('-')
    self.new(chromosome, from.to_i, to.to_i)
  end

  def self.each_in_file(filename, &block)
    File.readlines(filename).map{|line| self.from_string(line) }.each(&block)
  end

  def to_interval_set
    IntervalNotation::Syntax::Long.closed_closed(from + 1, to)
  end

  def to_s
    [chromosome, from, to].join("\t")
  end

  def to_joint_string
    "#{chromosome}:#{from}-#{to}"
  end
end
