#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/config.sh

mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type
mkdir -p $SAVE_LOC/$project_name/logs
mkdir -p $SAVE_LOC/$project_name/logs/$trim_type

trim_dir_in="$SAVE_LOC/$project_name/concat"
trim_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type"
trim_log="$SAVE_LOC/$project_name/logs/$trim_type"

SAMPLES=$(find $trim_dir_in -type f -printf '%f\n')

for s in $SAMPLES; do
	samplename="${s%%.*}"
	if [[ ! -d $trim_dir_out/$samplename ]]; then
		logfile="$samplename.processed.log"
		stoutfile="$samplename.processed.fastq.gz"
		echo "Begining trimming of $s...."
		$UMI_TOOLS extract --bc-pattern=NNNNNN -I $trim_dir_in/$s --log $trim_log/$logfile | $CUTADAPT -u 4 -j 0 -o $trim_final_dir/$samplename.trimm.fastq.gz -
		echo "Trimming of $s is now complete."
	fi
done
