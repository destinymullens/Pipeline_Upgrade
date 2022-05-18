#!/bin/bash

## This script is to perform mappings for exfoliome samples with parameter settings

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
qc_dir_in=$(cat $config_dir/qc_dir_in.txt)
qc_dir_out=$(cat $config_dir/qc_dir_out.txt)
trim_dir_in=$(cat $config_dir/trim_dir_in.txt)
htseq_dir_in=$(cat $config_dir/htseq_dir_in.txt)
mapping_information=$(cat $config_dir/mapping_information.txt)
mapfiles=$(cat $config_dir/mapfiles.txt)
trim_type=$(cat $config_dir/trim_type.txt)
mapping_dir_out=$(cat $config/mapping_dir_out.txt)
mapping_logs=$(cat $config_dir/mapping_logs.txt)

## Create list for files that need to be mapped
MAP_FILES=$(ls $mapfiles)
SUMMARY="$SAVE_LOC/$project_name/summary/$project_name-Mapping_summary.csv"

##### RUN BOWTIE2 #########
exfoliome_mapping_parameter=$(cat $SAVE_LOC/$project_name/mapping_parameter.txt)

for m in $MAP_FILES; do
	FILE=$(basename $m)

	A=$(echo $exfoliome_mapping_parameter | cut -d "-" -f1 | cut -c 2-2)
	B=$(echo $exfoliome_mapping_parameter | cut -d "-" -f2 | cut -c 2-2)

	## Additional options can be added for the -mp and -ma mappings if preferred, but the number of loops needs to be changed if other options are added
	mp_options=(6 4 2)
	ma_options=(2 6 8)

	mp=$(echo ${mp_options[A]})
	ma=$(echo ${ma_options[B]})
	
	MAPPING="D$A-F$B"

	if [[ ! -f $mapping_dir_out/$FILE-$MAPPING.sam ]]; then

		printf "%s\n" "Mapping $FILE with $MAPPING mapping options beginning..."

		if [[ "$strand_num" = "1" ]]; then
			$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -U $mapfiles/$m --mp $mp --ma $ma --local --time -S $mapping_dir_out/$FILE-$MAPPING.sam 2> $mapping_logs/$FILE-$MAPPING-Results.log
		else
			$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -1 $mapfiles/$m*1.fastq.gz -2 $mapfiles/$m*2.fastq.gz --mp $mp --ma $ma --local --time -S $mapping_dir_out/$FILE-$MAPPING.sam 2> $mapping_logs/$FILE-$MAPPING-Results.log
		fi
		
		printf "%s\n" "Mapping $FILE with $MAPPING mapping options complete."
		
		## Cut info from each log file for comparision to see which is the best mapping option
		TOTAL_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -5 | tail -1 | cut -d " " -f1)
		SINGLE_MAPPED_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -8 | tail -1 | cut -d " " -f5)
		UNMAPPED_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -7 | tail -1 | cut -d " " -f5)
		MULTI_MAP_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -9 | tail -1 | cut -d " " -f5)
		ALIGNMENT_RATE=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -10 | tail -1 | cut -d " " -f1)

	else
	
	echo "Mapping of $FILE with $MAPPING is already complete."
	TOTAL_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -5 | tail -1 | cut -d " " -f1)
	SINGLE_MAPPED_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -8 | tail -1 | cut -d " " -f5)
	UNMAPPED_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -7 | tail -1 | cut -d " " -f5)
	MULTI_MAP_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -9 | tail -1 | cut -d " " -f5)
	ALIGNMENT_RATE=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -10 | tail -1 | cut -d " " -f1)
fi

done
bowtie_version=$($BOWTIE --version | cut -d " " -f3 | head -1)
echo "Mapping performed using Bowtie2 version $bowtie_version with parameters ma $ma and mp $mp." >> $mapping_information