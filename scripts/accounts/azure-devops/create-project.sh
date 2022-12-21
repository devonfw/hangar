#!/bin/bash

helpFunction()
{
   echo "Usage: $0 -n projectName -d description -o organization -v visibility -t pat_token. "
   echo ""
   echo -e "\t-n [Required] Name of the new project."
   echo -e "\t-d [Required] Description for the new project."
   echo -e "\t-o [Required] Name of the organization for which the project will be configured."
   echo -e "\t-v [Required] Visibility. Accepted values: private, public."
   echo -e "\t-t [Required] PAT token to login Azure DevOps."
   echo -e "\t-w            Process workflow that will be used. Accepted values: basic, agile, scrum, cmmi. Default: basic."
}

while getopts "n:d:o:v:t:w:h" opt
do
   case "$opt" in
      n ) projectName="$OPTARG" ;;
      d ) description="$OPTARG" ;;
      o ) organization="$OPTARG" ;;
      v ) visibility="$OPTARG" ;;
      t ) pat_token="$OPTARG" ;;
      w ) process="$OPTARG" ;;
      h ) helpFunction; exit ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent.
   esac
done

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Print helpFunction in case parameters are empty.
if [ -z "$projectName" ] || [ -z "$description" ] || [ -z "$organization" ] || [ -z "$visibility" ] || [ -z "$pat_token" ] 
then
   echo -e "${red}Error: Some required parameters are missing." >&2
   echo -e "${white}" >&2
   helpFunction
   exit 2
fi

# Check if Azure CLI is installed
if ! [ -x "$(command -v az)" ]; then
  echo -e "${red}Error: Azure CLI is not installed." >&2
  exit 127
fi

# Install the Azure DevOps extension.
echo -e "${green}Installing Azure DevOps extension for CLI use..."
echo -ne ${white}
az extension add --name azure-devops

# Log into Azure DevOps with the PAT.
echo -e "${green}Logging in to Azure DevOps with PAT token..."
echo -ne ${white}
echo $pat_token | az devops login

# Create the Azure DevOps project.
echo -e "${green}Creating project..."
echo -ne ${white}
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
echo -ne ${white}
az devops project list  --organization https://dev.azure.com/$organization

# Configure the default organization and project.
echo -e "${green}Configuring default organization and project..."
echo -ne ${white}
az devops configure --defaults organization=https://dev.azure.com/$organization project="$projectName"  

# Print the list of the configured organization.
echo -e "${green}List of configured organization:"
echo -ne ${white}
az devops configure --list
