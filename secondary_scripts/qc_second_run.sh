#!/bin/bash

## This script is to run QC Reports
# Read config.sh
. $(dirname $0)/../config.sh

SAMPLES=$(find $mapfiles -type f -printf '%f\n')
echo "$SAMPLES"
mkdir -p "$SAVE_LOC/$project_name/qc_reports_after_trim"
results="$SAVE_LOC/$project_name/qc_reports_after_trim"
for s in $SAMPLES; do
samplename="${s%%.*}"
	if [[ ! -d $results/$samplename ]]; then
		echo "$samplename QC Report currently running."
		mkdir -p $results/$samplename
		$FASTQC $mapfiles/$s -o $results/$samplename -t 50
		echo ""
	fi
done
