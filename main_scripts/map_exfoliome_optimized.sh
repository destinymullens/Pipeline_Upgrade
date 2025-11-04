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
		echo "Mapping of ${FILE} already complete!"
		else
		if [[ ! -f ${mapping_dir_out}/${FILE}-${MAPPING}.sam ]]; then
			printf "%s\n" "Mapping ${FILE} with ${MAPPING} mapping options beginning..."
			if [[ "${strand_num}" = "1" ]]; then
				${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -U ${mapfiles}/${m} -N 1 --mp 4,2  --very-sensitive-local --time -S ${mapping_dir_out}/${FILE}-Optimized.sam 2> ${mapping_logs}/${FILE}-Optimized-Results.log
				else
				${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -1 ${mapfiles}/${m}*1.fastq.gz -2 ${mapfiles}/${m}*2.fastq.gz -N 1 --mp 4,2  --very-sensitive-local --time -S ${mapping_dir_out}/${FILE}-Optimized.sam 2> ${mapping_logs}/${FILE}--Optimized-Results.log
			fi		
			printf "%s\n" "Optimized alignment of ${FILE} complete."
			else
			echo "Mapping of ${FILE} is already complete."
		fi
	fi
done
bowtie_version=$(${BOWTIE} --version | cut -d " " -f3 | head -1)
echo "Mapping performed using Bowtie2 version ${bowtie_version} with parameters ma ${ma} and mp ${mp}." >> ${mapping_information}