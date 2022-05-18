##!/bin/bash
# Read config.sh
#. $(dirname $0)/../config.sh
. $SAVE_LOC/$project_name/config.sh

echo "Mapping paired-end biopsy now.."

star_version=$($STAR --version)
echo "Mapping performed using STAR version $star_version with default settings." >> $mapping_information
