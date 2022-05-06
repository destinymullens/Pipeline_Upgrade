#!/bin/bash

## This script is to perform test mappings for exfoliome samples

# Read config.sh
. $(dirname $0)/config.sh

## Select random files for test mapping

mkdir -p $SAVE_LOC/$project_name/test_mapping
mkdir -p $SAVE_LOC/$project_name/logs/test_mapping

test_map_out="$SAVE_LOC/$project_name/test_mapping"
test_map_logs="$SAVE_LOC/$project_name/logs/test_mapping"


test_mappings=$(ls $mapfiles | shuf -n 3)
SUMMARY="$test_map_logs/Test_mapping_results.txt"

printf "%s\n" "Test mappings are: $test_mappings"

##### RUN BOWTIE2 #########

if [[ ! -f $SAVE_LOC/$project_name/mapping_parameter.txt ]]; then
	for t in $test_mappings/*.gz; do
		FILE=$(basename $t)

		A=0
		B=0

		## Additional options can be added for the -mp and -ma mappings if preferred, but the number of loops needs to be changed if other options are added
		mp_options=(6 4 2)
		ma_options=(2 6 8)

		## The number of loops here (3) should be the same as the number of options being tested.
		while [ $A -lt 3 ]
			do
			mp=$(echo ${mp_options[A]})
		
			## The number of loops here (3) should be the same as the number of options being tested.
			while [ $B -lt 3 ]
				do
				ma=$(echo ${ma_options[B]})
	
				## This designates mapping "D" for the first option (mp) and option "F" for the second option (ma)
				## The options will be 0, 1 & 2 for the 3 options given above for each parameter
				MAPPING="D$A-F$B"

				printf "%s\n" "Test mapping of $FILE with $MAPPING mapping options beginning..."

				$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -U $mapfiles/$t --mp $mp --ma $ma --local --time -S $test_map_out/$FILE-$MAPPING.sam 2> $test_map_logs/$FILE-$MAPPING-Results.log
	
				printf "%s\n" "Test mapping of $FILE with $MAPPING mapping options finished."
		
				## Cut info from each log file for comparision to see which is the best mapping option
				TOTAL_READS=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -5 | tail -1 | cut -d " " -f1)
				SINGLE_MAPPED_READS=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -8 | tail -1 | cut -d " " -f5)
				UNMAPPED_READS=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -7 | tail -1 | cut -d " " -f5)
				MULTI_MAP_READS=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -9 | tail -1 | cut -d " " -f5)
				ALIGNMENT_RATE=$(cat $test_map_logs/$FILE-$MAPPING-Results.log | head -10 | tail -1 | cut -d " " -f1)

				printf "%s\t" "$FILE" >> $SUMMARY ## Print sample name to summary	
				printf "%s\t" "$MAPPING" >> $SUMMARY ## Print mapping to summary
				printf "%s\t" "$TOTAL_READS" >> $SUMMARY ## Print Total reads to summary
				printf "%s\t" "$SINGLE_MAPPED_READS" >> $SUMMARY ## Print single mapped reads to summary
				printf "%s\t" "$UNMAPPED_READS" >> $SUMMARY ## Print unmapped reads to summary 
				printf "%s\t" "$MULTI_MAP_READS" >> $SUMMARY ## Print multimapped reads to summary
				printf "%s\n" "$ALIGNMENT_RATE" >> $SUMMARY ## Print alignment rate to summary

				B=$((B+1))
			done
			
			A=$((A+1))
			B=0
		done
	done


exfoliome_mapping_parameter=$(awk '$7>max[$1]{max[$1]=$7; row[$1]=$0} END{for (i in row) print row[i]}' $SUMMARY | cut -f 2 | grep -v "^\s*$" | sort | uniq -c | sort -bnr | head -1 | cut -c 9-13)
echo "$exfoliome_mapping_parameter" > $SAVE_LOC/$project_name/mapping_parameter.txt
echo "Test mapping complete and $exfoliome_mapping_parameter is the best mapping option."
echo "Cleaning up files..."

mkdir -p $SAVE_LOC/$project_name/mapping
mkdir -p $SAVE_LOC/$project_name/logs/mapping

	for t in $test_mappings; do
		FILE=$(basename $t)
		mv $test_map_out/$FILE-$exfoliome_mapping_parameter.sam $SAVE_LOC/$project_name/mapping/
		mv $test_map_logs/$FILE-$exfoliome_mapping_parameter-Results.log $SAVE_LOC/$project_name/logs/mapping
	done

#rm $SAVE_LOC/$project_name/test_mapping/*.sam 
fi
