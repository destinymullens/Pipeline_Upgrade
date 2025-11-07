#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

mkdir -p "${SAVE_LOC}/${project_name}/htseq_counts"
htseq_dir_out="${SAVE_LOC}/${project_name}/htseq_counts"
samples=$(ls $htseq_dir_in/*am)

summary_file="${SAVE_LOC}/${project_name}/summary/$project_name-htseq-metrics.csv"
## Creates headers for summary
printf "%s\t" "Sample Name" >> ${summary_file} ## Print sample name to summary  
printf "%s\t" "Genes > 0 Reads" >> ${summary_file} ## Print sample name to summary
printf "%s\t" "Genes > 1 Reads" >> ${summary_file} ## Print sample name to summary  
printf "%s\n" "Genes > 2 Reads" >> ${summary_file} ## Print sample name to summary  

mkdir -p "${htseq_dir_out}/sam_files"
mkdir -p "${htseq_dir_out}/counts"
mkdir -p "${htseq_dir_out}/summary"
mkdir -p "${htseq_dir_out}/temp"

for i in ${samples}; do
	FILE=$(basename $i)
	if [[ ! -f ${htseq_dir_out}/counts/${FILE}-htseq.csv ]]; then
		#mkdir -p "${htseq_dir_out}/${FILE}"
		printf "%s\n" "Counting of ${FILE} beginning..."
			if [[ "${strand_num}" = "1" ]]; then	
				${HTSEQ_LOC} ${i} ${species_location}/genes.gtf --stranded=no -m intersection-strict -f sam -i gene --additional-attr=GeneID -o ${htseq_dir_out}/sam_files/${FILE}-htseq.sam -c ${htseq_dir_out}/counts/${FILE}-htseq.csv --with-header
			else
				${HTSEQ_LOC} --stranded=yes -m intersection-strict -f sam -i gene --additional-attr=GeneID ${i} ${species_location}/genes.gtf -o ${htseq_dir_out}/sam_files/${FILE}-htseq.sam -c ${htseq_dir_out}/counts/${FILE}-htseq.csv --with-header
			fi
		printf "%s\n" "Counting of ${FILE} complete."
	else
		echo "Counting of ${FILE} complete."
	fi

#### This section is saving the htseq counts file & individual metrics for overall summary output

	## Htseq count overall metrics
	tail -5 ${htseq_dir_out}/counts/${FILE}-htseq.csv > ${htseq_dir_out}/summary/${FILE}-htseq_summary.txt
	
	## Outputs number of genes with > X number of genes
	awk '{if ($3>0) print }' ${htseq_dir_out}/counts/${FILE}-htseq.csv | wc -l > ${htseq_dir_out}/${FILE}-htseq.0.count
	awk '{if ($3>1) print }' ${htseq_dir_out}/counts/${FILE}-htseq.csv | wc -l > ${htseq_dir_out}/${FILE}-htseq.1.count
	awk '{if ($3>2) print }' ${htseq_dir_out}/counts/${FILE}-htseq.csv | wc -l > ${htseq_dir_out}/${FILE}-htseq.2.count

	printf "%s\t" "${FILE}" >> ${summary_file} ## Print sample name to summary   
    printf "%s\t" $(cat ${htseq_dir_out}/${FILE}-htseq.0.count) >> ${summary_file} ## Print Total > 0 reads to summary
    printf "%s\t" $(cat ${htseq_dir_out}/${FILE}-htseq.1.count) >> ${summary_file} ## Print Total > 1 reads to summary
    printf "%s\n" $(cat ${htseq_dir_out}/${FILE}-htseq.2.count) >> ${summary_file} ## Print Total > 2 reads to summary
    rm ${htseq_dir_out}/${FILE}-*.count
done

htseq_version=$(${HTSEQ_LOC} --version)
echo "Counting performed using htseq-count version ${htseq_version}." >> ${mapping_information}
