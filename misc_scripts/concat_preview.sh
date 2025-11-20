#!/bin/bash

# Read config.sh
source ${project_location}/config.sh

verify="0"

SampleList=$(find ${file_location} -type f -printf '%f\n' | cut -c 1-${concat_length} | sort | uniq)

Output="${project_location}/concat"

for s in ${SampleList}; do
	NEW=${Output}/${s}.fastq.gz
	if [[ ! -s ${NEW} ]]; then
		FILES=$(find $file_location -iname "${s}"*.gz)
		echo "For sample $s, concatenating input files:"
			for f in ${FILES}; do
				echo ${f}
			done
		echo "into new file: ${NEW}"
		echo ""
	fi
done