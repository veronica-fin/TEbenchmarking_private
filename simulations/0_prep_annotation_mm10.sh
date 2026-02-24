#!/bin/bash

mkdir data_mouse
# add gene and TE annotations

# take gtf TE annotation file and create matching rmsk bed file with chr, start, end, locus name, locus name, strand
cat data_mouse/mm10_GENCODE_rmsk_TE.gtf | awk 'OFS="\t" {if ($3=="exon") {print $1,$4-1,$5,$12,$12,$7}}' | \
    tr -d '";' > data_mouse/mm10_rmsk_wName.bed

# create fasta file from rmsk bed; header = locus name
bedtools getfasta -fi data_mouse/GRCm38.primary_assembly.genome.fa -bed data_mouse/mm10_rmsk_wName.bed \
    -nameOnly > data_mouse/mm10_rmsk_nameOnly.fa

# create gentrome file with both rmsk sequences and primary assembly of the genome
cat data_mouse/rmsk_mm10_nameOnly.fa data_mouse/GRCm38.primary_assembly.genome.fa > data_mouse/gentrome_rmsk_mm10.fa

# create gentrome file with both rmsk sequences, gene transcripts and primary assembly of the genome
cat data_mouse/rmsk_mm10_nameOnly.fa data_mouse/gencode.vM10.transcripts.fa \
    data_mouse/GRCm38.primary_assembly.genome.fa > data_mouse/gentrome_rmsk_mm10_wGenes.fa

# create transcript - gene translation file. In our case it's just the same column, repeated
awk -F "\t" '$3 == "exon" { print $9 }' data_mouse/mm10_GENCODE_rmsk_TE.gtf | tr -d ";\"" | \
    awk '{print $4"\t"$4}' > data_mouse/mm10_GENCODE_rmsk_TE.annotation.tx2gene.tsv

echo "Salmon indexing..."
# salmon indexing
salmon index -t data_mouse/gentrome_rmsk_mm10.fa -i data_mouse/rmsk_mm10.sidx \
    -p 12 -d data_mouse/GRCm38.primary_assembly.genome.chrnames.txt --gencode
echo "Done salmon indexing"
echo ""


# # get chromosome names
# grep ">" data_mouse/GRCm38.primary_assembly.genome.fa | cut -d ">" -f 2 | cut -d " " -f 1 > data_mouse/GRCm38.primary_assembly.genome.chrnames.txt
gunzip data_mouse/gencode.vM10.annotation.gtf.gz
awk -F "\t" '$3 == "transcript" { print $9 }' data_mouse/gencode.vM10.annotation.gtf | \
    tr -d ";\"" | awk '{print $4"\t"$2}' > data_mouse/gencode.vM10.annotation.tx2gene.tsv
cat data_mouse/mm10_GENCODE_rmsk_TE.annotation.tx2gene.tsv \
    data_mouse/gencode.vM10.annotation.tx2gene.tsv > data_mouse/mm10_GENCODE_rmsk_TE_wGene.annotation.tx2gene.tsv

echo "Salmon indexing with genes..."
# salmon indexing
salmon index -t data_mouse/gentrome_rmsk_mm10_wGenes.fa -i data_mouse/rmsk_mm10_wGenes.sidx \
    -p 12 -d data_mouse/GRCm38.primary_assembly.genome.chrnames.txt --gencode
echo "Done salmon indexing with genes"
echo ""