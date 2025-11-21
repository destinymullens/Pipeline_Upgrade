#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
set -e

dedup_log="${project_dir}/logs/umi_trim/deduplication"
SampleList=$(ls ${map_dir_out})

for Sample in ${SampleList}; do

	SampleName="${Sample%%.*}"
	logfile="${dedup_log}/${samplename}-dedup.log"
	statsfile="${dedup_log}/${samplename}-dedup.stats.log"
	dedup_out_file="${dedup_dir_out}/${samplename}-dedup.bam"
	sorted_file="${index_dir_out}/${SampleName}-sort.bam"
	trim_out_file="${trim_dir_out2}/${SampleName}.trimmed.processed.fastq.gz"

	if [[ ! -f ${dedup_dir_out}/${SampleName}-dedup.bam ]]; then
		echo "Begining sorting of ${Sample}...."
		${SAMTOOLS} sort ${dedup_dir_in}/${Sample} -o ${sorted_file}
		echo "Sorting of ${Sample} is complete."

		echo "Begining indexing of ${Sample}..."
		${SAMTOOLS} index ${sorted_file}
		echo "Indexing of ${Sample} is complete."

		echo "Beginning deduplication of ${Sample}..."
		${UMI_TOOLS} dedup -I ${sorted_file} --output-stats=${statsfile} -S ${dedup_out_file} -L ${logfile}
		echo "Deduplication of ${Sample} is now complete."
	else
		echo "✅ Sample ${SampleName} is already complete."
	fi

done

echo "✅ Deduplication of all samples is complete."
samtools_version=$(${SAMTOOLS} --version | cut -d " " -f2 | head -1)
cat >> "${mapping_information}" <<EOF
Sorting and indexing was performed using Samtools ${samtools_version} prior to deduplication with umi_tools.
EOF