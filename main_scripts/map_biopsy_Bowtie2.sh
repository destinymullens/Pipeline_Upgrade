#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
set -e

## Create directories to save various files in

map_log_dir="${project_dir}/logs/mapping"
mkdir -p ${map_log_dir}

## Create list for files that need to be mapped
SampleList=$(ls ${map_dir_in})

if [[ "${strand_num}" = "1" ]]; then

	for Sample in ${SampleList}; do
		SampleName="${Sample%%.*}"
		map_file_out="${map_dir_out}/${SampleName}.sam"
		map_log_file="${map_log_dir}/${SampleName}.results.log"

		if [[ ! -f ${map_file_out} ]]; then
			echo "Alignment of ${SampleName} is already complete!"
		else
			echo "Beginning alignment of $SampleName..."
			${BOWTIE} -x ${Bowtie2_ref} --threads ${THREADS} -U ${map_dir_in}/${Sample} --time -S ${map_file_out} 2> ${map_log_file}
			echo "Optimized alignment of $SampleName complete."
		fi
	done
else
	for Sample in $(ls ${map_dir_in}/*R1*); do
        SampleName="${Sample%%.*}"
        map_file_out="${map_dir_out}/${SampleName}.sam"
		map_log_file="${map_log_dir}/${SampleName}.results.log"
        read1=${Sample}
        readsearch=$(echo ${Sample} | cut -d_ -f1)
        read2=$(ls ${mapfiles}/${readsearch}*R2*)
        map_file_out="${map_dir_out}/${SampleName}.sam"
		map_log_file="${map_log_dir}/${SampleName}.results.log"

		${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -1 ${map_dir_in}/${read1} -2 ${map_dir_in}/${read2} --time -S ${map_file_out} 2> ${map_log_file}
			printf "%s\n" "Mapping of ${FILE} complete."
	done
fi

echo "✅ Alignment of all samples is complete!!!"

bowtie_version=$(${BOWTIE} --version | cut -d " " -f3 | head -1)

## Add Reference information to Mapping Info!!!!
cat >> "${mapping_information}" <<EOF
Alignment performed with Bowtie2 ${bowtie_version} with default parameters.
The reference ${species_ref} was used for sample alignment.
EOF