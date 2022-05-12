#!/bin/bash

## This script is to perform test mappings for exfoliome samples

# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
config_dir="$SAVE_LOC/$project_name/tmp"

mapfiles=$(cat $config_dir/mapfiles.txt)
mapping_information=$(cat $config_dir/mapping_information.txt)
project_name=$(cat $config_dir/project_name.txt)
SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)
species_location=$(cat $config_dir/species_location.txt)
strand_num=$(cat $config_dir/strand_num.txt)

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

done
bowtie_version=$BOWTIE --version | cut -d " " -f3
echo "Mapping performed using Bowtie2 version $bowtie_version with defaul settings." >> $mapping_information