#!/bin/bash

# Read config.sh
. $(dirname $0)/../config.sh

SAVE_LOC="/mnt/zion/Destiny_Pipeline_Test"
project_name="Zion_Write_Test"

htseq_dir_out="$SAVE_LOC/$project_name/htseq_counts"
samples=$(ls $htseq_dir_out/*/*.txt)
summary_dir="$SAVE_LOC/$project_name/summary"
counts_file="$project_name-counts.csv"
mapping_logs="$SAVE_LOC/$project_name/logs/mapping"
summary_file="$SAVE_LOC/$project_name/summary/$project_name-summary.csv"


### Merge htseq count files into one counts csv file
for i in $samples; do
	ID=$(echo "$i" | cut -d "-" -f1)
	if [[ ! -f $counts_file ]]; then
		printf "%s\t" "Gene Name" > GeneName-tmp.txt
		awk '{print $1}' $i >> GeneName-tmp.txt
		printf "%s\t" "Gene ID" > GeneID.txt
		awk '{print $2}' $i >> GeneID.txt
		printf "%s\t" "$ID" > $i-tmp.txt
		awk '{print $3}' $i >> $i-tmp.txt
		paste GeneID.txt GeneName-tmp.txt $i-tmp >> $counts_file
	else
		printf "%s\t" "$ID" > $i-tmp.txt
		awk '{print $3}' $i >> $i-tmp.txt
		paste $counts_file $i-tmp >> $counts_file		
	fi
rm -f *.tmp.txt
done

#for j in $(seq $n)
 #	do
 #	d=`expr 2 \* $j`
 #	c=$c,$d
#done

#echo $c
cut $c $htseq_dir_out/tmpOK > $SAVE_LOC/$project_name/summary/$final_counts_file
rm $htseq_dir_out/tmpOK