#!/bin/bash

source pipeline_configuration.sh

while getopts n:l:d:b:w: flag
do
    case "${flag}" in
        n) name=${OPTARG};;
        l) language=${OPTARG};;
        d) directory=${OPTARG};;
        b) targetbranch=${OPTARG};;
        w) webBrowser=${OPTARG};;
                  
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
    echo "  -b               Name of the branch to which the Pull Request will target. PR is not created if the flag is not provided."
    echo "  -w               Open the Pull Request on the web browser if it can not be automatically merged. Requires -b flag."
    
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
git checkout -b ${sourcebranch}
cd ${hangarPath}

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo -e "${green}Committing and pushing to Git remote..."
echo -e ${white}
cd ${directory}
git add ${pipelines} ${scripts} -f
git commit -m "Adding test pipeline source YAML"
git push -u origin ${sourcebranch}

# Create Azure Pipeline
echo -e "${green}Create Azure Test Pipeline:"
echo -e ${white}
az pipelines create --name $name --yml-path ${pipelines} 

# PR creation.
if test -z "$targetbranch"
then
    # No branch specified in the parameters, no Pull Request is created, the code will be stored in the current branch.
    echo -e "${green}No branch specified to do the Pull Request, changes left in the feature/test-pipeline branch."
    echo -e $white
    exit
else
    # Create the Pull Request to merge into the specified branch
    echo -e "${green}Creating a Pull Request..."
    echo -e ${white}
    pr=$(az repos pr create --source-branch ${sourcebranch} --target-branch $targetbranch --title "Test new Pipeline" --auto-complete true)
    # Obtain the PR id.
    id=$(echo "$pr" | python -c "import sys, json; print(json.load(sys.stdin)['pullRequestId'])")
    # Obtain the PR status.
    showOutput=$(az repos pr show --id $id)
    status=$(echo "$showOutput" | python -c "import sys, json; print(json.load(sys.stdin)['status'])")
    # Check if the Pull Request merge has succeeded.
    if test "$status" = "completed"
    then
        # Pull Request merged successfully.
        echo -e "${green}Pull Request merged into $targetbranch branch successfully."
        echo -e ${white}
        exit
    else
        # Obtain the PR URL.
        url=$(echo "$showOutput" | python -c "import sys, json; print(json.load(sys.stdin)['repository']['webUrl'])")
        prURL="$url/pullrequest/$id"
        # Check if the -w is activated.
        flags=$*
        if [[ "$flags" == *" -w"* ]]
        then
            # -w flag is activated and a page with the corresponding Pull Request is opened in the web browser.
            echo -e "${green}Pull Request successfully created."
            echo -e "${green}Opening the Pull Request on the web browser..."
            echo -e ${white}
            az repos pr show --id $id --open > /dev/null
            exit
        else
            # -w flag is not activated and the URL to the Pull Request is shown in the console.
            echo -e "${green}Pull Request successfully created."
            echo -e "${green}To review the Pull Request and accept it, click on the following link:"
            echo -e ${white}
            echo ${prURL}
            exit
        fi
    fi
fi






