#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

hostrefdir=${species_location}


MAP_FILES=$(ls ${mapfiles})
map_dir_out="${SAVE_LOC}/${project_name}/mapping"

SAMPLES=$(find ${map_dir_in} -type f -printf '%f\n')

for s in ${SAMPLES}; do
  samplename="${s%%.*}"
  outputdir="${map_dir_out}/${samplename}"
  mkdir -p ${outputdir}
  echo "##################################################################"
  echo "Processing file ${samplename}..."

  if [[ ! -d ${outputdir}/${samplename} ]]; then
    if [[ "${strand_num}" = "1" ]]; then
      for i in $(ls ${map_dir_in}); do
#       pushd ${outputdir}/star/$species
        ${STAR} --genomeDir ${species_location}/STAR --readFilesCommand gunzip -c --readFilesIn ${map_dir_in}/${i} --runThreadN $THREADS --sjdbGTFfile ${species_location}/genes.gtf --outSAMtype BAM Unsorted --genomeLoad NoSharedMemory --outFileNamePrefix ${outputdir}/${samplename}
#       popd
        echo -n "Mapping for ${samplename} is complete."
      done
    else
      for i in $(ls ${map_dir_in}/*R1*); do
        readsearch=$(echo ${i} | cut -c 1-10)
        read1=${i}
        read2=$(ls ${map_dir_in}/${readsearch}*R2*)r/${species}
        ${STAR} --genomeDir ${species_location}/STAR --readFilesCommand gunzip -c --readFilesIn ${map_dir_in}/${read1} ${map_dir_in}/${read2}  --runThreadN ${THREADS} --sjdbGTFfile ${species_location}/genes.gtf --outSAMtype BAM Unsorted --genomeLoad NoSharedMemory --outFileNamePrefix ${outputdir}/${samplename}
        echo -n "Mapping for ${samplename} is complete."
      done
    fi
    echo -n "Mapping for ${samplename} is already complete."
  fi
  echo "##################################################################"
done

star_version=$($STAR --version)
echo "Mapping performed using STAR version ${star_version}." >> ${mapping_information}