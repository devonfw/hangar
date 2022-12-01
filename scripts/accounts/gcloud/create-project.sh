#!/bin/bash

set -e
FLAGS=$(getopt -a --options n:d:f:o:b:h --long "help,firebase" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
         -h | --help )             help="true"; shift 1;;
         -n )                      projectName=$2; shift 2;;
         -d )                      description=$2; shift 2;;
         -f )                      folder=$2; shift 2;;
         -o )                      organization=$2; shift 2;;
         -b )                      billing=$2; shift 2;;
         --firebase )              firebase="true"; shift 1;;
         --) shift; break;;
    esac
done


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
   echo -e "\t--firebase    Creates the project as a Firebase project."
}

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

if [[ "$help" == "true" ]]; then helpFunction; exit; fi

# Mandatory argument check
if [ -z "$projectName" ] || [ -z "$billing" ];
then
   echo -e "${red}Error: Missing parameters, -n and -b are mandatory." >&2
   echo -e "${red}Use -h flag to display help." >&2
   echo -ne "${white}" >&2
   exit 2
fi

# Check if GCloud CLI is installed
if ! [ -x "$(command -v gcloud)" ]; then
  echo -e "${red}Error: GCloud CLI is not installed." >&2
  echo -ne "${white}" >&2
  exit 127
fi

# Check if Firebase CLI is installed
if [ "$firebase" == "true" ] && ! [ -x "$(command -v firebase)" ]; then
  echo -e "${red}Error: Firebase CLI is not installed." >&2
  echo -ne "${white}" >&2
  exit 127
fi

# Check if exists a Google Cloud project with that project ID. 
if gcloud projects describe "$projectName" &>/dev/null ; then
   echo "Project ID already exists."
else
   # Create the Google Cloud project.
   echo -e "${green}Creating project..."
   echo -ne "${white}"
   if [ "$firebase" == "true" ]; then
      command="firebase projects:create $projectName --non-interactive"
   else
      command="gcloud projects create $projectName"
   fi

   if [ -n "$description" ]; then
      if [ "$firebase" == "true" ]; then
         command=$command" --display-name=\"$description\""
      else
         command=$command" --name=\"$description\""
      fi
   fi
   if [ -n "$folder" ]; then
      command=$command" --folder=$folder"
   fi
   if [ -n "$organization" ]; then
      command=$command" --organization=$organization"
   fi

   if ! eval "$command"; then
      echo -e "${red}Error while creating the project." >&2
      echo -ne "${white}" >&2
      exit 200
   fi
fi

echo "Linking project to billing account..."
if ! gcloud beta billing projects link "$projectName" --billing-account "$billing"; then 
   echo -e "${red}ERROR: Unable to link project to billing account" >&2
   echo -ne "${white}" >&2
   exit 210
fi

echo "Enabling Cloud Source Repositories..."
if ! gcloud services enable sourcerepo.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable Cloud Source Repositories API" >&2
   echo -ne "${white}" >&2
   exit 220
fi

echo "Enabling CloudRun..."
if ! gcloud services enable run.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable Cloud Run API" >&2
   echo -ne "${white}" >&2
   exit 221
fi

echo "Enabling Artifact Registry..."
if ! gcloud services enable artifactregistry.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable Artifact Registry API" >&2
   echo -ne "${white}" >&2
   exit 222
fi

echo "Enabling CloudBuild..."
if ! gcloud services enable cloudbuild.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable Cloud Build API" >&2
   echo -ne "${white}" >&2
   exit 223
fi

echo "Enabling Secret Manager..."
if ! gcloud services enable secretmanager.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable Secret Manager API" >&2
   echo -ne "${white}" >&2
   exit 224
fi

echo "Enabling Cloud Resource Manager..."
if ! gcloud services enable cloudresourcemanager.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable Cloud Resource Manager API"  >&2
   echo -ne "${white}" >&2
   exit 225
fi

echo "Enabling IAM Control..."
if ! gcloud services enable iam.googleapis.com --project "$projectName"; then
   echo -e "${red}Error: Cannot enable IAM Control API" >&2
   echo -ne "${white}" >&2
   exit 226
fi
