#!/bin/bash

## This script is to perform test mappings for exfoliome samples

# Read config.sh
. $(dirname $0)/config.sh

## Select random files for test mapping

mkdir -p $SAVE_LOC/$project_name/test_mapping
mkdir -p $SAVE_LOC/$project_name/test_mapping/logs
test_map_out="$SAVE_LOC/$project_name/test_mapping"
test_map_logs="$SAVE_LOC/$project_name/test_mapping/logs"


test_mappings=$(ls $mapfiles | shuf -n 3)

echo -n "Test mappings are: $test_mappings"
echo -n " "
echo -n " "
##### RUN BOWTIE2 #########


for t in $test_mappings; do

FILE=$(basename $t)

A=0
B=0

mp_options=(6 8 4 2 10)
ma_options=(2 1 4 6 8)

while [ $A -lt 5 ]
do
mp=$(echo ${mp_options[A]})

	while [ $B -lt 5 ]
	do
	ma=$(echo ${ma_options[B]})
	MAPPING="D$A-F$B"

	echo -n "Test mapping of $FILE with $MAPPING mapping options beginning..."
	echo -n "  "
	$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -U $mapfiles/$t --mp $mp --ma $ma --local --time -S $test_map_out/$FILE-$MAPPING.sam 2> $test_map_logs/$FILE-$MAPPING-Results.log

	echo -n "Test mapping of $FILE with $MAPPING mapping options finished."
	echo -n "  "
	B=$((B+1))
        done


A=$((A+1))
B=0
done
done

TEST_RESULTS="$(ls $test_map_logs/*.log)"
SUMMARY="$test_map_logs/Test_mapping_results.txt"

for i in $TEST_RESULTS; do

	SAMPLE=$(basename $i)
	TOTAL_READS=$(cat $i | head -1 | cut -c 1-8)
	SINGLE_MAPPED_READS=$(cat $i | head -4 | tail -1 | cut -c 5-12)
	UNMAPPED_READS=$(cat $i | head -3 | tail -1 | cut -c 5-12)
	MULTI_MAP_READS=$(cat $i | head -5 | tail -1 | cut -c 5-12)
	ALIGNMENT_RATE=$(cat $i | head -6 | tail -1 | cut -c 1-6)

	printf "%s\t" "$SAMPLE" >> $SUMMARY
	printf "%s\t" "$MAPPING" >> $SUMMARY
	printf "%s\t" "$TOTAL_READS" >> $SUMMARY
	printf "%s\t" "$SINGLE_MAPPED_READS" >> $SUMMARY
	printf "%s\t" "$UNMAPPED_READS" >> $SUMMARY
	printf "%s\t" "$MULTI_MAP_READS" >> $SUMMARY
	printf "%s\n" "$ALIGNMENT_RATE" >> $SUMMARY

done
