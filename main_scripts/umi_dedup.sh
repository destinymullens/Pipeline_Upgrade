#!/bin/bash

# Read config.sh
source ${project_location}/config.sh

# Exit on error
set -e

index_dir_out="${project_location}/trimmed_files/umi_trim/3_indexed_files"
dedup_dir_out="${project_location}/trimmed_files/umi_trim/4_deduplicated_files"
mkdir -p ${index_dir_out}
mkdir -p ${dedup_dir_out}

deduplog="${project_location}/logs/umi_trim/deduplication"

SampleList=$(ls ${map_dir_out})

for Sample in ${SampleList}; do
	SampleName=$(basename ${Sample})
	if [[ ! -f ${dedup_dir_out}/${SampleName}-dedup.bam ]]; then
		echo "Begining sorting of ${Sample}...."
		${SAMTOOLS} sort ${mapping_dir_out}/${Sample} -o ${index_dir_out}/${SampleName}-sort.bam
		echo "Sorting of ${Sample} is complete."
		echo "Begining indexing of ${Sample}..."
		${SAMTOOLS} index ${index_dir_out}/${SampleName}-sort.bam
		echo "Indexing of ${Sample} is complete."
		echo "Beginning deduplication of ${Sample}..."
		${UMI_TOOLS} dedup -I ${index_dir_out}/${SampleName}-sort.bam --output-stats=${deduplog}/${SampleName}-dedup -S ${dedup_dir_out}/${samplename}-dedup.bam -L ${deduplog}/${samplename}-dedup.log
		echo "Deduplication of ${Sample} is now complete."
	else
		echo "✅ Sample ${SampleName} is already complete."
	fi
done
echo "✅ Deduplication of all samples is complete."