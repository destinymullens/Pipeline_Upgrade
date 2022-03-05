#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/config.sh


mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type
trim_dir_in="$SAVE_LOC/$project_name/concat"
trim_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type"

SAMPLES=$(find $trim_dir_in -type f -printf '%f\n')

for s in $SAMPLES; do
	if [[ ! -f $trim_dir_out/$samplename.trimm.fastq.gz ]]; then
	samplename="${s%%.*}"
	$CUTADAPT -u $trim_base_num -j 0 -o $trim_dir_out/$samplename.trimm.fastq.gz $s
	echo ""
	fi
done
