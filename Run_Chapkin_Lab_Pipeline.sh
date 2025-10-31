#!/bin/bash

# Read config.sh
. $(dirname $0)/config.sh
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
read -p "Where would you like to save your project? (Note: Please use /home/username instead of ~/ if files are located in your home directory.)" SAVE_LOC
echo ""
read -p "What would you like to name your project? " project_name
echo "";
echo "Thank you! Your final results will be saved at ${SAVE_LOC}/${project_name}"; sleep 3

## Get file location
./misc_scripts/top_banner.sh
if [[ -f ${SAVE_LOC}/${project_name}/config.sh ]]; then
	echo "This is already a configuration file saved at that location? Would you like to continue a previous mapping?"; echo "1. Yes"; echo "2. No"
	read -p "> " continuenum
	if [[ "${continuenum}" == "1" ]]; then
		nohup ./main_scripts/Pipeline_Execute.sh 1> ${SAVE_LOC}/${project_name}/${project_name}-log.out 2> ${SAVE_LOC}/${project_name}/${project_name}-log.err &
	else
		:
	fi
else
	rm ${SAVE_LOC}/${project_name}/config.sh


until [[ "${verify}" = "1" ]]; do
	## Get file location
	verify="0"
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		read -p "Where are your files located? (Note: Please use /home/username instead of ~/ if files are located in your home directory.) " file_location
		echo " "
		find ${file_location} -type f -printf '%f\n'
		echo " "; echo "Are these the correct files?"; echo "1. Yes"; echo "2. No"
		read -p "> " verify
	done

## Get concat number & check
	verify="0"	
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		read -p "Do you need to concatenate your files? 1. Yes 2. No " concat_response
		if [[ "${concat_response}" == "1" ]]; then
			read -p "How long is your filename? " concat_length
			./misc_scripts/concat_preview.sh
			echo "Is this correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		else
			concat_length="NA"
			verify="1"
		fi
	done

## Input data type: Biopsy or Exfoliome
	verify="0"
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		echo "What type of data are you using?"; echo "1. Biopsy"; echo "2. Exfoliome"
		read -p "> " data_type_num
		if [[ "${data_type_num}" = "1" ]]; then data_type="biopsy"
			echo ""; echo "You have entered ${data_type} as the type of data you are using. Is this correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		elif [[ "${data_type_num}" = "2" ]]; then data_type="exfoliome"
			echo ""; echo "You have entered ${data_type} as the type of data you are using. Is this correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		else echo "Your input is not one of the options, please try again."; sleep 3; continue
		fi
	done

## Input species and set htseq type (gene_id or gene_name)
## Updated pre-programmed genomes (human,mouse,pig,horse,rat) that have been updated and
## are now in a folder with a new name should be updated in the corresponding species_location line
	verify="0"
	REF_LOC="/mnt/matrix/roo/refs"
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		echo "Please enter the species type:"
		echo "1. Human"; echo "2. Mouse"; echo "3. Pig"; echo "4. Horse"; echo "5. Rat"; echo "6. Other"
		read -p "> " species_type
		if [[ "${species_type}" = "1" ]]; then 
			echo "Which reference would you like to use?"; echo "1. GRCh38.p12"; echo "2. GRCh38.p14"
			read -p "> " ref_version
			if [[ "${ref_version}" == "1" ]]; then
				species_location="${REF_LOC}/GRCh38.94-human"; 
				species="human"; htseq_num="1"
				echo ""; echo "Is ${species} reference GRCh38.p12 correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
			else
				species_location="${REF_LOC}/GRCh38p14-human"; 
				species="human"; htseq_num="1"
				echo ""; echo "Is ${species} reference GRCh38.p14 correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
			fi				
		elif [[ "${species_type}" = "2" ]]; then 
			echo "Which reference would you like to use?"; echo "1. GRCm38.94"; echo "2. GRCm39"
			read -p "> " ref_version
			if [[ "${ref_version}" == "1" ]]; then
				species_location="${REF_LOC}/GRCm38.94-mouse"; species="mouse"; htseq_num="1"
				echo ""; echo "Is ${species} reference GRCm38.94 correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
			else
				species_location="${REF_LOC}/GRCm39-mouse"; species="mouse"; htseq_num="1"
				echo ""; echo "Is ${species} reference GRCm39 correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
			fi			
		elif [[ "${species_type}" = "3" ]]; then 
			species_location="${REF_LOC}/pig"
			species="pig"; htseq_num="1"
			echo ""; echo "Is ${species} correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		elif [[ "${species_type}" = "4" ]]; then species_location="${REF_LOC}/Equus_caballus"
			species="horse"; htseq_num="1"
			echo ""; echo "Is ${species} correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		elif [[ "${species_type}" = "5" ]]; then species_location="${REF_LOC}/GRCr-8-rat"
			species="GRCr8"; htseq_num="1"
			echo ""; echo "Is ${species} correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		elif [[ "${species_type}" = "6" ]]; then
				echo ""
				read -p "Please enter the species you will be using: " species
				read -p "Please enter the name of the genome folder located at ${REF_LOC}/ " species_new
				species_location="${REF_LOC}/${species}_new"
				
				echo ""
				echo "The location for ${species} reference is ${species}_location."
				echo "Is this correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
		else echo "Your input is not one of the options, please try again."; sleep 3; continue
		fi
	done

## Determine strands
	verify="0"
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		echo "Is your data single end or paired end? "
		echo "1. Single end"; echo "2. Paired end"
		read -p "> " strand_num
		if [[ "${strand_num}" = "1" ]]; then strand_type="single end"
		elif [[ "${strand_num}" = "2" ]]; then strand_type="paired end"
		echo "Important note: When using paired end samples, the files must end with R1.fastq.gz and R2.fastq.gz."
		else echo "Your input is not one of the options, please try again."; sleep 3; continue
		fi
		echo " "; echo "You entered ${strand_type}. Is this correct?"; echo "1. Yes"; echo "2. No"
		read -p "> " verify
	done


## Determine type of trimming and trimming options.
	verify="0"
	until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
		echo "Do you need to trim the data?"
		echo "1. No, the data does not need to be trimmed."; 
		echo "2. Yes, the data needs to be trimmed using a quality score."
		echo "3. Yes, the data needs a specific number of bases trimmed."; 
		echo "4. Yes, the data needs to be trimmed using UMI's."
		read -p "> " trim_num
		if [[ "${trim_num}" = "1" ]]; then 
			trim_type="untrimmed"
			trim_disp="The data does not need to be trimmed."
				if [[ "${concat_num}" = "1" ]]; then mapfiles="${SAVE_LOC}/${project_name}/concat"
			else 
				mapfiles="${file_location}"
				fi
		elif [[ "${trim_num}" = "2" ]]; then trim_type="quality_trim"
                	read -p "Please enter the quality score you would like to use: " trim_quality_num
                	trim_disp="The data needs to be trimmed using a quality score of ${trim_quality_num}."
					mapfiles="${SAVE_LOC}/${project_name}/trimmed_files/$trim_type"
        elif [[ "${trim_num}" = "3" ]]; then trim_type="base_trim"
            		read -p "Please enter the number of bases you would like to trim: " trim_base_num
            		trim_disp="The data needs ${trim_base_num} bases trimmed."
            		mapfiles="${SAVE_LOC}/${project_name}/trimmed_files/${trim_type}"
        elif [[ "${trim_num}" = "4" ]]; then trim_type="umi_trim"
                	trim_disp="The data needs to be trimmed using UMI's."
                	mapfiles="${SAVE_LOC}/${project_name}/trimmed_files/${trim_type}/trimmed"
        else  echo "Your input is not one of the options, please try again."; sleep 3; continue
        	fi
	  	
	  	echo ""; echo "${trim_disp} Is this correct?"; echo "1. Yes"; echo "2. No"
		read -p "> " verify
	done

	verify="0"
## Final verification of information before beginning pipeline
	./misc_scripts/top_banner.sh
	echo "Thank you for all of your input! Let's verify things one last time before beginning."; echo ""
	echo "Project Name: ${project_name}"; echo "File Location: ${file_location}"
	echo "Final filename length: ${concat_length}"; echo "Type of samples: ${data_type}"
	echo "Species: ${species}"; echo "Your data is ${strand_type}."
	echo "${trim_disp}"; echo ""; echo ""
	echo "Would you like to proceed?"; echo "1. Yes"; echo "2. No"; echo "3. Please exit"
	read -p "> " verify

	## Save information to Mapping Info
	mkdir -p "${SAVE_LOC}/${project_name}/summary"
	mapping_information="${SAVE_LOC}/${project_name}/summary/${project_name}-Mapping_Information.txt"
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
#mkdir -p "${SAVE_LOC}/${project_name}/tmp"
#config_dir="${SAVE_LOC}/${project_name}/tmp"
mkdir -p ${SAVE_LOC}/${project_name}/mapping
mapping_dir_out="${SAVE_LOC}/${project_name}/mapping"
mkdir -p ${SAVE_LOC}/${project_name}/logs/mapping
mapping_logs="${SAVE_LOC}/${project_name}/logs/mapping"

## Create project specific config file
cp config.sh ${SAVE_LOC}/${project_name}/config.sh
project_config="${SAVE_LOC}/${project_name}/config.sh"

echo "project_name=\"${project_name}\"" >> ${project_config}
echo "SAVE_LOC=\"$SAVE_LOC\"" >> ${project_config}
echo "concat_response=\"${concat_response}\"" >> ${project_config}
echo "concat_length=\"${concat_length}\"" >> ${project_config}
echo "trim_num=\"${trim_num}\"" >> ${project_config}
echo "data_type=\"$data_type\"" >> ${project_config}
echo "strand_num=\"${strand_num}\"" >> ${project_config}
echo "file_location=\"${file_location}\"" >> ${project_config}
echo "mapfiles=\"${mapfiles}\"" >> ${project_config}
echo "mapping_information=\"${mapping_information}\"" >> ${project_config}
echo "trim_type=\"${trim_type}\"" >> ${project_config}
echo "species=\"${species}\"" >> ${project_config}
echo "species_location=\"${species_location}\"" >> ${project_config}
echo "trim_quality_num=\"${trim_quality_num}\"" >> ${project_config}
echo "trim_base_num=\"${trim_base_num}\"" >> ${project_config}
echo "mapping_dir_out=\"${mapping_dir_out}\"" >> ${project_config}
echo "mapping_logs=\"${mapping_logs}\"" >> ${project_config}

trim_dir_out="${SAVE_LOC}/${project_name}/trimmed_files/$trim_type/trimmed"
#echo "$trim_dir_out" > $config_dir/trim_dir_out.txt
echo "trim_dir_out=\"${trim_dir_out}\"" >> ${project_config}

if [[ "${trim_num}" = "4" ]]; then
		htseq_dir_in="${SAVE_LOC}/${project_name}/trimmed_files/${trim_type}/deduplicated_files"
		#echo "${htseq_dir_in}" > $config_dir/htseq_dir_in.txt
		echo "htseq_dir_in=\"${htseq_dir_in}\"" >> ${project_config}
	else
		htseq_dir_in="${SAVE_LOC}/${project_name}/mapping"
		#echo "${htseq_dir_in}" > $config_dir/htseq_dir_in.txt
		echo "htseq_dir_in=\"${htseq_dir_in}\"" >> ${project_config}
fi

#./main_scripts/Pipeline_Execute.sh
nohup ./main_scripts/Pipeline_Execute.sh 1> ${SAVE_LOC}/${project_name}/${project_name}-log.out 2> ${SAVE_LOC}/${project_name}/${project_name}-log.err &
fi
