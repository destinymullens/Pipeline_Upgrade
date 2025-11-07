#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

MAP_FILES=$(ls ${mapfiles})
SUMMARY="${SAVE_LOC}/${project_name}/summary/$project_name-Mapping_summary.csv"

##### RUN BOWTIE2 #########
for m in $MAP_FILES; do
	FILE=$(basename $m)
	printf "%s\n" "Mapping of ${FILE} beginning..."
	${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -U ${mapfiles}/${m} --time -S ${mapping_dir_out}/${FILE}.sam 2> ${mapping_logs}/${FILE}-Results.log
	printf "%s\n" "Mapping of ${FILE} complete."
done
printf "%s\n" "✅ Mapping of all samples complete."
bowtie_version=$(${BOWTIE} --version | cut -d " " -f3)
echo "Mapping performed using Bowtie2 version ${bowtie_version} with default settings." >> ${mapping_information}