#!/bin/bash

helpFunction()
{
   echo "Creates a new project and enables billing and required APIs"
   echo ""
   echo "Arguments:"
   echo -e "\t-n [Required] Name of the new project."
   echo -e "\t-b [Required] Billing account. If not specified, won't be able to enable some services."
   echo -e "\t-d            Description for the new project. If not specified, name will be used as description"
   echo -e "\t-f            Numeric ID of the folder for which the project will be configured."
   echo -e "\t-o            Numeric ID of the organization for which the project will be configured."
}

while getopts "n:d:f:o:b:h" opt
do
   case "$opt" in
      n ) projectName="$OPTARG" ;;
      d ) description="$OPTARG" ;;
      f ) folder="$OPTARG" ;;
      o ) organization="$OPTARG" ;;
      b ) billing="$OPTARG" ;;
      h ) helpFunction; exit ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent.
   esac
done

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Mandatory argument check
if [ -z "$projectName" ] || [ -z "$billing" ];
then
   echo -e "${red}Error: Missing paramenters, -n and -b are mandatory." >&2
   echo -e "${red}Use -h flag to display help." >&2
   echo -ne "${white}"
   exit 2
fi

# Check if GCloud CLI is installed
if ! [ -x "$(command -v gcloud)" ]; then
  echo -e "${red}Error: GCloud CLI is not installed." >&2
  echo -ne "${white}"
  exit 127
fi
# Check if exists a Google Cloud project with that project ID. 
if gcloud projects describe "$projectName" &>/dev/null ; then
   echo "Project ID already exists."
else
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

   if ! eval "$command"; then
      echo -e "${red}Error while creating the project." >&2
      echo -ne "${white}"
      exit 200
   fi
fi

echo "Linking project to billing account..."
if ! gcloud beta billing projects link "$projectName" --billing-account "$billing"; then 
   echo -e "${red}ERROR: Unable to link project to billing account"
   echo -ne "${white}"
   exit 210
fi

echo "Enabling Cloud Source Repositories..."
if ! gcloud services enable sourcerepo.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable Cloud Source Repositories API"
   echo -ne "${white}"
   exit 220
fi

echo "Enabling CloudRun..."
if ! gcloud services enable run.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable CloudRun API"
   echo -ne "${white}"
   exit 221
fi

echo "Enabling Artifact Registry..."
if ! gcloud services enable artifactregistry.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable Artifact Registry API"
   echo -ne "${white}"
   exit 222
fi

echo "Enabling Secret Manager..."
if ! gcloud services enable secretmanager.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable Secret Manager API"
   echo -ne "${white}"
   exit 224
fi