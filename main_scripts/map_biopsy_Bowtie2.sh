#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

MAP_FILES=$(ls ${map_dir_in}/*R1*)
SUMMARY="${SAVE_LOC}/${project_name}/summary/$project_name-Mapping_summary.csv"

##### RUN BOWTIE2 #########
for m in $MAP_FILES; do
	FILE=$(basename $m)
	if [[ ! -f ${mapping_dir_out}/${FILE}.sam ]]; then
		echo "Mapping of ${FILE} is already complete!"
	else
		printf "%s\n" "Mapping of ${FILE} beginning..."

		if [[ "${strand_num}" = "1" ]]; then
			${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -U ${mapfiles}/${m} --time -S ${mapping_dir_out}/${FILE}.sam 2> ${mapping_logs}/${FILE}-Results.log
			printf "%s\n" "✅ Mapping of ${FILE} complete."
		else
			m2="${m/_R1/_R2}"
			${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -1 ${mapfiles}/${m} -2 ${mapfiles}/${m2} --time -S ${mapping_dir_out}/${FILE}.sam 2> ${mapping_logs}/${FILE}-Results.log
			printf "%s\n" "✅ Mapping of ${FILE} complete."

		fi

	fi
done
 
bowtie_version=$(${BOWTIE} --version | cut -d " " -f3)
echo "Mapping performed using Bowtie2 version ${bowtie_version} with default settings." >> ${mapping_information}