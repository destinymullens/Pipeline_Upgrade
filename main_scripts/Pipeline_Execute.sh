#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
set -e # Exit on error
set -a # Command exports variables automatically for other scripts
./misc_scripts/top_banner.sh

## Run concatenation script if needed
if [[ "${concat_response}" == "1" ]]; then
	concat_dir=${project_dir}/concat
	mkdir -p ${concat_dir}
	trim_dir_in=${concat_dir}
	qc_dir_in=${concat_dir}

	./main_scripts/concat_files.sh
else
	echo "File concatentation not needed."
	trim_dir_in=${file_location}
	qc_dir_in="${file_location}"
fi

## Run FastQC script if needed
if [[ "${qc_response}" == "1" ]]; then
	qc_dir_out=${project_dir}/qc_reports
	mkdir -p "${qc_dir_out}"
	./main_scripts/FastQC_run.sh
else
	echo "Skipping FastQC!"
fi

## Run trimming scripts if needed
if [[ "${trim_num}" = "4" ]]; then ## Trimming with UMI's
	echo "Beginning trimming of files..."
	trim_dir_out1=${project_dir}/trimmed_files/umi_trim/1_umi_extract
	trim_dir_out2=${project_dir}/trimmed_files/umi_trim/2_quality_trim
	mkdir -p ${trim_dir_out1}
	mkdir -p ${trim_dir_out2}
	map_dir_in=${trim_dir_out2}
	./main_scripts/umi_extract.sh.sh
elif [[ "${trim_num}" = "3" ]]; then ## Trimming by Quality Score
	trim_dir_out=${project_dir}/trimmed_files/base_trim 
	mkdir -p ${trim_dir_out}
	map_dir_in=${trim_dir_out}
	./main_scripts/trim_quality.sh		
elif [[ "${trim_num}" = "2" ]]; then ## Trimming by Number Bases
	trim_dir_out=${project_dir}/trimmed_files/quality_trim
	mkdir -p ${trim_dir_out}
	map_dir_in=${trim_dir_out}
	./main_scripts/trim_base.sh		
else
	echo "No trimming needed!"
	if [[ "${concat_response}" == "1" ]]; then
	map_dir_in=${concat_dir}	
else
	map_dir_in=${file_location}
fi


## Map Samples
if [[ "${trim_num}" = "4" ]]; then
	map_dir_out=${project_dir}/mapping_results
	mkdir -p ${map_dir_out}
	if [[ "${data_option}" = "1A" ]]; then
		./main_scripts/map_biopsy_Bowtie2.sh
	elif [[ "${data_option}" = "1B" ]]; then 
		./main_scripts/map_biopsy_STAR.sh
	elif [[ "${data_option}" = "2A" ]]; then 
		./main_scripts/map_exfoliome_optimized.sh
	else
		./main_scripts/map_exfoliome_default.sh
	fi
	dedup_dir_in=$map_dir_out
	index_dir_out=${project_dir}/trimmed_files/umi_trim/3_indexed_files
	dedup_dir_out=${project_dir}/trimmed_files/umi_trim/4_deduplicated_files
	mkdir -p ${index_dir_out}
	mkdir -p ${dedup_dir_out}
	./main_scripts/umi_dedup.sh
	htseq_dir_in=${dedup_dir_out}
	htseq_dir_out=${project_dir}/htseq_results
	mkdir -p ${htseq_dir_out}
	./main_scripts/htseq.sh
else
	map_dir_out=${project_dir}/mapping_results
	mkdir -p ${map_dir_out}
	if [[ "${data_option}" = "1A" ]]; then
		./main_scripts/map_biopsy_Bowtie2.sh
	elif [[ "${data_option}" = "1B" ]]; then 
		./main_scripts/map_biopsy_STAR.sh
	elif [[ "${data_option}" = "2A" ]]; then 
		./main_scripts/map_exfoliome_optimized.sh
	else
		./main_scripts/map_exfoliome_default.sh
	fi
	htseq_dir_in=${map_dir_out}
	htseq_dir_out=${project_dir}/htseq_results
	mkdir -p ${htseq_dir_out}
	./main_scripts/htseq.sh
fi
./main_scripts/summary.sh 	
echo " " >> ${mapping_information}
echo "All mapping is completed for ${project_name}! Your files are located at ${project_dir}."
echo "All mapping is completed for ${project_name} and files are located at ${project_dir}." >> ${mapping_information}
completed_time=$(timedatectl | head -1 | cut -d " " -f18-20)
echo "Mapping completed at: ${completed_time}." >> ${mapping_information}