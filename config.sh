#!/bin/bash
## These are the variables that are the same across all of the various scripts in the pipeline. 
## Change necessary locations for program installations, reference locations & threads available

#The following variables are for the program file paths.
#If the location is ~/.local/ it needs to be written as $HOME/.local/
FASTQC="/bin/fastqc"
STAR="/bin/STAR"
BOWTIE="/bin/bowtie2" #When installed using apt-get install it is located here.
HTSEQ_LOC="htseq-count"
UMI_TOOLS="umi_tools"
CUTADAPT="/bin/cutadapt"
SAMTOOLS="/bin/samtools"


#The following variable is for the number of threads available on the computer you are using.
THREADS=8

#The following variable is for the parent folder that the reference genomes are saved in.
ref_dir="/mnt/matrix/roo/refs"

## The following points to the reference genome information for each species in the pipeline
## and to the reference gtf file for htseq quantification.
## NOTE: If a new species is added here, the option must also be added to the selection in Run_Chapkin_Lab_Pipeline.sh
if [[ "${species_type}" = "1" ]]; then 
	species_ref=GRCh38.p14; 
	Bowtie2_ref=${ref_dir}/GRCh38p14-human/bowtie2/GRCh38p14-human;
	STAR_ref=${ref_dir}/GRCh38p14-human/STAR; 
	HTSeq_ref=${ref_dir}/GRCh38p14-human/gencode.v49.primary_assembly.annotation.gtf;
elif [[ "${species_type}" = "2" ]]; then 
	species_ref=GRCm39; 
	Bowtie2_ref=${ref_dir}/GRCm39-mouse/bowtie2/GRCm39.mouse; 
	STAR_ref=${ref_dir}/GRCm39-mouse/STAR; 
	HTSeq_ref=${ref_dir}/GRCm39-mouse/bowtie2/GRCm39.mouse/GCF_000001635.27_GRCm39_genomic.gtf; 
elif [[ "${species_type}" = "3" ]]; then
	species_ref="Sus crofa 11.1";
	Bowtie2_ref=${ref_dir}/pig/bowtie2/pig; 
	STAR_ref=${ref_dir}/pig/STAR;
	HTSeq_ref=${ref_dir}/pig/Sus_scrofa.Sscrofa11.1.107.gtf; 
elif [[ "${species_type}" = "4" ]]; then
	species_ref="Equus caballus 3.0";
	Bowtie2_ref=${ref_dir}/Equus_caballus_Aug2024/bowtie2/Equus_caballus-horse; 
	STAR_ref=${ref_dir}/Equus_caballus_Aug2024/STAR;
	HTSeq_ref=${ref_dir}/Equus_caballus_Aug2024/GCF_041296265.1_TB-T2T_genomic.gtf; 
else 
	species_ref="GRCr8";
	Bowtie2_ref=${ref_dir}/GRCr8-rat/bowtie2/GRCr8; 
	STAR_ref=${ref_dir}/GRCr8-rat/STAR;
	HTSeq_ref=${ref_dir}/GRCr8-rat/GCF_036323735.1/genomic.gtf; 
fi

## To add a new reference, change the last "else to" to the following line:
# elif [[ "${species_type}" = "5" ]]; then
## The add the following lines:
# else
#	species_ref=new_species; 
#	Bowtie2_ref=${ref_dir}/new_species/bowtie2/new_species; 
#	STAR_ref=${ref_dir}/new_species/STAR;
#	HTSeq_ref=${ref_dir}/new_species/new_species.gtf;

#fi

############################################################
## Variables selected during pipeline execution:
