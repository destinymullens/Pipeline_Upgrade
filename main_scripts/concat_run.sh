#!/bin/bash

# Read config.sh
#. $(dirname $0)/../config.sh
source ${SAVE_LOC}/${project_name}/config.sh

##Import sample list from file location
SAMPLES=$(find ${file_location} -type f -printf '%f\n' | cut -c 1-${concat_length} | sort | uniq)

for s in ${SAMPLES}; do
	NEW=$s.fastq.gz
    if [[ ! -s ${SAVE_LOC}/concat/$NEW ]]; then
        touch ${SAVE_LOC}/concat/$NEW
        FILES=$(find ${file_location} -iname "${s}"*.gz)
        
        echo "For sample $s, concatenating input files:"
        for f in ${FILES}; do
            echo ${f}
        done
        echo "into new file: $SAVE_LOC/concat/$NEW"; echo ""
    	zcat ${FILES} >> ${SAVE_LOC}/concat/${NEW}
        echo "... Done."; echo ""; echo ""
    
    fi
done