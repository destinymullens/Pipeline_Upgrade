#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
set -e

mkdir -p "${project_dir}/htseq_counts"
htseq_dir_out="${project_dir}/htseq_counts"

SampleList=$(ls $htseq_dir_in)

## Creates headers for summary
mkdir -p "${htseq_dir_out}/sam_files"
mkdir -p "${htseq_dir_out}/counts"
#mkdir -p "${htseq_dir_out}/temp"
mkdir -p "${htseq_dir_out}/summary_file"

for Sample in ${SampleList}; do
	SampleName="${Sample%%.*}"
	counts_file_out="${htseq_dir_out}/counts/${SampleName}-htseq.csv"
	sam_file_out="${htseq_dir_out}/sam_files/${SampleName}-htseq.sam"
	summary_file_out="${htseq_dir_out}/summary_file/${SampleName}-htseq_summary.txt"

	FILE=$(basename $Sample)
	if [[ ! -f ${htseq_dir_out}/counts/${SampleName}-htseq.csv ]]; then
		echo "Quanitification of ${SampleName} beginning..."
			if [[ "${strand_num}" = "1" ]]; then	
				${HTSEQ_LOC} ${htseq_dir_in}/${Sample} ${HTSeq_ref} --stranded=no -m intersection-strict -f sam -i gene_id --additional-attr=gene_name -o ${sam_file_out} -c ${counts_file_out} --with-header
			else
				${HTSEQ_LOC} --stranded=yes -m intersection-strict -f sam -i gene_id --additional-attr=gene_name ${htseq_dir_in}/${Sample} ${HTSeq_ref} -o ${sam_file_out} -c ${counts_file_out} --with-header
			fi
		echo "Quanitification of ${SampleName} complete."
	else
		echo "Quanitification of ${SampleName} is already complete."
	fi
	#touch ${summary_file_out}
	tail -5 ${counts_file_out} > ${summary_file_out} #### Saving summary info to separate file
done

htseq_version=$(${HTSEQ_LOC} --version)

cat >> "${mapping_information}" <<EOF
Quanitification performed using htseq-count version ${htseq_version}.
EOF