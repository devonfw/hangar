#!/bin/bash

set -e
FLAGS=$(getopt -a --options n:r:p:h:o: --long "help,project:,region:,name:,output:" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -h | --help )             help="true"; shift 1;;
        -p | --project )          projectName=$2; shift 2;;
        -r | --region )           region=$2; shift 2;;
        -n | --name )             serviceName=$2; shift 2;;
        -o | --output )           outputFile=$2; shift 2;;
        --) shift; break;;
    esac
done

helpFunction() {
   echo "Inits Cloud Run Instance and Returns Public URL"
   echo ""
   echo "Arguments:"
   echo -e "\t-p, --project        [Required] ID of the project."
   echo -e "\t-n, --name           [Required] Name of the new Cloud Run Service."
   echo -e "\t-r, --region                    Region to create Cloud Run Service on."
   echo -e "\t-o, --output                    Output file path to store the service URL."
}

# Colours for the messages.
white='\e[1;37m'
red='\e[0;31m'

# Mandatory argument check
checkMandatoryArguments() {
    # Project name check
    if [ -z "$projectName" ];
    then
        echo -e "${red}Error: Missing paramenters, -p or --project is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}"
        exit 2
    fi
    # Service Name check
    if [ -z "$serviceName" ];
    then
        echo -e "${red}Error: Missing paramenters, -n or --name is mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -ne "${white}"
        exit 2
    fi
}

# Required CLI check
ckeckCliInstalled() {
    # Check if GCloud CLI is installed
    if ! [ -x "$(command -v gcloud)" ]; then
        echo -e "${red}Error: GCloud CLI is not installed." >&2
        echo -ne "${white}"
        exit 127
    fi
}

checkGcloudProjectName() {
    # Check if exists a Google Cloud project with that project ID. 
    if ! gcloud projects describe "$projectName" 2> /dev/null ; then
        echo -e "${red}Error: Project $projectName does not exist."
        echo -ne "${white}"
        exit 200
    fi
}

createCloudRunService() {
    echo "Creating Cloud Run Instance..."
    if [[ "$region" == "" ]]; then
        region="europe-west6"
    fi
    if ! gcloud run deploy "$serviceName" --image=us-docker.pkg.dev/cloudrun/container/hello --region "$region" --project "$projectName" --allow-unauthenticated; then
        echo -e "${red}Error: Cannot create Cloud Run Instance"
        echo -ne "${white}"
        exit 240
    fi
    serviceUrl=$(gcloud run services describe $serviceName --format 'value(status.url)' --project "$projectName" --region "$region")
    echo "$serviceUrl"
    if [[ "$outputFile" != "" ]]; then
        echo "$serviceUrl" > "$outputFile"
    fi
}

#==============================================================
# SCRIPT EXECUTION:

if [[ "$help" == "true" ]]; then helpFunction; exit; fi

checkMandatoryArguments

ckeckCliInstalled

checkGcloudProjectName

createCloudRunService
