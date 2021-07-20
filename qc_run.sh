#!/bin/bash

## This script is to run QC Reports
# Read config.sh
. $(dirname $0)/config.sh

SAMPLES=$(find $qc_dir_in -type f -printf '%f\n')
echo "$SAMPLES"
for s in $SAMPLES; do
samplename="${s%%.*}"
	if [[ ! -d $qc_dir_out/$samplename ]]; then
		echo "$samplename QC Report currently running."
		mkdir -p $qc_dir_out/$samplename
		$FASTQC $qc_dir_in/$s -o $qc_dir_out/$samplename -t 50
		echo ""
	fi
done
