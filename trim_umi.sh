#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/config.sh

mkdir -p $SAVE_LOC/$project_name/logs/$trim_type
mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type/trimmed
mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type/umi_extracted

processed_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type/umi_extracted"
trim_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type/trimmed"
trim_log="$SAVE_LOC/$project_name/logs/$trim_type"

#### Extract UMI's ####
SAMPLES=$(find $trim_dir_in -type f -printf '%f\n')
for s in $SAMPLES; do
	samplename="${s%%.*}"
	if [[ ! -f $trim_dir_out/$samplename-trimmmed.fastq.gz ]]; then
		logfile="$samplename.processed.log"
		stoutfile="$samplename.processed.fastq.gz"
		echo "Extracting of UMI's from $s...."
		$UMI_TOOLS extract --bc-pattern=NNNNNN -I $trim_dir_in/$s --log $trim_log/$logfile -S $processed_dir_out/$stoutfile
		wait
		echo "Extraction of UMI's from $s is now complete."
		echo "Begining trimming of $s...."
		cutadapt -u 4 -j 0 -o $trim_dir_out/$samplename-processed.trim.fastq.gz $processed_dir_out/$s
		echo "Trimming of $t is now complete."
		fi
done
