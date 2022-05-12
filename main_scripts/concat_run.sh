#!/bin/bash

# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
config_dir="$SAVE_LOC/$project_name/tmp"
project_name=$(cat $config_dir/project_name.txt)
SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)
concat_response=$(cat $config_dir/concat_response.txt)
concat_length=$(cat $config_dir/concat_response.txt)
trim_num=$(cat $config_dir/trim_num.txt)
data_type=$(cat $config_dir/data_type.txt)
strand_num=$(cat $config_dir/strand_num.txt)
file_location=$(cat $config_dir/file_location.txt)
qc_dir_in=$(cat $config_dir/qc_dir_in.txt)
qc_dir_out=$(cat $config_dir/qc_dir_out.txt)
trim_dir_in=$(cat $config_dir/trim_dir_in.txt)
htseq_dir_in=$(cat $config_dir/htseq_dir_in.txt)
mapping_information=$(cat $config_dir/mapping_information.txt)
mapfiles=$(cat $config_dir/mapfiles.txt)
trim_type=$(cat $config_dir/trim_type.txt)

SAMPLES=$(find $file_location -type f -printf '%f\n' | cut -c 1-$concat_length | sort | uniq)

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
#           zcat $FILES | lbzip2 > $NEW
    	   zcat $FILES | gzip > $NEW
           echo "... Done."; echo ""; echo ""
    fi
done

