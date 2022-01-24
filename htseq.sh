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
			$HTSEQ_LOC --stranded=no -f sam -i gene_id $i $REF/genes.gtf --additional-attr=gene_name > $htseq_dir_out/$FILE/$FILE-htseq.txt
			else
			$HTSEQ_LOC --stranded=yes -f sam -i gene_id $i $REF/genes.gtf --additional-attr=gene_name > $htseq_dir_out/$FILE/$FILE-htseq_output.txt
		fi
	printf "%s\n" "Counting of $FILE complete."


#### This section is saving the htseq counts file & individual metrics for overall summary output later

	## Htseq count overall metrics
	tail -5 $htseq_dir_out/$FILE/$FILE-htseq.txt > $htseq_dir_out/$FILE/$FILE-htseq_summary.log

	## Outputs only the gene counts without overall metrics at end of file (for easier merging with other gene counts later)
	head -n -5  $htseq_dir_out/$FILE/$FILE-htseq.txt > $$htseq_dir_out/$FILE/FILE-gene_counts_all.list

	## Creates list of only ERCC genes
	grep "^ERCC-" $htseq_dir_out/$FILE/$FILE-htseq.txt > $FILE-ERCC.list
	ercc_num=(wc -l ERCC.count)
	## Gets count of ERCC reads
	awk '{ sum+=$3 } END { print sum }' $htseq_dir_out/$FILE/$FILE-ERCC.list >! $htseq_dir_out/$FILE/$FILE-ERCC.count

	## Creates list of only mitochondrial genes
	grep -i "MT-" $htseq_dir_out/$FILE/$FILE-htseq.txt > $htseq_dir_out/$FILE/$FILE-MITO.list
	## Gets count of mitocondrial reads
	awk '{ sum+=$3 } END { print sum }' $htseq_dir_out/$FILE/$FILE-MITO.list >! $htseq_dir_out/$FILE/$FILE-MITO.count

	## Create list without ERCC genes to get gene counts
	head -n -$ercc_num $htseq_dir_out/$FILE/$FILE-htseq_gene_counts.log >! $htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.log
	## Outputs number of genes with > X number of genes
	awk '{if ($3>0) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/htseq.0.count
	awk '{if ($3>1) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/htseq.1count
	awk '{if ($3>2) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/htseq.2.count
	awk '{if ($3>3) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/htseq.3.count
	awk '{if ($3>5) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/htseq.5.count
	awk '{if ($3>10) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/htseq.10.count

done
