mkdir -p results/ChIP-seq_sequences_GTRD/mouse/

ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/JARID2_MOUSE/ESC/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.ESC.mfa
ruby extract_multifasta.rb 'source_data/ChIP-seq_peaks_GTRD/mouse/JARID2_MOUSE/LF2 (ES)/combined.bed' mouse > results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.LF2.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/JARID2_MOUSE/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.ESC_and_LF2.mfa

ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/NR5A2_MOUSE/ESC/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/NR5A2_MOUSE.ESC.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/NR5A2_MOUSE/Pancreas/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/NR5A2_MOUSE.Pancreas.mfa

ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/BMAL1_MOUSE/Liver/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/BMAL1_MOUSE.Liver.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/CXXC6_MOUSE/ESC/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/CXXC6_MOUSE.ESC.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/E2F1_MOUSE/ESC/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/E2F1_MOUSE.ESC.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/ERR2_MOUSE/ESC/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/ERR2_MOUSE.ESC.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/NFYA_MOUSE/ESC/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/NFYA_MOUSE.ESC.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/NR1D1_MOUSE/Liver/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/NR1D1_MOUSE.Liver.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/SMAD1_MOUSE/ESC/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/SMAD1_MOUSE.ESC.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/TBP_MOUSE/ESC/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/TBP_MOUSE.ESC.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/TBX20_MOUSE/AdultWholeHeart/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/TBX20_MOUSE.AdultWholeHeart.mfa
ruby extract_multifasta.rb source_data/ChIP-seq_peaks_GTRD/mouse/ZN698_MOUSE/ESC/combined.bed mouse > results/ChIP-seq_sequences_GTRD/mouse/ZN698_MOUSE.ESC.mfa

mkdir -p results/mouse_sites_tissue_specific/
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/BMAL1_MOUSE.Liver.mfa source_data/motif_collections/mouse/BMAL1_MOUSE.H10MO.C.pwm > results/mouse_sites_tissue_specific/BMAL1_MOUSE.Liver^BMAL1_MOUSE.H10MO.C.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/E2F1_MOUSE.ESC.mfa source_data/motif_collections/mouse/E2F1_MOUSE.H10MO.A.pwm > results/mouse_sites_tissue_specific/E2F1_MOUSE.ESC^E2F1_MOUSE.H10MO.A.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/ERR2_MOUSE.ESC.mfa source_data/motif_collections/mouse/ERR2_MOUSE.H10MO.B.pwm > results/mouse_sites_tissue_specific/ERR2_MOUSE.ESC^ERR2_MOUSE.H10MO.B.txt

ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/NR5A2_MOUSE.ESC.mfa source_data/motif_collections/mouse/NR5A2_MOUSE.H10MO.A.pwm > results/mouse_sites_tissue_specific/NR5A2_MOUSE.ESC^NR5A2_MOUSE.H10MO.A.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/NR5A2_MOUSE.Pancreas.mfa source_data/motif_collections/mouse/NR5A2_MOUSE.H10MO.A.pwm > results/mouse_sites_tissue_specific/NR5A2_MOUSE.Pancreas^NR5A2_MOUSE.H10MO.A.txt

ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/NR1D1_MOUSE.Liver.mfa source_data/motif_collections/mouse/NR1D1_MOUSE.H10MO.D.pwm > results/mouse_sites_tissue_specific/NR1D1_MOUSE.Liver^NR1D1_MOUSE.H10MO.D.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/SMAD1_MOUSE.ESC.mfa source_data/motif_collections/mouse/SMAD1_MOUSE.H10MO.D.pwm > results/mouse_sites_tissue_specific/SMAD1_MOUSE.ESC^SMAD1_MOUSE.H10MO.D.txt


ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/TBP_MOUSE.ESC.mfa source_data/motif_collections/mouse/TBP_MOUSE.H10MO.C.pwm > results/mouse_sites_tissue_specific/TBP_MOUSE.ESC^TBP_MOUSE.H10MO.C.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/TBX20_MOUSE.AdultWholeHeart.mfa source_data/motif_collections/mouse/TBX20_MOUSE.H10MO.C.pwm > results/mouse_sites_tissue_specific/TBX20_MOUSE.AdultWholeHeart^TBX20_MOUSE.H10MO.C.txt

ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/NFYA_MOUSE.ESC.mfa source_data/motif_collections/mouse/NFYA_MOUSE.H10MO.D.pwm > results/mouse_sites_tissue_specific/NFYA_MOUSE.ESC^NFYA_MOUSE.H10MO.D.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/NFYA_MOUSE.ESC.mfa source_data/motif_collections/mouse/NFYA_MOUSE.H10MO.S.pwm > results/mouse_sites_tissue_specific/NFYA_MOUSE.ESC^NFYA_MOUSE.H10MO.S.txt

# exact motif unavailable, motif of similar TF used
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/CXXC6_MOUSE.ESC.mfa source_data/motif_collections/mouse/CXXC1_MOUSE.H10MO.D.pwm > results/mouse_sites_tissue_specific/CXXC6_MOUSE.ESC^CXXC1_MOUSE.H10MO.D.txt

ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.ESC.mfa source_data/motif_collections/mouse/ARI5B_MOUSE.H10MO.C.pwm > results/mouse_sites_tissue_specific/JARID2_MOUSE.ESC^ARI5B_MOUSE.H10MO.C.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.ESC.mfa source_data/motif_collections/mouse/ARI3A_MOUSE.H10MO.D.pwm > results/mouse_sites_tissue_specific/JARID2_MOUSE.ESC^ARI3A_MOUSE.H10MO.D.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.ESC.mfa source_data/motif_collections/mouse/ARI3A_MOUSE.H10MO.S.pwm > results/mouse_sites_tissue_specific/JARID2_MOUSE.ESC^ARI3A_MOUSE.H10MO.S.txt

ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.LF2.mfa source_data/motif_collections/mouse/ARI5B_MOUSE.H10MO.C.pwm > results/mouse_sites_tissue_specific/JARID2_MOUSE.LF2^ARI5B_MOUSE.H10MO.C.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.LF2.mfa source_data/motif_collections/mouse/ARI3A_MOUSE.H10MO.D.pwm > results/mouse_sites_tissue_specific/JARID2_MOUSE.LF2^ARI3A_MOUSE.H10MO.D.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.LF2.mfa source_data/motif_collections/mouse/ARI3A_MOUSE.H10MO.S.pwm > results/mouse_sites_tissue_specific/JARID2_MOUSE.LF2^ARI3A_MOUSE.H10MO.S.txt

ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.ESC_and_LF2.mfa source_data/motif_collections/mouse/ARI5B_MOUSE.H10MO.C.pwm > results/mouse_sites_tissue_specific/JARID2_MOUSE.ESC_and_LF2^ARI5B_MOUSE.H10MO.C.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.ESC_and_LF2.mfa source_data/motif_collections/mouse/ARI3A_MOUSE.H10MO.D.pwm > results/mouse_sites_tissue_specific/JARID2_MOUSE.ESC_and_LF2^ARI3A_MOUSE.H10MO.D.txt
ruby site_occurences.rb results/ChIP-seq_sequences_GTRD/mouse/JARID2_MOUSE.ESC_and_LF2.mfa source_data/motif_collections/mouse/ARI3A_MOUSE.H10MO.S.pwm > results/mouse_sites_tissue_specific/JARID2_MOUSE.ESC_and_LF2^ARI3A_MOUSE.H10MO.S.txt
