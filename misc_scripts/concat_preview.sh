#!/bin/bash

# Read config.sh
. $(dirname $0)/../config.sh

verify="0"

SAMPLES=$(find $file_location -type f -printf '%f\n' | cut -c 1-$concat_length | sort | uniq)

OUT="$SAVE_LOC/$project_name/concat"

for s in $SAMPLES; do
	NEW=$OUT/$s.fastq.gz
	if [[ ! -s $NEW ]]; then
		FILES=$(find $file_location -iname "$s"*.gz)
		echo "For sample $s, concatenating input files:"
			for f in $FILES; do
				echo $f
			done
		echo "into new file: $NEW"
		echo ""
	fi
done
