#!/bin/bash

set -a # Command exports variables automatically for other scripts
. $(dirname $0)/../config.sh

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
	echo "Our pipeline is designed to asked questions about your data before proceeding to map your samples."; echo ""
	echo "After all questions are answered, the pipeline will process your data and all output will be saved at $SAVE_LOC."
	echo ""
	echo "To begin, we need to name your project to create the folder that will contain your results."
	echo "It is easier to avoid special characters and spaces for folder names, so please keep that in mind when naming your project."
	echo ""
	read -p "What would you like to name your project?" project_name
	echo ""; echo "Thank you! Your final results wil be saved at $SAVE_LOC/$project_name"

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

## Input species and set htseq type (gene_id or gene_name)
## Updated pre-programmed genomes (human,mouse,pig,horse,rat) that have been updated and 
## are now in a folder with a new name should be updated in the corresponding species_location line
	verify="0"
	until [[ "$verify" = "1" ]]; do ./top_banner.sh
		echo "Please enter the species type:"
		echo "1. Human"; echo "2. Mouse"; echo "3. Pig"; echo "4. Horse"; echo "5. Rat"; echo "6. Other" 
		read -p "> " species_type
		if [[ "$species_type" = "1" ]]; then species_location="$REF_LOC/GRCh38.94-human"
			htseq_type="gene_name"; species="human"; htseq_num="1"
			echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"				
			read -p "> " verify
		elif [[ "$species_type" = "2" ]]; then species_location="$REF_LOC/GRCm38.94.150-mouse"
				htseq_type="gene_name"; species="mouse"; htseq_num="1"
				echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
		elif [[ "$species_type" = "3" ]]; then species_location="$REF_LOC/pig"
				htseq_type="gene_id"; species="pig"; htseq_num="2"
				echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
		elif [[ "$species_type" = "4" ]]; then species_location="$REF_LOC/horse-Equus_caballus"
				htseq_type="gene_id"; species="horse"; htseq_num="2"
				echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
		elif [[ "$species_type" = "5" ]]; then species_location="$REF_LOC/Rnor6.0"
				htseq_type="gene_id"; species="rat"; htseq_num="2"
				echo ""; echo "Is $species correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
		elif [[ "$species_type" = "6" ]]; then
				echo ""
				read -p "Please enter the species you will be using: " species
				read -p "Please enter the name of the genome folder located at $REF_LOC/ " species_new
				species_location="$REF_LOC/$species_new"
				echo ""; echo "Does the annotation file use gene_id or gene_name?"; echo "1. gene_id"; echo "2. gene_name"
				read -p "> " htseq_num
					if [[ "$htseq_num" = "1" ]]; then htseq_type="gene_id"
					elif [[ "$htseq_num" = "2" ]]; then htseq_type="gene_name"
					else echo "Your input is not one of the options, please try again."
					fi
				echo ""
				echo "The location for $species reference is $species_location and the annotation file uses $htseq_type."
				echo "Is this correct?"; echo "1. Yes"; echo "2. No"
				read -p "> " verify
		else echo "Your input is not one of the options, please try again."; sleep 3; continue
		fi
	done

## Get file location		
	verify="0"
	until [[ "$verify" = "1" ]]; do ./top_banner.sh
		read -p "Where are your files located? " file_location
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
		if [[ "$trim_num" = "1" ]]; then trim_type="none"
			trim_disp="You do not need to trim your data."
		elif [[ "$trim_num" = "2" ]]; then trim_type="quality_trim"
                read -p "Please enter the quality score you would like to use: " trim_quality_num
                trim_disp="You need to trim your data using a quality score of $trim_quality_num."       
        elif [[ "$trim_num" = "3" ]]; then trim_type="base_trim"
            	read -p "Please enter the number of bases you would like to trim: " trim_base_num
            	trim_disp="You would like to trim $trim_base_num bases from your data."
        elif [[ "$trim_num" = "4" ]]; then trim_type="umi_trim"
                trim_disp="You need to trim your data using UMI's."
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
	echo "Species: $species_new"; echo "Your data is $strand_type."
	echo "$trim_disp"; echo ""; echo ""
	echo "Would you like to proceed?"; echo "1. Yes"; echo "2. No"; echo "3. Please exit"
	read -p "> " verify
	if [[ "$verify" = "3" ]]; then
		exit
	fi
done




