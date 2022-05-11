#!/bin/bash

# Read config.sh
. $(dirname $0)/../config.sh

SAVE_LOC="/mnt/zion/Destiny_Pipeline_Test"
project_name="Zion_Write_Test"
mkdir -p $SAVE_LOC/$project_name/htseq_counts/temp

htseq_dir_out="$SAVE_LOC/$project_name/htseq_counts"
samples=$(ls $htseq_dir_out/*/*.txt)
summary_dir="$SAVE_LOC/$project_name/summary"
counts_file="$project_name-counts.csv"
mapping_logs="$SAVE_LOC/$project_name/logs/mapping"
summary_file="$SAVE_LOC/$project_name/summary/$project_name-summary.csv"
tmp_dir="$SAVE_LOC/$project_name/htseq_counts/temp"

### Merge htseq count files into one counts csv file
	
#awk 'NF > 1{ a[$1] = a[$3]"\t"$2} END {for( I in a ) print I a[i]}' $samples > merged.tmp

for i in $samples; do
    ID=$(echo "$i" | cut -d "-" -f1)
    if [[ ! -f $counts_file ]]; then
        printf "%s" "Gene Name" > $tmp_dir/GeneName-tmp.txt
        awk '{print $1}' $i >> $tmp_dir/GeneName-tmp.txt
        printf "%s\t" "Gene ID" > $tmp_dir/GeneID.txt
        awk '{print $2}' $i >> $tmp_dir/GeneID.txt
        printf "%s" "$ID" > $tmp_dir/$ID-tmp.txt
        awk '{print $3}' $i >> $tmp_dir/$ID-tmp.txt
        paste $tmp_dir/GeneID.txt $tmp_dir/GeneName-tmp.txt $tmp_dir/$ID-tmp >> $counts_file
    else
        printf "%s" "$ID" > $tmp_dir/$ID-tmp.txt
        awk '{print $3}' $i >> $tmp_dir/$ID-tmp.txt
        paste $tmp_dir/$counts_file $tmp_dir/$ID-tmp >> $counts_file        
    fi
#rm -r $tmp_dir/
done

#for i in $samples; do
#	ID=$(echo "$i" | cut -d "-" -f1)
#	if [[ ! -f $counts_file ]]; then
#		printf "%s" "Gene Name" > $tmp_dir/GeneName-tmp.txt
#		awk '{print $1}' $i >> $tmp_dir/GeneName-tmp.txt
#		printf "%s\t" "Gene ID" > $tmp_dir/GeneID.txt
#		awk '{print $2}' $i >> $tmp_dir/GeneID.txt
#		printf "%s" "$ID" > $tmp_dir/$ID-tmp.txt
#		awk '{print $3}' $i >> $tmp_dir/$ID-tmp.txt
#		paste $tmp_dir/GeneID.txt $tmp_dir/GeneName-tmp.txt $tmp_dir/$ID-tmp >> $counts_file
#	else
#		printf "%s" "$ID" > $tmp_dir/$ID-tmp.txt
#		awk '{print $3}' $i >> $tmp_dir/$ID-tmp.txt
#		paste $tmp_dir/$counts_file $tmp_dir/$ID-tmp >> $counts_file		
#	fi
#rm -r $tmp_dir/
#done

#for j in $(seq $n)
 #	do
 #	d=`expr 2 \* $j`
 #	c=$c,$d
#done

#echo $c
#cut $c $htseq_dir_out/tmpOK > $SAVE_LOC/$project_name/summary/$final_counts_file
#rm $htseq_dir_out/tmpOK