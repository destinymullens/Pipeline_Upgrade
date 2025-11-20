#!/usr/bin/env bash
# setup_pipeline.sh
# Modular interactive setup for Chapkin Lab pipeline.
# Behavior:
#  - data_option 1A / 1B (biopsy) => ask about strand and trimming
#  - data_option 2A / 2B (exfoliome) => auto single-end and UMI trimming (trim_option=4)
set -Eeuo pipefail
IFS=$'\n\t'

die() { echo "❌ ERROR: $*" >&2; exit 1; }
ok()  { echo "✅ $*"; }
info(){ echo "ℹ️  $*"; }

call_banner() {
    ./misc_scripts/top_banner.sh 2>/dev/null || true
}

ask_input() {
    # ask_input "<prompt>" varname [default]
    local prompt="$1" varname="$2" default="${3-}"
    local reply
    if [[ -n "$default" ]]; then
        read -r -p "$prompt [$default] > " reply
        reply="${reply:-$default}"
    else
        read -r -p "$prompt > " reply
    fi
    printf -v "$varname" '%s' "$reply"
}

ask_confirm() {
    # ask_confirm "<prompt>" => returns 0 if yes
    local prompt="$1" ans
    while true; do
        read -r -p "$prompt (1=Yes, 2=No) > " ans
        case "$ans" in
            1) return 0 ;;
            2) return 1 ;;
            *) echo "Please enter 1 or 2." ;;
        esac
    done
}

ask_directory() {
    # ask_directory "<prompt>" -> prints chosen dir to stdout
    local prompt="${1:-Enter directory}" dir
    while true; do
        call_banner
        ask_input "$prompt (use full paths, e.g. /home/user/data)" dir
        dir="${dir/#\~/$HOME}"
        if [[ ! -d "$dir" ]]; then
            echo "❌ Directory does not exist: $dir"
            if ask_confirm "Create it?"; then
                mkdir -p "$dir" || die "Failed to create $dir"
                ok "Created $dir"
            else
                continue
            fi
        fi
        echo "Files found in '$dir':"
        find "$dir" -maxdepth 1 -type f -printf '%f\n' || true
        if ask_confirm "Are these the correct files?"; then
            printf '%s' "$dir"
            return 0
        fi
    done
}

ask_trim_option() {
    # returns trim_option (1..4)
    local choice
    echo ""
    echo "Do you need to trim the data?"
    echo "  1) No, the data does not need to be trimmed."
    echo "  2) Yes, trim using a quality score."
    echo "  3) Yes, trim a specific number of bases."
    echo "  4) Yes, trim using UMI's."
    while true; do
        read -r -p "> " choice
        case "$choice" in
            1|2|3|4) printf '%s' "$choice"; return 0 ;;
            *) echo "Enter 1, 2, 3 or 4." ;;
        esac
    done
}

ask_species() {
    local sel
    echo "Please enter the species type:"
    echo "  1) Human"
    echo "  2) Mouse"
    echo "  3) Pig"
    echo "  4) Horse"
    echo "  5) Rat"
    while true; do
        read -r -p "> " sel
        case "$sel" in
            1) printf '%s' "human"; return 0 ;;
            2) printf '%s' "mouse"; return 0 ;;
            3) printf '%s' "pig";   return 0 ;;
            4) printf '%s' "horse"; return 0 ;;
            5) printf '%s' "rat";   return 0 ;;
            *) echo "Enter a number 1-5." ;;
        esac
    done
}

# ---- Start interactive flow ----
call_banner
echo ""
echo "🧬 Chapkin Lab Sequencing Pipeline — Setup"
echo ""

# Project save location & project name
SAVE_LOC=""
while true; do
    ask_input "Where should the project be saved? (full path, avoid ~)" SAVE_LOC
    [[ -n "$SAVE_LOC" ]] || { echo "Please enter a directory path."; continue; }
    SAVE_LOC="${SAVE_LOC/#\~/$HOME}"
    if [[ ! -d "$SAVE_LOC" ]]; then
        if ask_confirm "Directory '$SAVE_LOC' does not exist. Create it?"; then
            mkdir -p "$SAVE_LOC" || die "Failed to create $SAVE_LOC"
            ok "Created $SAVE_LOC"
            break
        else
            continue
        fi
    else
        break
    fi
done

project_name=""
while true; do
    ask_input "What would you like to name your project? (no / in name)" project_name
    [[ -n "$project_name" ]] || { echo "Project name cannot be empty."; continue; }
    if [[ "$project_name" == *"/"* ]]; then echo "Project name must not contain '/'."; continue; fi
    break
done

project_location="${SAVE_LOC%/}/${project_name}"
ok "Project will be saved at: ${project_location}"

mkdir -p "$project_location" || die "Unable to create project dir"

# If existing config exists
if [[ -f "${project_location}/config.sh" ]]; then
    call_banner
    echo "Existing config found at ${project_location}/config.sh"
    if ask_confirm "Continue previous mapping (launch pipeline now)?"; then
        nohup ./main_scripts/Pipeline_Execute.sh \
            > "${project_location}/${project_name}-log.out" \
            2> "${project_location}/${project_name}-log.err" \
            </dev/null &
        ok "Pipeline launched in background. Exiting setup."
        exit 0
    else
        if ask_confirm "Delete existing config and start new run?"; then
            rm -f "${project_location}/config.sh" || true
            ok "Old config removed."
        else
            ok "Keeping existing config. Exiting."
            exit 0
        fi
    fi
fi

# 1) File location
file_location="$(ask_directory "Where are your input files located?")"
ok "Using input files at: $file_location"

# 2) Concatenation
call_banner
if ask_confirm "Do the files need to be concatenated?"; then
    read -r -p "How long is the filename grouping length (characters)? > " concat_length
    concat_response=1
    concat_text="Files will be concatenated using filename length ${concat_length}."
    # optional preview
    ./misc_scripts/concat_preview.sh "${file_location}" "${concat_length}" || true
    if ! ask_confirm "Is the concatenation preview correct?"; then
        echo "You may re-run or adjust settings later."
    fi
else
    concat_response=2
    concat_text="Files will NOT be concatenated."
fi
ok "$concat_text"

# 3) Data type / pipeline option
call_banner
echo "What type of RNA-seq data are you aligning?"
echo "  1) Biopsy"
echo "  2) Exfoliome"
while true; do
    read -r -p "> " dt_choice
    case "$dt_choice" in
        1)
            data_type="biopsy"
            # ask mapping program
            call_banner
            echo "Choose aligner:"
            echo "  1) Bowtie2"
            echo "  2) STAR"
            while true; do
                read -r -p "> " a
                case "$a" in
                    1) aligner="bowtie2"; data_option="1A"; break ;;
                    2) aligner="star";    data_option="1B"; break ;;
                    *) echo "Enter 1 or 2." ;;
                esac
            done
            break
            ;;
        2)
            data_type="exfoliome"
            call_banner
            echo "Exfoliome pipeline type:"
            echo "  1) Optimized"
            echo "  2) Default"
            while true; do
                read -r -p "> " e
                case "$e" in
                    1) data_option="2A"; break ;;
                    2) data_option="2B"; break ;;
                    *) echo "Enter 1 or 2." ;;
                esac
            done
            # for exfoliome defaults we set an aligner placeholder
            aligner="exfoliome_default"
            break
            ;;
        *) echo "Enter 1 or 2." ;;
    esac
done
ok "Selected data_type=${data_type}, data_option=${data_option}, aligner=${aligner}"

# 4 & 5: Strand and trim
# Behavior per your requirement:
# - data_option 1A / 1B => ASK about strand and trim
# - data_option 2A / 2B => AUTO single end and trim_option=4 (UMI)
if [[ "${data_option}" == "2A" || "${data_option}" == "2B" ]]; then
    # Auto behavior for exfoliome
    strand_num=1
    strand_text="single end"
    trim_option=4
    trim_text="Trim using UMI's"
    trim_type="umi"
    ok "Exfoliome selected: automatically set single-end and UMI trimming."
else
    # Biopsy branch: ask interactive strand and trim
    call_banner
    echo "Is your data single end or paired end?"
    echo "  1) Single end"
    echo "  2) Paired end"
    while true; do
        read -r -p "> " s
        case "$s" in
            1) strand_num=1; strand_text="single end"; break ;;
            2) strand_num=2; strand_text="paired end"; echo "Note: Paired-end files must end with R1.fastq.gz and R2.fastq.gz"; break ;;
            *) echo "Enter 1 or 2." ;;
        esac
    done
    ok "Selected ${strand_text}"

    # trimming (interactive)
    trim_option="$(ask_trim_option)"
    case "$trim_option" in
        1) trim_text="No trimming"; trim_type="none" ;;
        2) read -r -p "Enter quality score to use: " trim_quality_score; trim_text="Trim using quality score ${trim_quality_score}"; trim_type="quality" ;;
        3) read -r -p "Enter number of bases to trim: " trim_num_base; trim_text="Trim ${trim_num_base} bases"; trim_type="bases" ;;
        4) trim_text="Trim using UMI's"; trim_type="umi" ;;
    esac
    ok "$trim_text"
fi

# 6) Species
call_banner
species_key="$(ask_species)"
REF_LOC="${REF_LOC:-/path/to/ref_genomes}"
case "$species_key" in
    human)
        species="human"; species_location="${REF_LOC}/GRCh38p14-human"; species_ref="GRCh38.p14"; species_icon="👫" ;;
    mouse)
        species="mouse"; species_location="${REF_LOC}/GRCm39-mouse"; species_ref="GRCm39"; species_icon="🐭" ;;
    pig)
        species="pig"; species_location="${REF_LOC}/pig"; species_ref="Sus_scrofa_11.1"; species_icon="🐷" ;;
    horse)
        species="horse"; species_location="${REF_LOC}/Equus_caballus_Aug2024"; species_ref="Equus_caballus_3.0"; species_icon="🐴" ;;
    rat)
        species="rat"; species_location="${REF_LOC}/GRCr-8-rat"; species_ref="GRCr8"; species_icon="🐀" ;;
    *) die "Unhandled species: $species_key" ;;
esac
ok "Species set to ${species} (${species_ref})"

# 7) FastQC
call_banner
if ask_confirm "Would you like to run FastQC?"; then
    qc_response=1
    qc_text="run FastQC"
else
    qc_response=2
    qc_text="skip FastQC"
fi
ok "$qc_text"

# Final verification
call_banner
echo "Final settings:"
echo "  Project: ${project_name}"
echo "  Project dir: ${project_location}"
echo "  Input files: ${file_location}"
echo "  Concatenate: ${concat_text}"
echo "  Data type / option: ${data_type} / ${data_option} (aligner: ${aligner})"
echo "  Read type: ${strand_text}"
echo "  Trimming: ${trim_text}"
echo "  FastQC: ${qc_text}"
echo "  Species: ${species} (${species_ref}) at ${species_location}"
echo ""
if ! ask_confirm "Proceed with these settings?"; then
    echo "Setup cancelled."
    exit 0
fi

# Save summary and config
mkdir -p "${project_location}/summary" "${project_location}/logs"
mapping_information="${project_location}/summary/${project_name}-Pipeline_settings.txt"
{
    echo "Project: ${project_name}"
    echo "Project dir: ${project_location}"
    echo "Input files: ${file_location}"
    echo "Concatenate: ${concat_text}"
    echo "Data type: ${data_type} (option: ${data_option}, aligner: ${aligner})"
    echo "Read type: ${strand_text}"
    echo "Trimming: ${trim_text}"
    echo "FastQC: ${qc_text}"
    echo "Species: ${species} (${species_ref})"
    echo "Species location: ${species_location}"
    echo ""
    printf "Setup completed at: "
    timedatectl | head -1 || date
} > "${mapping_information}"

# Write safe config shell file
project_config="${project_location}/config.sh"
cat > "${project_config}" <<EOF
# config generated by setup_pipeline.sh
SAVE_LOC="${SAVE_LOC}"
project_name="${project_name}"
project_location="${project_location}"
file_location="${file_location}"
concat_response="${concat_response:-2}"
concat_length="${concat_length:-}"
qc_response="${qc_response:-2}"
trim_option="${trim_option:-${trim_option:-1}}"
trim_type="${trim_type:-}"
trim_quality_score="${trim_quality_score:-}"
trim_num_base="${trim_num_base:-}"
data_type="${data_type}"
data_option="${data_option}"
aligner="${aligner}"
strand_num="${strand_num}"
strand_text="${strand_text}"
species="${species}"
species_location="${species_location}"
species_ref="${species_ref}"
mapping_information="${mapping_information}"
EOF

ok "Saved configuration to ${project_config}"

# Launch pipeline in background
log_out="${project_location}/${project_name}-log.out"
log_err="${project_location}/${project_name}-log.err"

nohup ./main_scripts/Pipeline_Execute.sh \
    > "${log_out}" \
    2> "${log_err}" \
    </dev/null &

pid=$!
ok "Pipeline launched (PID $pid). Logs: ${log_out} ${log_err}"
echo "Monitor with: tail -f \"${log_out}\""

exit 0