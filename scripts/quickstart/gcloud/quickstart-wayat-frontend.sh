#!/bin/bash

set -e
FLAGS=$(getopt -a --options w:d:p:h --long "help,workspace:,directory:,project:,keystore:,google-services:,storage-bucket:" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -h | --help )             help="true"; shift 1;;
        -w | --workspace )        workspace=$2; shift 2;;
        -d | --directory )        directory=$2; shift 2;;
        -p | --project )          projectName=$2; shift 2;;
        --keystore )              keystore=$2; shift 2;;
        --google-services )       googleServices=$2; shift 2;;
        --backend-url )           backendUrl=$2; shift 2;;
        --frontend-url )          frontendUrl=$2; shift 2;;
        --storage-bucket )        storageBucket=$2; shift 2;;
        --) shift; break;;
    esac
done

helpFunction() {
   echo "Inits the Wayat backend project in the specified workspace folder."
   echo ""
   echo "Flags:"
   echo -e "\t-w, --workspace        [Required] Path for the Takeoff Workspace Project directory"
   echo -e "\t-d, --directory        [Required] Path for the directory of the Frontend code"
   echo -e "\t-p, --project          [Required] Project shortname (ID)"
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
    if [ -z "$projectName" ];
    then
        echo -e "${red}Error: Missing paramenters, -p or --project is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ ! -d "$workspace" ];
    then
        echo -e "${red}Error: Workspace directory does not exists." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    if [ ! -d "$directory" ];
    then
        echo -e "${red}Error: Frontend code directory does not exists." >&2
        echo -ne "${white}" >&2
        exit 2
    fi
    # Dir path
    currentPath=$(pwd)
    cd "$workspace"
    workspace=$(pwd)
    cd "$directory"
    directory=$(pwd)
    cd $currentPath
}

function obtainHangarPath {
    # This line goes to the script directory independent of wherever the user is and then jumps 3 directories back to get the path
    hangarPath=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd ../../.. && pwd )
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
    wget -O "$workspace"/wayat-backend-template.zip https://github.com/devonfw/hangar/archive/refs/heads/template/wayat-flutter-frontend.zip
    unzip "$workspace"/wayat-backend-template.zip -d "$workspace/tmp"
    shopt -s dotglob
    mv -f "$workspace"/tmp/hangar-template-wayat-python-backend/* "$directory"
    rm -rf "$workspace/tmp"
    rm "$workspace"/wayat-backend-template.zip
}

prepareENVFile() {
    export storageBucket
    export projectName
# shellcheck disable=SC2016
    envsubst '$backendUrl' < "$directory/env.template" > "$directory/env.template"
    envsubst '$storageBucket' < "$directory/env.template" > "$directory/.env"
    rm "$directory/env.template"
    rm "$directory/firebaserc.template"
    cp "$workspace"/firebase-key.json "$directory"/firebase-key.json
}

commitFiles() {
    cd "$directory" && git add -A && git commit -m "Init Wayat Backend Code" && git push
}

addSecrets() {
    "$hangarPath"/scripts/pipelines/gcloud/add-secret-file.sh -d "$directory" -f "$directory/.env" -r .env -b develop
    "$hangarPath"/scripts/pipelines/gcloud/add-secret-file.sh -d "$directory" -f "$directory/key.properties" -r android/key.properties -b develop
    "$hangarPath"/scripts/pipelines/gcloud/add-secret-file.sh -d "$directory" -f "$googleServices" -r android/app/google-services.json -b develop
    "$hangarPath"/scripts/pipelines/gcloud/add-secret-file.sh -d "$directory" -f "$keystore" -r keystore.jks -b develop
}

corsCloudStorage() {
# shellcheck disable=SC2016
    envsubst '$frontendUrl' < "$hangarPath/scripts/quickstart/gcloud/cors.json" > "$hangarPath/scripts/quickstart/gcloud/cors.json"
    gsutil cors set "$hangarPath/scripts/quickstart/gcloud/cors.json" $storageBucket
}

nextSteps() {

}

#==============================================================
# SCRIPT EXECUTION:

if [[ "$help" == "true" ]]; then helpFunction; exit; fi

checkMandatoryArguments

ckeckCliInstalled

obtainHangarPath

downloadTemplate

prepareENVFile

commitFiles

addSecrets

nextSteps