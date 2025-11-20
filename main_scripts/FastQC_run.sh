#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
set -e

SampleList=$(find ${qc_dir_in} -type f -printf '%f\n')

for Sample in ${SampleList}; do
SampleName="${Sample%%.*}"
	if [[ ! -d ${qc_dir_out}/${SampleName} ]]; then
		echo "${SampleName} QC Report currently running."
		${FASTQC} ${qc_dir_in}/${Sample} -o ${qc_dir_out}/${SampleName} -t ${THREADS}
		echo ""
	else
		echo "${SampleName} is already complete."
	fi
done
echo "✅ FastQC completed for all samples!!"
fastqc_version=$(${FASTQC} --version)
echo "QC Reports completed with: ${fastqc_version}." >> ${mapping_information}