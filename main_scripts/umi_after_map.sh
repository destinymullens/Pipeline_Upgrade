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
mapping_information=$(cat $config_dir/mapping_information.txt)
mapfiles=$(cat $config_dir/mapfiles.txt)
trim_type=$(cat $config_dir/trim_type.txt)


mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type/deduplicated_files
mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type/indexed_files
mkdir -p $SAVE_LOC/$project_name/logs/$trim_type/deduplication 

map_dir_in="$SAVE_LOC/$project_name/mapping"
index_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type/indexed_files"
dedup_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type/deduplicated_files"
deduplog="$SAVE_LOC/$project_name/logs/$trim_type/deduplication"

SAMPLES=$(find $map_dir_in -type f -printf '%f\n')

for s in $SAMPLES; do
	samplename="${s%%.*}"
	if [[ ! -f $dedup_dir_out/$samplename-dedup.bam ]]; then
			echo "Begining sorting of $s...."
			$SAMTOOLS sort $map_dir_in/$s -o $index_dir_out/$samplename-sort.bam
			echo "Sorting of $s is complete."
			echo "Begining indexing of $s..."
			$SAMTOOLS index $index_dir_out/$samplename-sort.bam
			echo "Indexing of $s is complete."
			echo "Beginning deduplication of $s..."
			$UMI_TOOLS dedup -I $index_dir_out/$samplename-sort.bam --output-stats=$deduplog/$samplename-dedup -S $dedup_dir_out/$samplename-dedup.bam -L $deduplog/$samplename-dedup.log
			echo "Deduplication of $s is now complete."
			else
				echo "Sample already complete."
	fi
done
