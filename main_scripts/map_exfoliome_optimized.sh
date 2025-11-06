#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

## Create list for files that need to be mapped
MAP_FILES=$(ls ${mapfiles})
SUMMARY="${SAVE_LOC}/${project_name}/summary/$project_name-Mapping_summary.csv"

for m in ${MAP_FILES}; do
	FILE=$(basename $m)

	if [[ -f ${mapping_dir_out}/${FILE}-Optimized.sam ]]; then
		echo "Mapping of ${FILE} is already complete!"
		else
			${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -U ${mapfiles}/${m} -N 1 --mp 4,2  --very-sensitive-local --time -S ${mapping_dir_out}/${FILE}-Optimized.sam 2> ${mapping_logs}/${FILE}-Optimized-Results.log
			printf "%s\n" "✅ Optimized alignment of ${FILE} complete."	
	fi
done
bowtie_version=$(${BOWTIE} --version | cut -d " " -f3 | head -1)
echo "Mapping performed using Bowtie2 version ${bowtie_version} with optimized parameters -N 1, --mp 4,2, and --very-sensitive-local." >> ${mapping_information}