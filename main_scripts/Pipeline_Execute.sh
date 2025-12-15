#!/bin/bash

# Read config.sh
source ${project_dir}/config.sh
project_config="${project_dir}/config.sh"
# Exit on error
set -e # Exit on error
set -a # Command exports variables automatically for other scripts
./misc_scripts/top_banner.sh

## The following points to the reference genome information for each species in the pipeline
## and to the reference gtf file for htseq quantification.
## NOTE: If a new species is added here, the option must also be added to the selection in Run_Chapkin_Lab_Pipeline.sh
if [[ "${species_type}" = "1" ]]; then 
	species_ref=GRCh38.p14; 
	Bowtie2_ref=${ref_dir}/GRCh38p14-human/bowtie2/GRCh38p14-human;
	STAR_ref=${ref_dir}/GRCh38p14-human/STAR; 
	HTSeq_ref=${ref_dir}/GRCh38p14-human/gencode.v49.primary_assembly.annotation.gtf;
	htseq_id="gene_id";
	htseq_extra_id="gene_name";
elif [[ "${species_type}" = "2" ]]; then 
	species_ref=GRCm39; 
	Bowtie2_ref=${ref_dir}/GRCm39-mouse/bowtie2/GRCm39.mouse; 
	STAR_ref=${ref_dir}/GRCm39-mouse/STAR; 
	HTSeq_ref=${ref_dir}/GRCm39-mouse/bowtie2/GRCm39.mouse/GCF_000001635.27_GRCm39_genomic.gtf;
	htseq_id="db_xref";
	htseq_extra_id="gene_id";
elif [[ "${species_type}" = "3" ]]; then
	species_ref="Sus crofa 11.1";
	Bowtie2_ref=${ref_dir}/pig/bowtiedb_xref2/pig; 
	STAR_ref=${ref_dir}/pig/STAR;
	HTSeq_ref=${ref_dir}/pig/Sus_scrofa.Sscrofa11.1.107.gtf;
	htseq_id="gene_id";
	htseq_extra_id="gene_name";
elif [[ "${species_type}" = "4" ]]; then
	species_ref="Equus caballus 3.0";
	Bowtie2_ref=${ref_dir}/Equus_caballus_Aug2024/bowtie2/Equus_caballus-horse; 
	STAR_ref=${ref_dir}/Equus_caballus_Aug2024/STAR;
	HTSeq_ref=${ref_dir}/Equus_caballus_Aug2024/GCF_041296265.1_TB-T2T_genomic.gtf;
	htseq_id="db_xref";
	htseq_extra_id="gene_id";
else 
	species_ref="GRCr8";
	Bowtie2_ref=${ref_dir}/GRCr8-rat/bowtie2/GRCr8; 
	STAR_ref=${ref_dir}/GRCr8-rat/STAR;
	HTSeq_ref=${ref_dir}/GRCr8-rat/GCF_036323735.1/genomic.gtf;
	htseq_id="db_xref";
	htseq_extra_id="gene_id";
fi

cat >> "${project_config}" <<EOF
species_ref="${species_ref}"
Bowtie2_ref="${Bowtie2_ref}"
STAR_ref="${STAR_ref}"
HTSeq_ref="${HTSeq_ref}"
htseq_id="${htseq_id}";
htseq_extra_id="${htseq_extra_id}";
EOF
## To add a new reference, change the last "else to" to the following line:
# elif [[ "${species_type}" = "5" ]]; then
## The add the following lines:
# else
#	species_ref=new_species; 
#	Bowtie2_ref=${ref_dir}/new_species/bowtie2/new_species; 
#	STAR_ref=${ref_dir}/new_species/STAR;
#	HTSeq_ref=${ref_dir}/new_species/new_species.gtf;
#	htseq_id=""; # <- Should contain the field with Ensembl ID
#	htseq_extra_id=""; # <- Should contain the field with Gene Name

#fi
##################################################################

## Run concatenation script if needed
if [[ "${concat_response}" == "1" ]]; then
	concat_dir=${project_dir}/concat
	mkdir -p ${concat_dir}
	trim_dir_in=${concat_dir}
	qc_dir_in=${concat_dir}
	echo "${trim_dir_in}"
	./main_scripts/concat_files.sh
else
	echo "File concatentation not needed."
	trim_dir_in=${file_location}
	qc_dir_in="${file_location}"
fi

## Run FastQC script if needed
if [[ "${qc_response}" == "1" ]]; then
	qc_dir_out=${project_dir}/qc_reports
	mkdir -p "${qc_dir_out}"
	./main_scripts/FastQC_run.sh
else
	echo "Skipping FastQC!"
fi

## Run trimming scripts if needed
if [[ "${trim_option}" = "4" ]]; then ## Trimming with UMI's
	echo "Beginning trimming of files..."
	trim_dir_out1=${project_dir}/trimmed_files/1_umi_extract
	#trim_dir_out2=${project_dir}/trimmed_files/2_quality_trim
	mkdir -p ${trim_dir_out1}
	#mkdir -p ${trim_dir_out2}
	map_dir_in=${trim_dir_out1}
	./main_scripts/umi_extract.sh
elif [[ "${trim_option}" = "3" ]]; then ## Trimming by Quality Score
	trim_dir_out=${project_dir}/trimmed_files/base_trim 
	mkdir -p ${trim_dir_out}
	map_dir_in=${trim_dir_out}
	./main_scripts/trim_quality.sh		
elif [[ "${trim_option}" = "2" ]]; then ## Trimming by Number Bases
	trim_dir_out=${project_dir}/trimmed_files/quality_trim
	mkdir -p ${trim_dir_out}
	map_dir_in=${trim_dir_out}
	./main_scripts/trim_base.sh		
else
	echo "No trimming needed!"
	if [[ "${concat_response}" == "1" ]]; then
		map_dir_in=${concat_dir}	
	else
		map_dir_in=${file_location}
	fi
fi

## Map Samples
if [[ "${trim_option}" = "4" ]]; then
	map_dir_out=${project_dir}/mapping_results
	mkdir -p ${map_dir_out}
	if [[ "${data_option}" = "1A" ]]; then
		./main_scripts/map_biopsy_Bowtie2.sh
	elif [[ "${data_option}" = "1B" ]]; then 
		./main_scripts/map_biopsy_STAR.sh
	elif [[ "${data_option}" = "2A" ]]; then 
		./main_scripts/map_exfoliome_optimized.sh
	else
		./main_scripts/map_exfoliome_default.sh
	fi
	dedup_dir_in=$map_dir_out
	index_dir_out=${project_dir}/trimmed_files/2_indexed_files
	dedup_dir_out=${project_dir}/trimmed_files/3_deduplicated_files
	mkdir -p ${index_dir_out}
	mkdir -p ${dedup_dir_out}
	./main_scripts/umi_dedup.sh
	htseq_dir_in=${dedup_dir_out}
	htseq_dir_out=${project_dir}/htseq_counts
	mkdir -p ${htseq_dir_out}
	./main_scripts/htseq.sh
else
	map_dir_out=${project_dir}/mapping_results
	mkdir -p ${map_dir_out}
	if [[ "${data_option}" = "1A" ]]; then
		./main_scripts/map_biopsy_Bowtie2.sh
	elif [[ "${data_option}" = "1B" ]]; then 
		./main_scripts/map_biopsy_STAR.sh
	elif [[ "${data_option}" = "2A" ]]; then 
		./main_scripts/map_exfoliome_optimized.sh
	else
		./main_scripts/map_exfoliome_default.sh
	fi
	htseq_dir_in=${map_dir_out}
	htseq_dir_out=${project_dir}/htseq_counts
	mkdir -p ${htseq_dir_out}
	./main_scripts/htseq.sh
fi

./main_scripts/summary.sh 	
echo " " >> ${mapping_information}
echo "All mapping is completed for ${project_name}! Your files are located at ${project_dir}."
echo "All mapping is completed for ${project_name} and files are located at ${project_dir}." >> ${mapping_information}
completed_time=$(timedatectl | head -1 | cut -d " " -f18-20)
echo "Mapping completed at: ${completed_time}." >> ${mapping_information}