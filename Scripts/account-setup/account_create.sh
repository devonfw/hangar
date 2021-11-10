#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p projectname -d description -o organization -v visibility -t pat_token "
   echo -e "\t-p Description of what is projectname"
   echo -e "\t-d Description of what is description"
   echo -e "\t-o Description of what is organization"
   echo -e "\t-v Description of what is visibility"
   echo -e "\t-t Description of what is pat_token"
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
   echo "Some or all of the parameters are empty";
   helpFunction
fi


	echo "Install the Azure DevOps extension for cli use"
	az extension add --name azure-devops

	echo "Login to Azure Devops With PAT Token"
	echo $pat_token | az devops login

	echo "Create project"
	az devops project create --name $projectname --description $description --organization https://dev.azure.com/$organization --visibility $visibility

	echo "project list"
	az devops project list  --organization https://dev.azure.com/$organization

	echo "Configure Organizations and project"
	az devops configure --defaults organization=https://dev.azure.com/$organization project=$projectname  #"$organization" #prathibhapadma-org

	echo "List of Configured Organizations list"
	az devops configure --list

