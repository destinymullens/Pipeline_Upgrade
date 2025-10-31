#!/bin/bash

# Read config.sh
#. $(dirname $0)/../config.sh
. ${SAVE_LOC}/${project_name}/config.sh

##Import sample list from file location
SAMPLES=$(find ${file_location} -type f -printf '%f\n' | cut -c 1-${concat_length} | sort | uniq)

for s in ${SAMPLES}; do
	NEW="${SAVE_LOC}/concat/$s.fastq.gz"
    if [[ ! -s $NEW ]]; then
        FILES=$(find ${file_location} -iname "${s}"*.gz)
        
        echo "For sample $s, concatenating input files:"
        for f in ${FILES}; do
            echo ${f}
        done
        echo "into new file: ${NEW}"; echo ""
    	zcat ${FILES} >> ${NEW}
        echo "... Done."; echo ""; echo ""
    
    fi
done