#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p projectName -d description -o organization -v visibility -t pat_token. "
   echo -e "\t-n [Required] Name of the new project."
   echo -e "\t-d [Required] Description for the new project."
   echo -e "\t-o [Required] Name of the organization for which the project will be configured."
   echo -e "\t-v [Required] Visibility. Accepted values: private, public."
   echo -e "\t-t [Required] PAT token to login Azure DevOps."
   echo -e "\t-p            Process that will be used. Accepted values: basic, agile, scrum, cmmi."
   exit 1 # Exit script after printing help.
}

while getopts "n:d:o:v:t:p:" opt
do
   case "$opt" in
      n ) projectName="$OPTARG" ;;
      d ) description="$OPTARG" ;;
      o ) organization="$OPTARG" ;;
      v ) visibility="$OPTARG" ;;
      t ) pat_token="$OPTARG" ;;
      p ) process="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent.
   esac
done

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Print helpFunction in case parameters are empty.
if [ -z "$projectName" ] || [ -z "$description" ] || [ -z "$organization" ] || [ -z "$visibility" ] || [ -z "$pat_token" ] 
then
   echo ""
   echo -e "${red}ERROR: Some required parameters are missing.";
   echo -e ${white}
   helpFunction
fi

# Install the Azure DevOps extension.
echo -e "${green}Installing Azure DevOps extension for CLI use..."
echo -e ${white}
az extension add --name azure-devops

# Log into Azure DevOps with the PAT.
echo -e "${green}Logging in to Azure DevOps with PAT token..."
echo -e ${white}
echo $pat_token | az devops login

# Create the Azure DevOps project.
echo -e "${green}Creating project..."
echo -e ${white}
if [ -z "$process" ]
then
   # Create the Azure DevOps project with a Basic workflow.
   az devops project create --name "$projectName" --description "$description" --organization https://dev.azure.com/$organization --visibility "$visibility"
else
   # Create the Azure DevOps project with the specified workflow.
   az devops project create --name "$projectName" --description "$description" --organization https://dev.azure.com/$organization --visibility "$visibility" --process $process
fi

# Print the list of existing projects.
echo -e "${green}Project list:"
echo -e ${white}
az devops project list  --organization https://dev.azure.com/$organization

# Configure the default organization and project.
echo -e "${green}Configuring default organization and project..."
echo -e ${white}
az devops configure --defaults organization=https://dev.azure.com/$organization project="$projectName"  

# Print the list of the configured organization.
echo -e "${green}List of configured organization:"
echo -e ${white}
az devops configure --list
