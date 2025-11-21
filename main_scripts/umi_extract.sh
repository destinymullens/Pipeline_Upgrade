#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
set -e

trim_log="${project_dir}/logs/umi_extraction"
mkdir -p ${trim_log}

#### Extract UMI's ####
SampleList=$(find ${trim_dir_in} -type f -printf '%f\n')

for Sample in ${SampleList}; do
	SampleName="${Sample%%.*}"

	logfile="${SampleName}_processed.log"
	stoutfile="${SampleName}_processed.fastq.gz"
	trimoutfile="${SampleName}_trimmed.processed.fastq.gz"
	
	if [[ ! -f ${trim_dir_out1}/${stoutfile} ]]; then	
		echo "Extracting of UMI's from ${SampleName}...."	
		${UMI_TOOLS} extract --bc-pattern=NNNNNN -I ${trim_dir_in}/${Sample} --log ${trim_log}/${logfile} -S ${trim_dir_out1}/${stoutfile}
		echo "Extraction of UMI's from ${Sample} is now complete."

		${CUTADAPT} -q 30 -m 30 -j ${THREADS} -o ${trimmed_dir_out}/${trimoutfile} ${trim_dir_out2}/${stoutfile}
	else
		echo "Extraction of UMI's from ${Sample} is already complete."
	fi
done

echo "✅ Extraction of UMI's and trimming complete!"

umi_tools_version=$($UMI_TOOLS --version)
echo "UMI extraction and deduplication performed with $umi_tools_version." >> $mapping_information
cutadapt_version=$($CUTADAPT --version)
echo "Quality trimming performed using Cutadapt version $cutadapt_version." >> $mapping_information