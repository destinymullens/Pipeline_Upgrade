#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh

# Exit on error
set -e


SUMMARY="${project_dir}/summary/$project_name-Mapping_summary.csv"

##### RUN BOWTIE2 #########

if [[ "${strand_num}" = "1" ]]; then

	for i in $(ls ${mapfiles}); do

		FILE=$(basename $i)
		if [[ ! -f ${mapping_dir_out}/${FILE}.sam ]]; then
			echo "Mapping of ${FILE} is already complete!"
		else
			printf "%s\n" "Mapping of ${FILE} beginning..."
			${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -U ${mapfiles}/${m} --time -S ${mapping_dir_out}/${FILE}.sam 2> ${mapping_logs}/${FILE}-Results.log
			printf "%s\n" "Mapping of ${FILE} complete."
		fi
	done

else
	for i in $(ls ${mapfiles}/*R1*); do
        read1=${i}
        readsearch=$(echo ${i} | cut -d_ -f1)
        read2=$(ls ${mapfiles}/${readsearch}*R2*)
		${BOWTIE} -x ${species_location}/bowtie2/${species} --threads ${THREADS} -1 ${mapfiles}/${read1} -2 ${mapfiles}/${read2} --time -S ${mapping_dir_out}/${FILE}.sam 2> ${mapping_logs}/${FILE}-Results.log
			printf "%s\n" "Mapping of ${FILE} complete."
	done
fi
printf "%s\n" "✅ Mapping of all samples complete."
bowtie_version=$(${BOWTIE} --version | cut -d " " -f3)
echo "Mapping performed using Bowtie2 version ${bowtie_version} with default settings." >> ${mapping_information}