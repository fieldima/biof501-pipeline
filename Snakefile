rule all:
    input:
        "hyphy_out/WNV_Genomes_aligned.msa.FUBAR.json"

rule concatenate:
    input:
        a = "Viral_Sequence_Data/Reference.fasta",
        b = "Viral_Sequence_Data/{genome}.fasta"
    output:
        "Viral_Sequence_Data/{genome}_fixed.fasta"
    shell:
        "cat {input.a} {input.b} > {output}"

rule preprocess:
    input:
        "Viral_Sequence_Data/{genome}_fixed.fasta"
    output:
        "Viral_Sequence_Data/{genome}_fixed.fasta_nuc.fas",
        "Viral_Sequence_Data/{genome}_fixed.fasta_protein.fas"
    shell:
        "hyphy codon-msa/pre-msa.bf --input {input}"
        
rule msa:
    input: 
        "Viral_Sequence_Data/{genome}_fixed.fasta_protein.fas"
    output:
        "MSA/{genome}_intermediate.msa"
    shell:
        "mafft --auto {input} > {output}"
        
rule postprocess:
    input:
        a = "MSA/{genome}_intermediate.msa",
        b = "Viral_Sequence_Data/{genome}_fixed.fasta_nuc.fas"
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
        "hyphy_out/{genome}_aligned.msa.FUBAR.json"
    shell:
        "hyphy fubar --alignment {input.msa} --tree {input.tree} > {output}"
