#!/bin/bash

# Read config.sh
source ${project_location}/config.sh

# Exit on error
set -e

## Create directories to save various files in

map_dir_out="${project_location}/mapping"
mkdir -p ${map_dir_out}

map_logs="${project_location}/logs/mapping"
mkdir -p ${map_logs}

## Create list for files that need to be mapped
SampleList=$(ls ${map_dir_in})
SUMMARY="${SAVE_LOC}/${project_name}/summary/$project_name-Mapping_summary.csv"

for s in ${SampleList}; do
	FILE=$(basename $s)
	
	${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -U ${map_dir_in}/${s} -N 1 --mp 4,2  --very-sensitive-local --time -S ${mapping_dir_out}/${FILE}-Optimized.sam 2> ${mapping_logs}/${FILE}-Optimized-Results.log
	printf "%s\n" "Optimized alignment of ${FILE} complete."	
done
printf "%s\n" "✅ Mapping of all samples complete."
bowtie_version=$(${BOWTIE} --version | cut -d " " -f3 | head -1)
echo "Mapping performed using Bowtie2 version ${bowtie_version} with optimized parameters -N 1, --mp 4,2, and --very-sensitive-local." >> ${mapping_information}