#!/bin/bash

set -e
FLAGS=$(getopt -a --options w:d:h --long "help,workspace:,directory:" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -h | --help )             help="true"; shift 1;;
        -w | --workspace )        workspace=$2; shift 2;;
        -d | --directory )        directory=$2; shift 2;;
        --) shift; break;;
    esac
done


helpFunction() {
    # TODO
   echo "Creates a new Cloud Run service with a predefined HelloWorld image deployed and retrieves the public URL."
   echo ""
   echo "Flags:"
   echo -e "\t-w, --workspace        [Required] Path for the Takeoff Workspace Project directory"
   echo -e "\t-d, --directory        [Required] Path for the directory of the Backend code"
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
    mv "$workspace"/tmp/hangar-template-wayat-python-backend/ "$directory"
    rm -rf "$workspace/tmp"
    rm "$workspace"/wayat-backend-template.zip
}

#==============================================================
# SCRIPT EXECUTION:

if [[ "$help" == "true" ]]; then helpFunction; exit; fi

checkMandatoryArguments

ckeckCliInstalled

downloadTemplate