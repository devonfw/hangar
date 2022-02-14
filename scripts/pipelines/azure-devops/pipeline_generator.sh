#!/bin/bash
while getopts c:n:d:b:w:l:p:u:t:i:a: flag
do
    case "${flag}" in
        c) configFile=${OPTARG};;
        n) pipelineName=${OPTARG};;
        d) localDirectory=${OPTARG};;
        b) targetBranch=${OPTARG};;
        w) webBrowser=${OPTARG};;
        l) language=${OPTARG};;
        p) buildPipelineName=${OPTARG};;
        u) sonarUrl=${OPTARG};;
        t) sonarToken=${OPTARG};;
        i) imageName=${OPTARG};;       
        a) artifactPath=${OPTARG};;
    esac
done

if test "$1" = "-h"
then
    echo "Generates a pipeline on Azure DevOps based on the parameters set in the configuration file."
    echo ""
    echo "Arguments:"
    echo "  -c    [Required] Configuration file containing parameters and variables."
    echo "  -n    [Required] Name that will be set to the pipeline."
    echo "  -d    [Required] Local directory of your project (the path should always be using '/' and not '\')."
    echo "  -b               Name of the branch to which the Pull Request will target. PR is not created if the flag is not provided."
    echo "  -w               Open the Pull Request on the web browser if it cannot be automatically merged. Requires -b flag."
    echo "  -l               Language or framework of the directory. Only required when generating Build and Test pipelines."
    echo "  -p    [Required] Build pipeline name."
    echo "  -u    [Required] Sonarqube URL."
    echo "  -t    [Required] Sonarqube token."   
    echo "  -i    [Required] Name that will be given to the Docker image."
    echo "  -a               Published artifacts in user specified path."
    exit
fi

white='\e[1;37m'
green='\e[1;32m'
red='\e[0;31m'

source $configFile
IFS=, read -ra values <<< "$mandatoryFlags"
#Check if configuration file and pipeline name are passed.
if test -z "$configFile"
then
    echo -e "${red}Error: Pipeline definition configuration file not specified." >&2
    exit 2
fi
# Check if the required flags in the config file have been activated.
for flag in "${flags[@]}"
do
	if test -z $flag
	then
        echo -e "${red}Missing parameters, some flags are mandatory." >&2
        echo -e "${red}Use -h flag to display help." >&2
        echo -e ${white}
        exit 2
	fi
done

# Check if Git is installed
if ! [ -x "$(command -v git)" ]; then
  echo -e "${red}Error: Git is not installed." >&2
  exit 127
fi

# Check if Azure CLI is installed
if ! [ -x "$(command -v az)" ]; then
  echo -e "${red}Error: Azure CLI is not installed." >&2
  exit 127
fi

# Check if Python is installed
if ! [ -x "$(command -v python)" ]; then
  echo -e "${red}Error: Python is not installed." >&2
  exit 127
fi

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

# Check if the pipeline is a Package pipeline.
if test -z "$language"
then
    # It is a Package pipeline, copy the script.
    cp "${hangarPath}/${templatesPath}/${scriptFile}" "${localDirectory}/${scriptFilePath}/${scriptFile}"
else
    # It is a Build, Test or Quality pipeline, copy the script according to its language.
    cp "${hangarPath}/${templatesPath}/${language}-${scriptFile}" "${localDirectory}/${scriptFilePath}/${scriptFile}"
    # Check if the pipeline is a Quality pipeline.
    if test ! -z "$buildPipelineName" && test ! -z "$sonarUrl" && test ! -z "$sonarToken"
    then
        sed -i "s/<build-pipeline-name>/$buildPipelineName/g" "${localDirectory}/${pipelinePath}/${yamlFile}"
        sed -i "s,<sonarqube-url>,$sonarUrl,g" "${localDirectory}/${scriptFilePath}/${scriptFile}"
        sed -i "s/<sonarqube-token>/$sonarToken/g" "${localDirectory}/${scriptFilePath}/${scriptFile}"
    fi
fi

# Move into the project's directory and pushing the template into the Azure DevOps repository.
echo -e "${green}Commiting and pushing into Git remote..."
echo -e ${white}
cd ${localDirectory}
git add .pipelines -f
git commit -m "Adding the source YAML"
git push -u origin ${sourceBranch}

# Create Azure pipeline
echo -e "${green}Creating the pipeline from the YAML template..."
echo -e ${white}
az pipelines create --name $pipelineName --yml-path "${pipelinePath}/${yamlFile}"

# Check if -a flag is activated
if ! test -z "$artifactPath"
then
    # Create variables in Azure pipeline
    echo -e "${green}Creating the variable to store test cases logs..."
    echo -e ${white}
    az pipelines variable create --name "artifactPath" --pipeline-name $pipelineName --value ${artifactPath}
fi

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
