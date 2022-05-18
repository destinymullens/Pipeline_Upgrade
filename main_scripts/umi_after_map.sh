#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
config_dir="$SAVE_LOC/$project_name/tmp"

project_name=$(cat $config_dir/project_name.txt)
SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)
trim_type=$(cat $config_dir/trim_type.txt)
mapping_dir_out=$(cat $config/mapping_dir_out.txt)

mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type/deduplicated_files
mkdir -p $SAVE_LOC/$project_name/trimmed_files/$trim_type/indexed_files
mkdir -p $SAVE_LOC/$project_name/logs/$trim_type/deduplication

index_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type/indexed_files"
dedup_dir_out="$SAVE_LOC/$project_name/trimmed_files/$trim_type/deduplicated_files"
deduplog="$SAVE_LOC/$project_name/logs/$trim_type/deduplication"

SAMPLES=$(find $mapping_dir_out -type f -printf '%f\n')

for s in $SAMPLES; do
	samplename="${s%%.*}"
	if [[ ! -f $dedup_dir_out/$samplename-dedup.bam ]]; then
			echo "Begining sorting of $s...."
			$SAMTOOLS sort $mapping_dir_out/$s -o $index_dir_out/$samplename-sort.bam
			echo "Sorting of $s is complete."
			echo "Begining indexing of $s..."
			$SAMTOOLS index $index_dir_out/$samplename-sort.bam
			echo "Indexing of $s is complete."
			echo "Beginning deduplication of $s..."
			$UMI_TOOLS dedup -I $index_dir_out/$samplename-sort.bam --output-stats=$deduplog/$samplename-dedup -S $dedup_dir_out/$samplename-dedup.bam -L $deduplog/$samplename-dedup.log
			echo "Deduplication of $s is now complete."
			else
				echo "Sample $samplename is already complete."
	fi
done