#!/bin/bash

## This script is to perform test mappings for exfoliome samples

# Read config.sh
#. $(dirname $0)/../config.sh
. $SAVE_LOC/$project_name/config.sh

MAP_FILES=$(ls "$mapfiles")
SUMMARY="$SAVE_LOC/$project_name/summary/$project_name-Mapping_summary.csv"

##### RUN BOWTIE2 #########
for m in $MAP_FILES; do
	FILE=$(basename $m)
	if [[ ! -f $mapping_dir_out/$FILE.sam ]]; then
		printf "%s\n" "Mapping of $FILE beginning..."
	
		if [[ "$strand_num" = "1" ]]; then
			$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -U $mapfiles/$m --time -S $mapping_dir_out/$FILE.sam 2> $mapping_logs/$FILE-Results.log
		else
			$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -1 $mapfiles/$m*1.fastq.gz -2 $mapfiles/$m*2.fastq.gz --time -S $mapping_out/$FILE.sam 2> $mapping_logs/$FILE-Results.log
		fi
		
	printf "%s\n" "Mapping of $FILE complete."	
	fi

done
bowtie_version=$($BOWTIE --version | cut -d " " -f3)
echo "Mapping performed using Bowtie2 version $bowtie_version with default settings." >> $mapping_information