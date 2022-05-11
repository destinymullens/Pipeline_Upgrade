#!/bin/bash

# Read config.sh
. $(dirname $0)/../config.sh

##Importinh input variables
config_dir="$SAVE_LOC/$project_name/tmp"
READ project_name < $config_dir/project_name.txt
READ SAVE_LOC < $config_dir/SAVE_LOC.txt
READ concat_response < $config_dir/concat_response.txt
READ concat_length < $config_dir/concat_response.txt
READ trim_num < $config_dir/trim_num.txt
READ data_type < $config_dir/data_type.txt
READ strand_num < $config_dir/strand_num.txt
READ file_location < $config_dir/file_location.txt

./misc_scripts/top_banner.sh
## Runs concat script to concatenate script

if [[ "$concat_response" == "1" ]]; then
	echo "Beginning concatenation of files..."
	./main_scripts/concat_run.sh
	qc_dir_in="$SAVE_LOC/$project_name/concat"
	trim_dir_in="$SAVE_LOC/$project_name/concat"
	echo "Concatenation of files is finished! Moving on to QC Reports."
	else
	echo "File concatentation not needed. Moving on to QC Reports."
	qc_dir_in="$file_location"
	trim_dir_in="$file_location"
fi

echo " "
## Runs script for QC Reports

echo "Beginning QC Reports..."
qc_dir_out="$SAVE_LOC/$project_name/qc_reports/untrimmed"
./main_scripts/qc_run.sh
echo "QC Reports complete!"

## Run scripts for trimming options 
echo " "
if [[ "$trim_num" = "1" ]]; then
	echo "No trimming needed!"
	elif [[ "$trim_num" = "2" ]]; then
		echo "Beginning trimming of files!"
		./main_scripts/trim_quality.sh
		./secondary_scripts/qc_second_run.sh		
	elif [[ "$trim_num" = "3" ]]; then
		echo "Beginning trimming of files!"
		./main_scripts/trim_base.sh
		./secondary_scripts/qc_second_run
	else
		echo "Beginning trimming of files!"
		./main_scripts/trim_umi.sh
		./secondary_scripts/qc_second_run.sh
fi

###echo "Beginning mapping of files."

if [[ "$data_type" = "biopsy" ]]; then 
	if [[ "$strand_num" = "1" ]]; then 
		./main_scripts/map_SE_biopsy.sh
		if [[ "$trim_num" = "4" ]]; then
			echo "Moving on to dedup"
			./main_scripts/umi_after_map.sh
			htseq_dir_in="$SAVE_LOC/$project_name/trimmed_files/$trim_type/indexed_files"
			./main_scripts/htseq.sh
		else
			htseq_dir_in="$SAVE_LOC/$project_name/mapping"
			./main_scripts/htseq.sh
		fi
	else 
		./main_scripts/map_PE_biopsy.sh
		if [[ "$trim_num" = "4" ]]; then
			echo "Moving on to dedup"
			./main_scripts/umi_after_map.sh
			htseq_dir_in="$SAVE_LOC/$project_name/trimmed_files/$trim_type/indexed_files"
			./main_scripts/htseq.sh
		else
			htseq_dir_in="$SAVE_LOC/$project_name/mapping"
			./main_scripts/htseq.sh
		fi
	fi
elif [[ "$data_type" = "exfoliome with testing" ]]; then
	./main_scripts/map_test_exfoliome.sh
	./main_scripts/map_exfoliome_with_parameters.sh
		if [[ "$trim_num" = "4" ]]; then
			echo "Moving on to dedup"
			./main_scripts/umi_after_map.sh
			htseq_dir_in="$SAVE_LOC/$project_name/trimmed_files/$trim_type/indexed_files"
			./main_scripts/htseq.sh
		else
			htseq_dir_in="$SAVE_LOC/$project_name/mapping"
			./main_scripts/htseq.sh
		fi
	
elif [[ "$data_type" = "exfoliome with default values" ]]; then 
	./main_scripts/map_exfoliome_default.sh
	if [[ "$trim_num" = "4" ]]; then
		echo "Moving on to dedup"
		./main_scripts/umi_after_map.sh
		htseq_dir_in="$SAVE_LOC/$project_name/trimmed_files/$trim_type/indexed_files"		
		./main_scripts/htseq.sh
	else
		htseq_dir_in="$SAVE_LOC/$project_name/mapping"
		./main_scripts/htseq.sh
	fi
else 
	./main_scripts/map_exfoliome_with_parameters.sh
		if [[ "$trim_num" = "4" ]]; then
		echo "Moving on to dedup"
		./main_scripts/umi_after_map.sh
		./main_scripts/htseq.sh
	else
		htseq_dir_in="$SAVE_LOC/$project_name/mapping"
		./main_scripts/htseq.sh
	fi
fi

./main_scripts/summary.sh 	
echo " " >> $mapping_information
echo "All mapping is completed for $project_name! Your files are located at $SAVE_LOC/$project_name."
echo "All mapping is completed for $project_name and files are located at $SAVE_LOC/$project_name." >> $mapping_information
completed_time=$(timedatectl | head -1 | cut -d " " -f23-28)
echo "Mapping began at: $completed_time." >> $mapping_information
