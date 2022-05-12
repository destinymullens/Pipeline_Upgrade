#!/bin/bash

# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
config_dir="$SAVE_LOC/$project_name/tmp"
project_name=$(cat $config_dir/project_name.txt)
SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)
concat_response=$(cat $config_dir/concat_response.txt)
concat_length=$(cat $config_dir/concat_response.txt)
trim_num=$(cat $config_dir/trim_num.txt)
data_type=$(cat $config_dir/data_type.txt)
strand_num=$(cat $config_dir/strand_num.txt)
file_location=$(cat $config_dir/file_location.txt)
mapfiles=$(cat $config_dir/mapfiles.txt)
mapping_information=$(cat $config_dir/mapping_information.txt)

./misc_scripts/top_banner.sh
## Runs concat script to concatenate script

if [[ "$concat_response" == "1" ]]; then
	echo "Beginning concatenation of files..."
	./main_scripts/concat_run.sh
	qc_dir_in="$SAVE_LOC/$project_name/concat"
	trim_dir_in="$SAVE_LOC/$project_name/concat"
	echo "$qc_dir_in" > $config_dir/qc_dir_in.txt
	echo "$trim_dir_in" > $config_dir/trim_dir_in.txt
	echo "Concatenation of files is finished! Moving on to QC Reports."
	else
	echo "File concatentation not needed. Moving on to QC Reports."
	qc_dir_in="$file_location"
	trim_dir_in="$file_location"
	echo "$qc_dir_in" > $config_dir/qc_dir_in.txt
	echo "$trim_dir_in" > $config_dir/trim_dir_in.txt
fi

echo " "
## Runs script for QC Reports

echo "Beginning QC Reports..."
qc_dir_out="$SAVE_LOC/$project_name/qc_reports/untrimmed"
echo "$qc_dir_out" > $config_dir/qc_dir_out.txt

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
			./main_scripts/htseq.sh
		else
			./main_scripts/htseq.sh
		fi
	else 
		./main_scripts/map_PE_biopsy.sh
		if [[ "$trim_num" = "4" ]]; then
			echo "Moving on to dedup"
			./main_scripts/umi_after_map.sh
			./main_scripts/htseq.sh
		else
			./main_scripts/htseq.sh
		fi
	fi
elif [[ "$data_type" = "exfoliome with testing" ]]; then
	./main_scripts/map_test_exfoliome.sh
	./main_scripts/map_exfoliome_with_parameters.sh
		if [[ "$trim_num" = "4" ]]; then
			echo "Moving on to dedup"
			./main_scripts/umi_after_map.sh
			./main_scripts/htseq.sh
		else
			./main_scripts/htseq.sh
		fi
	
elif [[ "$data_type" = "exfoliome with default values" ]]; then 
	./main_scripts/map_exfoliome_default.sh
	if [[ "$trim_num" = "4" ]]; then
		echo "Moving on to dedup"
		./main_scripts/umi_after_map.sh	
		./main_scripts/htseq.sh
	else
		./main_scripts/htseq.sh
	fi
else 
	./main_scripts/map_exfoliome_with_parameters.sh
		if [[ "$trim_num" = "4" ]]; then
		echo "Moving on to dedup"
		./main_scripts/umi_after_map.sh
		./main_scripts/htseq.sh
	else
		./main_scripts/htseq.sh
	fi
fi

./main_scripts/summary.sh 	
echo " " >> $mapping_information
echo "All mapping is completed for $project_name! Your files are located at $SAVE_LOC/$project_name."
echo "All mapping is completed for $project_name and files are located at $SAVE_LOC/$project_name." >> $mapping_information
completed_time=$(timedatectl | head -1 | cut -d " " -f23-28)
echo "Mapping began at: $completed_time." >> $mapping_information