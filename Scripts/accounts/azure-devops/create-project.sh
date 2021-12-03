#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p projectName -d description -o organization -v visibility -t pat_token. "
   echo -e "\t-p [Required] Name of the new project."
   echo -e "\t-d [Required] Description for the new project."
   echo -e "\t-o [Required] Name of the organization for which the project will be configured."
   echo -e "\t-v [Required] Visibility. Accepted values: private, public."
   echo -e "\t-t [Required] PAT token to login Azure DevOps."
   exit 1 # Exit script after printing help
}

while getopts "p:d:o:v:t:" opt
do
   case "$opt" in
      p ) projectname="$OPTARG" ;;
      d ) description="$OPTARG" ;;
      o ) organization="$OPTARG" ;;
      v ) visibility="$OPTARG" ;;
      t ) pat_token="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$projectname" ] || [ -z "$description" ] || [ -z "$organization" ] || [ -z "$visibility" ] || [ -z "$pat_token" ] 
then
   echo "ERROR: Some required parameters are missing.";
   helpFunction
fi
   
echo "Installing Azure DevOps extension for CLI use..."
az extension add --name azure-devops

echo "Logging in to Azure DevOps with PAT token..."
echo $pat_token | az devops login

echo "Creating project..."
az devops project create --name "$projectName" --description "$description" --organization https://dev.azure.com/$organization --visibility "$visibility"

echo "Project list:"
az devops project list  --organization https://dev.azure.com/$organization

echo "Configuring default organization and project..."
az devops configure --defaults organization=https://dev.azure.com/$organization project="$projectname"  

echo "List of configured organization:"
az devops configure --list

