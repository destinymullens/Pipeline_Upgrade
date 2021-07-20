#!/bin/bash

## This script is to run QC Reports
# Read config.sh
. $(dirname $0)/config.sh

#project_name="Test_for_QC_Runs"
#qc_dir_in="$SAVE_LOC/$project_name/concat"
#qc_dir_out="$SAVE_LOC/$project_name/qc_reports/untrimmed"

if [ ! -d "SAVE_LOC/$project_name/qc_reports/untrimmed" ]
	then
		qc_dir_in="$SAVE_LOC/$project_name/concat"
		qc_dir_out="$SAVE_LOC/$project_name/qc_reports/untrimmed"
	else
		qc_dir_in="$SAVE_LOC/$project_name/trimmed_files/$trim_type"
		qc_dir_out="$SAVE_LOC/$project_name/qc_reports/$trim_type"
fi

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
