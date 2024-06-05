#!/bin/bash

## This script is to trim a specfic number of bases

# Read config.sh
#. $(dirname $0)/../config.sh
. ${SAVE_LOC}/${project_name}/config.sh

mkdir -p ${SAVE_LOC}/${project_name}/trimmed_files/$trim_type/trimmed
mkdir -p ${SAVE_LOC}/${project_name}/trimmed_files/$trim_type/umi_extracted

processed_dir_out="${SAVE_LOC}/${project_name}/trimmed_files/$trim_type/umi_extracted"
trim_log="${SAVE_LOC}/${project_name}/logs/$trim_type"
mkdir -p ${trim_log}

#### Extract UMI's ####
SAMPLES=$(find ${trim_dir_in} -type f -printf '%f\n')
for s in ${SAMPLES}; do
	samplename="${s%%.*}"
	logfile="${samplename}.processed.log"
	stoutfile="${samplename}.processed.fastq.gz"
	stoutfile_trimmed="${samplename}.trimmed.processed.fastq.gz"
	if [[ ! -f ${processed_dir_out}/${stoutfile} ]]; then
		echo "Extracting of UMI's from ${s}...."
		${UMI_TOOLS} extract --bc-pattern=NNNNNN -I ${trim_dir_in}/${s} --log ${trim_log}/${logfile} -S ${processed_dir_out}/${stoutfile}
		echo "Extraction of UMI's from ${s} is now complete."
	else
		echo "Extraction of UMI's from ${s} is already complete."
	fi
	if [[ ! -f ${trim_dir_out}/${stoutfile_trimmed} ]]; then
		echo "Begining trimming of ${s}...."
		${CUTADAPT} -u 4 -q 28 -o ${trim_dir_out}/${stoutfile_trimmed} ${processed_dir_out}/${stoutfile}
		echo "Trimming of ${s} is now complete."
		else
		echo "Trimming of ${s} is already complete."
	fi
done

echo "Extraction of UMI's and trimming complete!"
umi_tools_version=$($UMI_TOOLS --version)
echo "UMI extraction and deduplication performed with $umi_tools_version." >> $mapping_information
cutadapt_version=$($CUTADAPT --version)
echo "Trimming performed using Cutadapt version $cutadapt_version." >> $mapping_information