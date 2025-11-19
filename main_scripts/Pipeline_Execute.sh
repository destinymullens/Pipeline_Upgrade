#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

./misc_scripts/top_banner.sh
## Runs concat script to concatenate script

if [[ "${concat_response}" == "1" ]]; then
	echo "Beginning concatenation of files..."
	mkdir -p "${SAVE_LOC}/${project_name}/concat"
	qc_dir_in="${SAVE_LOC}/${project_name}/concat"
	trim_dir_in="${SAVE_LOC}/${project_name}/concat"
	echo "qc_dir_in=${qc_dir_in}" >> ${SAVE_LOC}/${project_name}/config.sh
	echo "trim_dir_in=${trim_dir_in}" >> ${SAVE_LOC}/${project_name}/config.sh
	./main_scripts/concat_run.sh
	echo "Concatenation of files is finished! Moving on to QC Reports."
else
	echo "File concatentation not needed. Moving on to QC Reports."
	qc_dir_in="${file_location}"
	trim_dir_in="${file_location}"
	echo "qc_dir_in=${qc_dir_in}" >> ${SAVE_LOC}/${project_name}/config.sh
	echo "trim_dir_in=${trim_dir_in}" >> ${SAVE_LOC}/${project_name}/config.sh
fi

echo " "
## Runs script for QC Reports

echo "Beginning QC Reports..."
mkdir -p "${SAVE_LOC}/${project_name}/qc_reports/untrimmed"
qc_dir_out=${SAVE_LOC}/${project_name}/qc_reports/untrimmed
echo "qc_dir_out=${qc_dir_out}" >> ${SAVE_LOC}/${project_name}/config.sh
#./main_scripts/qc_run.sh
echo "QC Reports complete!"

## Run scripts for trimming options 
echo " "
if [[ "${trim_num}" = "1" ]]; then
	echo "No trimming needed!"

	elif [[ "${trim_num}" = "2" ]]; then
		echo "Beginning trimming of files!"
		./main_scripts/trim_quality.sh
		
	elif [[ "${trim_num}" = "3" ]]; then
		echo "Beginning trimming of files!"
		./main_scripts/trim_base.sh
		
	else
		echo "Beginning trimming of files!"
		./main_scripts/umi_extract.sh.sh
fi

###echo "Beginning mapping of files."

if [[ "${data_type}" = "biopsy" ]]; then
	if [[ "${trim_num}" = "4" ]]; then
		./main_scripts/map_biopsy.sh
		echo "Moving on to deduplication..."
		./main_scripts/umi_dedup.sh
		./main_scripts/htseq.sh
	else
		./main_scripts/map_biopsy.sh
		./main_scripts/htseq.sh
	fi

elif [[ "${data_type}" = "exfoliome_default" ]]; then 
	./main_scripts/map_exfoliome_default.sh
	echo "Moving on to deduplication..."
	./main_scripts/umi_dedup.sh
	./main_scripts/htseq.sh
	
else 
	./main_scripts/map_exfoliome_optimized.sh
	if [[ "${trim_num}" = "4" ]]; then
		echo "Moving on to deduplication..."
		./main_scripts/umi_dedup.sh
		./main_scripts/htseq.sh
	else
		./main_scripts/htseq.sh
	fi
fi

./main_scripts/summary.sh 	
echo " " >> ${mapping_information}
echo "All mapping is completed for ${project_name}! Your files are located at ${SAVE_LOC}/${project_name}."
echo "All mapping is completed for ${project_name} and files are located at ${SAVE_LOC}/${project_name}." >> ${mapping_information}
completed_time=$(timedatectl | head -1 | cut -d " " -f18-20)
echo "Mapping completed at: ${completed_time}." >> ${mapping_information}