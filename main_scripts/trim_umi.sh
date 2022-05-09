#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/../config.sh

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
	logfile="$samplename.processed.log"
	stoutfile="$samplename.processed.fastq.gz"
	stoutfile_trimmed="$samplename.trimmed.processed.fastq.gz"
	if [[ ! -f $processed_dir_out/$stoutfile ]]; then
		echo "Extracting of UMI's from $s...."
		$UMI_TOOLS extract --bc-pattern=NNNNNN -I $trim_dir_in/$s --log $trim_log/$logfile -S $processed_dir_out/$stoutfile
		echo "Extraction of UMI's from $s is now complete."
	fi
	if [[ ! -f $trim_dir_out/$stoutfile_trimmed ]]; then
		echo "Begining trimming of $s...."
		$CUTADAPT -u 4 -o $trim_dir_out/$stoutfile_trimmed $processed_dir_out/$stoutfile
		echo "Trimming of $s is now complete."
	fi
	echo "Extraction of UMI's and trimming complete!"
done
umi_tools_version=$($UMI_TOOLS --version)
echo "UMI extraction and deduplication performed with $umi_tools_version." >> $SAVE_LOC/$project_name/summary/Mapping_Information.txt
cutadapt_version=$($CUTADAPT --version)
echo "Trimming performed using Cutadapt version $cutadapt_version." >> $SAVE_LOC/$project_name/summary/Mapping_Information.txt
