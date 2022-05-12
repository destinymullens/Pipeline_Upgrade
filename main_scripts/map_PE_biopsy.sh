##!/bin/bash
# Read config.sh
. $(dirname $0)/../config.sh

##Importing input variables
config_dir="$SAVE_LOC/$project_name/tmp"

data_type=$(cat $config_dir/data_type.txt)
file_location=$(cat $config_dir/file_location.txt)
mapfiles=$(cat $config_dir/mapfiles.txt)
mapping_information=$(cat $config_dir/mapping_information.txt)
project_name=$(cat $config_dir/project_name.txt)
SAVE_LOC=$(cat $config_dir/SAVE_LOC.txt)
species_location=$(cat $config_dir/species_location.txt)
strand_num=$(cat $config_dir/strand_num.txt)
trim_type=$(cat $config_dir/trim_type.txt)
trim_dir_out=$(cat $config_dir/trim_dir_out.txt)

echo "Mapping paired-end biopsy now.."

star_version=$($STAR --version)
echo "Mapping performed using STAR version $star_version with default settings." >> $mapping_information
