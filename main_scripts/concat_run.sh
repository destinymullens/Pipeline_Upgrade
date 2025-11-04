#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

input_dir="$file_location"
prefix_length="$concat_length"
output_dir="${SAVE_LOC}/${project_name}/concat"


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