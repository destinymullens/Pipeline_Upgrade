#!/bin/bash

InDir="/mnt/matrix/pooh/2022_Lampe_Fish_and_Fiber/Batch2/Lampe_FF_Batch2-optimized/logs/mapping"
OutDir="/mnt/matrix/pooh/2022_Lampe_Fish_and_Fiber/Batch2/Lampe_FF_Batch2-optimized/logs/mapping/short_logs"


SAMPLES=$(find ${InDir} -type f -printf '%f\n')

for i in ${SAMPLES}; do
   listname="${i%%.*}"
   samplename="${listname%%_*}.log"
#   echo "The sample is: ${i}."
 #  echo "The listname is: ${listname}"
  # echo "The samplename is: ${samplename}."
   cat ${i} | tail -9 > ${OutDir}/${samplename}
done