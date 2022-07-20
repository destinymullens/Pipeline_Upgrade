#!/bin/bash

# Read config.sh
#. $(dirname $0)/../config.sh
. $SAVE_LOC/$project_name/config.sh

mkdir -p "$SAVE_LOC/$project_name/htseq_counts"
htseq_dir_out="$SAVE_LOC/$project_name/htseq_counts"
samples=$(ls $htseq_dir_in/*.bam)

summary_file="$SAVE_LOC/$project_name/summary/$project_name-htseq-metrics.csv"
	printf "%s\t" "Sample Name" >> $summary_file ## Print sample name to summary  
	printf "%s\t" "Mitochondrial Reads" >> $summary_file ## Print sample name to summary	
	printf "%s\t" "Genes > 0 Reads" >> $summary_file ## Print sample name to summary
	printf "%s\t" "Genes > 1 Reads" >> $summary_file ## Print sample name to summary  
	printf "%s\n" "Genes > 2 Reads" >> $summary_file ## Print sample name to summary  
	
for i in $samples; do
	FILE=$(basename $i)
	if [[ ! -d $htseq_dir_out/$FILE ]]; then
		mkdir -p "$htseq_dir_out/$FILE"
		printf "%s\n" "Counting of $FILE beginning..."
			if [[ "$strand_num" = "1" ]]; then	
				$HTSEQ_LOC $i $species_location/genes.gtf --stranded=no -m intersection-strict -f sam -i gene_id --additional-attr=gene_name > $htseq_dir_out/$FILE/$FILE-htseq.txt
			else
				$HTSEQ_LOC --stranded=yes -m intersection-strict -f sam -i gene_id --additional-attr=gene_name $i $species_location/genes.gtf  > $htseq_dir_out/$FILE/$FILE-htseq.txt
			fi
		printf "%s\n" "Counting of $FILE complete."
	else
		echo "Counting of $FILE complete."
	fi

#### This section is saving the htseq counts file & individual metrics for overall summary output

	## Htseq count overall metrics
	tail -5 $htseq_dir_out/$FILE/$FILE-htseq.txt > $htseq_dir_out/$FILE/$FILE-htseq_summary.log

	## Outputs only the gene counts without overall metrics at end of file (for easier merging with other gene counts later)
	head -n -5 $htseq_dir_out/$FILE/$FILE-htseq.txt > $htseq_dir_out/$FILE/$FILE-gene_counts_all.list

	## Creates list of only ERCC genes
	grep "^ERCC-" $htseq_dir_out/$FILE/$FILE-htseq.txt > $htseq_dir_out/$FILE/$FILE-ERCC.list
	
	## Gets count of ERCC reads
	awk '{ sum+=$3 } END { print sum }' $htseq_dir_out/$FILE/$FILE-ERCC.list > $htseq_dir_out/$FILE/$FILE-ERCC.count

	## Creates list of only mitochondrial genes
	grep -i "MT-" $htseq_dir_out/$FILE/$FILE-htseq.txt > $htseq_dir_out/$FILE/$FILE-MITO.list
	## Gets count of mitocondrial reads
	awk '{ sum+=$3 } END { print sum }' $htseq_dir_out/$FILE/$FILE-MITO.list > $htseq_dir_out/$FILE/$FILE-MITO.count

	## Create list without ERCC genes to get gene counts
	grep -Fvxf $htseq_dir_out/$FILE/$FILE-ERCC.list $htseq_dir_out/$FILE/$FILE-gene_counts_all.list >$htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.txt

	## Outputs number of genes with > X number of genes
	awk '{if ($3>0) print }' $htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.txt | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.0.count
	awk '{if ($3>1) print }' $htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.txt | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.1.count
	awk '{if ($3>2) print }' $htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.txt | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.2.count
#	awk '{if ($3>5) print }' $htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.txt | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.5.count
#	awk '{if ($3>10) print }' $htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.txt | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.10.count

	printf "%s\t" "$FILE" >> $summary_file ## Print sample name to summary   
    printf "%s\t" $(cat $htseq_dir_out/$FILE/$FILE-MITO.count) >> $summary_file ## Print Total mito reads to summary
    printf "%s\t" $(cat $htseq_dir_out/$FILE/$FILE-htseq.0.count) >> $summary_file ## Print Total > 0 reads to summary
    printf "%s\t" $(cat $htseq_dir_out/$FILE/$FILE-htseq.1.count) >> $summary_file ## Print Total > 1 reads to summary
    printf "%s\n" $(cat $htseq_dir_out/$FILE/$FILE-htseq.2.count) >> $summary_file ## Print Total > 2 reads to summary
done

htseq_version=$($HTSEQ_LOC --version)
echo "Counting performed using htseq-count version $htseq_version." >> $mapping_information