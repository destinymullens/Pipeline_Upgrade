##!/bin/bash

#!/bin/bash

## This script is to perform test mappings for exfoliome samples

# Read config.sh
. $(dirname $0)/config.sh

## Select random files for test mapping

mkdir -p $SAVE_LOC/$project_name/mapping
mkdir -p $SAVE_LOC/$project_name/mapping/logs
mapping_out="$SAVE_LOC/$project_name/mapping"
mapping_logs="$SAVE_LOC/$project_name/mapping/logs"
mappings=$(ls $mapfiles)
SUMMARY="$mapping_logs/Mapping_results.txt"


mp_input=$(echo $exfoliome_mapping_parameter | cut -c 2-2)
ma_input=$(echo $exfoliome_mapping_parameter | cut -c 5-5)


##### RUN BOWTIE2 #########


for m in $mappings; do

	FILE=$(basename $m)

	A=mp_input
	B=ma_input

	## Additional options can be added for the -mp and -ma mappings if preferred, but the number of loops needs to be changed if other options are added
	mp_options=(6 4 2)
	ma_options=(2 6 8)

	mp=$(echo ${mp_options[A]})
	ma=$(echo ${ma_options[B]})
	
	MAPPING="D$A-F$B"

	printf "%s\n" "Mapping $FILE with $MAPPING mapping options beginning..."

	$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -U $mapfiles/$m --mp $mp --ma $ma --local --time -S $test_map_out/$FILE-$MAPPING.sam 2> $test_map_logs/$FILE-$MAPPING-Results.log
	
	printf "%s\n" "Mapping $FILE with $MAPPING mapping options finished."
		
	## Cut info from each log file for comparision to see which is the best mapping option
	TOTAL_READS=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -5 | tail -1 | cut -c 1-9)
	SINGLE_MAPPED_READS=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -8 | tail -1 | cut -c 5-12)
	UNMAPPED_READS=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -7 | tail -1 | cut -c 5-12)
	MULTI_MAP_READS=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -9 | tail -1 | cut -c 5-12)
	ALIGNMENT_RATE=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -10 | tail -1 | cut -c 1-6)

	printf "%s\t" "$FILE" >> $SUMMARY ## Print sample name to summary	
	printf "%s\t" "$MAPPING" >> $SUMMARY ## Print mapping to summary
	printf "%s\t" "$TOTAL_READS" >> $SUMMARY ## Print Total reads to summary
	printf "%s\t" "$SINGLE_MAPPED_READS" >> $SUMMARY ## Print single mapped reads to summary
	printf "%s\t" "$UNMAPPED_READS" >> $SUMMARY ## Print unmapped reads to summary 
	printf "%s\t" "$MULTI_MAP_READS" >> $SUMMARY ## Print multimapped reads to summary
	printf "%s\n" "$ALIGNMENT_RATE" >> $SUMMARY ## Print alignment rate to summary
done
