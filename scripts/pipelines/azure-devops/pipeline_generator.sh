#!/bin/bash
while getopts c:d:n:l:k:i:b:w: flag
do
    case "${flag}" in
        c) configFile=${OPTARG};;
        d) localDirectory=${OPTARG};;
        n) pipelineName=${OPTARG};;
        l) language=${OPTARG};;
        k) projectKey=${OPTARG};;
        i) imageName=${OPTARG};;
        b) targetBranch=${OPTARG};;
        w) webBrowser=${OPTARG};;
    esac
done

if test "$1" = "-h"
then
    echo "Generates a pipeline on Azure DevOps based on the parameters set in the configuration file."
    echo ""
    echo "Arguments:"
    echo "  -c    [Required] Configuration file containing parameters and variables."
    echo "  -n    [Required] Name that will be set to the quality pipeline."
    echo "  -d    [Required] Local directory of your project (the path should always be using '/' and not '\')."
    echo "  -l               Language or framework of the directory. Only required when generating Build and Test pipelines."
    echo "  -k               SonarQube project key. Only required when generating Quality pipelines."
    echo "  -i               Name that will be given to the Docker image. Only required when generating Package pipelines."
    echo "  -b               Name of the branch to which the Pull Request will target. PR is not created if the flag is not provided."
    echo "  -w               Open the Pull Request on the web browser if it cannot be automatically merged. Requires -b flag."
    exit
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

#Check if configuration file and pipeline name are passed.
if test -z "$configFile"
then
    echo -e "${red}Missing configuration file parameter, use -c."
    echo -e "${red}Use -h flag to display help."
    echo -e ${white}
    exit 2
fi
source $configFile
IFS=, read -ra values <<< "$mandatoryFlags"
for arg in "${values[@]}"
do
	if test -z $arg
	then
        echo -e "${red}Missing parameters, some flags are mandatory."
        echo -e "${red}Use -h flag to display help."
        echo -e ${white}
        exit 2
	fi
done
cd ../../..
hangarPath=$(pwd)

# Create the new branch.
echo -e "${green}Creating the new branch: ${sourceBranch}..."
echo -e ${white}
cd ${localDirectory}
git checkout -b ${sourceBranch}

# Copy the corresponding YAML and script into the directory.
echo -e "${green}Copying the corresponding files into your directory..."
echo -e ${white}
# Check if the folders .pipelines and .scripts exist.
if [ ! -d "${localDirectory}/${pipelinePath}" ]
then
    # The folder does not exists.
    # Create the .pipelines folder.
    cd ${localDirectory}
    mkdir .pipelines
    cd ${localDirectory}/${pipelinePath}
    mkdir scripts
fi
cp "${hangarPath}/${templatesPath}/${yamlFile}" "${localDirectory}/${pipelinePath}/${yamlFile}"
# Check if -k and -i flags are activated.
if test -z "$projectKey" && test -z "$imageName"
then
    # -k and -i flags are not activated so it is a build or test pipeline.
    cp "${hangarPath}/${templatesPath}/${language}-${scriptFile}" "${localDirectory}/${scriptFilePath}/${scriptFile}"
else
    # Check if -i flag is activated.
    if test -z "$imageName"
    then
        # -i flag is not activated so it is a quality pipeline.
        sed -i "s/<Project-key>/$projectKey/g" "${localDirectory}/${pipelinePath}/${yamlFile}"
    fi
fi

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo -e "${green}Commiting and pushing into Git remote..."
echo -e ${white}
cd ${localDirectory}
git add .pipelines -f
git commit -m "Adding the source YAML"
git push -u origin ${sourceBranch}

# Create Azure Pipeline
echo -e "${green}Generating the pipeline from the YAML template..."
echo -e ${white}
az pipelines create --name $pipelineName --yml-path "${pipelinePath}/${yamlFile}"

# PR creation
if test -z "$targetBranch"
then
    # No branch specified in the parameters, no Pull Request is created, the code will be stored in the current branch.
    echo -e "${green}No branch specified to do the Pull Request, changes left in the ${sourceBranch} branch."
    echo -e ${white}
    exit
else
    # Create teh Pull Request to merge into the specified branch.
    echo -e "${green}Creating a Pull Request..."
    echo -e ${white}
    pr=$(az repos  pr create --source-branch ${sourceBranch} --target-branch $targetBranch --title "Pipeline" --auto-complete true)
    # Obtain the PR id.
    id=$(echo "$pr" | python -c "import sys, json; print(json.load(sys.stdin)['pullRequestId'])")
    # Obtain the PR status.
    showOutput=$(az repos pr show --id $id)
    status=$(echo "$showOutput" | python -c "import sys, json; print(json.load(sys.stdin)['status'])")
    # Check if the Pull  Request merge has succeeded.
    if test "$status" = "completed"
    then
        # Pull Request merged successfully.
        echo -e "${green}Pull Request merged into $targetBranch branch successfully."
        echo -e ${white}
        exit
    else
        # Obtain the PR URL.
        url=$(echo "$showOutput" | python -c "import sys, json; print(json.load(sys.stdin)['repository']['webUrl'])")
        prURL="$url/pullrequest/$id"
        # Check if the -w flag is activated.
        flags=$*
        if [[ "$flags" == *" -w"* ]]
        then
            # -w flag is activated and a page with the corresponding Pull Request is opened in the web browser.
            echo -e "${green}Pull Request successfully created."
            echo -e "${green}Opening the Pull Request on the web browser..."
            echo -e ${white}
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
