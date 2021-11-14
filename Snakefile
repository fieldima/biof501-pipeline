rule all:
    input:
        "MSA/WNV_Genomes_aligned.msa.FEL.json"

rule preprocess:
    input:
        "Viral_Sequence_Data/{genome}.fasta"
    output:
        "Viral_Sequence_Data/{genome}.fasta_nuc.fas",
        "Viral_Sequence_Data/{genome}.fasta_protein.fas"
    shell:
        "hyphy codon-msa/pre-msa.bf --input {input}"
        
rule msa:
    input: 
        "Viral_Sequence_Data/{genome}.fasta_protein.fas"
    output:
        "MSA/{genome}_intermediate.msa"
    shell:
        "mafft --auto {input} > {output}"
        
rule postprocess:
    input:
        a = "MSA/{genome}_intermediate.msa",
        b = "Viral_Sequence_Data/{genome}.fasta_nuc.fas"
    output: 
        "MSA/{genome}_aligned.msa"
    shell:
        "hyphy codon-msa/post-msa.bf --protein-msa {input.a} --nucleotide-sequences {input.b} --output {output}"
        
rule phylo:
    input:
        "MSA/{genome}_aligned.msa"
    output:
        "tree/{genome}_tree"
    shell:
        "fasttree -nt {input} > {output}"
        
rule analysis:
    input:
        msa = "MSA/{genome}_aligned.msa",
        tree = "tree/{genome}_tree"
    output:
        "MSA/{genome}_aligned.msa.FEL.json"
    shell:
        "hyphy fel --alignment {input.msa} --tree {input.tree}"
