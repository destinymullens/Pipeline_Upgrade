#!/bin/bash

# Read config.sh
#. $(dirname $0)/../config.sh
source ${SAVE_LOC}/${project_name}/config.sh

##Import sample list from file location
#SAMPLES=$(find ${file_location} -type f -printf '%f\n' | cut -c 1-${concat_length} | sort | uniq)
#mkdir 
#for s in ${SAMPLES}; do
#	NEW=$s.fastq.gz
#   if [[ ! -s ${SAVE_LOC}/concat/$NEW ]]; then
#        FILES=$(find ${file_location} -iname "${s}"*.gz)
#        touch ${SAVE_LOC}/concat/$NEW
#        echo "For sample $s, concatenating input files:"
#        for f in ${FILES}; do
#            echo ${f}        
#        echo "into new file: $SAVE_LOC/concat/$NEW"; echo ""
#    	zcat ${FILES} > ${SAVE_LOC}/concat/${NEW}
#        echo "... Done."; echo ""; echo ""
#        done
#    fi
#done


#!/bin/bash
# Concatenate files in a directory based on shared filename prefix

# Exit on error
set -e

input_dir="$file_location"
prefix_length="$concat_length"
output_dir="${SAVE_LOC}/${project_name}/concat"

# Make sure directories exist
if [ ! -d "$file_location" ]; then
    echo "Error: Input directory '$file_location' not found."
    exit 1
fi

mkdir -p "$output_dir"

# Loop through files and group by prefix
declare -A groups

for file in "$file_location"/*; do
    # Skip directories
    [ -f "$file" ] || continue
    
    filename=$(basename "$file")
    prefix=${filename:0:$concat_length}
    
    groups["$prefix"]+="$file "
done

# Concatenate each group
for prefix in "${!groups[@]}"; do
    output_file="$output_dir/${prefix}.fastq.gz"
    echo "Concatenating group '$prefix' -> $output_file"
    cat ${groups[$prefix]} > "$output_file"
done

echo "✅ All groups concatenated successfully into '$output_dir'"