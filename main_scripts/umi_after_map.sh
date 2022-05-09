#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
. $(dirname $0)/../config.sh

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
