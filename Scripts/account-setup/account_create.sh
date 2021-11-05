#!/bin/bash

organization=$1
project=$2


# Install the Azure DevOps extension for cli use
az extension add --name azure-devops

# Login to Azure Devops With PAT Token
echo "You can Login by using PAT."
cat pat_token.txt | az devops login

#cat pat_token.txt | az devops login --organization https://dev.azure.com/Orgalization-org/

# Configured the Organizations and project
echo "Configure Organizations and project"

az devops configure --defaults organization=https://dev.azure.com/"$organization" #prathibhapadma-org

az devops configure --defaults project="$project"


# List of Configured Organizations
echo "Configure list"

az devops configure --list
