#!/bin/bash

# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
concat_length=$(cat $config_dir/concat_response.txt)
config_dir="$SAVE_LOC/$project_name/tmp"
data_type=$(cat $config_dir/data_type.txt)
file_location=$(cat $config_dir/file_location.txt)
project_name=$(cat $config_dir/project_name.txt)
SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)

##Import sample list from file location
SAMPLES=$(find $file_location -type f -printf '%f\n' | cut -c 1-$concat_length | sort | uniq)

$Set ouput directory for concatenated files
OUT="$SAVE_LOC/$project_name/concat"
mkdir -p $OUT

for s in $SAMPLES; do 
	NEW=$OUT/$s.fastq.gz
    if [[ ! -s $NEW ]]; then
        FILES=$(find $file_location -iname "$s"*.gz)
        echo "For sample $s, concatenating input files:"
        for f in $FILES; do 
            echo $f
        done
            echo "into new file: $NEW"; echo ""
    	   zcat $FILES | gzip > $NEW
           echo "... Done."; echo ""; echo ""
    fi
done