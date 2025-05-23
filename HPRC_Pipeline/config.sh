#!/bin/bash
## Git Test

## These are the variables that are the same across all of the various scripts in the pipeline. 
## Change necessary locations for program installtions, reference locations & threads available


#The following variables are for the program file paths.
#If the location is ~/.local/ it needs to be written as $HOME/.local/
FASTQC="/usr/bin/fastqc"
STAR="/usr/bin/STAR"
BOWTIE="/usr/bin/bowtie2" #When installed using apt-get install it is located here.
HTSEQ_LOC="/usr/local/bin/htseq-count"
UMI_TOOLS="/usr/local/bin/umi_tools"
CUTADAPT="/usr/bin/cutadapt"
SAMTOOLS="/usr/bin/samtools"
 
#The following variable is for the parent folder that the reference genomes are saved in.
REF_LOC="/mnt/zion/refs"
#The following variable is for the parent folder that projects are saved in.
#SAVE_LOC="/mnt/zion/Destiny_Pipeline_Test"
#The following variable is for the number of threads available on the computer you are using.
THREADS=30
