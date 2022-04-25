##!/bin/bash

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

	## Cut info from each log file for comparision to see which is the best mapping option
	TOTAL_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -5 | tail -1 | cut -d " " -f1)
	SINGLE_MAPPED_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -8 | tail -1 | cut -d " " -f5)
	UNMAPPED_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -7 | tail -1 | cut -d " " -f5)
	MULTI_MAP_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -9 | tail -1 | cut -d " " -f5)
	ALIGNMENT_RATE=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -10 | tail -1 | cut -d " " -f1)

	printf "%s\t" "$FILE" >> $SUMMARY ## Print sample name to summary	
	printf "%s\t" "$MAPPING" >> $SUMMARY ## Print mapping to summary
	printf "%s\t" "$TOTAL_READS" >> $SUMMARY ## Print Total reads to summary
	printf "%s\t" "$SINGLE_MAPPED_READS" >> $SUMMARY ## Print single mapped reads to summary
	printf "%s\t" "$UNMAPPED_READS" >> $SUMMARY ## Print unmapped reads to summary 
	printf "%s\t" "$MULTI_MAP_READS" >> $SUMMARY ## Print multimapped reads to summary
	printf "%s\n" "$ALIGNMENT_RATE" >> $SUMMARY ## Print alignment rate to summary
	
	fi
done
