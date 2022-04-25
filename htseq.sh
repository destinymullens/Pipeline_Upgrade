#!/bin/bash

# Read config.sh
. $(dirname $0)/config.sh

mkdir -p "$SAVE_LOC/$project_name/summary/htseq_counts"
htseq_dir_out="$SAVE_LOC/$project_name/summary/htseq_counts"
samples=$(ls $htseq_dir_in/*.bam)

for i in $samples; do
	FILE=$(basename $i)
	mkdir "$htseq_dir_out/$FILE"
	printf "%s\n" "Counting of $FILE beginning..."
		if [[ "$strand_num" = "1" ]]; then	
			$HTSEQ_LOC $i $REF/genes.gtf --stranded=no -f sam -i gene_name --additional-attr=gene_id > $htseq_dir_out/$FILE-htseq.txt
			else
			$HTSEQ_LOC --stranded=yes -f sam -i gene_id --additional-attr=gene_name $i $REF/genes.gtf  > $htseq_dir_out/$FILE-htseq.txt
		fi
	printf "%s\n" "Counting of $FILE complete."
