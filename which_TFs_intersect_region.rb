require 'open3'

region = "chr1\t160616924\t160616969"

Dir.glob("results/panchipseq_peaks/*.bed").each{|fn|
  res = Open3.popen2("bedtools intersect -a #{fn} -b stdin"){|io_w, io_r|
    io_w.puts(region)
    io_w.close
    io_r.read
  }
  puts File.basename(fn, '.bed')  unless res.empty?
}
