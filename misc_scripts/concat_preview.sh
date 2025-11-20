#!/usr/bin/env bash
# concat_preview.sh
# Preview which files will be concatenated based on filename prefix length

set -Eeuo pipefail

# Load project config
if [[ -z "${project_location:-}" || -z "${file_location:-}" || -z "${concat_length:-}" ]]; then
    echo "❌ Please set project_location, file_location, and concat_length in config.sh before running."
    exit 1
fi

SampleList=$(find "${file_location}" -type f -printf '%f\n' | cut -c 1-"${concat_length}" | sort | uniq)
Output="${project_location}/concat"

echo ""
echo "📋 Concat Preview:"
echo "Output directory would be: ${Output}"
echo ""

for s in ${SampleList}; do
    NEW="${Output}/${s}.fastq.gz"
    FILES=$(find "${file_location}" -type f -iname "${s}"*.gz | sort)
    if [[ -n "$FILES" ]]; then
        echo "Sample prefix: $s"
        echo "Files to concatenate:"
        for f in ${FILES}; do
            echo "  - ${f}"
        done
        echo "Preview output file: ${NEW}"
        echo "----------------------------------------"
    else
        echo "⚠️  No files found for sample prefix: $s"
        echo "----------------------------------------"
    fi
done

echo "✅ Preview complete. No files were modified."