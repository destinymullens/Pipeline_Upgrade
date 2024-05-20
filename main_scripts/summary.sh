#!/bin/bash

# Read config.sh
#. $(dirname $0)/../config.sh
. $SAVE_LOC/$project_name/config.sh

mkdir -p $SAVE_LOC/$project_name/htseq_counts/temp

htseq_dir_out="$SAVE_LOC/$project_name/htseq_counts"
samples=$(ls $htseq_dir_out/counts/*htseq.csv)
counts_file="$SAVE_LOC/$project_name/summary/$project_name-counts.csv"
tmp_dir="$SAVE_LOC/$project_name/htseq_counts/temp"

mapping_logs="$SAVE_LOC/$project_name/logs/mapping"
summary_file="$SAVE_LOC/$project_name/summary/$project_name-Overall_mapping_summary.csv"

### Merge individual htseq count files into counts csv file
for i in $samples; do
    ID=$(basename $i | cut -d "." -f1)
 
    if [[ ! -f $counts_file ]]; then
        printf "%s\n" "Ensembl.ID" > $tmp_dir/GeneID-tmp.txt
        awk '{print $1}' $i >> $tmp_dir/GeneID-tmp.txt
        printf "%s\n" "Gene.Name" > $tmp_dir/GeneName.txt
        awk '{print $2}' $i >> $tmp_dir/GeneName.txt
        printf "%s\n" "$ID" > $tmp_dir/$ID-tmp.txt
        awk '{print $3}' $i >> $tmp_dir/$ID-tmp.txt
        paste $tmp_dir/GeneID.txt $tmp_dir/GeneName-tmp.txt $tmp_dir/$ID-tmp.txt >> $counts_file
    else 
        printf "%s\n" "$ID" > $tmp_dir/$ID-tmp.txt
        awk '{print $3}' $i >> $tmp_dir/$ID-tmp.txt
        paste $counts_file $tmp_dir/$ID-tmp.txt >> $tmp_dir/$ID-counts-tmp.txt
        mv $tmp_dir/$ID-counts-tmp.txt $counts_file
    fi
done

head -n -5 $counts_file > $tmp_dir/counts_file-tmp.txt
mv $tmp_dir/counts_file-tmp.txt $counts_file
rm -r $tmp_dir/

## Compile overall mapping metrics into one file
logs=$(ls $mapping_logs/*.log)
## Print headers for overall for overall metrics
printf "%s\t" "Sample Name" >> $summary_file ## Print sample name to summary  
printf "%s\t" "Total Reads" >> $summary_file ## Print sample name to summary  
printf "%s\t" "Single Mapped" >> $summary_file ## Print sample name to summary  
printf "%s\t" "Unmapped Reads" >> $summary_file ## Print sample name to summary  
printf "%s\t" "Multi-Mapped Reads" >> $summary_file ## Print sample name to summary  
printf "%s\n" "Alignment Rate" >> $summary_file ## Print sample name to summary  

## Collect and paste information from each sample into overall summary file
for j in $logs; do
    FILE=$(basename $j | cut -d "." -f1)
    ## Cut info from each log file for overall metrics
    TOTAL_READS=$(cat $j | tail -8 | head -1 | cut -d " " -f1)
    SINGLE_MAPPED_READS=$(cat $j | tail -5 | head -1 | cut -d " " -f5)
    UNMAPPED_READS=$(cat $j | tail -6 | head -1 | cut -d " " -f5)
    MULTI_MAP_READS=$(cat $j | tail -4 | head -1 | cut -d " " -f5)
    ALIGNMENT_RATE=$(cat $j | tail -3 | head -1 | cut -d " " -f1)

    printf "%s\t" "$FILE" >> $summary_file ## Print sample name to summary   
    printf "%s\t" "$TOTAL_READS" >> $summary_file ## Print Total reads to summary
    printf "%s\t" "$SINGLE_MAPPED_READS" >> $summary_file ## Print single mapped reads to summary
    printf "%s\t" "$UNMAPPED_READS" >> $summary_file ## Print unmapped reads to summary 
    printf "%s\t" "$MULTI_MAP_READS" >> $summary_file ## Print multimapped reads to summary
    printf "%s\n" "$ALIGNMENT_RATE" >> $summary_file ## Print alignment rate to summary
done

echo "Summary complete! The summary files are saved $SAVE_LOC/summary"
