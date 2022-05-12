#!/bin/bash

# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
config_dir="$SAVE_LOC/$project_name/tmp"

concat_length=$(cat $config_dir/concat_response.txt)
concat_response=$(cat $config_dir/concat_length.txt)
data_type=$(cat $config_dir/data_type.txt)
file_location=$(cat $config_dir/file_location.txt)
htseq_dir_in=$(cat $config_dir/htseq_dir_in.txt)
mapfiles=$(cat $config_dir/mapfiles.txt)
mapping_information=$(cat $config_dir/mapping_information.txt)
project_name=$(cat $config_dir/project_name.txt)
qc_dir_in=$(cat $config_dir/qc_dir_in.txt)
qc_dir_out=$(cat $config_dir/qc_dir_out.txt)
SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)
strand_num=$(cat $config_dir/strand_num.txt)
trim_dir_in=$(cat $config_dir/trim_dir_in.txt)
trim_num=$(cat $config_dir/trim_num.txt)
trim_type=$(cat $config_dir/trim_type.txt)
species_location=$(cat $config_dir/species_location.txt)

mkdir -p "$SAVE_LOC/$project_name/htseq_counts"
htseq_dir_out="$SAVE_LOC/$project_name/htseq_counts"
samples=$(ls $htseq_dir_in/*.bam)


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
	awk '{if ($3>3) print }' $htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.txt | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.3.count
	awk '{if ($3>5) print }' $htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.txt | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.5.count
	awk '{if ($3>10) print }' $htseq_dir_out/$FILE/$FILE-gene_counts-no_ercc.txt | wc -l > $htseq_dir_out/$FILE/$FILE-htseq.10.count
done
htseq_version=$($HTSEQ_LOC --version)
echo "Counting performed using htseq-count version $htseq_version." >> $mapping_information