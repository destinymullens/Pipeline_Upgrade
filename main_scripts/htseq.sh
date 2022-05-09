#!/bin/bash

# Read config.sh
. $(dirname $0)/config.sh

mkdir -p "$SAVE_LOC/$project_name/htseq_counts"
htseq_dir_out="$SAVE_LOC/$project_name/htseq_counts"
samples=$(ls $htseq_dir_in/*)



for i in $samples; do
	FILE=$(basename $i)
	if [[ ! -d $htseq_dir_out/$FILE ]]; then
		mkdir -p "$htseq_dir_out/$FILE"
		printf "%s\n" "Counting of $FILE beginning..."
			if [[ "$strand_num" = "1" ]]; then	
				$HTSEQ_LOC $i $species_location/genes.gtf --stranded=no -f sam -i gene_name --additional-attr=gene_id > $htseq_dir_out/$FILE/$FILE-htseq.txt
			else
				$HTSEQ_LOC --stranded=yes -f sam -i gene_id --additional-attr=gene_name $i $species_location/genes.gtf  > $htseq_dir_out/$FILE/$FILE-htseq.txt
			fi
		printf "%s\n" "Counting of $FILE complete."
	else
		echo "Counting of $FILE complete."
	fi

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
	awk '{if ($3>0) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.0.count
	awk '{if ($3>1) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.1count
	awk '{if ($3>2) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.2.count
	awk '{if ($3>3) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.3.count
	awk '{if ($3>5) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.5.count
	awk '{if ($3>10) print }' $htseq_dir_out/$FILE/htseq.list | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.10.count
done
htseq_version=$HTSEQ_LOC --version
echo "Counting performed using htseq-count version $htseq_version." >> $SAVE_LOC/$project_name/summary/Mapping_Information.txt
