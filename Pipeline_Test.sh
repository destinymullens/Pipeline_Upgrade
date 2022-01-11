#!/bin/bash

# Read config.sh
. $(dirname $0)/config.sh

set -a # Command exports variables automatically for other scripts

## Gather user input for various variables needed to determine the correct scripts for the pipeline to process
verify="0"
until [[ "$verify" = "1" ]]; do
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
	read -p "What would you like to name your project? " project_name
	echo ""; echo "Thank you! Your final results wil be saved at $SAVE_LOC/$project_name"; sleep 3

## Input data type: Biopsy or Exfoliome
	verify="0"
	until [[ "$verify" = "1" ]]; do ./top_banner.sh
		echo "What type of data are you using?"; echo "1. Biopsy"; echo "2. Exfoliome"
		read -p "> " data_type_num
		if [[ "$data_type_num" = "1" ]]; then data_type="biopsy"
		elif [[ "$data_type_num" = "2" ]]; then data_type="exfoliome"
		else echo "Your input is not one of the options, please try again."; sleep 3; continue
		fi
		echo ""; echo "You have entered $data_type as the type of data you are using. Is this correct?"; echo "1. Yes"; echo "2. No"
		read -p "> " verify
	done

## Check exfoliome options if data type is exfoliome
verify="0"
	until [[ "$verify" = "1" ]]; do ./top_banner.sh	
		if [[ "$data_type_num" = "2" ]]; then
		echo "Would you like to test parameters for exfoliome data?"; echo "1. Yes, I would like to test parameters.";
		echo "2. No, please map with default paramters.";
		echo "3. No, I already know my testing paremters."; read -p "> " exfoliome_map_option
			if [[ "$exfoliome_map_option" == "1" ]]; then data_type="exfoliome with testing"
				echo "You have chosen to test parameters for exfoliome data. Is this correct?"; echo "1. Yes"; echo "2. No" 
				read -p "> " verify
			elif [[ "$exfoliome_map_option" == "2" ]]; then data_type="exfoliome with default values" exfoliome_map_option="D0-F0"
				echo "You have chosen to map exfoliome data with default parameters. 
				Is this correct?"; echo "1. Yes"; echo "2. No" 
				read -p "> "verify
			else echo "Please enter preset mapping options:  " 
				read -p "> " exfoliome_mapping_parameter
				echo "You have given $exfoliome_mapping_parameter for presets for mapping your exfoliome data. Is this correct?"; 
				echo "1. Yes"; echo "2. No" 
				read -p "> " verify
			fi
		fi
	done


## Input species and set htseq type (gene_id or gene_name)
## Updated pre-programmed genomes (human,mouse,pig,horse,rat) that have been updated and
## are now in a folder with a new name should be updated in the corresponding species_location line
	verify="0"
	until [[ "$verify" = "1" ]]; do ./top_banner.sh
		echo "Please enter the species type:"
		echo "1. Human"; echo "2. Mouse"; echo "3. Pig"; echo "4. Horse"; echo "5. Rat"; echo "6. Other"
		read -p "> " species_type
		if [[ "$species_type" = "1" ]]; then species_location="$REF_LOC/GRCh38.94-human"
			species="human"; htseq_num="1"
			echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		elif [[ "$species_type" = "2" ]]; then species_location="$REF_LOC/GRCm38.94-mouse"
			species="mouse"; htseq_num="1"
			echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		elif [[ "$species_type" = "3" ]]; then species_location="$REF_LOC/pig"
			species="pig"; htseq_num="2"
			echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		elif [[ "$species_type" = "4" ]]; then species_location="$REF_LOC/Equus_caballus"
			species="horse"; htseq_num="2"
			echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		elif [[ "$species_type" = "5" ]]; then species_location="$REF_LOC/Rnor6.0"
			species="rat"; htseq_num="2"
			echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"
			read -p "> " verify
		elif [[ "$species_type" = "6" ]]; then
				echo ""
				read -p "Please enter the species you will be using: " species
				read -p "Please enter the name of the genome folder located at $REF_LOC/ " species_new
				species_location="$REF_LOC/$species_new"
				
				echo ""
				echo "The location for $species reference is $species_location."
				echo "Is this correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
		else echo "Your input is not one of the options, please try again."; sleep 3; continue
		fi
	done

## Get file location
	verify="0"
	until [[ "$verify" = "1" ]]; do ./top_banner.sh
		read -p "Where are your files located? (Note: Please use /home/username instead of ~/ if files are located in your home directory.) " file_location
		echo " "
		find $file_location -type f -printf '%f\n'
		echo " "; echo "Are these the correct files?"; echo "1. Yes"; echo "2. No"
		read -p "> " verify
	done

## Get concat number & check
	verify="0"
	until [[ "$verify" = "1" ]]; do ./top_banner.sh
		read -p "How long is your filename? " concat_length
		./concat_preview.sh
		echo "Is this correct?"; echo "1. Yes"; echo "2. No"
		read -p "> " verify
	done

## Determine strands
	verify="0"
	until [[ "$verify" = "1" ]]; do ./top_banner.sh
		echo "Is your data single end or paired end? "
		echo "1. Single end"; echo "2. Paired end"
		read -p "> " strand_num
		if [[ "$strand_num" = "1" ]]; then strand_type="single end"
		elif [[ "$strand_num" = "2" ]]; then strand_type="paired end"
		else echo "Your input is not one of the options, please try again."; sleep 3; continue
		fi
		echo " "; echo "You entered $strand_type. Is this correct?"; echo "1. Yes"; echo "2. No"
		read -p "> " verify
	done

## Determine type of trimming and trimming options.
	verify="0"
	until [[ "$verify" = "1" ]]; do ./top_banner.sh
		echo "Do you need to trim your data?"
		echo "1. No, I do not need to trim my data."; echo "2. Yes, I need to trim by quality."
		echo "3. Yes, I need to trim by bases."; echo "4. Yes, I need to trim using UMI's."
		read -p "> " trim_num
		if [[ "$trim_num" = "1" ]]; then trim_type="untrimmed"
			trim_disp="You do not need to trim your data."
			mapfiles="$SAVE_LOC/$project_name/concat"
		elif [[ "$trim_num" = "2" ]]; then trim_type="quality_trim"
                	read -p "Please enter the quality score you would like to use: " trim_quality_num
                	trim_disp="You need to trim your data using a quality score of $trim_quality_num."
			mapfiles="$SAVE_LOC/$project_name/trimmed_files/$trim_type"
        	elif [[ "$trim_num" = "3" ]]; then trim_type="base_trim"
            		read -p "Please enter the number of bases you would like to trim: " trim_base_num
            		trim_disp="You would like to trim $trim_base_num bases from your data."
            		mapfiles="$SAVE_LOC/$project_name/trimmed_files/$trim_type"
            	elif [[ "$trim_num" = "4" ]]; then trim_type="umi_trim"
                	trim_disp="You need to trim your data using UMI's."
                	mapfiles="$SAVE_LOC/$project_name/trimmed_files/$trim_type/final_trim"
                else  echo "Your input is not one of the options, please try again."; sleep 3; continue
        	fi
	  	
	  	echo ""; echo "$trim_disp Is this correct?"; echo "1. Yes"; echo "2. No"
		read -p "> " verify
	done

	verify="0"
## Final verification of information before beginning pipeline
	./top_banner.sh
	echo "Thank you for all of your input! Let's verify things one last time before beginning."; echo ""
	echo "Project Name: $project_name"; echo "File Location: $file_location"
	echo "Final filename length: $concat_length"; echo "Type of samples: $data_type"
	echo "Species: $species"; echo "Your data is $strand_type."
	echo "$trim_disp"; echo ""; echo ""
	echo "Would you like to proceed?"; echo "1. Yes"; echo "2. No"; echo "3. Please exit"
	read -p "> " verify
	if [[ "$verify" = "3" ]]; then
		exit
	fi
done

mkdir="SAVE_LOC/$project_name"
outputfile="$project_name-stout.txt"
outputerr="$project_name=err.txt"
mkdir="$SAVE_LOC/$project_name/concat"
mkdir="$SAVE_LOC/$project_name/mapping"
mkdir="$SAVE_LOC/$project_name/summary"

./top_banner.sh
## Runs concat script to concatenate script

echo "Beginning concatenation of files..."
echo ""

./concat_run.sh

echo ""
echo "Concatenation of files is finished! Moving on to QC Reports now!"
echo ""

## Runs script for QC Reports

echo "Beginning QC Reports..."
echo ""
qc_dir_in="$SAVE_LOC/$project_name/concat"
qc_dir_out="$SAVE_LOC/$project_name/qc_reports/untrimmed"
./qc_run.sh
echo "QC Reports complete!"
echo ""

## Run scripts for trimming options 

if [[ "$trim_num" = "1" ]]; then
	echo "No trimming needed, beginning mapping of files!"
	mapfiles="$SAVE_LOC/$project_name/concat"
elif [[ "$trim_num" = "2" ]]; then
	echo "Beginning trimming of files!"
	./trim_quality.sh
	mapfiles="$SAVE_LOC/$project_name/$trim_type"
	./secondary_scripts/qc_second_run.sh
elif [[ "$trim_num" = "3" ]]; then
	echo "Beginning trimming of files!"
	./trim_base.sh
	mapfiles="$SAVE_LOC/$project_name/$trim_type"
	./secondary_scripts/qc_second_run
else
	echo "Beginning trimming of files!"
	./trim_umi.sh
	mapfiles="$SAVE_LOC/$project_name/$trim_type/final_trim"
	./secondary_scripts/qc_second_run.sh
fi

echo "Beginning mapping of files."
if [[ "$data_type_num" = "1" ]]; then 
	if [[ "$strand_num" = "1" ]]; then 
		./map_SE_biopsy.sh
	else ./map_PE_biopsy.sh
	fi
elif [[ "$data_type" = "exfliome with testing" ]]; then
	if [[ "$strand_num" = "1" ]]; then 
	./map_test_exfoliome.sh
	./map_exfoliome.sh
		else ./map_PE_exfoliome_test.sh
	fi
elif [[ "$data_type" = "exfoliome with default values" ]]; then
	if [[ "$strand_num" = "1" ]]; then ./map_exfoliome.sh
		else ./map_PE_exfoliome.sh
	fi
else 
	if [[ "$strand_num" = "1" ]]; then ./map_exfoliome.sh
		else ./map_exfoliome.sh
	fi

fi


./htseq.sh
./summary.sh 	

echo "All mapping is completed for $project_name! Your files are located at $SAVE_LOC/$project_name."
