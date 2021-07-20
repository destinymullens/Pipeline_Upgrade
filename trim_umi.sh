#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/config.sh

mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type
trim_dir_in="$SAVE_LOC/$project_name/concat"
trim_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type"

SAMPLES=$(find $trim_dir_in -type f -printf '%f\n')

for s in $SAMPLES; do
	logfile="$s.processed.log"
	stoutfile="$s.processed.stout.log"
	$UMI_TOOLS extract --bc-pattern=NNNNNN --stdin $trim_dir_in/$s --log $trim_dir_out/$logfile --stout $trim_dir_out/$stoutfile
	$CUTADAPT -u 4 -o $trim_dir_out/$samplename.trimm.fastq.gz $trim_dir_in/$s
done
