#!/bin/bash

## This script is to perform test mappings for exfoliome samples

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

## Select random files for test mapping

mkdir -p $SAVE_LOC/$project_name/mapping
mkdir -p $SAVE_LOC/$project_name/logs/mapping
mapping_out="$SAVE_LOC/$project_name/mapping"
mapping_logs="$SAVE_LOC/$project_name/logs/mapping"
mappings=$(ls "$mapfiles")
SUMMARY="$SAVE_LOC/$project_name/summary/$project_name-Mapping_summary.csv"

##### RUN BOWTIE2 #########
for m in $mappings; do
	FILE=$(basename $m)
	if [[ ! -f $mapping_out/$FILE-$MAPPING.sam ]]; then
		printf "%s\n" "Mapping of $FILE beginning..."
	
		if [[ "$strand_num" = "1" ]]; then
			$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -U $mapfiles/$m --time -S $mapping_out/$FILE.sam 2> $mapping_logs/$FILE-Results.log
		else
			$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -1 $mapfiles/$m*1.fastq.gz -2 $mapfiles/$m*2.fastq.gz --time -S $mapping_out/$FILE.sam 2> $mapping_logs/$FILE-Results.log
		fi
		
	printf "%s\n" "Mapping of $FILE complete."	
	fi

if [[ ! -f $SUMMARY ]];then
	touch $SUMMARY
	printf "%s\t" "Sample Name" >> $SUMMARY ## Print sample name to summary
	printf "%s\t" "Mapping" >> $SUMMARY ## Print mapping to summary
	printf "%s\t" "Total_Reads" >> $SUMMARY ## Print Total reads to summary
	printf "%s\t" "Single Mapped Reads" >> $SUMMARY ## Print single mapped reads to summary
	printf "%s\t" "Unmapped Reads" >> $SUMMARY ## Print unmapped reads to summary 
	printf "%s\t" "Multi-mapped Reads" >> $SUMMARY ## Print multimapped reads to summary
	printf "%s\n" "Alignment Rate" >> $SUMMARY ## Print alignment rate to summary

	printf "%s\t" "$FILE" >> $SUMMARY ## Print sample name to summary	
	printf "%s\t" "$MAPPING" >> $SUMMARY ## Print mapping to summary
	printf "%s\t" "$TOTAL_READS" >> $SUMMARY ## Print Total reads to summary
	printf "%s\t" "$SINGLE_MAPPED_READS" >> $SUMMARY ## Print single mapped reads to summary
	printf "%s\t" "$UNMAPPED_READS" >> $SUMMARY ## Print unmapped reads to summary 
	printf "%s\t" "$MULTI_MAP_READS" >> $SUMMARY ## Print multimapped reads to summary
	printf "%s\n" "$ALIGNMENT_RATE" >> $SUMMARY ## Print alignment rate to summary

	else
	printf "%s\t" "$FILE" >> $SUMMARY ## Print sample name to summary	
	printf "%s\t" "$MAPPING" >> $SUMMARY ## Print mapping to summary
	printf "%s\t" "$TOTAL_READS" >> $SUMMARY ## Print Total reads to summary
	printf "%s\t" "$SINGLE_MAPPED_READS" >> $SUMMARY ## Print single mapped reads to summary
	printf "%s\t" "$UNMAPPED_READS" >> $SUMMARY ## Print unmapped reads to summary 
	printf "%s\t" "$MULTI_MAP_READS" >> $SUMMARY ## Print multimapped reads to summary
	printf "%s\n" "$ALIGNMENT_RATE" >> $SUMMARY ## Print alignment rate to summary
fi

done
bowtie_version=$BOWTIE --version | cut -d " " -f3
echo "Mapping performed using Bowtie2 version $bowtie_version with defaul settings." >> $mapping_information