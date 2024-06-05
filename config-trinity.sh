#!/bin/bash
## Trinity config

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
THREADS=30
