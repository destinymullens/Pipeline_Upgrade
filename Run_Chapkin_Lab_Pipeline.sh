#!/bin/bash

# Read config.sh
source ./config.sh

set -e # Exit on error
set -a # Command exports variables automatically for other scripts

## Gather user input for various variables needed to determine the correct scripts for the pipeline to process
clear
echo ""
echo "⎡‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾⎤"
echo "⎜                                 🧬 Chapkin Lab Sequencing Pipeline 🧬                            ⎟" 
echo "⎣__________________________________________________________________________________________________⎦"
echo ""
echo "Our pipeline is designed to asked questions about the data before proceeding to align the samples."
echo ""
echo "After all questions are answered the pipeline will process the data."
echo ""
echo "To begin, we need to name the project to create the folder that will contain the results."
echo "Please avoid using special characters such as: spaces, /, >, |, :, ?, *  or & in the project name."
echo "If using special characters, it must be quoted or escaped using the \ symbol."
echo ""
## Determine were to save project
echo "Where should the project be saved?"
read -p "(Note: Please use /home/username instead of ~/ for files located in the home directory.)" SAVE_LOC
echo ""
read -p "What would you like to name your project? " project_name
echo "";
project_location="${SAVE_LOC}/${project_name}"
echo "Thank you! Your final results will be saved at ${project_location}"; sleep 3

#### Determine if pipeline was previously ran
./misc_scripts/top_banner.sh
if [[ -f ${project_location}/config.sh ]]; then
	echo "There is a configuration file saved at that location? Would you like to continue a previous mapping?"; 
	echo "1. Yes"; echo "2. No"
	read -p "> " continuenum
	if [[ "${continuenum}" == "2" ]]; then
		nohup ./main_scripts/Pipeline_Execute.sh 1> ${project_location}/${project_name}-log.out 2> ${project_location}/${project_name}-log.err &
	else
	rm ${project_location}/config.sh
	fi
else

#### Start New Pipeline Run
	verify="0"	
	until [[ "${verify}" = "1" ]]; do

#### Get file location
		verify="0"
		until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh
			echo "Where are your files located? "
			read -p "(Note: Please use /home/username instead of ~/ for files located in the home directory.)" file_location
			echo " "
			find ${file_location} -type f -printf '%f\n'
			echo " "; echo "Are these the correct files?"; echo "1. Yes 👍"; echo "2. No  👎 "
			read -p "> " verify
		done

#### Determine if files need concatentation
		verify="0"	
		until [[ "${verify}" = "1" ]]; do ./misc_scripts/top_banner.sh;
			read -p "Do the files need to concatenated? 1. Yes 👍 2. No 👎 " concat_response
		
			if [[ "${concat_response}" == "1" ]]; then
				read -p "How long is the filename? " concat_length
				concat_text="You indicated files need to be concatenated and the filename length is ${concat_length} letters."
				./misc_scripts/concat_preview.sh
				echo "Is this correct?"; echo "1. Yes 👍"; echo "2. No 👎 "
				read -p "> " verify
			else
				concat_text="You indicated the files do not need to be concatenated."; verify="1"
			fi
		done

#### Determine input data type: Biopsy or Exfoliome
		./misc_scripts/top_banner.sh
		echo "What type of RNA-seq data are you aligning?"; echo "1. Biopsy"; echo "2. Exfoliome"
		read -p "> " response
		
	## If biopsy then determine mapping program
		if [[ "${response}" = "1" ]]; then 
			./misc_scripts/top_banner.sh
			echo ""; echo "You have entered ${data_type} as the type of data you are using. Would you like to use Bowtie2 or STAR for alignment?"; 
			echo "1. Bowtie2"; echo "2. STAR"
			read -p "> " response

			if [[ "${response}" = "1" ]]; then 
				data_type="You have indicated biopsy/tissues sample alignment using Bowtie2."
				data_option='1A'
			elif [[ "${response}" = "2" ]]; then 
				data_type="You have indicated biopsy/tissues sample alignment using STAR."
				data_option='1B'
			else 
				echo "⁉️ Your input is not one of the options, please try again."; sleep 3; continue
			fi
	
		## If biopsy then determine if paired or single end reads	
			./misc_scripts/top_banner.sh
			echo ""
			echo "Is your data single end or paired end? "
			echo "1. Single end"; echo "2. Paired end"
			echo " Note: When using paired end samples, the files must end with R1.fastq.gz and R2.fastq.gz."
			read -p "> " strand_num
			if [[ "${strand_num}" = "1" ]]; then 
				strand_text="single end"
			elif [[ "${strand_num}" = "2" ]]; then 
				strand_text="paired end"				
			else echo "⁉️ Your input is not one of the options, please try again."; sleep 3; continue
			fi

		## If biopsy then determine type of trimming and trimming options.
			./misc_scripts/top_banner.sh
			echo ""
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
   	    		trim_text="The data needs ${trim_num_base} bases trimmed."
   	    	elif [[ "${trim_option}" = "4" ]]; then
   	    		trim_text="The data needs to be trimmed using UMI's."
   	    	else
   	    		echo "⁉️ Your input is not one of the options, please try again."; sleep 3; continue
   	    	fi


		## If data is exfoliome, set options and select pipeline
		elif [[ "${response}" = "2" ]]; then 
			echo ""; echo "You have entered exfoliome as the type of data you are using. Is this correct?"; 
			trim_option="4"
			trim_text="The data needs to be trimmed using UMI's."
			strand_text="single end"
			strand_num="1"
 			
 		## Determine Exfoliome Default or Optimized Pipeline
			./misc_scripts/top_banner.sh
			echo ""; echo "Would you like to use the default or optimized exfoliome pipeline?"; 
			echo "1. Default"; echo "2. Optimized"
			read -p "> " response

			if [[ "${response}" = "1" ]]; then 
				data_type="You have selected the default exfoliome pipeline using Bowtie2 for alignment."
				data_option='2B'
			elif [[ "${response}" = "2" ]]; then
				data_type="You have selected the optimized exfoliome pipeline using Bowtie2 for alignment."
				data_option='2A'
			else 
				echo "⁉️ Your input is not one of the options, please try again."; sleep 3; continue
			fi
		else 
				echo "⁉️ Your input is not one of the options, please try again."; sleep 3; continue
			fi
	
#### Input species and set htseq type (gene_id or gene_name)
#### Updated pre-programmed genomes (human,mouse,pig,horse,rat) that have been updated and
#### are now in a folder with a new name should be updated in the corresponding species_location line
		
		./misc_scripts/top_banner.sh
		echo ""
		echo "Please enter the species type:"
		echo "1. Human 👫"; echo "2. Mouse 🐭"; echo "3. Pig 🐷"; echo "4. Horse 🐴"; echo "5. Rat 🐀";
		read -p "> " species_type	
		if [[ "${species_type}" = "1" ]]; then 
			species="human"; species_ref="GRCh38.p14"; species_icon="👫";
		elif [[ "${species_type}" = "2" ]]; then 
			species="mouse"; species_ref="GRCm39"; species_icon="🐭";
		elif [[ "${species_type}" = "3" ]]; then 
			species="pig"; species_ref="Sus crofa 11.1"; species_icon="🐷";
		elif [[ "${species_type}" = "4" ]]; then 
			species="Equus_caballus-horse"; species_ref="Equus caballus 3.0";		
		elif [[ "${species_type}" = "5" ]]; then 
			species="rat"; species_ref="GRCr8"; species_icon="🐀";
		else 
			echo "⁉️ Your input is not one of the options, please try again."; sleep 3; continue
		fi
		
#### Check if FastQC run is wanted

		./misc_scripts/top_banner.sh
		echo ""
		read -p "Would you like to run FastQC or skip it? 1. Yes! Run FastQC! 2. No. Please skip for now. " qc_response
	

#### Final verification of information before beginning pipeline
		./misc_scripts/top_banner.sh
		echo ""
		echo "Thank you for all of your input! Let's verify things one last time before beginning."; echo ""
		echo "📂 The project ${project_name} will be saved at ${project_location} 📂"
		echo "📂 THe samples for ${project_name} are located at at ${file_location} 📂"
		echo "✅ ${concat_text}";
		echo "✅ You have indicated you would like to ${qc_text}"
		echo "✅ ${data_type}"
		echo "✅ The data is ${strand_text}."
		echo "✅ The species selected was ${species} ${species_icon}" using reference ${species_ref}; 
		echo "✅ ${trim_text}"; echo ""; echo ""
		echo "❓ Would you like to proceed?"; echo "1. Yes 👍"; echo "2. No  👎 "; echo "3. Please exit"
		read -p "> " verify
		if [[ "${verify}" = "3" ]]; then
			exit
		fi
	done

	## Save information to Mapping Info
mkdir -p "${project_location}/summary_information"
mapping_information="${project_location}/summary_information/${project_name}-Pipeline_settings.txt"
#touch ${mapping_information}
start_time=$(timedatectl | head -1 | cut -d " " -f18-20)
cat << EOF > "${mapping_information}"
The project "${mapping_information}" is mapping data located at "${file_location}".
cat > "${mapping_information}" <<EOF
"${concat_text}"
"${data_type}"
The data is "${strand_text}".
The species selected was "${species}" using reference "${species_ref}".
"${trim_text}"
Pipeline began running at "${start_time}".
EOF

## Create project specific config file
mkdir -p "${project_location}"
cp config.sh ${project_location}/config.sh
project_config="${project_location}/config.sh"

cat > "${project_config}" <<EOF
SAVE_LOC="${SAVE_LOC}"
project_name="${project_name}"
project_location="${project_location}"
file_location="${file_location}"
concat_response="${concat_response:-2}"
concat_length="${concat_length:-}"
qc_response="${qc_response:-2}"
trim_option="${trim_option:-}"
trim_quality_score="${trim_quality_score:-}"
trim_num_base="${trim_num_base:-}"
data_type="${data_type}"
data_option="${data_option}"
strand_num="${strand_num}"
strand_text="${strand_text}"
species="${species}"
species_location="${species_location}"
species_ref="${species_ref}"
mapping_information="${mapping_information}"
EOF
	
nohup ./main_scripts/Pipeline_Execute.sh \
	> "${project_location}/${project_name}-log.out" \
   	2> "${project_location}/${project_name}-log.err" \
   	</dev/null &
fi