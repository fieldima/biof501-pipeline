rule all:
    input:
        "hyphy_out/WNV_Genomes_plot.png"

rule concatenate:
    input:
        a = "Viral_Sequence_Data/Reference.fasta",
        b = "Viral_Sequence_Data/{genome}.fasta"
    output:
        "Intermediates/{genome}_fixed.fasta"
    shell:
        "cat {input.a} {input.b} > {output}"

rule preprocess:
    input:
        "Intermediates/{genome}_fixed.fasta"
    output:
        "Intermediates/{genome}_fixed.fasta_nuc.fas",
        "Intermediates/{genome}_fixed.fasta_protein.fas"
    shell:
        "hyphy codon-msa/pre-msa.bf --input {input}"
        
rule msa:
    input: 
        "Intermediates/{genome}_fixed.fasta_protein.fas"
    output:
        "Intermediates/{genome}_fixed_intermediate.msa"
    shell:
        "mafft --auto {input} > {output}"
        
rule postprocess:
    input:
        a = "Intermediates/{genome}_fixed_intermediate.msa",
        b = "Intermediates/{genome}_fixed.fasta_nuc.fas"
    output: 
        "MSA/{genome}_fixed_aligned.msa"
    shell:
        "hyphy codon-msa/post-msa.bf --protein-msa {input.a} --nucleotide-sequences {input.b} --output {output}"
        
rule phylo:
    input:
        "MSA/{genome}_fixed_aligned.msa"
    output:
        "tree/{genome}_fixed_tree"
    shell:
        "fasttree -nt {input} > {output}"
        
rule analysis:
    input:
        msa = "MSA/{genome}_fixed_aligned.msa",
        tree = "tree/{genome}_fixed_tree"
    output:
        "hyphy_out/{genome}_FUBAR"
    shell:
        "hyphy fubar --alignment {input.msa} --tree {input.tree} > {output}"

rule plot:
    input:
        "hyphy_out/{genome}_FUBAR"
    output:
        "hyphy_out/{genome}_plot.png"
    script:
        "scripts/plot_fubar.R"
