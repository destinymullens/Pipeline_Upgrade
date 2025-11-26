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

	logfile="${trim_log}/${SampleName}_processed.log"
	umi_out_file="${trim_dir_out1}/${SampleName}.processed.fastq.gz"
	trim_out_file="${trim_dir_out2}/${SampleName}.trimmed.processed.fastq.gz"
	
	if [[ ! -f ${trim_out_file} ]]; then	
		echo "Extracting of UMI's from ${SampleName}...."	
		${UMI_TOOLS} extract --bc-pattern=NNNNNN -I ${trim_dir_in}/${Sample} --log ${logfile} -S ${umi_out_file}
		echo "Extraction of UMI's from ${Sample} is now complete."
		${CUTADAPT} -q 30 -m 30 -j ${THREADS} -o ${trim_out_file} ${umi_out_file}
	else
		echo "Extraction of UMI's from ${Sample} is already complete."
	fi
done

echo "✅ Extraction of UMI's and trimming complete!"

umi_tools_version=$($UMI_TOOLS --version)
cutadapt_version=$($CUTADAPT --version)
## Add information to Mapping information document
cat >> "${mapping_information}" <<EOF

UMI extraction and deduplication performed with $umi_tools_version.
Quality trimming (Q30) performed and discarding of reads < 30 bp using Cutadapt version $cutadapt_version.
EOF