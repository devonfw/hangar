#!/bin/bash

## configuration file path to parse variables
source ./pipeline_configuration.cfg

while getopts n:l:d: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        l) language=${OPTARG};;
        d) directory=${OPTARG};;
                  
    esac
done

if test "$1" = "-h"
then
    echo ""
    echo "Generates a test pipeline on Azure DevOps from a YAML."
    echo ""
    echo "Arguments:"
    echo "  -n    [Required] Name that will be set to the test pipeline."
    echo "  -l    [Required] Language or framework of the project."
    echo "  -d    [Required] Local directory of your project (the path should always be using '/' and not '\')."
       
    exit
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

# Argument check.
if test -z "$name" || test -z "$language" || test -z "$directory"
then
    echo -e "${red}Missing parameters, all flags are mandatory."
    echo -e "${red}Use -h flag to display help."
    echo -e ${white}
    exit
fi

cd ../../..
pipelinesDirectory="${directory}/.pipelines"
scriptsDirectory="${pipelinesDirectory}/.scripts"
hangarPath=$(pwd)

# Create the new branch.
echo -e "${green}Creating the new branch: feature/test-pipeline..."
echo -e ${white}
cd ${directory}
git checkout -b ${branch[test_pipeline]}
cd ${hangarPath}

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo -e "${green}Committing and pushing to Git remote..."
echo -e ${white}
cd ${directory}
git add $pipelines $scripts -f
git commit -m "Adding test pipeline source YAML"
git push -u origin ${branch[test_pipeline]}

# Create Azure Pipeline
echo -e "${green}Create Azure Test Pipeline:"
echo -e ${white}
az pipelines create --name $name --yml-path $pipelines 



