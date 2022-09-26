#!/bin/bash

helpFunction()
{
   echo "Usage: $0 -n projectName -d description -o organization. "
   echo ""
   echo -e "\t-n [Required] Name of the new project."
   echo -e "\t-d [Optional] Description for the new project. If not specified, name will be used as description"
   echo -e "\t-f [Optional] Numeric ID of the folder for which the project will be configured."
   echo -e "\t-o [Optional] Numeric ID of the organization for which the project will be configured."
}

while getopts "n:d:f:o:h" opt
do
   case "$opt" in
      n ) projectName="$OPTARG" ;;
      d ) description="$OPTARG" ;;
      f ) organization="$OPTARG" ;;
      o ) organization="$OPTARG" ;;
      h ) helpFunction; exit ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent.
   esac
done

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Print helpFunction in case parameters are empty.
if [ -z "$projectName" ]
then
   echo -e "${red}Error: Some required parameters are missing." >&2
   echo -e ${white} >&2
   helpFunction
   exit 2
fi

# Check if GCloud CLI is installed
if ! [ -x "$(command -v gcloud)" ]; then
  echo -e "${red}Error: GCloud CLI is not installed." >&2
  exit 127
fi

#Authenticate (interactively) with the master user
gcloud auth login
if ! [ $? -eq 0 ]
then
    echo -e "${red}Error: Authentication process failed. Please make sure you are copying the right verification code." >&2
    exit 2
fi

# Create the Google Cloud project.
echo -e "${green}Creating project..."
echo -ne ${white}

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
