#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

mkdir -p ${SAVE_LOC}/${project_name}/trimmed_files/${trim_type}

SAMPLES=$(find ${trim_dir_in} -type f -printf '%f\n')

for s in ${SAMPLES}; do
	samplename="${s%%.*}"
	if [[ ! -s ${trim_dir_out}/${samplename}.trimm.fastq.gz ]]; then
		${CUTADAPT} -q ${trim_quality_num} -j 0 -o ${trim_dir_out}/${samplename}.trimm.fastq.gz ${trim_dir_in}/${s}
		echo ""
	fi
done
echo "✅ Trimming of samples is complete!!"

cutadapt_version=$(${CUTADAPT} --version)
echo "Trimming performed using Cutadapt version ${cutadapt_version}." >> ${mapping_information}