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
mappings=$(ls $mapfiles)
SUMMARY="$SAVE_LOC/$project_name/summary/$project_name-Mapping_summary.csv"

##### RUN BOWTIE2 #########
exfoliome_mapping_parameter=$(cat $SAVE_LOC/$project_name/mapping_parameter.txt)

for m in $mappings; do
	FILE=$(basename $m)

	A=$(echo $exfoliome_mapping_parameter | cut -d "-" -f1 | cut -c 2-2)
	B=$(echo $exfoliome_mapping_parameter | cut -d "-" -f2 | cut -c 2-2)
#	echo "The mapping parameter is $exfoliome_mapping_parameter"
#	echo "The test mapping value A is $A"
#	echo "The test mapping value B is $B"

	## Additional options can be added for the -mp and -ma mappings if preferred, but the number of loops needs to be changed if other options are added
	mp_options=(6 4 2)
	ma_options=(2 6 8)

	mp=$(echo ${mp_options[A]})
	ma=$(echo ${ma_options[B]})
	
#	echo "mp value is $mp"
#	echo "ma value is $ma"
	
	MAPPING="D$A-F$B"

	printf "%s\n" "Mapping $FILE with $MAPPING mapping options beginning..."
	
	if [[ "$strand_num" = "1" ]]; then
		$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -U $mapfiles/$m --mp $mp --ma $ma --local --time -S $mapping_out/$FILE-$MAPPING.sam 2> $mapping_logs/$FILE-$MAPPING-Results.log
	else
		$BOWTIE -x $species_location/bowtie2/$species --threads $THREADS -1 $mapfiles/$m*1.fastq.gz -2 $mapfiles/$m*2.fastq.gz --mp $mp --ma $ma --local --time -S $mapping_out/$FILE-$MAPPING.sam 2> $mapping_logs/$FILE-$MAPPING-Results.log
	fi
		
	printf "%s\n" "Mapping $FILE with $MAPPING mapping options finished."
		
	## Cut info from each log file for comparision to see which is the best mapping option
	TOTAL_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -5 | tail -1 | cut -d " " -f1)
	SINGLE_MAPPED_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -8 | tail -1 | cut -d " " -f5)
	UNMAPPED_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -7 | tail -1 | cut -d " " -f5)
	MULTI_MAP_READS=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -9 | tail -1 | cut -d " " -f5)
	ALIGNMENT_RATE=$(cat $mapping_logs/$FILE-$MAPPING-Results.log | head -10 | tail -1 | cut -d " " -f1)

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
echo "Mapping performed using Bowtie2 version $bowtie_version with parameters ma $ma and mp $mp." >> $SAVE_LOC/$project_name/summary/Mapping_Information.txt
