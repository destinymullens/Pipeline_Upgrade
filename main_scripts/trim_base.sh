#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
config_dir="$SAVE_LOC/$project_name/tmp"
project_name=$(cat $config_dir/project_name.txt)
SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)
concat_response=$(cat $config_dir/concat_response.txt)
concat_length=$(cat $config_dir/concat_response.txt)
trim_num=$(cat $config_dir/trim_num.txt)
data_type=$(cat $config_dir/data_type.txt)
strand_num=$(cat $config_dir/strand_num.txt)
file_location=$(cat $config_dir/file_location.txt)
qc_dir_in=$(cat $config_dir/qc_dir_in.txt)
qc_dir_out=$(cat $config_dir/qc_dir_out.txt)
trim_dir_in=$(cat $config_dir/trim_dir_in.txt)
htseq_dir_in=$(cat $config_dir/htseq_dir_in.txt)
mapping_information=$(cat $config_dir/mapping_information.txt)
mapfiles=$(cat $config_dir/mapfiles.txt)
trim_type=$(cat $config_dir/trim_type.txt)


mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type
trim_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type"

SAMPLES=$(find $trim_dir_in -type f -printf '%f\n')

for s in $SAMPLES; do
	if [[ ! -f $trim_dir_out/$samplename.trimm.fastq.gz ]]; then
	samplename="${s%%.*}"
	$CUTADAPT -u $trim_base_num -j 0 -o $trim_dir_out/$samplename.trimm.fastq.gz $s
	echo ""
	fi
done
