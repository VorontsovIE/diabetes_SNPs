require 'tempfile'
require 'bioinform'
require 'interval_notation'
require_relative 'experiment_configuration'
require_relative 'lib/genome_reader'
require_relative 'lib/ape_find_threshold'
require_relative 'lib/perfectosape/SNPScanRunner'
require_relative 'lib/perfectosape/SNPScanResults'
require_relative 'lib/perfectosape/Hocomoco10Results'

require_relative 'lib/chipseq_dataset'
require_relative 'lib/vcf_info'

require_relative 'lib/genome_region'
require_relative 'lib/site_regions'


def with_temp_file(filename, &block)
  temp_file = Tempfile.new(filename)
  yield temp_file
ensure
  temp_file.close
  temp_file.unlink
end

def merge_bed_files(files, output_file)
  all_regions = files.flat_map{|filename|
    GenomeRegion.each_in_file(filename).to_a
  }.reject{|region|
    region.chromosome == 'chrMT' || region.chromosome == 'chrM'
  }

  with_temp_file('joined.bed') do |joined_file|
    joined_file.write(all_regions.map(&:to_s).join("\n"))
    joined_file.close

    with_temp_file('sorted.bed') do |sorted_file|
      sorted_file.close
      system 'bedtools', 'sort', '-i', joined_file.path, out: sorted_file.path
      system 'bedtools', 'merge', '-i', sorted_file.path, out: output_file
    end
  end
end

# (method has duplicate in `count_affected_sites.rb`)
# Hocomoco10 expected
def all_sites_in_file(filename, motif_collection:,
                                precalulated_thresholds:,
                                additional_options: [])
  Ape.run_SNPScan(snvs_file: filename,
                  motif_collection: motif_collection,
                  precalulated_thresholds: precalulated_thresholds,
                  fold_change_cutoff: 1,
                  pvalue_cutoff: PVALUE_CUTOFF,
                  additional_options: additional_options) do |pipe|
    PerfectosAPE::Hocomoco10Result.each_in_stream(pipe).to_a
  end
end

directory 'results/chipseq_peaks/'
directory 'results/panchipseq_peaks/'
directory 'results/sequences/'
directory 'results/confident_sites/'
directory 'source_data/snp_sequences/'
directory 'results/affected_sites/'
directory 'results/affected_sites_adipocytes/'
directory 'results/affected_sites_pancreas/'
directory 'results/accessible_sites/'
directory 'source_data/genome_sizes/'

desc 'Copy and rename ChIP-Seq peaks for good datasets'
task 'normalize_peak_names' => ['results/chipseq_peaks/'] do
  ChIPSeqDataset.each_in_file('source_data/good_peaks.tsv').each{|dataset|
    uniprot_folder = "results/chipseq_peaks/#{dataset.uniprot}"
    mkdir_p uniprot_folder unless Dir.exist?(uniprot_folder)
    cp "source_data/ChIP-seq_peaks/#{dataset.gtrd_peaks_id}.interval", "#{uniprot_folder}/#{dataset.uniprot}^#{dataset.gtrd_peaks_id}.interval"
  }
end

desc 'Generate pan-ChIP-Seq'
task 'panChIPSeq'  => ['results/panchipseq_peaks/'] do
  Dir.glob('results/chipseq_peaks/*').each{|uniprot_folder|
    uniprot_id = File.basename(uniprot_folder)
    merge_bed_files(Dir.glob(File.join(uniprot_folder, '*.interval')), "results/panchipseq_peaks/#{uniprot_id}.bed")
  }
end

desc 'Extract peak sequences for pan-ChIP-Seq data'
task 'extract_peak_sequences' => ['results/sequences/'] do
  Dir.glob('results/panchipseq_peaks/*.bed').each{|filename|
    uniprot = File.basename(filename,'.bed')
    species = uniprot.split('_').last.downcase
    system 'ruby', 'extract_multifasta.rb',
            filename, species,
            out: "results/sequences/#{uniprot}.mfa"
  }

  system 'ruby', 'extract_multifasta.rb',
          'source_data/chromatin_accesibility/adipocytes/combined.bed', 'human',
          out: "results/accessible_sequences/adipocytes_human.mfa"
end

desc 'Calculate positions of sites'
task 'site_positions' => ['results/confident_sites/', 'results/accessible_sites/'] do
  Dir.glob('source_data/motif_collections/*/*.pwm').each do |motif_filename|
    motif_name = File.basename(motif_filename, '.pwm')
    # uniprot = motif_name.split('.').first
    # sequences_filename = "results/sequences/#{uniprot}.mfa"
    sequences_filename = "results/accessible_sequences/adipocytes_human.mfa"
    next  unless File.exist?(sequences_filename)

    system('ruby', 'site_occurences.rb',
          sequences_filename, motif_filename,
          '--pvalue-cutoff', PVALUE_CUTOFF.to_s,
          out: "results/accessible_sites/#{motif_name}.txt")
          # out: "results/confident_sites/#{motif_name}.txt")
  end
end

desc 'Extract SNP sequences'
task 'extract_SNP_sequences' do
  output_folder = 'results/snp_sequences/'
  mkdir_p output_folder  unless Dir.exist?(output_folder)
  Dir.glob('results/snp_infos*/*.vcf').each do |filename|
    basename = File.basename(filename,'.vcf')
    system 'ruby', 'snv_sequences.rb', filename,
            '--species', 'human',
            '--chromosome-prefix',
            '--skip-nonexistent-chromosomes',
            '--reject-multiallele-snvs',
            '--flank-length', FLANK_LENGTH.to_s,
            out: File.join(output_folder, "#{basename}.txt")
  end
end

desc 'Find affected sites'
task 'affected_sites' => ['results/affected_sites/', 'results/affected_sites_adipocytes/', 'results/affected_sites_pancreas/'] do
  Dir.glob('results/snp_sequences/*').each do |snp_sequences_filename|
    basename = File.basename(snp_sequences_filename)

    all_affected_sites = all_sites_in_file(
      snp_sequences_filename,
      motif_collection: 'source_data/motif_collections/human/',
      precalulated_thresholds: 'source_data/motif_thresholds/human/'
    ).group_by(&:motif_name)

    # all_affected_sites.default_proc = ->(h,k){ h[k] = [] }

    File.open("results/affected_sites_adipocytes/#{basename}", 'w') do |fw|
    # File.open("results/affected_sites/#{basename}", 'w') do |fw|
      Dir.glob("results/accessible_sites/*_HUMAN.*.txt").each do |confident_sites_filename|
      # Dir.glob("results/confident_sites/*_HUMAN.*.txt").each do |confident_sites_filename|
        motif_name = File.basename(confident_sites_filename, '.txt').to_sym
        next  unless all_affected_sites.has_key?(motif_name)
        confident_regions = SiteRegion.from_file_by_chromosome(confident_sites_filename)

        all_affected_sites[motif_name].select{|site|
          site.disrupted?(fold_change_cutoff: 4) || site.emerged?(fold_change_cutoff: 4)
        }.select{|site|
          site.has_site_on_any_allele?(pvalue_cutoff: 0.0005)
        }.select{|site|
          variant_id, genome_pos = site.variant_id.split('@')
          chromosome, pos = genome_pos.split(':')
          pos = pos.to_i
          confident_regions[chromosome].include_position?(pos)
        }.each{|site|
          fw.puts site
        }
        fw.flush
      end
    end
  end
end


desc 'Count affected sites (not taking ChIP-Seq into account)'
task 'affected_sites_wo_chipseq' do
  output_folder = 'results/affected_sites/'
  mkdir_p(output_folder)  unless Dir.exist?(output_folder)

  Dir.glob('results/snp_sequences/*').each do |filename|
    basename = File.basename(filename)
    system('ruby', 'count_affected_sites.rb', filename,
                    '--fold-change-direction', 'any',
                    '--fold-change-cutoff', 4.to_s,
                    '--pvalue-cutoff', PVALUE_CUTOFF.to_s,
                    out: File.join(output_folder, basename))
  end
end

desc 'Count all sites (not taking ChIP-Seq into account)'
task 'nonaffected_sites_wo_chipseq' do
  output_folder = 'results/affected_sites/'
  mkdir_p(output_folder)  unless Dir.exist?(output_folder)

  Dir.glob('results/snp_sequences/*').each do |filename|
    basename = File.basename(filename)
    system('ruby', 'count_affected_sites.rb', filename,
                    '--no-filter-by-fold-change',
                    '--pvalue-cutoff', PVALUE_CUTOFF.to_s,
                    out: File.join(output_folder, basename))
  end
end


desc 'Create auxiliary .genome files'
task 'create_genome_files' => 'source_data/genome_sizes/' do
  GENOME_READER.each do |species, genome_reader|
    File.open("source_data/genome_sizes/#{species}.genome", 'w') do |fw|
      genome_reader.chromosome_names.sort.each{|chr|
        fw.puts [chr, File.size(genome_reader.chromosome_filename(chr))].join("\t")
      }
    end
  end
end

desc 'Convert vcf files into bed files with SNP positions'
task 'snp_positions_2bed' do
  Dir.glob('source_data/snp_infos/*.vcf') do |filename|
    bed_filename = File.join('source_data/snp_infos/', File.basename(filename,'.vcf') + '.bed')
    File.write bed_filename, VCFInfo.each_in_file(filename).select(&:snp?).map(&:to_bed_positions).join("\n")
  end
end

desc 'Extract VCF infos'
task 'extract_vcf_infos' do
  output_folder = 'results/snp_infos/'
  mkdir_p(output_folder)  unless Dir.exist?(output_folder)
  Dir.glob('source_data/snps/*.tsv') do |filename|
    basename = File.basename(filename, '.tsv')
    output_filename = File.join(output_folder, "#{basename}.vcf")
    system 'ruby', 'filter_SNPs.rb', filename, out: output_filename
  end
end

desc 'Extract nearby SNPs'
task 'extract_nearby_snps' do
  output_folder = 'results/snp_infos_extended'
  mkdir_p output_folder  unless Dir.exist?(output_folder)
  Dir.glob('results/snp_infos/*.vcf') do |filename|
    basename = File.basename(filename, '.vcf')
    output_filename = File.join(output_folder, "#{basename}_25k.vcf")
    system 'ruby', 'extract_nearby_snps.rb', filename,
                  '--flank-length', 25000.to_s,
                  '--species', 'human',
                  out: output_filename
  end
end

desc 'Make all'
task 'make_all' do
  Rake::Task['normalize_peak_names'].invoke
  Rake::Task['panChIPSeq'].invoke
  Rake::Task['extract_peak_sequences'].invoke
  Rake::Task['site_positions'].invoke

  Rake::Task['extract_vcf_infos'].invoke
  Rake::Task['extract_nearby_snps'].invoke
  Rake::Task['extract_SNP_sequences'].invoke
  Rake::Task['affected_sites'].invoke
end

# cat results/panchipseq_peaks/*_MOUSE.bed | bedtools slop -b 50 -g source_data/genome_sizes/mouse.genome | bedtools sort | bedtools merge > results/panchipseq_peaks_mouse.bed
# cat results/panchipseq_peaks/*_HUMAN.bed | bedtools slop -b 50 -g source_data/genome_sizes/human.genome | bedtools sort | bedtools merge > results/panchipseq_peaks_human.bed
# bedtools flank -i source_data/knownGene.txt -g source_data/genome_sizes/human.genome -l 5000 -r 500 -s > results/human_promoters.bed
# bedtools intersect -a results/human_promoters.bed -b results/panchipseq_peaks_human.bed > results/human_regulatory_promoter.bed

# bedtools intersect -a source_data/chromatine_accesibility/adipocytes/combined.bed -b source_data/snp_infos/t2d_snps_chr.vcf | awk '{print $1":"$2}' | grep -f - source_data/snp_sequences/t2d_snps.txt

