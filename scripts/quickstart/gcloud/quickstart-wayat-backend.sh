#!/bin/bash

set -e
FLAGS=$(getopt -a --options w:d:h --long "help,workspace:,directory:,storage-bucket:" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -h | --help )             help="true"; shift 1;;
        -w | --workspace )        workspace=$2; shift 2;;
        -d | --directory )        directory=$2; shift 2;;
        --storage-bucket )        storageBucket=$2; shift 2;;
        --) shift; break;;
    esac
done


helpFunction() {
    # TODO
   echo "Inits the Wayat backend project in the specified workspace folder."
   echo ""
   echo "Flags:"
   echo -e "\t-w, --workspace        [Required] Path for the Takeoff Workspace Project directory"
   echo -e "\t-d, --directory        [Required] Path for the directory of the Backend code"
   echo -e "\t--storage-bucket       [Required] Storage bucket for storing pictures"
}

# Colours for the messages.
white='\e[1;37m'
red='\e[0;31m'

# Mandatory argument check
checkMandatoryArguments() {
    if [ -z "$workspace" ];
    then
        echo -e "${red}Error: Missing paramenters, -w or --workspace is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ -z "$directory" ];
    then
        echo -e "${red}Error: Missing paramenters, -d or --directory is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ -z "$storageBucket" ];
    then
        echo -e "${red}Error: Missing paramenters, --storage-bucket is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
}

# Required CLI check
ckeckCliInstalled() {
    # Check if GCloud CLI is installed
    if ! [ -x "$(command -v gcloud)" ]; then
        echo -e "${red}Error: GCloud CLI is not installed." >&2
        echo -ne "${white}" >&2
        exit 127
    fi
}

downloadTemplate() {
    wget -O "$workspace"/wayat-backend-template.zip https://github.com/devonfw/hangar/archive/refs/heads/template/wayat-python-backend.zip
    unzip "$workspace"/wayat-backend-template.zip -d "$workspace/tmp"
    shopt -s dotglob
    mv -f "$workspace"/tmp/hangar-template-wayat-python-backend/* "$directory"
    rm -rf "$workspace/tmp"
    rm "$workspace"/wayat-backend-template.zip
}

prepareENVFile() {
    export storageBucket
# shellcheck disable=SC2016
    envsubst '$storageBucket' < "$directory/env.template" > "$directory/PROD.env"
    rm "$directory/env.template"
    cp "$workspace"/firebase.json "$directory"/firebase.json
}

commitFiles() {
    cd "$directory" && git add -A && git commit -m "Init Wayat Backend Code" && git push
}

addSecrets() {
    /scripts/pipelines/gcloud/add-secret-file.sh -d "$directory" -f "$directory/PROD.env" -r PROD.env -b develop  
    /scripts/pipelines/gcloud/add-secret-file.sh -d "$directory" -f "$directory/firebase.json" -r firebase.json -b develop
}

#==============================================================
# SCRIPT EXECUTION:

if [[ "$help" == "true" ]]; then helpFunction; exit; fi

checkMandatoryArguments

ckeckCliInstalled

downloadTemplate

prepareENVFile

commitFiles

addSecrets