#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
set -e

mkdir -p ${project_dir}/trimmed_files/${trim_type}

SAMPLES=$(find ${trim_dir_in} -type f -printf '%f\n')

for s in ${SAMPLES}; do
	samplename="${s%%.*}"
	if [[ ! -f ${trim_dir_out}/${samplename}.trimm.fastq.gz ]]; then
		${CUTADAPT} -u ${trim_base_num} -j 0 -o ${trim_dir_out}/${samplename}.trimm.fastq.gz ${s}
		echo ""
	fi
done
echo "✅ Trimming of samples is complete!!"
cutadapt_version=$(${CUTADAPT} --version)
echo "Trimming performed using Cutadapt version ${cutadapt_version}." >> ${mapping_information}