# GTRD peaks ID Cell Line Treatment Antibody  PubMed  GEO UniProt
# PEAKS000490 H1 embryonic stem cells   NANOG 19829295  GSE18292,GSM456571,GSM456572  NANOG_HUMAN
ChIPSeqDataset = Struct.new(:gtrd_peaks_id, :cell_line, :treatment, :antibody, :pubmed, :geo, :uniprot) do
  def self.from_string(str)
    gtrd_peaks_id, cell_line, treatment, antibody, pubmed, geo, uniprot = str.chomp.split("\t", 7)
    self.new(gtrd_peaks_id, cell_line, treatment, antibody, pubmed, geo, uniprot)
  end

  def self.each_in_file(filename, &block)
    File.readlines(filename).drop(1).map{|line| self.from_string(line) }.each(&block)
  end
end
