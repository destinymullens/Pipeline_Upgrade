#!/bin/bash

# Read config.sh
source ${SAVE_LOC}/${project_name}/config.sh

set -e # Exit on error
set -a # Command exports variables automatically for other scripts

## Gather user input for various variables needed to determine the correct scripts for the pipeline to process
verify="0"

clear
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                                                                  +"
echo "+                                          Welcome to the                                          +"
echo "+                                 Chapkin Lab Sequencing Pipeline!                                 +"
echo "+                                                                                                  +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "Our pipeline is designed to asked questions about your data before proceeding to map your samples."
echo ""
echo "After all questions are answered the pipeline will process your data."
echo ""
echo "To begin, we need to name your project to create the folder that will contain your results."
echo "Please avoid using special characters such as: spaces, /, >, |, :, ?, *  or & in your project name."
echo "If using special characters, it must be quoted or escaped using the \ symbol."
echo ""
## Determine were to save project
read -p "Where would you like to save your project? (Note: Please use /home/username instead of ~/ if files are located in your home directory.)" SAVE_LOC
echo ""
read -p "What would you like to name your project? " project_name
project_location="${SAVE_LOC}/${project_name}"
echo "";
echo "Thank you! Your final results will be saved at ${project_location}"; sleep 3

## Determine if pipeline was previously ran
./misc_scripts/top_banner.sh
if [[ -f ${project_location}/config.sh ]]; then
	echo "This is already a configuration file saved at that location? Would you like to continue a previous mapping?"; echo "1. Yes"; echo "2. No"
	read -p "> " continuenum
	if [[ "${continuenum}" == "1" ]]; then
		nohup ./main_scripts/Pipeline_Execute.sh 1> ${SAVE_LOC}/${project_name}/${project_name}-log.out 2> ${SAVE_LOC}/${project_name}/${project_name}-log.err &
	else
		:
	rm ${SAVE_LOC}/${project_name}/config.sh
	fi
else

### Get file location
until [[ "${verify}" = "1" ]]; do
	verify="0"
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		read -p "Where are your files located? (Note: Please use /home/username instead of ~/ if files are located in your home directory.) " file_location
		echo " "
		find ${file_location} -type f -printf '%f\n'
		echo " "; echo "Are these the correct files?"; echo "1. Yes"; echo "2. No"
		read -p "> " verify
	done


## Determine if files need concatentation
	verify="0"	
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		read -p "Do you need to concatenate your files? 1. Yes 2. No " concat_response
		
		if [[ "${concat_response}" == "1" ]]; then
			read -p "How long is your filename? " concat_length
			concat_text="Your files need to be concatenated with a filename length of: ${concat_length}."
			./misc_scripts/concat_preview.sh
			echo "Is this correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		else
			concat_text="Your files do not need to be concatenated."; verify="1"
		fi
	done

## Determine input data type: Biopsy or Exfoliome
	verify="0"
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		echo "What type of RNA-seq data are you aligning?"; echo "1. Biopsy"; echo "2. Exfoliome"
		read -p "> " response
		
		## If biopsy then determine mapping program
		if [[ "${response}" = "1" ]]; then data_type="biopsy"
			echo ""; echo "You have entered ${data_type} as the type of data you are using. Is this correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify

			verify="0"
			until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
				echo ""; echo "You have entered ${data_type} as the type of data you are using. Would you like to use Bowtie2 or STAR for alignment?"; echo "1. Bowtie2"; echo "2. STAR"
				read -p "> " response
				
				if [[ "${response}" = "1" ]]; then data_type="You have selected biopsy using Bowtie2 for alignment."
					echo ""; echo "${data_type} Is this correct?"; echo "1. Yes"; echo "2. No"
					map_option='1A'
					read -p "> " verify

				elif [[ "${response}" = "2" ]]; then data_type="You have selected biopsy using STAR for alignment."
					echo ""; echo "You have selected biopsy using STAR for alignment. Is this correct?"; echo "1. Yes"; echo "2. No"
					map_option='1B'
					read -p "> " verify

				else echo "Your input is not one of the options, please try again."; sleep 3; continue
				fi
			done


		## If biopsy then determine if paired or single end reads
			verify="0"
			until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
				echo "Is your data single end or paired end? "
				echo "1. Single end"; echo "2. Paired end"
				read -p "> " strand_num
				if [[ "${strand_num}" = "1" ]]; then strand_text="single end"
				elif [[ "${strand_num}" = "2" ]]; then strand_text="paired end"
					echo "Important note: When using paired end samples, the files must end with R1.fastq.gz and R2.fastq.gz."
				else echo "Your input is not one of the options, please try again."; sleep 3; continue
				fi
				echo " "; echo "You entered ${strand_text}. Is this correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
			done


		## If biopsy then determine type of trimming and trimming options.
			verify="0"
			until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
				echo "Do you need to trim the data?"
				echo "1. No, the data does not need to be trimmed."; 
				echo "2. Yes, the data needs to be trimmed using a quality score."
				echo "3. Yes, the data needs a specific number of bases trimmed."; 
				echo "4. Yes, the data needs to be trimmed using UMI's."
				read -p "> " trim_option
		
			if [[ "${trim_option}" = "1" ]]; then 
				trim_text="The data does not need to be trimmed."				
			elif [[ "${trim_option}" = "2" ]]; then
				read -p "Please enter the quality score you would like to use: " trim_quality_score
				trim_text="The data needs to be trimmed using a quality score of ${trim_quality_score}."				
        	elif [[ "${trim_option}" = "3" ]]; then
            	read -p "Please enter the number of bases you would like to trim: " trim_num_base
            	trim_text="The data needs ${trim_base_num} bases trimmed." 	
        	elif [[ "${trim_option}" = "4" ]]; then 
				trim_text="The data needs to be trimmed using UMI's."			
        	else echo "Your input is not one of the options, please try again."; sleep 3; continue

        	fi
	  		echo ""; echo "${trim_text} Is this correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
			done

		## If data is exfoliome, set options and select pipeline
		elif [[ "${data_type_num}" = "2" ]]; then data_type="exfoliome"
			echo ""; echo "You have entered ${data_type} as the type of data you are using. Is this correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
			trim_option="4"
			trim_text="The data needs to be trimmed using UMI's."
			strand_text="single end"
 			
 			## Determine Exfoliome Default or Optimized Pipeline
 			verify="0"
			until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
				echo ""; echo "You have entered ${data_type} as the type of data you are using. Would you like to use the default or optimized pipeline?"; echo "1. Default"; echo "2. Optimized"
				read -p "> " exfoliome_map_option

				if [[ "${exfoliome_map_option}" = "1" ]]; then data_type="exfoliome_default"
					echo ""; echo "You have selected the exfoliome default pipeline. Is this correct?"; echo "1. Yes"; echo "2. No"
					map_option='2B'
					read -p "> " verify

				elif [[ "${exfoliome_map_option}" = "2" ]]; then data_type="exfoliome_optimized"
					echo ""; echo "You have selected the exfoliome optimized pipeline. Is this correct?"; echo "1. Yes"; echo "2. No"
					map_option='2A'
					read -p "> " verify

				else echo "Your input is not one of the options, please try again."; sleep 3; continue
				fi
			done
		else echo "Your input is not one of the options, please try again."; sleep 3; continue
		fi
	done




## Input species and set htseq type (gene_id or gene_name)
## Updated pre-programmed genomes (human,mouse,pig,horse,rat) that have been updated and
## are now in a folder with a new name should be updated in the corresponding species_location line
	verify="0"

	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		echo "Please enter the species type:"
		echo "1. Human"; echo "2. Mouse"; echo "3. Pig"; echo "4. Horse"; echo "5. Rat"; echo "6. Other"
		read -p "> " species_type
		
		if [[ "${species_type}" = "1" ]]; then 
			species="human"; species_location="${REF_LOC}/GRCh38p14-human"; species_ref="GRCh38.p14"
			echo ""; echo "Is ${species} correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify	


		elif [[ "${species_type}" = "2" ]]; then 
			species="mouse"; species_location=${REF_LOC}/GRCm39-mouse; species_ref="GRCm39"
			echo ""; echo "Is ${species} correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify		

		elif [[ "${species_type}" = "3" ]]; then 
			species="pig"; species_location=${REF_LOC}/pig; species_ref="Sus crofa 11.1"
			echo ""; echo "Is ${species} correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify			

		elif [[ "${species_type}" = "4" ]]; then 
			species="Equus_caballus-horse"; species_location=${REF_LOC}/Equus_caballus_Aug2024; species_ref="Equus caballus 3.0"
			echo ""; echo "Is ${species} correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify		

		elif [[ "${species_type}" = "5" ]]; then 
			species="rat"; species_location=${REF_LOC}/GRCr-8-rat; species_ref="GRCr8"; 
			echo ""; echo "Is ${species} correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify		

		else echo "Your input is not one of the options, please try again."; sleep 3; continue
		fi
	done

## Get concat number & check
	verify="0"	
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		read -p "Would you like to run FastQC or skip it? 1. Yes! Run FastQC! 2. No. Please skip for now." qc_response
		
		if [[ "${qc_response}" == "1" ]]; then
			qc_text="run FastQC"
			read -p "You have indicated you would like to run FastQC. " 
			echo "Is this correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
			verify="1"
		else
			qc_text="skip FastQC"
			read -p "You have indicated you would like to skip running FastQC. " 
			echo "Is this correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
			verify="1"
		fi
	done

## Final verification of information before beginning pipeline
	./misc_scripts/top_banner.sh
	echo "Thank you for all of your input! Let's verify things one last time before beginning."; echo ""
	echo "The project ${project_name} will be saved at ${file_location}"
	echo "${concat_text}"; 
	echo "Type of samples: ${data_type}"
	echo "Species: ${species}" with reference ${species_ref}; 
	echo "Your data is ${strand_type}."
	echo "${trim_disp}"; echo ""; echo ""
	echo "Would you like to proceed?"; echo "1. Yes"; echo "2. No"; echo "3. Please exit"
	read -p "> " verify

	## Save information to Mapping Info
	mkdir -p "${project_location}/summary"
	mapping_information="${project_location}/summary/${project_name}-Mapping_Information.txt"
	echo "The project ${project_name} is mapping data located at ${file_location}." >> ${mapping_information}
	echo "The samples were indicated to be ${species} ${data_type}." >> ${mapping_information}
	echo "Your data is ${strand_type}." >> ${mapping_information}
	echo "${trim_disp}" >> ${mapping_information}
	echo " " >> ${mapping_information}
	start_time=$(timedatectl | head -1 | cut -d " " -f18-20)
	echo "Mapping beginning at ${start_time}." >> ${mapping_information}
	
	if [[ "${verify}" = "3" ]]; then
		exit
	fi
done

## Create directories to save various files in
mkdir -p ${SAVE_LOC}/${project_name}/mapping
mapping_dir_out="${SAVE_LOC}/${project_name}/mapping"
mkdir -p ${SAVE_LOC}/${project_name}/logs/mapping
mapping_logs="${SAVE_LOC}/${project_name}/logs/mapping"

## Create project specific config file
cp config.sh ${project_location}/config.sh
project_config="${project_location}/config.sh"

echo "SAVE_LOC=$SAVE_LOC" >> ${project_config}
echo "project_name=${project_name}" >> ${project_config}
echo "project_location=${project_location}" >> ${project_location}
echo "concat_response=${concat_response}" >> ${project_config}
echo "concat_length=${concat_length}" >> ${project_config}
echo "qc_response=${qc_response}" >> ${project_config}
echo "trim_num=${trim_num}" >> ${project_config}
echo "data_type=$data_type" >> ${project_config}
echo "exfoliome_map_option=$exfoliome_map_option" >> ${project_config}
echo "strand_num=${strand_num}" >> ${project_config}
echo "file_location=${file_location}" >> ${project_config}
echo "mapfiles=${mapfiles}" >> ${project_config}
echo "mapping_information=${mapping_information}" >> ${project_config}
echo "trim_type=${trim_type}" >> ${project_config}
echo "species=${species}" >> ${project_config}
echo "species_location=${species_location}" >> ${project_config}
echo "trim_quality_num=${trim_quality_num}" >> ${project_config}
echo "trim_base_num=${trim_base_num}" >> ${project_config}
echo "mapping_dir_out=${mapping_dir_out}" >> ${project_config}
echo "mapping_logs=${mapping_logs}" >> ${project_config}


if [[ "${trim_num}" = "4" ]]; then
		htseq_dir_in=${SAVE_LOC}/${project_name}/trimmed_files/${trim_type}/4_deduplicated_files
		echo "htseq_dir_in=${htseq_dir_in}" >> ${project_config}
	else
		htseq_dir_in=${SAVE_LOC}/${project_name}/mapping
		echo "htseq_dir_in=${htseq_dir_in}" >> ${project_config}
fi

nohup ./main_scripts/Pipeline_Execute.sh 1> ${SAVE_LOC}/${project_name}/${project_name}-log.out 2> ${SAVE_LOC}/${project_name}/${project_name}-log.err &
fi
