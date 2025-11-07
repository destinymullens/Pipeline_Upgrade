#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

mkdir -p ${SAVE_LOC}/${project_name}/trimmed_files/${trim_type}/deduplicated_files
mkdir -p ${SAVE_LOC}/${project_name}/trimmed_files/${trim_type}/indexed_files
mkdir -p ${SAVE_LOC}/${project_name}/logs/${trim_type}/deduplication

index_dir_out="${SAVE_LOC}/${project_name}/trimmed_files/${trim_type}/indexed_files"
dedup_dir_out="${SAVE_LOC}/${project_name}/trimmed_files/${trim_type}/deduplicated_files"

deduplog="${SAVE_LOC}/${project_name}/logs/${trim_type}/deduplication"

SAMPLES=$(ls ${mapping_dir_out})

for s in ${SAMPLES}; do
	samplename=$(basename ${s})
	if [[ ! -f ${dedup_dir_out}/${samplename}-dedup.bam ]]; then
			echo "Begining sorting of ${s}...."
			${SAMTOOLS} sort ${mapping_dir_out}/${s} -o $index_dir_out/${samplename}-sort.bam
			echo "Sorting of ${s} is complete."
			echo "Begining indexing of ${s}..."
			${SAMTOOLS} index $index_dir_out/${samplename}-sort.bam
			echo "Indexing of ${s} is complete."
			echo "Beginning deduplication of ${s}..."
			${UMI_TOOLS} dedup -I $index_dir_out/${samplename}-sort.bam --output-stats=${deduplog}/${samplename}-dedup -S ${dedup_dir_out}/${samplename}-dedup.bam -L ${deduplog}/${samplename}-dedup.log
			echo "Deduplication of ${s} is now complete."
			else
			echo "✅ Sample ${samplename} is already complete."
	fi
done