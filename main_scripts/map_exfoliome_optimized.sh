#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
#set -e

## Create directories to save various files in
map_log_dir="${project_dir}/logs/mapping"
mkdir -p ${map_log_dir}

## Create list for files that need to be mapped
SampleList=$(ls ${map_dir_in})

for Sample in ${SampleList}; do
	SampleName="${Sample%%.*}"
	map_file_out="${map_dir_out}/${SampleName}.optimized.sam"
	map_log_file="${map_log_dir}/${SampleName}.optimized.results.log"
		
		if [[ ! -f ${map_file_out} ]]; then
			echo "Beginning optimized alignment of $SampleName..."
			${BOWTIE} -x ${Bowtie2_ref} --threads ${THREADS} -U ${map_dir_in}/${Sample} -N 1 --mp 4,2  --very-sensitive-local --time -S ${map_file_out} 2> ${map_log_file}
			echo "Optimized alignment of $SampleName cmplete."
		else
			echo "✅ Sample ${SampleName} is already complete."
		fi
done

echo "✅ Alignment of all samples is complete!!!"

bowtie_version=$(${BOWTIE} --version | cut -d " " -f3 | head -1)

## Add Reference information to Mapping Info!!!!
cat >> "${mapping_information}" <<EOF
Alignment performed with Bowtie2 ${bowtie_version} with optimized parameters of -N 1, --mp 4,2, and --very-sensitive-local.
The reference ${species_ref} was used for sample alignment.
EOF