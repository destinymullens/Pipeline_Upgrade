#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/config.sh

mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type/barcodes_removed
mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type/final_trim
mkdir -p $SAVE_LOC/$project_name/logs
mkdir -p $SAVE_LOC/$project_name/logs/$trim_type/barcodes_removal

trim_dir_in="$SAVE_LOC/$project_name/concat"
trim_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type/barcodes_removed"
trim_final_dir="$SAVE_LOC/$project_name/trimmed_files/$trim_type/final_trim"
trim_log="$SAVE_LOC/$project_name/logs/$trim_type/barcodes_removal"
SAMPLES=$(find $trim_dir_in -type f -printf '%f\n')

for s in $SAMPLES; do
	logfile="$s.processed.log"
	stoutfile="$s.processed.fastq.gz"
	echo "Extracting UMI's from $s."
	$UMI_TOOLS extract --bc-pattern=NNNNNN -I $trim_dir_in/$s --log $trim_log/$logfile -S $trim_dir_out/$stoutfile
	echo "Extracting UMI's from $s is now complete."
done

SAMPLES2=$(find $trim_dir_out -type f -printf '%f\n')

for s in $SAMPLES2; do
	filename=$(basename $s)
	echo "Trimming bases from $s."
	$CUTADAPT -u 4 -o $trim_final_dir/$filename.trimm.fastq.gz $trim_dir_out/$s
	echo "Trimming complete for $s."
done
