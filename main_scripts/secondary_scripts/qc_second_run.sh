#!/bin/bash

## This script is to run QC Reports

#. $(dirname $0)/../config.sh
. $SAVE_LOC/$project_name/config.sh

SAMPLES=$(find $mapfiles -type f -printf '%f\n')

for s in $SAMPLES; do
	samplename="${s%%.*}"
	if [[ ! -d $qc_dir_out2/$samplename ]]; then
		echo "$samplename post-trimming QC Report currently running."
		mkdir -p $qc_dir_out2/$samplename
		$FASTQC $mapfiles/$s -o $qc_dir_out2/$samplename -t $THREADS
		echo "$samplename post-trimming QC Report completed."
	fi
done