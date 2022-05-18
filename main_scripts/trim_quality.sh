#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
#. $(dirname $0)/../config.sh
. $SAVE_LOC/$project_name/config.sh

##Importing input variables
#config_dir="$SAVE_LOC/$project_name/tmp"

#mapping_information=$(cat $config_dir/mapping_information.txt)
#project_name=$(cat $config_dir/project_name.txt)
#SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)
#trim_dir_in=$(cat $config_dir/trim_dir_in.txt)
#trim_type=$(cat $config_dir/trim_type.txt)
#trim_dir_out=$(cat $config_dir/trim_dir.txt)
#trim_quality_num=$(cat $config_dir/trim_quality_num.txt)

mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type

SAMPLES=$(find $trim_dir_in -type f -printf '%f\n')

for s in $SAMPLES; do
	samplename="${s%%.*}"
	if [[ ! -s $trim_dir_out/$samplename.trimm.fastq.gz ]]; then
		$CUTADAPT -q $trim_quality_num -j 0 -o $trim_dir_out/$samplename.trimm.fastq.gz $trim_dir_in/$s
		echo ""
	fi
done

cutadapt_version=$($CUTADAPT --version)
echo "Trimming performed using Cutadapt version $cutadapt_version." >> $mapping_information