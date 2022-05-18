#!/bin/bash

## This script is to run QC Reports

# Read config.sh
. $(dirname $0)/../config.sh
config_dir="$SAVE_LOC/$project_name/tmp"
mapfiles=$(cat $config_dir/mapfiles.txt)
qc_dir_out2=$(cat $config_dir/qc_dir_out2.txt)

SAMPLES=$(find $mapfiles -type f -printf '%f\n')

for s in $SAMPLES; do
	samplename="${s%%.*}"
	if [[ ! -d $qc_dir_out2/$samplename ]]; then
		echo "$samplename QC Report currently running."
		mkdir -p $qc_dir_out2/$samplename
		$FASTQC $mapfiles/$s -o $qc_dir_out2/$samplename -t 50
		echo ""
	fi
done