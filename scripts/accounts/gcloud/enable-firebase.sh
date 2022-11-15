#!/bin/bash

helpFunction()
{
   echo "Enables Firebase on a project and required APIs"
   echo ""
   echo "Arguments:"
   echo -e "\t-n [Required] Name of the new project."
}

while getopts "n:d:f:o:b:h" opt
do
   case "$opt" in
      n ) projectName="$OPTARG" ;;
      h ) helpFunction; exit ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent.
   esac
done

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Mandatory argument check
if [ -z "$projectName" ];
then
   echo -e "${red}Error: Missing paramenters, -n is mandatory." >&2
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

# Check if Firebase CLI is installed
if ! [ -x "$(command -v firebase)" ]; then
  echo -e "${red}Error: Firebase CLI is not installed." >&2
  echo -ne "${white}"
  exit 127
fi