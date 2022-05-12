##!/bin/bash

echo "Mapping single-end biopsy now.."

#!/bin/bash

## This script is to map biopsy samples using STAR

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
