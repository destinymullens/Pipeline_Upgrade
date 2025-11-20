#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
set -e

mkdir -p ${project_dir}/trimmed_files/${trim_type}

SampleList=$(find ${trim_dir_in} -type f -printf '%f\n')

for s in ${SampleList}; do
	samplename="${s%%.*}"
	if [[ ! -s ${trim_dir_out}/${samplename}.trimm.fastq.gz ]]; then
		${CUTADAPT} -q ${trim_quality_num} -j ${THREADS} -o ${trim_dir_out}/${samplename}.trimm.fastq.gz ${trim_dir_in}/${s}
		echo ""
	fi
done
echo "✅ Trimming of samples is complete!!"

cutadapt_version=$(${CUTADAPT} --version)
echo "Trimming performed using Cutadapt version ${cutadapt_version}." >> ${mapping_information}