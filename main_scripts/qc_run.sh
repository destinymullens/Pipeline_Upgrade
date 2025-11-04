#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

SAMPLES=$(find ${qc_dir_in} -type f -printf '%f\n')

for s in ${SAMPLES}; do
samplename="${s%%.*}"
	if [[ ! -d ${qc_dir_out}/${samplename} ]]; then
		echo "${samplename} QC Report currently running."
		mkdir -p ${qc_dir_out}/${samplename}
		${FASTQC} ${qc_dir_in}/${s} -o ${qc_dir_out}/${samplename} -t ${THREADS}
		echo ""
	else
		echo "${samplename} is already complete."
	fi
done
fastqc_version=$(${FASTQC} --version)
echo "QC Reports completed with: ${fastqc_version}." >> ${mapping_information}