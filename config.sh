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

#The following variable is for the parent folder that the reference genomes are saved in.
REF_LOC="/mnt/matrix/roo/refs"

#The following variable is for the number of threads available on the computer you are using.
THREADS=8

if [[ "${species_type}" = "1" ]]; then 
	species_location="${REF_LOC}/GRCh38p14-human"; species_ref="GRCh38.p14"; 
elif [[ "${species_type}" = "2" ]]; then 
	species_location=${REF_LOC}/GRCm39-mouse; species_ref="GRCm39";
elif [[ "${species_type}" = "3" ]]; then
	species_location=${REF_LOC}/pig; species_ref="Sus crofa 11.1";
elif [[ "${species_type}" = "4" ]]; then
	species_location=${REF_LOC}/Equus_caballus_Aug2024; species_ref="Equus caballus 3.0";
elif [[ "${species_type}" = "5" ]]; then 
	species_location=${REF_LOC}/GRCr-8-rat; species_ref="GRCr8";
else
fi
############################################################
## Variables selected during pipeline execution: