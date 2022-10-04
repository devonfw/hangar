#!/bin/bash

while getopts "n:d:f:o:b:" opt
do
   case "$opt" in
      n ) projectName="$OPTARG" ;;
      d ) description="$OPTARG" ;;
      f ) folder="$OPTARG" ;;
      o ) organization="$OPTARG" ;;
      b ) billing="$OPTARG" ;;
   esac
done

if [ "$1" == "-h" ];
then
   echo "Creates a new project and enables billing and required APIs"
   echo ""
   echo "Arguments:"
   echo -e "\t-n [Required] Name of the new project."
   echo -e "\t-b [Required] Billing account. If not specified, won't be able to enable some services."
   echo -e "\t-d            Description for the new project. If not specified, name will be used as description"
   echo -e "\t-f            Numeric ID of the folder for which the project will be configured."
   echo -e "\t-o            Numeric ID of the organization for which the project will be configured."
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Mandatory argument check
if [ -z "$projectName" ] || [ -z "$billing" ];
then
   echo -e "${red}Error: Missing paramenters, -n and -b are mandatory." >&2
   echo -e "${red}Use -h flag to display help." >&2
   exit 2
fi

# Check if GCloud CLI is installed
if ! [ -x "$(command -v gcloud)" ]; then
  echo -e "${red}Error: GCloud CLI is not installed." >&2
  exit 127
fi

# Create the Google Cloud project.
echo -e "${green}Creating project..."
echo -ne "${white}"

command="gcloud projects create $projectName"

if [ -n "$description" ]; then
   command=$command" --name=\"$description\""
fi
if [ -n "$folder" ]; then
   command=$command" --folder=$folder"
fi
if [ -n "$organization" ]; then
   command=$command" --organization=$organization"
fi

eval $command
if ! [ $? -eq 0 ]
then
    echo -e "${red}Error while creating the project." >&2
    exit 2
fi

echo "Linking project to billing account..."
gcloud beta billing projects link "$projectName" --billing-account "$billing"
echo "Enabling Cloud Source Repositories..."
gcloud services enable sourcerepo.googleapis.com --project "$projectName"
echo "Enabling CloudRun..."
gcloud services enable run.googleapis.com --project "$projectName"
echo "Enabling Artifact Registry..."
gcloud services enable artifactregistry.googleapis.com --project "$projectName"


