#!/bin/bash
#Run pre-processing of sequences
CODDIR=/home/fieldima/biof501-pipeline/codon-msa

hyphy $CODDIR/pre-msa.bf --input namerica_only.fasta
echo Pre-processing finished.

mafft namerica_only.fasta_protein.fas > namerica_only.msa

hyphy $CODDIR/post-msa.bf --protein-msa namerica_only.msa --nucleotide-sequences namerica_only.fasta_nuc.fas --output codon-aware.msa
