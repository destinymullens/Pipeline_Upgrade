#!/bin/bash

## This script is to perform mappings for exfoliome samples with parameter settings

# Read config.sh
#. $(dirname $0)/../config.sh
. ${SAVE_LOC}/${project_name}/config.sh

## Create list for files that need to be mapped
MAP_FILES=$(ls ${mapfiles})
SUMMARY="${SAVE_LOC}/${project_name}/summary/$project_name-Mapping_summary.csv"

##### RUN BOWTIE2 #########
exfoliome_mapping_parameter=$(cat ${SAVE_LOC}/${project_name}/mapping_parameter.txt)

for m in ${MAP_FILES}; do
	FILE=$(basename $m)

	A=$(echo $exfoliome_mapping_parameter | cut -d "-" -f1 | cut -c 2-2)
	B=$(echo $exfoliome_mapping_parameter | cut -d "-" -f2 | cut -c 2-2)

	## Additional options can be added for the -mp and -ma mappings if preferred, but the number of loops needs to be changed if other options are added
	mp_options=(6 4 2)
	ma_options=(2 6 8)

	mp=$(echo ${mp_options[A]})
	ma=$(echo ${ma_options[B]})
	
	MAPPING="D${A}-F${B}"

	if [[ -f ${test_map_out}/${FILE}-${MAPPING}.sam ]]; then
		cp ${test_map_out}/${FILE}-${MAPPING}.sam ${mapping_dir_out}/${FILE}-${MAPPING}.sam
		echo "Moving ${FILE}-${MAPPING}.sam test mapping to save time!"
		else
		if [[ ! -f ${mapping_dir_out}/${FILE}-${MAPPING}.sam ]]; then
			printf "%s\n" "Mapping ${FILE} with ${MAPPING} mapping options beginning..."
			if [[ "${strand_num}" = "1" ]]; then
				${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -U ${mapfiles}/${m} --mp ${mp} --ma ${ma} --local --time -S ${mapping_dir_out}/${FILE}-${MAPPING}.sam 2> ${MAPPING}_logs/${FILE}-${MAPPING}-Results.log
				else
				${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -1 ${mapfiles}/${m}*1.fastq.gz -2 ${mapfiles}/${m}*2.fastq.gz --mp ${mp} --ma ${ma} --local --time -S ${mapping_dir_out}/${FILE}-${MAPPING}.sam 2> ${MAPPING}_logs/${FILE}-${MAPPING}-Results.log
			fi		
			printf "%s\n" "Mapping ${FILE} with ${MAPPING} mapping options complete."
			else
			echo "Mapping of ${FILE} with ${MAPPING} is already complete."
		fi
	fi
done
bowtie_version=$(${BOWTIE} --version | cut -d " " -f3 | head -1)
echo "Mapping performed using Bowtie2 version ${bowtie_version} with parameters ma ${ma} and mp ${mp}." >> ${mapping_information}