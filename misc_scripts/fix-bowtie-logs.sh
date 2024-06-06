#!/bin/bash

InDir="/mnt/matrix/pooh/2023_Donovan-4yr-olds/Exfoliome/Mappings/Donovan_4YR_Exfoliome_Mapping/logs/mapping"
OutDir="${InDir}/short_logs"


SAMPLES=$(find ${InDir} -type f -printf '%f\n')

for i in ${SAMPLES}; do
   listname="${i%%.*}"
   samplename="${listname%%_*}.log"
#   echo "The sample is: ${i}."
 #  echo "The listname is: ${listname}"
  # echo "The samplename is: ${samplename}."
   cat ${i} | tail -9 > ${OutDir}/${samplename}
done