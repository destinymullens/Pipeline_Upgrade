#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

# Exit on error
set -e

mkdir -p ${SAVE_LOC}/${project_name}/trimmed_files/$trim_type
mkdir -p ${SAVE_LOC}/${project_name}/trimmed_files/$trim_type/umi_extracted

processed_dir_out="${SAVE_LOC}/${project_name}/trimmed_files/$trim_type/1_umi_extracted"
trimmed_dir_out="${SAVE_LOC}/${project_name}/trimmed_files/$trim_type/2_quality_trim"
trim_log="${SAVE_LOC}/${project_name}/logs/$trim_type/umi_extraction"
mkdir -p ${trim_log}

#### Extract UMI's ####
SAMPLES=$(find ${trim_dir_in} -type f -printf '%f\n')

for s in ${SAMPLES}; do
	samplename="${s%%.*}"
	logfile="${samplename}_processed.log"
	stoutfile="${samplename}_processed.fastq.gz"
	trimoutfile="${samplename}_trimmed.processed.fastq.gz"
	
	if [[ ! -f ${processed_dir_out}/${stoutfile} ]]; then	
		echo "Extracting of UMI's from ${s}...."	
		${UMI_TOOLS} extract --bc-pattern=NNNNNN -I ${trim_dir_in}/${s} --log ${trim_log}/${logfile} -S ${processed_dir_out}/${stoutfile}
		echo "Extraction of UMI's from ${s} is now complete."
		${CUTADAPT} -q 30 -m 30 -j ${THREADS} -o ${trimmed_dir_out}/${trimoutfile} ${processed_dir_out}/${stoutfile}
	else
		echo "Extraction of UMI's from ${s} is already complete."
	fi
done

echo "✅ Extraction of UMI's and trimming complete!"

umi_tools_version=$($UMI_TOOLS --version)
echo "UMI extraction and deduplication performed with $umi_tools_version." >> $mapping_information
cutadapt_version=$($CUTADAPT --version)
echo "Quality trimming performed using Cutadapt version $cutadapt_version." >> $mapping_information