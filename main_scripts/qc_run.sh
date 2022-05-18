#!/bin/bash

## This script is to run QC Reports
# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
config_dir="$SAVE_LOC/$project_name/tmp"
mapping_information=$(cat $config_dir/mapping_information.txt)
qc_dir_in=$(cat $config_dir/qc_dir_in.txt)
qc_dir_out=$(cat $config_dir/qc_dir_out.txt)

SAMPLES=$(find $qc_dir_in -type f -printf '%f\n')

for s in $SAMPLES; do
samplename="${s%%.*}"
	if [[ ! -d $qc_dir_out/$samplename ]]; then
		echo "$samplename QC Report currently running."
		mkdir -p $qc_dir_out/$samplename
		$FASTQC $qc_dir_in/$s -o $qc_dir_out/$samplename -t 50
		echo ""
	else
		echo "$samplename is already complete."
	fi
done
fastqc_version=$($FASTQC --version)
echo "QC Reports completed with: $fastqc_version." >> $mapping_information
