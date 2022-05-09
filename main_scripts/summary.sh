#!/bin/bash

# Read config.sh
. $(dirname $0)/../config.sh

htseq_dir_out="$SAVE_LOC/$project_name/summary/htseq_counts"
samples=$(ls $htseq_dir_out/*.txt)
summary_dir="$SAVE_LOC/$project_name/summary"
final_counts_file="$project_name-counts.csv"
mapping_logs="$SAVE_LOC/$project_name/logs/mapping"
overall_summary_file="$SAVE_LOC/$project_name/summary/$project_name-summary.csv"

### Merge htseq count files into one counts csv file
n=0
for i in $samples; do
	FILE=$(basename $i)
	echo -e "ID\t $FILE" > ${i}-tmp.txt
	head -n-1 $i | cut -f 1,2 | sort -k1 >> $htseq_dir_out/$i-tmp.txt
	((n++))
	paste $htseq_dir_out/$i-tmp.txt > $htseq_dir_out/tmpOK
	rm -f $htseq_dir_out/$i-tmp.txt
	c="-f1"
done

for j in $(seq $n)
 	do
 	d=`expr 2 \* $j`
 	c=$c,$d
done

#echo $c
cut $c $htseq_dir_out/tmpOK > $SAVE_LOC/$project_name/summary/$final_counts_file
rm $htseq_dir_out/tmpOK
