#!/bin/bash

helpFunction()
{
   echo "Usage: $0 -n projectName -d description -o organization. "
   echo ""
   echo -e "\t-n [Required] Name of the new project."
   echo -e "\t-d [Optional] Description for the new project. If not specified, name will be used as description"
   echo -e "\t-o [Optional] Name of the organization for which the project will be configured."
}

while getopts "n:d:o:h" opt
do
   case "$opt" in
      n ) projectName="$OPTARG" ;;
      d ) description="$OPTARG" ;;
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
if [ -n "$description" ] && [ -n "$organization" ]; then
   gcloud projects create "$projectName" --name="$description" --organization="$organization"
elif [ -n "$description" ]; then
   gcloud projects create "$projectName" --name="$description"
elif [ -n "$organization" ]; then
   gcloud projects create "$projectName" --organization="$organization"
else 
   gcloud projects create "$projectName"
fi
