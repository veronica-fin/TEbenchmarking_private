#!/bin/bash

R1path=".../fastqs/LIF/LIF_R1.fastq.gz"
R2path=".../fastqs/LIF/LIF_R2.fastq.gz"

echo "Running Alevin..."
# run alevin on fastq files from real data, using the files created in data_mouse
salmon alevin -l ISR -i data_mouse/rmsk_mm10.sidx/ \
    -1 $R1path \
    -2 $R2path \
    -o alevin_out_mm10_RA_TE -p 36 --tgMap data_mouse/mm10_GENCODE_rmsk_TE.annotation.tx2gene.tsv \
    --chromium --dumpFeatures --dumpBfh
echo ""
echo "Done with Alevin"
echo ""

echo "Minnow index..."
src/minnow index -r data_mouse/mm10_rmsk_nameOnly.fa -k 101 -f 20 --tmpdir tmp -p 24 -o minnow_index_mm10_RA_TE
echo ""
echo "Done with Minnow index"
echo ""


# get list of loci passing filters
grep ">" minnow_index_mm10_RA_TE/ref_k101_fixed.fa | sed 's/^>//' > TEs_passing_filter_RA_TE.txt

echo "Minnow estimate..."
src/minnow estimate \
    -o minnow_estimate_mm10_RA_TE  \
    -r data_mouse/mm10_rmsk_nameOnly.fa \
    --g2t data_mouse/mm10_GENCODE_rmsk_TE.annotation.tx2gene.tsv \
    --bfh alevin_out_mm_RA_TE/alevin/bfh.txt
echo ""
echo "Done with Minnow estimate"
echo ""


# Simulation with genes
echo "Simulation with genes"
echo "Running Alevin..."
# run alevin on fastq files from real data, using the files created in data_mouse
salmon alevin -l ISR -i data_mouse/rmsk_mm10_wGenes.sidx/ \
    -1 $R1path  \
    -2 $R2path  \
    -o alevin_out_mm10_RA_TEsNgenes -p 36 --tgMap data_mouse/mm10_GENCODE_rmsk_TE_wGene.annotation.tx2gene.tsv \
    --chromium --dumpFeatures --dumpBfh
echo ""
echo "Done with Alevin"
echo ""

cat data_mouse/mm10_rmsk_nameOnly.fa data_mouse/gencode.vM10.transcripts.fa > data_mouse/TEsNgenes_transcripts.fa

echo "Minnow index..."
src/minnow index -r data_mouse/TEsNgenes_transcripts.fa -k 101 -f 20 --tmpdir tmp \
    -p 24 -o minnow_index_mm10_RA_TEsNgenes
echo ""
echo "Done with Minnow index"
echo ""

# get list of loci passing filters
grep ">" minnow_index_mm10_RA_TEsNgenes/ref_k101_fixed.fa | \
    sed 's/^>//' > minnow_index_mm10_RA_TEsNgenes/TEs_passing_filter_RA_TE.txt



sed -e '/^>/ s/|.*//' data_mouse/gencode.vM10.transcripts.fa > data_mouse/gencode.vM10.transcripts.cleanHeader.fa
cat data_mouse/mm10_rmsk_nameOnly.fa \
    data_mouse/gencode.vM10.transcripts.cleanHeader.fa > data_mouse/TEsNgenes_transcripts_cleanHeader.fa

echo "Minnow estimate..."
src/minnow estimate \
    -o minnow_estimate_mm10_RA_TEsNgenes  \
    -r data_mouse/TEsNgenes_transcripts_cleanHeader.fa \
    --g2t data_mouse/mm10_GENCODE_rmsk_TE_wGene.annotation.tx2gene.tsv \
    --bfh alevin_out_mm10_RA_TEsNgenes/alevin/bfh.txt
echo ""
echo "Done with Minnow estimate"
echo ""