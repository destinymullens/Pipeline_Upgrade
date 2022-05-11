##!/bin/bash

echo "Mapping single-end biopsy now.."

#!/bin/bash

## This script is to map biopsy samples using STAR

# Read config.sh
. $(dirname $0)/../config.sh
. $SAVE_LOC/$project_name/project_config.sh

if [[ "$trim_type" = "untrimmed" ]]; then
	map_dir_in="$SAVE_LOC/$project_name/concat"
	read_cmd="bunzip2 -c"
	else
 	map_dir_in="$SAVE_LOC/$project_name/trimmed_files/$trim_type"
	read_cmd="gunzip -c"
fi

map_dir_out="$SAVE_LOC/$project_name/mapping"


SAMPLES=$(find $map_dir_in -type f -printf '%f\n')
ls -m $map_dir_in | tr -s ', ' ',' > "$project_name/samplelist.txt"

for s in $SAMPLES; do
  samplename="${s%%.*}"
  outputdir="$map_dir_out/$samplename"
  mkdir -p $outputdir
  hostrefdir=$species_location

  echo "##################################################################"
  echo "Processing file $samplename..."

  ################################ HOST ##########################

  if [[ ! -d $outputdir/$samplename ]];
    then
	for i in $(ls $map_dir_in); do
		echo -n "Running STAR against host reference ... "
#      		pushd $outputdir/star/$species
      		$STAR --genomeDir $species_location/STAR --readFilesCommand $read_cmd $map_dir_in/$i --runThreadN $THREADS --sjdbGTFfile $species_location/genes.gtf --outSAMtype BAM Unsorted --genomeLoad NoSharedMemory --outFileNamePrefix $outputdir/$samplename
      		echo "Done."
      		echo -n "Filtering STAR host alignments... "
#		popd
      		echo "Done."
	done
    fi

    echo "##################################################################"

  done #
#  mydate 
#  echo -n "Counting reads using HTSeq-count ... "
#  eval parallel --gnu -j15 main-scripts/htseq.sh {} $species $hostrefdir ::: $currouts
#  echo "Done."

#mydate
#echo ""
