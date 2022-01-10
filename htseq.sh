#!/bin/bash

# Read config.sh
. $(dirname $0)/config.sh

mkdir -p "$SAVE_LOC/$project_name/summary/htseq_counts"
htseq_dir_in="$SAVE_LOC/$project_name/mapping"
htseq_dir_out="$SAVE_LOC/$project_name/summary/htseq_counts"

if [[ "$strand_num" = "1" ]]; 
	for i in $htseq_dir_in; do
		FILE=$(basename $i)
		printf "%s\n" "Counting of $FILE beginning..."
		$HTSEQ_LOC --stranded=no -f sam -i gene_id --additional-attr=gene_name $REF > $htseq_dir_out/$FILE-htseq.txt
		printf "%s\n" "Counting of $FILE complete."
	done
else
	for i in $htseq_dir_in; do
		FILE=$(basename $i)
		printf "%s\n" "Counting of $FILE beginning..."
		$HTSEQ_LOC --stranded=yes -f sam -i gene_id --additional-attr=gene_name $REF > $htseq_dir_out/$FILE-htseq.txt
		printf "%s\n" "Counting of $FILE complete."
	done
fi

