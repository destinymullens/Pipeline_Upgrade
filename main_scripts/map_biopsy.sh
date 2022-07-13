##!/bin/bash

## This script is to map biopsy samples using STAR
# Read config.sh
. $SAVE_LOC/$project_name/config.sh

if [[ "$trim_type" = "untrimmed" ]]; then
  if [[ "$concat_response" = "1" ]]; then
    map_dir_in="$SAVE_LOC/$project_name/concat"
    read_cmd="bunzip2 -c"
  else
    map_dir_in="$file_location"
  fi
else
 	map_dir_in="$SAVE_LOC/$project_name/trimmed_files/$trim_type"
	read_cmd="gunzip -c"
fi

map_dir_out="$SAVE_LOC/$project_name/mapping"

SAMPLES=$(find $map_dir_in -type f -printf '%f\n')

for s in $SAMPLES; do
  samplename="${s%%.*}"
  outputdir="$map_dir_out/$samplename"
  mkdir -p $outputdir
  hostrefdir=$species_location

echo "##################################################################"
echo "Processing file $samplename..."

if [[ ! -d $outputdir/$samplename ]]; then
  if [[ "$strand_num" = "1" ]]; then
    for i in $(ls $map_dir_in); do
      echo -n "Running STAR against host reference ... "
#      pushd $outputdir/star/$species
      $STAR --genomeDir $species_location/STAR --readFilesCommand $read_cmd $map_dir_in/$i --runThreadN $THREADS --sjdbGTFfile $species_location/genes.gtf --outSAMtype BAM Unsorted --genomeLoad NoSharedMemory --outFileNamePrefix $outputdir/$samplename
      echo "Done."
      echo -n "Filtering STAR host alignments... "
#      popd
      echo "Done."
    done
  else
    for i in $(ls $map_dir_in/*R1*); do
      readsearch=$(echo $i | cut -c 1-10)
      read1=$i
      read2=$(ls $map_dir_in/$readsearch*R2*)
      echo -n "Running STAR against host reference ... "
#      pushd $outputdir/star/$species
      $STAR --genomeDir $species_location/STAR --readFilesCommand $read_cmd $map_dir_in/$read1 $map_dir_in/$read2  --runThreadN $THREADS --sjdbGTFfile $species_location/genes.gtf --outSAMtype BAM Unsorted --genomeLoad NoSharedMemory --outFileNamePrefix $outputdir/$samplename
      echo "Done."
      echo -n "Filtering STAR host alignments... "
#      popd
      echo "Done."
    done
  fi
  echo "Mapping for $samplename is already complete."
fi
echo "##################################################################"