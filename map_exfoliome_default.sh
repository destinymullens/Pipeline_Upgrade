#!/bin/bash

## This script is to perform test mappings for exfoliome samples

# Read config.sh
. $(dirname $0)/config.sh

## Select random files for test mapping

mkdir -p $SAVE_LOC/$project_name/mapping
mkdir -p $SAVE_LOC/$project_name/logs/mapping
mapping_out="$SAVE_LOC/$project_name/mapping"
mapping_logs="$SAVE_LOC/$project_name/logs/mapping"
mappings=$(ls "$mapfiles")
SUMMARY="$mapping_logs/Mapping_results.txt"


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
echo "Mapping performed using Bowtie2 version: " >> Mapping_Information.txt
$BOWTIE --version | cut -d " " -f3 >> Mapping_Information.txt
