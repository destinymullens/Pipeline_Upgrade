#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
config_dir="$SAVE_LOC/$project_name/tmp"
project_name=$(cat $config_dir/project_name.txt)
SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)
concat_response=$(cat $config_dir/concat_response.txt)
concat_length=$(cat $config_dir/concat_response.txt)
trim_num=$(cat $config_dir/trim_num.txt)
data_type=$(cat $config_dir/data_type.txt)
strand_num=$(cat $config_dir/strand_num.txt)
file_location=$(cat $config_dir/file_location.txt)
qc_dir_in=$(cat $config_dir/qc_dir_in.txt)
qc_dir_out=$(cat $config_dir/qc_dir_out.txt)
trim_dir_in=$(cat $config_dir/trim_dir_in.txt)
htseq_dir_in=$(cat $config_dir/htseq_dir_in.txt)
mapping_information=$(cat $config_dir/mapping_information.txt)
mapfiles=$(cat $config_dir/mapfiles.txt)
trim_type=$(cat $config_dir/trim_type.txt)

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
done
echo "Extraction of UMI's and trimming complete!"
umi_tools_version=$($UMI_TOOLS --version)
echo "UMI extraction and deduplication performed with $umi_tools_version." >> $mapping_information
cutadapt_version=$($CUTADAPT --version)
echo "Trimming performed using Cutadapt version $cutadapt_version." >> $mapping_information